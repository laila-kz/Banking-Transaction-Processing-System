USE bank_sys_final;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS legacy_transactions;
DROP TABLE IF EXISTS legacy_cards;
DROP TABLE IF EXISTS legacy_merchants;
DROP TABLE IF EXISTS legacy_mcc;
DROP TABLE IF EXISTS legacy_customers;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE legacy_customers (
    legacy_customer_id INT NOT NULL,
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
    num_credit_cards INT NULL,
    PRIMARY KEY (legacy_customer_id)
) ENGINE=InnoDB;

CREATE TABLE legacy_cards (
    legacy_card_id INT NOT NULL,
    legacy_customer_id INT NULL,
    card_brand VARCHAR(20) NULL,
    card_type VARCHAR(30) NULL,
    card_token CHAR(64) NULL,
    card_last_four CHAR(4) NULL,
    expires CHAR(7) NULL,
    has_chip ENUM('YES', 'NO') NULL,
    num_cards_issued INT NULL,
    credit_limit DECIMAL(18,2) NULL,
    acct_open_date CHAR(7) NULL,
    year_pin_last_changed INT NULL,
    card_on_dark_web ENUM('YES', 'NO') NULL,
    PRIMARY KEY (legacy_card_id),
    KEY idx_legacy_cards_customer_id (legacy_customer_id),
    CONSTRAINT fk_legacy_cards_customer
        FOREIGN KEY (legacy_customer_id) REFERENCES legacy_customers(legacy_customer_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE legacy_mcc (
    legacy_mcc_code VARCHAR(10) NOT NULL,
    legacy_mcc_description VARCHAR(100) NOT NULL,
    PRIMARY KEY (legacy_mcc_code)
) ENGINE=InnoDB;

CREATE TABLE legacy_merchants (
    merchant_id BIGINT NOT NULL,
    flag TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (merchant_id)
) ENGINE=InnoDB;

CREATE TABLE legacy_transactions (
    legacy_transaction_id BIGINT NOT NULL AUTO_INCREMENT,
    external_transaction_id BIGINT NULL,
    transaction_uuid CHAR(36) NOT NULL,
    reference_number VARCHAR(64) NOT NULL,
    transaction_date DATETIME NOT NULL,
    legacy_customer_id INT NULL,
    legacy_card_id INT NULL,
    merchant_id BIGINT NULL,
    amount DECIMAL(18,2) NULL,
    use_chip VARCHAR(30) NULL,
    errors TEXT NULL,
    source_system ENUM('LEGACY_IMPORT') NOT NULL DEFAULT 'LEGACY_IMPORT',
    status ENUM('POSTED') NOT NULL DEFAULT 'POSTED',
    PRIMARY KEY (legacy_transaction_id),
    UNIQUE KEY uk_legacy_transactions_uuid (transaction_uuid),
    UNIQUE KEY uk_legacy_transactions_reference (reference_number),
    KEY idx_legacy_transactions_customer_id (legacy_customer_id),
    KEY idx_legacy_transactions_card_id (legacy_card_id),
    KEY idx_legacy_transactions_merchant_id (merchant_id),
    KEY idx_legacy_transactions_date (transaction_date),
    CONSTRAINT fk_legacy_transactions_customer
        FOREIGN KEY (legacy_customer_id) REFERENCES legacy_customers(legacy_customer_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_legacy_transactions_card
        FOREIGN KEY (legacy_card_id) REFERENCES legacy_cards(legacy_card_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_legacy_transactions_merchant
        FOREIGN KEY (merchant_id) REFERENCES legacy_merchants(merchant_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;




