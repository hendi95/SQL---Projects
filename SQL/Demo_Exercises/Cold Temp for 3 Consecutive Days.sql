-- DROP TABLE IF EXISTS users
DROP TABLE IF EXISTS weather;

-- UP Metadata
CREATE TABLE weather (
    id int,
	city varchar(50),
	temperature int,
	day date
);

-- UP DATA
INSERT INTO weather (id, city, temperature, day)
VALUES
    (9, 'Syracuse', 2, CONVERT(DATE, '2021-01-01')),
    (10, 'Syracuse', 0, CONVERT(DATE, '2021-01-02')),
    (11, 'Syracuse', 3, CONVERT(DATE, '2021-01-03')),
    (12, 'Syracuse', -1, CONVERT(DATE, '2021-01-04')),
    (13, 'Syracuse', 0, CONVERT(DATE, '2021-01-05')),
    (14, 'Syracuse', -4, CONVERT(DATE, '2021-01-06')),
    (15, 'Syracuse', -6, CONVERT(DATE, '2021-01-07')),
    (16, 'Syracuse', -3, CONVERT(DATE, '2021-01-08'));


-- Verify
SELECT * FROM weather;





-- Query 7: From the weather table, fetch all the records when London had extremely cold temperature for 3 consecutive days or more.
		-- Note: Weather is considered to be extremely cold then its temperature is less than zero.

WITH ConsecutiveColdDays AS (
    SELECT
        id, city, temperature, day,
        LAG(temperature, 1) OVER (PARTITION BY city ORDER BY day) AS prev_temp,
        LAG(temperature, 2) OVER (PARTITION BY city ORDER BY day) AS prev_temp2,
        LEAD(temperature, 1) OVER (PARTITION BY city ORDER BY day) AS next_temp,
        LEAD(temperature, 2) OVER (PARTITION BY city ORDER BY day) AS next_temp2
    FROM weather
)
SELECT id, city, temperature, day
FROM ConsecutiveColdDays
WHERE city = 'Syracuse'
    AND (
        (temperature < 0 AND prev_temp < 0 AND prev_temp2 < 0) OR
        (temperature < 0 AND prev_temp < 0 AND next_temp < 0) OR
        (temperature < 0 AND next_temp < 0 AND next_temp2 < 0)
    );


