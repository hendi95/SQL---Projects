-- DROP TABLE IF EXISTS users
DROP TABLE IF EXISTS patient_logs;

-- UP Metadata
CREATE TABLE patient_logs (
	  account_id int,
	  date date,
	  patient_id int
);

-- UP DATA
INSERT INTO patient_logs (account_id, date, patient_id)
VALUES
    (1, CONVERT(DATE, '2020-01-02', 120), 150),
    (1, CONVERT(DATE, '2020-01-27', 120), 250),
    (2, CONVERT(DATE, '2020-01-01', 120), 350),
    (2, CONVERT(DATE, '2020-01-21', 120), 450),
    (2, CONVERT(DATE, '2020-01-21', 120), 350),
    (2, CONVERT(DATE, '2020-01-01', 120), 550),
    (3, CONVERT(DATE, '2020-01-20', 120), 450),
    (1, CONVERT(DATE, '2020-03-04', 120), 550),
    (3, CONVERT(DATE, '2020-01-20', 120), 500);

-- Verify
SELECT * FROM patient_logs;




-- Query 8: Find the top 2 accounts with the maximum number of unique patients on a monthly basis.
--			Note: Prefer the account if with the least value in case of same number of unique patients

WITH MonthlyUniquePatients AS (
    SELECT
        account_id,
        FORMAT(DATEADD(MONTH, DATEDIFF(MONTH, 0, date), 0), 'MMMM') AS month_start,
        COUNT(DISTINCT patient_id) AS unique_patients_count
    FROM patient_logs
    GROUP BY account_id, FORMAT(DATEADD(MONTH, DATEDIFF(MONTH, 0, date), 0), 'MMMM')
),
RankedAccounts AS (
    SELECT
        account_id,
        month_start,
        unique_patients_count,
        ROW_NUMBER() OVER (PARTITION BY month_start ORDER BY unique_patients_count DESC, account_id ASC) AS ranking
    FROM MonthlyUniquePatients
)
SELECT account_id, month_start, unique_patients_count
FROM RankedAccounts
WHERE ranking <= 2
ORDER BY month_start, ranking;
