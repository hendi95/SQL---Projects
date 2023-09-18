-- DROP TABLE IF EXISTS users
DROP TABLE IF EXISTS users;

-- UP Metadata
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(30) NOT NULL,
    email VARCHAR(50)
);

-- UP DATA
INSERT INTO users VALUES
    (1, 'John', 'john@example.com'),
    (2, 'Emily', 'emily@example.com'),
    (3, 'Michael', 'michael@example.com'),
    (4, 'Sarah', 'sarah@example.com'),
    (5, 'David', 'david@example.com'),
    (6, 'Jessica', 'jessica@example.com'),
    (7, 'Emily', 'emily@example.com'),
    (8, 'Maria', 'maria@example.com'),
    (9, 'Kevin', 'kevin@example.com'),
    (10, 'Sarah', 'sarah@example.com');

-- Verify
SELECT * FROM users;




 -- Query 1: Write a SQL query to fetch all the duplicate records from a table.

-- Solution 1:

SELECT *
FROM users u
WHERE u.user_id NOT IN (
    SELECT MIN(user_id) AS u_id -- list of unique user_id
    FROM users
    GROUP BY user_name
);

-- Solution 2: Using window function.

SELECT user_id, user_name, email
FROM (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_name, email ORDER BY user_id) AS rn -- gives a row number to each value, partitions based on the distinct values in the user_name and email
    FROM users u
) x
WHERE x.rn <> 1; -- row number different from 1
