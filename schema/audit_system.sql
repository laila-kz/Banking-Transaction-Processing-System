USE bank_sys_final;

CREATE TABLE IF NOT EXISTS audit_log (
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

CREATE TABLE IF NOT EXISTS transaction_errors (
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
