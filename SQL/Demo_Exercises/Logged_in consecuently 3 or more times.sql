-- DROP TABLE IF EXISTS users
DROP TABLE IF EXISTS login_details;

-- UP Metadata
CREATE TABLE login_details (
    login_id int primary key,
	user_name varchar(50) not null,
	login_date date
);

-- UP DATA
INSERT INTO login_details VALUES
    (114, 'Emma', GETDATE()),
    (115, 'Sophia', GETDATE()),
    (116, 'Oliver', DATEADD(DAY, -1, GETDATE())),
    (117, 'Oliver', DATEADD(DAY, -1, GETDATE())),
    (118, 'Oliver', DATEADD(DAY, -1, GETDATE())),
    (119, 'Emma', DATEADD(DAY, -2, GETDATE())),
    (120, 'Emma', DATEADD(DAY, -2, GETDATE())),
    (121, 'Oliver', DATEADD(DAY, -3, GETDATE())),
    (122, 'Oliver', DATEADD(DAY, -3, GETDATE())),
    (123, 'Sophia', DATEADD(DAY, -4, GETDATE())),
    (124, 'Sophia', DATEADD(DAY, -4, GETDATE())),
    (125, 'Sophia', DATEADD(DAY, -5, GETDATE())),
    (126, 'Sophia', DATEADD(DAY, -6, GETDATE()));

-- Verify
SELECT * FROM login_details;


-- Query 5: From the login_details table, fetch the users who logged in consecutively 3 or more times.

-- Step 1: Select repeated user names from the login_details table
SELECT DISTINCT repeated_names
FROM (
    -- Step 2: Create a temporary result set with an additional repeated_names column
    SELECT *,
        CASE
            WHEN user_name = LEAD(user_name) OVER(ORDER BY login_id) -- Compares current user name with next row
                AND user_name = LEAD(user_name, 2) OVER(ORDER BY login_id) -- Checks user name 2 rows ahead
            THEN user_name
            ELSE NULL
        END AS repeated_names
    FROM login_details
) x
-- Step 3: Filter the temporary result set to only include rows with non-null repeated_names
WHERE x.repeated_names IS NOT NULL;
