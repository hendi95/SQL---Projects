-- DROP TABLE IF EXISTS users
DROP TABLE IF EXISTS students;

-- UP Metadata
CREATE TABLE students (
    id int primary key,
	student_name varchar(50) not null
);

-- UP DATA
INSERT INTO students VALUES
    (1, 'James'),
	(2, 'Michael'),
	(3, 'George'),
	(4, 'Stewart'),
	(5, 'Robin');

-- Verify
SELECT * FROM students;



-- Query 6: From the students table, write a SQL query to interchange the adjacent student names.
		-- Note: If there are no adjacent student then the student name should stay the same.

SELECT 
    id,
    student_name,
    CASE
        WHEN id % 2 <> 0 THEN LEAD(student_name, 1, student_name) OVER(ORDER BY id) -- get the student_name of the next row (with an offset of 1) based on the order of id
        WHEN id % 2 = 0 THEN LAG(student_name) OVER(ORDER BY id) -- get the student_name of the previous row based on the order of id.
    END AS new_student_name
FROM students;
