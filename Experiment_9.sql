-- ============================================================
-- EXPERIMENT 9: RAILWAY BOOKING INDEXING AND QUERY BENCHMARK
-- Uses the Experiment 3 database.
-- Run table creation and data generation only once.
-- MySQL 8.0.18+ is required for EXPLAIN ANALYZE.
-- ============================================================

-- 1. CREATE RAILWAY BOOKING TABLE
CREATE TABLE railway_bookings (
    booking_id INT PRIMARY KEY,
    pnr CHAR(10) NOT NULL,
    passenger_name VARCHAR(60),
    train_no INT NOT NULL,
    journey_date DATE NOT NULL,
    source_station CHAR(3),
    destination_station CHAR(3),
    seat_no VARCHAR(8),
    booking_status VARCHAR(12),
    fare DECIMAL(8,2)
) ENGINE=InnoDB;

-- 2. GENERATE AT LEAST 5,000 RECORDS
SET SESSION cte_max_recursion_depth = 6000;

INSERT INTO railway_bookings
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 5000
)
SELECT
    n,
    LPAD(n,10,'0'),
    CONCAT('Passenger ',n),
    12001 + MOD(n,20),
    DATE_ADD('2026-01-01', INTERVAL MOD(n,90) DAY),
    ELT(MOD(n,5)+1,'LKO','NDL','CNB','BSB','ALD'),
    ELT(MOD(n+2,5)+1,'LKO','NDL','CNB','BSB','ALD'),
    CONCAT('S',MOD(n,12)+1,'-',MOD(n,72)+1),
    ELT(MOD(n,3)+1,'CONFIRMED','WAITLIST','CANCELLED'),
    250 + MOD(n*37,1800)
FROM seq;

SELECT COUNT(*) AS total_records
FROM railway_bookings;

-- 3. BENCHMARK QUERY BEFORE INDEXING
EXPLAIN
SELECT booking_id, passenger_name, train_no, journey_date
FROM railway_bookings
WHERE train_no = 12008
  AND journey_date = '2026-01-18';

-- Optional actual execution measurement before secondary indexes:
EXPLAIN ANALYZE
SELECT booking_id, passenger_name, train_no, journey_date
FROM railway_bookings
WHERE train_no = 12008
  AND journey_date = '2026-01-18';

-- 4. CREATE A SINGLE-COLUMN INDEX
CREATE UNIQUE INDEX idx_pnr
ON railway_bookings(pnr);

EXPLAIN
SELECT booking_id, passenger_name, booking_status
FROM railway_bookings
WHERE pnr = '0000001234';

-- 5. CREATE A COMPOSITE INDEX
CREATE INDEX idx_train_date
ON railway_bookings(train_no, journey_date);

EXPLAIN
SELECT booking_id, passenger_name, seat_no
FROM railway_bookings
WHERE train_no = 12008
  AND journey_date = '2026-01-18';

-- 6. ANALYZE THE EXECUTION PLAN
EXPLAIN ANALYZE
SELECT booking_id, passenger_name, seat_no
FROM railway_bookings
WHERE train_no = 12008
  AND journey_date = '2026-01-18';

-- 7. VERIFY INDEXES AND TABLE STATISTICS
SHOW INDEX FROM railway_bookings;

ANALYZE TABLE railway_bookings;

SELECT COUNT(*) AS total_records
FROM railway_bookings;

-- 8. COMPARISON OF EXECUTION PLANS
-- Before indexing: full table scan (ALL).
-- PNR index: indexed equality lookup using idx_pnr.
-- Composite index: lookup using idx_train_date for train_no + journey_date.

-- END EXPERIMENT 9
