USE bank_sys_final;

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
