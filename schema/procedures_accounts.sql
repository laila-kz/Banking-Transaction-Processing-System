USE bank_sys_final;

DELIMITER $$

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
