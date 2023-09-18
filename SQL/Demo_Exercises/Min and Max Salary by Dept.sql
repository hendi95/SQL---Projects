---- DROP TABLE IF EXISTS users
--DROP TABLE IF EXISTS employee;

---- UP Metadata
--CREATE TABLE employee (
--    emp_ID INT PRIMARY KEY,
--    emp_NAME VARCHAR(50) NOT NULL,
--    DEPT_NAME VARCHAR(50),
--    SALARY INT
--);

---- UP DATA
--INSERT INTO employee VALUES
--		(101, 'John', 'Admin', 4500),
--		(102, 'Emily', 'HR', 3200),
--		(103, 'Michael', 'IT', 4200),
--		(104, 'Sophia', 'Finance', 6800),
--		(105, 'David', 'HR', 3200),
--		(106, 'Olivia', 'Finance', 5200),
--		(107, 'Ethan', 'HR', 7200),
--		(108, 'Ava', 'Admin', 4200),
--		(109, 'Daniel', 'IT', 6700),
--		(110, 'Emma', 'IT', 7100),
--		(111, 'James', 'IT', 8200),
--		(112, 'Lily', 'IT', 10500),
--		(113, 'Matthew', 'Admin', 2400),
--		(114, 'Sophie', 'HR', 3200),
--		(115, 'Noah', 'IT', 4700),
--		(116, 'Isabella', 'Finance', 6700),
--		(117, 'Liam', 'HR', 3800),
--		(118, 'Mia', 'Finance', 5900),
--		(119, 'William', 'HR', 8400),
--		(120, 'Aiden', 'Admin', 5300),
--		(121, 'Charlotte', 'IT', 6400),
--		(122, 'Lucas', 'IT', 8400),
--		(123, 'Amelia', 'IT', 8400),
--		(124, 'Benjamin', 'IT', 11500);

---- Verify
--SELECT * FROM employee;




-- Query 3: Write a SQL query to display only the details of employees who either earn the highest salary
--			or the lowest salary in each department from the employee table.

WITH SalaryBounds AS (
    SELECT dept_name,
           MAX(salary) AS max_salary,
           MIN(salary) AS min_salary
    FROM employee
    GROUP BY dept_name
)
SELECT e.emp_id, e.emp_name, e.dept_name, e.salary,
       sb.max_salary AS department_max_salary,
       sb.min_salary AS department_min_salary
FROM employee e
JOIN SalaryBounds sb ON e.dept_name = sb.dept_name
WHERE e.salary = sb.max_salary OR e.salary = sb.min_salary
ORDER BY e.dept_name, e.salary;