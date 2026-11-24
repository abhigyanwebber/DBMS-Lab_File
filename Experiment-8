-- ============================================================
-- EXPERIMENT 8: TRANSACTIONS, ROLLBACK, SAVEPOINT AND ISOLATION
-- Uses the Experiment 3 database.
-- IMPORTANT: The concurrency demonstrations require TWO sessions.
-- Run the setup only once.
-- ============================================================

-- 1. CREATE BANK ACCOUNTS TABLE
CREATE TABLE bank_accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(60),
    balance DECIMAL(12,2) NOT NULL
) ENGINE=InnoDB;

INSERT INTO bank_accounts VALUES
(101,'Aarav Sharma',50000.00),
(102,'Diya Verma',30000.00),
(103,'Kabir Singh',20000.00);

SELECT * FROM bank_accounts ORDER BY account_id;

-- 2. SUCCESSFUL TRANSACTION USING BEGIN AND COMMIT
BEGIN;

UPDATE bank_accounts
SET balance = balance - 5000
WHERE account_id = 101;

UPDATE bank_accounts
SET balance = balance + 5000
WHERE account_id = 102;

COMMIT;

SELECT * FROM bank_accounts ORDER BY account_id;

-- 3. ROLLBACK WHEN A FAILURE OCCURS
BEGIN;

UPDATE bank_accounts
SET balance = balance - 4000
WHERE account_id = 101;

-- This deliberately fails because account_id 101 already exists.
INSERT INTO bank_accounts
VALUES (101,'Duplicate Account',0);

-- Execute ROLLBACK after observing the duplicate-key error.
ROLLBACK;

SELECT * FROM bank_accounts
WHERE account_id = 101;

-- 4. PARTIAL ROLLBACK USING SAVEPOINT
BEGIN;

UPDATE bank_accounts
SET balance = balance - 1000
WHERE account_id = 101;

SAVEPOINT before_optional_change;

UPDATE bank_accounts
SET balance = balance + 1000
WHERE account_id = 103;

ROLLBACK TO SAVEPOINT before_optional_change;
COMMIT;

SELECT * FROM bank_accounts ORDER BY account_id;

-- 5. TRANSACTION ISOLATION LEVELS
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation;

-- ============================================================
-- 6. DIRTY READ USING TWO SESSIONS
-- SESSION A: run these statements first.
-- ============================================================
-- SESSION A:
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN;

SELECT balance
FROM bank_accounts
WHERE account_id = 101;

-- Keep Session A transaction open while Session B updates the row.
-- Re-run the SELECT above while Session B has not committed.
-- Under READ UNCOMMITTED, Session A may see Session B's uncommitted value.

-- ============================================================
-- SESSION B: run while Session A's transaction remains open.
-- ============================================================
-- SESSION B:
BEGIN;

UPDATE bank_accounts
SET balance = 39000
WHERE account_id = 101;

-- Do NOT COMMIT. Return to Session A and run its SELECT again.
-- Then, in Session B, execute:
ROLLBACK;

-- Finally, in Session A:
-- COMMIT;

-- ============================================================
-- 7. NON-REPEATABLE READ – READ COMMITTED
-- SESSION A:
-- ============================================================
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;

SELECT balance
FROM bank_accounts
WHERE account_id = 101;

-- SESSION B (execute in a second connection):
-- BEGIN;
-- UPDATE bank_accounts SET balance = 42000 WHERE account_id = 101;
-- COMMIT;

-- BACK IN SESSION A: execute the same SELECT again.
SELECT balance
FROM bank_accounts
WHERE account_id = 101;

COMMIT;

-- ============================================================
-- 8. REPEATABLE READ
-- SESSION A:
-- ============================================================
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;

SELECT balance
FROM bank_accounts
WHERE account_id = 101;

-- SESSION B (execute in a second connection):
-- BEGIN;
-- UPDATE bank_accounts SET balance = 40000 WHERE account_id = 101;
-- COMMIT;

-- BACK IN SESSION A: run the same SELECT again, then COMMIT.
SELECT balance
FROM bank_accounts
WHERE account_id = 101;

COMMIT;

-- 9. SERIALIZABLE ISOLATION
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;

SELECT *
FROM bank_accounts
WHERE account_id = 101;

COMMIT;

-- 10. SUMMARY OF TRANSACTION CONTROL
-- BEGIN / START TRANSACTION: starts a transaction.
-- COMMIT: permanently saves changes.
-- ROLLBACK: cancels all uncommitted changes.
-- SAVEPOINT: creates a marker inside the current transaction.
-- ROLLBACK TO SAVEPOINT: undoes changes after that marker.

-- END EXPERIMENT 8
