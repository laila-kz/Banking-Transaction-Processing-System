USE bank_sys_final;

ALTER TABLE customers
    ADD CONSTRAINT chk_customers_current_age CHECK (current_age IS NULL OR current_age BETWEEN 0 AND 120),
    ADD CONSTRAINT chk_customers_retirement_age CHECK (
        retirement_age IS NULL OR current_age IS NULL OR retirement_age >= current_age
    ),
    ADD CONSTRAINT chk_customers_birth_year CHECK (birth_year IS NULL OR birth_year BETWEEN 1900 AND 2100),
    ADD CONSTRAINT chk_customers_birth_month CHECK (birth_month IS NULL OR birth_month BETWEEN 1 AND 12),
    ADD CONSTRAINT chk_customers_income CHECK (
        (per_capita_income IS NULL OR per_capita_income >= 0) AND
        (yearly_income IS NULL OR yearly_income >= 0) AND
        (total_debt IS NULL OR total_debt >= 0)
    ),
    ADD CONSTRAINT chk_customers_credit_score CHECK (credit_score IS NULL OR credit_score BETWEEN 300 AND 850),
    ADD CONSTRAINT chk_customers_num_cards CHECK (num_credit_cards >= 0);

ALTER TABLE accounts
    ADD CONSTRAINT chk_accounts_balance CHECK (balance >= 0),
    ADD CONSTRAINT chk_accounts_available_balance CHECK (available_balance >= 0),
    ADD CONSTRAINT chk_accounts_available_le_balance CHECK (available_balance <= balance);

ALTER TABLE cards
    ADD CONSTRAINT chk_cards_last_four CHECK (card_last_four REGEXP '^[0-9]{4}$'),
    ADD CONSTRAINT chk_cards_token CHECK (card_token REGEXP '^[0-9A-Fa-f]{64}$'),
    ADD CONSTRAINT chk_cards_expiry CHECK (expires REGEXP '^[0-9]{2}/[0-9]{4}$'),
    ADD CONSTRAINT chk_cards_credit_limit CHECK (credit_limit >= 0),
    ADD CONSTRAINT chk_cards_pin_year CHECK (year_pin_last_changed IS NULL OR year_pin_last_changed BETWEEN 1900 AND 2100);

ALTER TABLE merchants
    ADD CONSTRAINT chk_merchants_flag CHECK (flag IN (0, 1));

ALTER TABLE transactions
    ADD CONSTRAINT chk_transactions_amount CHECK (amount > 0),
    ADD CONSTRAINT chk_transactions_currency CHECK (currency REGEXP '^[A-Z]{3}$'),
    ADD CONSTRAINT chk_transactions_reference CHECK (reference_number <> ''),
    ADD CONSTRAINT chk_transactions_transfer_accounts CHECK (
        source_account_id IS NULL OR destination_account_id IS NULL OR source_account_id <> destination_account_id
    ),
    ADD CONSTRAINT chk_transactions_use_chip CHECK (
        use_chip IS NULL OR use_chip IN ('Chip', 'Swipe', 'Contactless', 'Online', 'Tap to Pay', 'ATM', 'Mobile')
    );

ALTER TABLE idempotency_requests
    ADD CONSTRAINT chk_idempotency_hash CHECK (request_hash REGEXP '^[0-9A-Fa-f]{64}$');

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

DELIMITER ;