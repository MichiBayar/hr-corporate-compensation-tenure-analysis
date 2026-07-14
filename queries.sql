/*
Date: July 12th, 2026
Name: Michi Bayarsaikhan
Description: Department Compensation & Organizational Structure Analysis
Database: Employees (classic MySQL sample dataset, imported into SQLite)
Tool: DB Browser for SQLite
*/



-- 1. Establishing the scale:
-- total number of employees 
SELECT
	COUNT(*) AS [Total Employees]
FROM
	employees;
-- output gave 300024

--  total number of departments 
SELECT
	COUNT(*) AS [Total Departments]
FROM
	departments;
-- output gave 9

--  total number of currently active employees 
SELECT
	COUNT(DISTINCT emp_no) AS [Total Current Employees]
FROM
	dept_emp
WHERE
	to_date = '9999-01-01';
-- output gave 240124



--2. Current headcount and average salary by department
SELECT
	d.dept_name,
	COUNT(DISTINCT de.emp_no) AS [Total Current Employees],
	ROUND(AVG(s.salary),2) AS [Average Salary]
FROM
	dept_emp AS de
JOIN
	departments AS d
	ON
		de.dept_no = d.dept_no
JOIN
	salaries AS s
	ON
	de.emp_no = s.emp_no
WHERE
	s.to_date = '9999-01-01'
	AND de.to_date = '9999-01-01'
GROUP BY
	d.dept_name
ORDER BY
	[Average Salary] ASC;

	
	
--3. Department, current title, and current salary for every current employee
SELECT
	e.first_name,
	e.last_name,
	d.dept_name,
	t.title,
	s.salary
FROM
	employees AS e
JOIN
	dept_emp AS de
	ON
		e.emp_no = de.emp_no
JOIN
	departments AS d
	ON
		de.dept_no = d.dept_no
JOIN
	titles AS t
	ON e.emp_no = t.emp_no
JOIN
	salaries AS s
	ON e.emp_no = s.emp_no
WHERE
	de.to_date = '9999-01-01'
	AND t.to_date = '9999-01-01'
	AND s.to_date = '9999-01-01'
ORDER	 BY
	s.salary DESC
LIMIT 20;
	
	
	
--4. Departments with no current manager on record
SELECT
	d.dept_name,
	dm.emp_no AS [Manager No]
FROM
	departments AS d
LEFT JOIN
	dept_manager AS dm
	ON 
	d.dept_no = dm.dept_no
	AND
	dm.to_date = '9999-01-01'
WHERE
	dm.emp_no IS  NULL;
-- output gave 0



--5. Percentage of  the current workforce hired before 1987 ("long tenured") 
SELECT
    SUM(CASE WHEN e.hire_date < '1987-01-01' THEN 1 ELSE 0 END) AS [Long Tenured Count],
    COUNT(DISTINCT de.emp_no) AS [Total Current Count],
    ROUND(100.0 * SUM(CASE WHEN e.hire_date < '1987-01-01' THEN 1 ELSE 0 END) / COUNT(DISTINCT de.emp_no), 2) AS [Percentage Long Tenured]
FROM
    dept_emp AS de
JOIN
    employees AS e
	ON
		de.emp_no = e.emp_no
WHERE
    de.to_date = '9999-01-01';
--output gave 23.79



--6. Which departments have the highest percentage of long-tenured employees from their current headcount? 
SELECT
	d.dept_name,
	COUNT(DISTINCT de.emp_no) AS [Total Current Count],
	SUM(CASE WHEN e.hire_date < '1987-01-01' THEN 1 ELSE 0 END) AS [Long Tenured Count],
	ROUND(100.0* SUM(CASE WHEN e.hire_date < '1987-01-01' THEN 1 ELSE 0 END) / COUNT(DISTINCT e.emp_no),2) AS [Percentage Long Tenured]
FROM
	dept_emp AS de
JOIN
	departments AS d
	ON
		de.dept_no = d.dept_no
JOIN
	employees AS e
	ON
		de.emp_no = e.emp_no
WHERE
	de.to_date = '9999-01-01'
GROUP BY
	d.dept_name
ORDER BY
	[Percentage Long Tenured] DESC;
--output gave all departments 23-24, ruling out tenure as a meaningful differentiator
	
	
	
--7. Job titles relation to average salary (deeper dive into query 2)
SELECT
	t.title,
	d.dept_name,
	COUNT(DISTINCT de.emp_no) AS [Total Current Employees],
	ROUND(AVG(s.salary),2) AS [Average Salary]
FROM
	dept_emp AS de
JOIN
	departments AS d
	ON
		de.dept_no = d.dept_no
JOIN
	titles AS t
	ON
	de.emp_no = t.emp_no
JOIN
	salaries AS s
	ON
	de.emp_no = s.emp_no
WHERE
	de.to_date = '9999-01-01'
  AND t.to_date = '9999-01-01'
  AND s.to_date = '9999-01-01'
GROUP BY
	t.title,
	d.dept_name
ORDER BY 
	d.dept_name DESC;



--8. Bucket departments into Low, Medium, and High pay tiers
SELECT
	d.dept_name,
	COUNT(DISTINCT de.emp_no) AS [Total Current Employees],
	ROUND(AVG(s.salary),2) AS [Average Salary],
	CASE
		WHEN ROUND(AVG(s.salary),2) >= 80000 THEN 'High Pay Tier'
		WHEN ROUND(AVG(s.salary),2) >= 67000 THEN 'Medium Pay Tier'
		ELSE 'Low Pay Tier'
		END AS pay_tier
FROM
	dept_emp AS de
JOIN
	departments AS d 
	ON
		de.dept_no = d.dept_no
JOIN
	salaries AS s
	ON
		de.emp_no = s.emp_no
WHERE
	de.to_date = '9999-01-01'
	AND s.to_date = '9999-01-01'
GROUP BY
	d.dept_name
ORDER BY
	[Average Salary] DESC;
	
	
	
--9. Make VIEW named DepartmentCompensationSnapshot
CREATE VIEW
	DepartmentCompensationSnapshot AS
SELECT
	d.dept_name,
	COUNT(DISTINCT de.emp_no) AS employee_count,
	ROUND(AVG(s.salary), 2) AS avg_salary,
	CASE
		WHEN ROUND(AVG(s.salary), 2) >= 80000 THEN 'High Pay Tier'
		WHEN ROUND(AVG(s.salary), 2) >= 67000 THEN 'Medium Pay Tier'
		ELSE 'Low Pay Tier'
       END AS pay_tier
FROM
	dept_emp AS de
JOIN
	departments AS d 
	ON
		de.dept_no = d.dept_no
JOIN
	salaries AS s
	ON 
	de.emp_no = s.emp_no
WHERE
	de.to_date = '9999-01-01'
	AND s.to_date = '9999-01-01'
GROUP BY
	d.dept_name;

-- Using VIEW
SELECT * FROM DepartmentCompensationSnapshot
ORDER BY avg_salary DESC
