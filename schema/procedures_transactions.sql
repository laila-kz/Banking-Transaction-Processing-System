USE bank_sys_final;

DELIMITER $$

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

DELIMITER ;
