USE bank_sys_final;

-- Seed a deterministic test customer.
INSERT INTO customers (
    customer_id, full_name, email, current_age, retirement_age, birth_year, birth_month,
    gender, address, latitude, longitude, per_capita_income, yearly_income, total_debt,
    credit_score, num_credit_cards, account_status
)
VALUES (
    900001, 'Smoke Test Customer', 'smoke.test@example.com', 35, 65, 1991, 6,
    'Other', 'Test Address', 0.00000000, 0.00000000, 50000.00, 85000.00, 0.00,
    720, 0, 'ACTIVE'
)
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

-- Create two accounts with opening balances.
CALL sp_create_account(900001, 'CHECKING', 'USD', 1000.00, 'smoke-test');
CALL sp_create_account(900001, 'SAVINGS', 'USD', 500.00, 'smoke-test');

-- Capture the accounts for the rest of the test.
SET @checking_account_id = (
    SELECT account_id FROM accounts
    WHERE customer_id = 900001 AND account_type = 'CHECKING'
    LIMIT 1
);
SET @savings_account_id = (
    SELECT account_id FROM accounts
    WHERE customer_id = 900001 AND account_type = 'SAVINGS'
    LIMIT 1
);

-- Deposit scenario.
CALL sp_deposit(@checking_account_id, 250.00, 'smoke-deposit-001', 'smoke-test');

-- Withdrawal scenario.
CALL sp_withdraw(@checking_account_id, 125.00, 'smoke-withdraw-001', 'smoke-test');

-- Transfer scenario.
CALL sp_transfer_funds(@checking_account_id, @savings_account_id, 200.00, 'smoke-transfer-001', 'smoke-test');

-- Verify history and balances.
CALL sp_get_account_summary(@checking_account_id);
CALL sp_get_account_summary(@savings_account_id);
CALL sp_get_transaction_history(@checking_account_id, NULL, NULL, 50);

DROP PROCEDURE IF EXISTS sp_smoke_expect_failure;
DELIMITER $$

CREATE PROCEDURE sp_smoke_expect_failure(
    IN p_operation VARCHAR(20)
)
BEGIN
    DECLARE v_failed TINYINT(1) DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_failed = 1;
    END;

    IF p_operation = 'WITHDRAWAL' THEN
        CALL sp_withdraw(@checking_account_id, 9999999.00, 'smoke-rollback-001', 'smoke-test');
    ELSEIF p_operation = 'TRANSFER' THEN
        CALL sp_transfer_funds(@checking_account_id, @checking_account_id, 1.00, 'smoke-rollback-002', 'smoke-test');
    END IF;

    SELECT p_operation AS operation, v_failed AS failed, 'rollback path exercised' AS note;
END$$

DELIMITER ;

CALL sp_smoke_expect_failure('WITHDRAWAL');
CALL sp_smoke_expect_failure('TRANSFER');

DROP PROCEDURE sp_smoke_expect_failure;

-- Final state check.
CALL sp_get_account_summary(@checking_account_id);
CALL sp_get_account_summary(@savings_account_id);