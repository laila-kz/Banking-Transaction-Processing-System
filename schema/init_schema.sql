-- ============================================================================
-- Banking System Complete Database Schema Initializer
-- Database: bank_sys_final
-- Engine: MySQL 8.0+ / InnoDB
-- ============================================================================

CREATE DATABASE IF NOT EXISTS bank_sys_final
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bank_sys_final;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS transaction_errors;
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS account_ledger;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS mcc;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS idempotency_requests;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. Core Tables
-- ----------------------------------------------------------------------------

CREATE TABLE customers (
	customer_id INT NOT NULL AUTO_INCREMENT,
	full_name VARCHAR(200) NOT NULL,
	email VARCHAR(255) NOT NULL,
	phone VARCHAR(30) NULL,
	current_age INT NULL,
	retirement_age INT NULL,
	birth_year INT NULL,
	birth_month INT NULL,
	gender VARCHAR(10) NULL,
	address VARCHAR(255) NULL,
	latitude DECIMAL(10,8) NULL,
	longitude DECIMAL(11,8) NULL,
	per_capita_income DECIMAL(14,2) NULL,
	yearly_income DECIMAL(14,2) NULL,
	total_debt DECIMAL(14,2) NULL,
	credit_score INT NULL,
	num_credit_cards INT NOT NULL DEFAULT 0,
	account_status ENUM('ACTIVE', 'FROZEN', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (customer_id),
	UNIQUE KEY uk_customers_email (email),
	KEY idx_customers_credit_score (credit_score),
	KEY idx_customers_status (account_status)
) ENGINE=InnoDB;

CREATE TABLE accounts (
	account_id BIGINT NOT NULL AUTO_INCREMENT,
	customer_id INT NOT NULL,
	account_number CHAR(20) NOT NULL,
	account_type ENUM('CHECKING', 'SAVINGS', 'MONEY_MARKET', 'LOAN') NOT NULL,
	currency CHAR(3) NOT NULL DEFAULT 'USD',
	balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
	available_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
	status ENUM('ACTIVE', 'FROZEN', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
	opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	closed_at DATETIME NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (account_id),
	UNIQUE KEY uk_accounts_number (account_number),
	UNIQUE KEY uk_customer_account_type (customer_id, account_type),
	KEY idx_accounts_customer (customer_id),
	KEY idx_accounts_status (status),
	CONSTRAINT fk_accounts_customers
		FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE cards (
	card_id INT NOT NULL AUTO_INCREMENT,
	customer_id INT NOT NULL,
	account_id BIGINT NULL,
	card_brand VARCHAR(20) NOT NULL,
	card_type VARCHAR(30) NOT NULL,
	card_token CHAR(64) NOT NULL,
	card_last_four CHAR(4) NOT NULL,
	expires CHAR(7) NOT NULL,
	has_chip ENUM('YES', 'NO') NOT NULL DEFAULT 'YES',
	num_cards_issued INT NOT NULL DEFAULT 1,
	credit_limit DECIMAL(18,2) NOT NULL DEFAULT 0.00,
	acct_open_date CHAR(7) NULL,
	year_pin_last_changed INT NULL,
	card_status ENUM('ACTIVE', 'EXPIRED', 'BLOCKED', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
	card_on_dark_web ENUM('YES', 'NO') NOT NULL DEFAULT 'NO',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (card_id),
	UNIQUE KEY uk_cards_token (card_token),
	KEY idx_cards_customer_id (customer_id),
	KEY idx_cards_account_id (account_id),
	KEY idx_cards_expires (expires),
	CONSTRAINT fk_cards_customers
		FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	CONSTRAINT fk_cards_accounts
		FOREIGN KEY (account_id) REFERENCES accounts(account_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE mcc (
	mcc_code VARCHAR(10) NOT NULL,
	mcc_description VARCHAR(100) NOT NULL,
	PRIMARY KEY (mcc_code)
) ENGINE=InnoDB;

CREATE TABLE merchants (
	merchant_id BIGINT NOT NULL,
	merchant_name VARCHAR(255) NULL,
	mcc_code VARCHAR(10) NULL,
	merchant_city VARCHAR(100) NULL,
	merchant_state VARCHAR(50) NULL,
	merchant_zip VARCHAR(20) NULL,
	flag TINYINT(1) NOT NULL DEFAULT 0,
	active_status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (merchant_id),
	KEY idx_merchants_mcc (mcc_code),
	KEY idx_merchants_location (merchant_city, merchant_state),
	KEY idx_merchants_flag (flag),
	CONSTRAINT fk_merchants_mcc
		FOREIGN KEY (mcc_code) REFERENCES mcc(mcc_code)
		ON UPDATE CASCADE
		ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE transactions (
	transaction_id BIGINT NOT NULL AUTO_INCREMENT,
	transaction_uuid CHAR(36) NOT NULL,
	reference_number VARCHAR(64) NOT NULL,
	external_transaction_id BIGINT NULL,
	source_system ENUM('BANK_CORE', 'LEGACY_IMPORT') NOT NULL DEFAULT 'BANK_CORE',
	transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'PURCHASE', 'REVERSAL', 'FEE', 'LEGACY_IMPORT') NOT NULL,
	status ENUM('PENDING', 'POSTED', 'DECLINED', 'REVERSED') NOT NULL DEFAULT 'PENDING',
	customer_id INT NOT NULL,
	source_account_id BIGINT NULL,
	destination_account_id BIGINT NULL,
	card_id INT NULL,
	merchant_id BIGINT NULL,
	amount DECIMAL(18,2) NOT NULL,
	currency CHAR(3) NOT NULL DEFAULT 'USD',
	use_chip VARCHAR(30) NULL,
	transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	posted_at DATETIME NULL,
	failure_reason VARCHAR(255) NULL,
	legacy_payload JSON NULL,
	idempotency_key VARCHAR(64) NULL,
	reversal_of_transaction_id BIGINT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (transaction_id),
	UNIQUE KEY uk_transactions_uuid (transaction_uuid),
	UNIQUE KEY uk_transactions_reference (reference_number),
	UNIQUE KEY uk_transactions_idempotency (idempotency_key),
	KEY idx_tx_customer_id (customer_id),
	KEY idx_tx_source_account (source_account_id),
	KEY idx_tx_destination_account (destination_account_id),
	KEY idx_tx_card_id (card_id),
	KEY idx_tx_merchant_id (merchant_id),
	KEY idx_tx_date (transaction_date),
	KEY idx_tx_status (status),
	CONSTRAINT fk_tx_customers
		FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	CONSTRAINT fk_tx_source_account
		FOREIGN KEY (source_account_id) REFERENCES accounts(account_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	CONSTRAINT fk_tx_destination_account
		FOREIGN KEY (destination_account_id) REFERENCES accounts(account_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	CONSTRAINT fk_tx_cards
		FOREIGN KEY (card_id) REFERENCES cards(card_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	CONSTRAINT fk_tx_merchants
		FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	CONSTRAINT fk_tx_reversal
		FOREIGN KEY (reversal_of_transaction_id) REFERENCES transactions(transaction_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE account_ledger (
	ledger_id BIGINT NOT NULL AUTO_INCREMENT,
	account_id BIGINT NOT NULL,
	transaction_id BIGINT NOT NULL,
	entry_direction ENUM('DEBIT', 'CREDIT') NOT NULL,
	amount DECIMAL(18,2) NOT NULL,
	balance_after DECIMAL(18,2) NOT NULL,
	description VARCHAR(255) NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (ledger_id),
	UNIQUE KEY uk_ledger_account_transaction_direction (account_id, transaction_id, entry_direction),
	KEY idx_ledger_account (account_id),
	KEY idx_ledger_transaction (transaction_id),
	KEY idx_ledger_created (created_at),
	CONSTRAINT fk_ledger_accounts
		FOREIGN KEY (account_id) REFERENCES accounts(account_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	CONSTRAINT fk_ledger_transactions
		FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE idempotency_requests (
	idempotency_key VARCHAR(64) NOT NULL,
	request_type ENUM('ACCOUNT_OPEN', 'DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'ACCOUNT_CLOSE') NOT NULL,
	request_hash CHAR(64) NOT NULL,
	transaction_id BIGINT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (idempotency_key),
	KEY idx_idempotency_request_type (request_type),
	CONSTRAINT fk_idempotency_transaction
		FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. Audit & Error Tables
-- ----------------------------------------------------------------------------

CREATE TABLE audit_log (
    audit_id BIGINT NOT NULL AUTO_INCREMENT,
    operation_type ENUM(
        'ACCOUNT_CREATED',
        'ACCOUNT_CLOSED',
        'DEPOSIT',
        'WITHDRAWAL',
        'TRANSFER',
        'PURCHASE',
        'SECURITY',
        'DATA_MOD',
        'SYSTEM'
    ) NOT NULL,
    status ENUM('SUCCESS', 'FAILED', 'FLAGGED', 'PENDING') NOT NULL,
    table_affected VARCHAR(64) NULL,
    customer_id INT NULL,
    account_id BIGINT NULL,
    transaction_id BIGINT NULL,
    card_id INT NULL,
    details TEXT NULL,
    error_code VARCHAR(32) NULL,
    error_message TEXT NULL,
    actor VARCHAR(100) NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (audit_id),
    KEY idx_audit_operation (operation_type),
    KEY idx_audit_status (status),
    KEY idx_audit_customer (customer_id),
    KEY idx_audit_account (account_id),
    KEY idx_audit_transaction (transaction_id),
    CONSTRAINT fk_audit_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_audit_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_audit_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_audit_card
        FOREIGN KEY (card_id) REFERENCES cards(card_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE transaction_errors (
    error_id BIGINT NOT NULL AUTO_INCREMENT,
    transaction_id BIGINT NULL,
    account_id BIGINT NULL,
    card_id INT NULL,
    error_code VARCHAR(32) NOT NULL,
    error_message TEXT NOT NULL,
    operation_name VARCHAR(64) NOT NULL,
    retryable TINYINT(1) NOT NULL DEFAULT 0,
    log_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (error_id),
    KEY idx_transaction_errors_transaction (transaction_id),
    KEY idx_transaction_errors_account (account_id),
    KEY idx_transaction_errors_card (card_id),
    KEY idx_transaction_errors_time (log_time),
    CONSTRAINT fk_transaction_errors_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_transaction_errors_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_transaction_errors_card
        FOREIGN KEY (card_id) REFERENCES cards(card_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. Business Triggers & Constraints
-- ----------------------------------------------------------------------------

DELIMITER $$

CREATE TRIGGER trg_accounts_prevent_negative_balance
BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF NEW.balance < 0 OR NEW.available_balance < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account balance cannot be negative';
    END IF;

    IF NEW.available_balance > NEW.balance THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Available balance cannot exceed balance';
    END IF;
END$$

CREATE TRIGGER trg_transactions_prevent_invalid_transfer
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'TRANSFER'
       AND NEW.source_account_id IS NOT NULL
       AND NEW.destination_account_id IS NOT NULL
       AND NEW.source_account_id = NEW.destination_account_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source and destination accounts must differ';
    END IF;
END$$

CREATE TRIGGER trg_transactions_prevent_delete
BEFORE DELETE ON transactions
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transactions are immutable and cannot be deleted';
END$$

CREATE TRIGGER trg_transactions_guard_updates
BEFORE UPDATE ON transactions
FOR EACH ROW
BEGIN
    IF OLD.amount <> NEW.amount
       OR OLD.customer_id <> NEW.customer_id
       OR IFNULL(OLD.source_account_id, 0) <> IFNULL(NEW.source_account_id, 0)
       OR IFNULL(OLD.destination_account_id, 0) <> IFNULL(NEW.destination_account_id, 0)
       OR IFNULL(OLD.card_id, 0) <> IFNULL(NEW.card_id, 0)
       OR IFNULL(OLD.merchant_id, 0) <> IFNULL(NEW.merchant_id, 0)
       OR OLD.transaction_type <> NEW.transaction_type THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Core transaction fields are immutable';
    END IF;
END$$

CREATE TRIGGER trg_ledger_balance_guard
BEFORE INSERT ON account_ledger
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ledger amount must be positive';
    END IF;

    IF NEW.balance_after < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ledger balance cannot be negative';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- 4. Stored Procedures
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_create_account$$
CREATE PROCEDURE sp_create_account(
	IN p_customer_id INT,
	IN p_account_type VARCHAR(20),
	IN p_currency CHAR(3),
	IN p_opening_balance DECIMAL(18,2),
	IN p_actor VARCHAR(100)
)
proc: BEGIN
	DECLARE v_customer_status VARCHAR(20);
	DECLARE v_account_id BIGINT;
	DECLARE v_account_number CHAR(20);
	DECLARE v_transaction_id BIGINT;
	DECLARE v_reference_number VARCHAR(64);
	DECLARE v_transaction_uuid CHAR(36);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		INSERT INTO audit_log (
			operation_type, status, table_affected, customer_id, actor, details, error_message
		)
		VALUES (
			'ACCOUNT_CREATED', 'FAILED', 'accounts', p_customer_id, p_actor,
			CONCAT('Account creation failed for customer ', p_customer_id), 'Account creation rolled back'
		);
		RESIGNAL;
	END;

	IF p_opening_balance IS NULL THEN
		SET p_opening_balance = 0.00;
	END IF;

	IF p_opening_balance < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opening balance cannot be negative';
	END IF;

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	START TRANSACTION;

	SELECT account_status
	INTO v_customer_status
	FROM customers
	WHERE customer_id = p_customer_id
	FOR UPDATE;

	IF v_customer_status IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found';
	END IF;

	IF v_customer_status <> 'ACTIVE' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer account is not active';
	END IF;

	SET v_account_number = CONCAT('AC', LPAD(p_customer_id, 8, '0'), RIGHT(REPLACE(UUID(), '-', ''), 10));

	INSERT INTO accounts (
		customer_id, account_number, account_type, currency, balance, available_balance, status, opened_at
	)
	VALUES (
		p_customer_id, v_account_number, UPPER(p_account_type), COALESCE(p_currency, 'USD'), p_opening_balance, p_opening_balance, 'ACTIVE', NOW()
	);

	SET v_account_id = LAST_INSERT_ID();

	IF p_opening_balance > 0 THEN
		SET v_transaction_uuid = UUID();
		SET v_reference_number = CONCAT('OPN-', REPLACE(v_transaction_uuid, '-', ''));

		INSERT INTO transactions (
			transaction_uuid,
			reference_number,
			source_system,
			transaction_type,
			status,
			customer_id,
			source_account_id,
			destination_account_id,
			amount,
			currency,
			transaction_date,
			posted_at
		)
		VALUES (
			v_transaction_uuid,
			v_reference_number,
			'BANK_CORE',
			'DEPOSIT',
			'POSTED',
			p_customer_id,
			v_account_id,
			NULL,
			p_opening_balance,
			COALESCE(p_currency, 'USD'),
			NOW(),
			NOW()
		);

		SET v_transaction_id = LAST_INSERT_ID();

		INSERT INTO account_ledger (
			account_id, transaction_id, entry_direction, amount, balance_after, description
		)
		VALUES (
			v_account_id, v_transaction_id, 'CREDIT', p_opening_balance, p_opening_balance, 'Opening balance'
		);
	END IF;

	INSERT INTO audit_log (
		operation_type, status, table_affected, customer_id, account_id, transaction_id, actor, details
	)
	VALUES (
		'ACCOUNT_CREATED', 'SUCCESS', 'accounts', p_customer_id, v_account_id, v_transaction_id, p_actor,
		CONCAT('Created account ', v_account_number, ' for customer ', p_customer_id)
	);

	COMMIT;

	SELECT v_account_id AS account_id, v_account_number AS account_number;
END$$

DROP PROCEDURE IF EXISTS sp_close_account$$
CREATE PROCEDURE sp_close_account(
	IN p_account_id BIGINT,
	IN p_actor VARCHAR(100)
)
proc: BEGIN
	DECLARE v_balance DECIMAL(18,2);
	DECLARE v_status VARCHAR(20);
	DECLARE v_customer_id INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		INSERT INTO audit_log (
			operation_type, status, table_affected, account_id, actor, details, error_message
		)
		VALUES (
			'ACCOUNT_CLOSED', 'FAILED', 'accounts', p_account_id, p_actor,
			CONCAT('Account close failed for account ', p_account_id), 'Account close rolled back'
		);
		RESIGNAL;
	END;

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	START TRANSACTION;

	SELECT customer_id, balance, status
	INTO v_customer_id, v_balance, v_status
	FROM accounts
	WHERE account_id = p_account_id
	FOR UPDATE;

	IF v_customer_id IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found';
	END IF;

	IF v_status <> 'ACTIVE' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only active accounts can be closed';
	END IF;

	IF v_balance <> 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account must have zero balance before closure';
	END IF;

	UPDATE accounts
	SET status = 'CLOSED',
		closed_at = NOW()
	WHERE account_id = p_account_id;

	INSERT INTO audit_log (
		operation_type, status, table_affected, customer_id, account_id, actor, details
	)
	VALUES (
		'ACCOUNT_CLOSED', 'SUCCESS', 'accounts', v_customer_id, p_account_id, p_actor,
		CONCAT('Closed account ', p_account_id)
	);

	COMMIT;

	SELECT p_account_id AS account_id, 'CLOSED' AS status;
END$$

DROP PROCEDURE IF EXISTS sp_deposit$$
CREATE PROCEDURE sp_deposit(
    IN p_account_id BIGINT,
    IN p_amount DECIMAL(18,2),
    IN p_idempotency_key VARCHAR(64),
    IN p_actor VARCHAR(100)
)
proc: BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_balance DECIMAL(18,2);
    DECLARE v_account_status VARCHAR(20);
    DECLARE v_transaction_id BIGINT;
    DECLARE v_existing_transaction_id BIGINT;
    DECLARE v_reference_number VARCHAR(64);
    DECLARE v_transaction_uuid CHAR(36);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO audit_log (
            operation_type, status, table_affected, account_id, transaction_id, actor, details, error_message
        )
        VALUES (
            'DEPOSIT', 'FAILED', 'accounts', p_account_id, v_transaction_id, p_actor,
            CONCAT('Deposit failed for account ', p_account_id), 'Deposit rolled back'
        );
        RESIGNAL;
    END;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposit amount must be greater than zero';
    END IF;

    IF p_idempotency_key IS NOT NULL THEN
        SELECT transaction_id INTO v_existing_transaction_id
        FROM transactions
        WHERE idempotency_key = p_idempotency_key
        LIMIT 1;
        IF v_existing_transaction_id IS NOT NULL THEN
            SELECT v_existing_transaction_id AS transaction_id, 'DUPLICATE_REQUEST' AS status;
            LEAVE proc;
        END IF;
    END IF;

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION;

    SELECT customer_id, balance, status
    INTO v_customer_id, v_balance, v_account_status
    FROM accounts
    WHERE account_id = p_account_id
    FOR UPDATE;

    IF v_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found';
    END IF;

    IF v_account_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is not active';
    END IF;

    SET v_transaction_uuid = UUID();
    SET v_reference_number = CONCAT('DEP-', REPLACE(v_transaction_uuid, '-', ''));

    UPDATE accounts
    SET balance = balance + p_amount,
        available_balance = available_balance + p_amount
    WHERE account_id = p_account_id;

    INSERT INTO transactions (
        transaction_uuid,
        reference_number,
        source_system,
        transaction_type,
        status,
        customer_id,
        source_account_id,
        destination_account_id,
        amount,
        currency,
        transaction_date,
        posted_at,
        idempotency_key
    )
    VALUES (
        v_transaction_uuid,
        v_reference_number,
        'BANK_CORE',
        'DEPOSIT',
        'POSTED',
        v_customer_id,
        p_account_id,
        NULL,
        p_amount,
        'USD',
        NOW(),
        NOW(),
        p_idempotency_key
    );

    SET v_transaction_id = LAST_INSERT_ID();

    INSERT INTO account_ledger (
        account_id, transaction_id, entry_direction, amount, balance_after, description
    )
    VALUES (
        p_account_id, v_transaction_id, 'CREDIT', p_amount, v_balance + p_amount, 'Deposit'
    );

    IF p_idempotency_key IS NOT NULL THEN
        INSERT INTO idempotency_requests (idempotency_key, request_type, request_hash, transaction_id)
        VALUES (p_idempotency_key, 'DEPOSIT', SHA2(CONCAT(p_account_id, ':', p_amount), 256), v_transaction_id)
        ON DUPLICATE KEY UPDATE transaction_id = VALUES(transaction_id), updated_at = CURRENT_TIMESTAMP;
    END IF;

    INSERT INTO audit_log (
        operation_type, status, table_affected, customer_id, account_id, transaction_id, actor, details
    )
    VALUES (
        'DEPOSIT', 'SUCCESS', 'transactions', v_customer_id, p_account_id, v_transaction_id, p_actor,
        CONCAT('Deposited ', p_amount, ' into account ', p_account_id)
    );

    COMMIT;

    SELECT v_transaction_id AS transaction_id, v_reference_number AS reference_number, 'POSTED' AS status;
END$$

DROP PROCEDURE IF EXISTS sp_withdraw$$
CREATE PROCEDURE sp_withdraw(
    IN p_account_id BIGINT,
    IN p_amount DECIMAL(18,2),
    IN p_idempotency_key VARCHAR(64),
    IN p_actor VARCHAR(100)
)
proc: BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_balance DECIMAL(18,2);
    DECLARE v_account_status VARCHAR(20);
    DECLARE v_transaction_id BIGINT;
    DECLARE v_existing_transaction_id BIGINT;
    DECLARE v_reference_number VARCHAR(64);
    DECLARE v_transaction_uuid CHAR(36);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO audit_log (
            operation_type, status, table_affected, account_id, transaction_id, actor, details, error_message
        )
        VALUES (
            'WITHDRAWAL', 'FAILED', 'accounts', p_account_id, v_transaction_id, p_actor,
            CONCAT('Withdrawal failed for account ', p_account_id), 'Withdrawal rolled back'
        );
        RESIGNAL;
    END;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Withdrawal amount must be greater than zero';
    END IF;

    IF p_idempotency_key IS NOT NULL THEN
        SELECT transaction_id INTO v_existing_transaction_id
        FROM transactions
        WHERE idempotency_key = p_idempotency_key
        LIMIT 1;
        IF v_existing_transaction_id IS NOT NULL THEN
            SELECT v_existing_transaction_id AS transaction_id, 'DUPLICATE_REQUEST' AS status;
            LEAVE proc;
        END IF;
    END IF;

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION;

    SELECT customer_id, balance, status
    INTO v_customer_id, v_balance, v_account_status
    FROM accounts
    WHERE account_id = p_account_id
    FOR UPDATE;

    IF v_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found';
    END IF;

    IF v_account_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is not active';
    END IF;

    IF v_balance < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;

    SET v_transaction_uuid = UUID();
    SET v_reference_number = CONCAT('WTH-', REPLACE(v_transaction_uuid, '-', ''));

    UPDATE accounts
    SET balance = balance - p_amount,
        available_balance = available_balance - p_amount
    WHERE account_id = p_account_id;

    INSERT INTO transactions (
        transaction_uuid,
        reference_number,
        source_system,
        transaction_type,
        status,
        customer_id,
        source_account_id,
        destination_account_id,
        amount,
        currency,
        transaction_date,
        posted_at,
        idempotency_key
    )
    VALUES (
        v_transaction_uuid,
        v_reference_number,
        'BANK_CORE',
        'WITHDRAWAL',
        'POSTED',
        v_customer_id,
        p_account_id,
        NULL,
        p_amount,
        'USD',
        NOW(),
        NOW(),
        p_idempotency_key
    );

    SET v_transaction_id = LAST_INSERT_ID();

    INSERT INTO account_ledger (
        account_id, transaction_id, entry_direction, amount, balance_after, description
    )
    VALUES (
        p_account_id, v_transaction_id, 'DEBIT', p_amount, v_balance - p_amount, 'Withdrawal'
    );

    IF p_idempotency_key IS NOT NULL THEN
        INSERT INTO idempotency_requests (idempotency_key, request_type, request_hash, transaction_id)
        VALUES (p_idempotency_key, 'WITHDRAWAL', SHA2(CONCAT(p_account_id, ':', p_amount), 256), v_transaction_id)
        ON DUPLICATE KEY UPDATE transaction_id = VALUES(transaction_id), updated_at = CURRENT_TIMESTAMP;
    END IF;

    INSERT INTO audit_log (
        operation_type, status, table_affected, customer_id, account_id, transaction_id, actor, details
    )
    VALUES (
        'WITHDRAWAL', 'SUCCESS', 'transactions', v_customer_id, p_account_id, v_transaction_id, p_actor,
        CONCAT('Withdrew ', p_amount, ' from account ', p_account_id)
    );

    COMMIT;

    SELECT v_transaction_id AS transaction_id, v_reference_number AS reference_number, 'POSTED' AS status;
END$$

DROP PROCEDURE IF EXISTS sp_transfer_funds$$
CREATE PROCEDURE sp_transfer_funds(
    IN p_source_account_id BIGINT,
    IN p_destination_account_id BIGINT,
    IN p_amount DECIMAL(18,2),
    IN p_idempotency_key VARCHAR(64),
    IN p_actor VARCHAR(100)
)
proc: BEGIN
    DECLARE v_source_customer_id INT;
    DECLARE v_destination_customer_id INT;
    DECLARE v_source_balance DECIMAL(18,2);
    DECLARE v_destination_balance DECIMAL(18,2);
    DECLARE v_source_status VARCHAR(20);
    DECLARE v_destination_status VARCHAR(20);
    DECLARE v_transaction_id BIGINT;
    DECLARE v_existing_transaction_id BIGINT;
    DECLARE v_reference_number VARCHAR(64);
    DECLARE v_transaction_uuid CHAR(36);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO audit_log (
            operation_type, status, table_affected, account_id, transaction_id, actor, details, error_message
        )
        VALUES (
            'TRANSFER', 'FAILED', 'accounts', p_source_account_id, v_transaction_id, p_actor,
            CONCAT('Transfer failed from account ', p_source_account_id, ' to ', p_destination_account_id),
            'Transfer rolled back'
        );
        RESIGNAL;
    END;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer amount must be greater than zero';
    END IF;

    IF p_source_account_id = p_destination_account_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source and destination accounts must differ';
    END IF;

    IF p_idempotency_key IS NOT NULL THEN
        SELECT transaction_id INTO v_existing_transaction_id
        FROM transactions
        WHERE idempotency_key = p_idempotency_key
        LIMIT 1;
        IF v_existing_transaction_id IS NOT NULL THEN
            SELECT v_existing_transaction_id AS transaction_id, 'DUPLICATE_REQUEST' AS status;
            LEAVE proc;
        END IF;
    END IF;

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION;

    -- Deadlock prevention: Lock accounts in ascending account_id order
    IF p_source_account_id < p_destination_account_id THEN
        SELECT customer_id, balance, status
        INTO v_source_customer_id, v_source_balance, v_source_status
        FROM accounts
        WHERE account_id = p_source_account_id
        FOR UPDATE;

        IF v_source_customer_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source account not found';
        END IF;

        SELECT customer_id, balance, status
        INTO v_destination_customer_id, v_destination_balance, v_destination_status
        FROM accounts
        WHERE account_id = p_destination_account_id
        FOR UPDATE;

        IF v_destination_customer_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination account not found';
        END IF;
    ELSE
        SELECT customer_id, balance, status
        INTO v_destination_customer_id, v_destination_balance, v_destination_status
        FROM accounts
        WHERE account_id = p_destination_account_id
        FOR UPDATE;

        IF v_destination_customer_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination account not found';
        END IF;

        SELECT customer_id, balance, status
        INTO v_source_customer_id, v_source_balance, v_source_status
        FROM accounts
        WHERE account_id = p_source_account_id
        FOR UPDATE;

        IF v_source_customer_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source account not found';
        END IF;
    END IF;

    IF v_source_status <> 'ACTIVE' OR v_destination_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Both accounts must be active';
    END IF;

    IF v_source_balance < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds in source account';
    END IF;

    SET v_transaction_uuid = UUID();
    SET v_reference_number = CONCAT('TRF-', REPLACE(v_transaction_uuid, '-', ''));

    UPDATE accounts
    SET balance = balance - p_amount,
        available_balance = available_balance - p_amount
    WHERE account_id = p_source_account_id;

    UPDATE accounts
    SET balance = balance + p_amount,
        available_balance = available_balance + p_amount
    WHERE account_id = p_destination_account_id;

    INSERT INTO transactions (
        transaction_uuid,
        reference_number,
        source_system,
        transaction_type,
        status,
        customer_id,
        source_account_id,
        destination_account_id,
        amount,
        currency,
        transaction_date,
        posted_at,
        idempotency_key
    )
    VALUES (
        v_transaction_uuid,
        v_reference_number,
        'BANK_CORE',
        'TRANSFER',
        'POSTED',
        v_source_customer_id,
        p_source_account_id,
        p_destination_account_id,
        p_amount,
        'USD',
        NOW(),
        NOW(),
        p_idempotency_key
    );

    SET v_transaction_id = LAST_INSERT_ID();

    INSERT INTO account_ledger (
        account_id, transaction_id, entry_direction, amount, balance_after, description
    )
    VALUES
        (p_source_account_id, v_transaction_id, 'DEBIT', p_amount, v_source_balance - p_amount, 'Transfer out'),
        (p_destination_account_id, v_transaction_id, 'CREDIT', p_amount, v_destination_balance + p_amount, 'Transfer in');

    IF p_idempotency_key IS NOT NULL THEN
        INSERT INTO idempotency_requests (idempotency_key, request_type, request_hash, transaction_id)
        VALUES (p_idempotency_key, 'TRANSFER', SHA2(CONCAT(p_source_account_id, ':', p_destination_account_id, ':', p_amount), 256), v_transaction_id)
        ON DUPLICATE KEY UPDATE transaction_id = VALUES(transaction_id), updated_at = CURRENT_TIMESTAMP;
    END IF;

    INSERT INTO audit_log (
        operation_type, status, table_affected, customer_id, account_id, transaction_id, actor, details
    )
    VALUES (
        'TRANSFER', 'SUCCESS', 'transactions', v_source_customer_id, p_source_account_id, v_transaction_id, p_actor,
        CONCAT('Transferred ', p_amount, ' from account ', p_source_account_id, ' to ', p_destination_account_id)
    );

    COMMIT;

    SELECT v_transaction_id AS transaction_id, v_reference_number AS reference_number, 'POSTED' AS status;
END$$

DROP PROCEDURE IF EXISTS sp_get_transaction_history$$
CREATE PROCEDURE sp_get_transaction_history(
	IN p_account_id BIGINT,
	IN p_from_date DATETIME,
	IN p_to_date DATETIME,
	IN p_limit INT
)
BEGIN
	SELECT
		t.transaction_id,
		t.transaction_uuid,
		t.reference_number,
		t.transaction_type,
		t.status,
		t.amount,
		t.currency,
		t.transaction_date,
		t.posted_at,
		t.source_account_id,
		t.destination_account_id,
		t.card_id,
		t.merchant_id,
		l.entry_direction,
		l.balance_after,
		l.description
	FROM transactions t
	LEFT JOIN account_ledger l ON l.transaction_id = t.transaction_id AND l.account_id = p_account_id
	WHERE (
		t.source_account_id = p_account_id OR
		t.destination_account_id = p_account_id OR
		l.account_id = p_account_id
	)
	AND (p_from_date IS NULL OR t.transaction_date >= p_from_date)
	AND (p_to_date IS NULL OR t.transaction_date <= p_to_date)
	ORDER BY t.transaction_date DESC, t.transaction_id DESC
	LIMIT COALESCE(p_limit, 100);
END$$

DROP PROCEDURE IF EXISTS sp_get_account_summary$$
CREATE PROCEDURE sp_get_account_summary(
	IN p_account_id BIGINT
)
BEGIN
	SELECT
		a.account_id,
		a.account_number,
		a.account_type,
		a.currency,
		a.balance,
		a.available_balance,
		a.status,
		c.customer_id,
		c.full_name,
		c.email
	FROM accounts a
	JOIN customers c ON c.customer_id = a.customer_id
	WHERE a.account_id = p_account_id;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- 5. Analytics Views
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_account_balances AS
SELECT
    a.account_id,
    a.account_number,
    a.account_type,
    a.currency,
    a.balance,
    a.available_balance,
    a.status,
    a.opened_at,
    a.closed_at,
    c.customer_id,
    c.full_name,
    c.email
FROM accounts a
JOIN customers c ON c.customer_id = a.customer_id;

CREATE OR REPLACE VIEW v_transaction_history AS
SELECT
    t.transaction_id,
    t.transaction_uuid,
    t.reference_number,
    t.transaction_type,
    t.status,
    t.amount,
    t.currency,
    t.transaction_date,
    t.posted_at,
    t.source_system,
    t.customer_id,
    c.full_name AS customer_name,
    t.source_account_id,
    asrc.account_number AS source_account_number,
    t.destination_account_id,
    adst.account_number AS destination_account_number,
    t.card_id,
    t.merchant_id,
    m.merchant_name,
    t.use_chip,
    t.failure_reason
FROM transactions t
JOIN customers c ON c.customer_id = t.customer_id
LEFT JOIN accounts asrc ON asrc.account_id = t.source_account_id
LEFT JOIN accounts adst ON adst.account_id = t.destination_account_id
LEFT JOIN merchants m ON m.merchant_id = t.merchant_id;

CREATE OR REPLACE VIEW v_daily_transaction_volume AS
SELECT
    DATE(t.transaction_date) AS transaction_day,
    t.transaction_type,
    COUNT(*) AS transaction_count,
    SUM(t.amount) AS total_amount,
    AVG(t.amount) AS average_amount
FROM transactions t
WHERE t.status = 'POSTED'
GROUP BY DATE(t.transaction_date), t.transaction_type;

CREATE OR REPLACE VIEW v_high_value_transactions AS
SELECT
    t.transaction_id,
    t.reference_number,
    t.transaction_type,
    t.amount,
    t.currency,
    t.transaction_date,
    t.customer_id,
    c.full_name,
    t.source_account_id,
    t.destination_account_id,
    t.merchant_id
FROM transactions t
JOIN customers c ON c.customer_id = t.customer_id
WHERE t.amount >= 10000
  AND t.status = 'POSTED';
