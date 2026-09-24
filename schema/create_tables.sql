USE bank_sys_final;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS account_ledger;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS mcc;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS idempotency_requests;
SET FOREIGN_KEY_CHECKS = 1;

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
