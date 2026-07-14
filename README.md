# Employee Workforce, Compensation & Tenure Analysis

Employee database analysis on organizational structure, department compensation, and employee retention/tenure using SQL and SQLite.

## Overview
The goal of this project was to act as a Corporate Human Resources & People Ops Analyst to evaluate the overall scale, payroll structure, and tenure distribution across the company's workforce. By analyzing a public relational dataset found online of over 300,000 employees, this project helps corporate leadership and FP&A teams understand organizational scale, locate high/low compensation tiers, investigate potential legacy tenure bottlenecks, and implement structural database tools (VIEWs) to support real-time executive decision-making.

---

## Resources
* **Original Datasets:** 
  * `employees.csv` (300,024 master employee profiles)
  * `departments.csv` (9 corporate departments)
  * `dept_emp.csv` (Workforce assignments)
  * `dept_manager.csv` (Historical and active manager records)
  * `salaries.csv` (967,330 historical payroll updates)
  * `titles.csv` (Job titles and promotion paths)
* **Software/Tools:** 
  * SQL
  * SQLite / DB Browser for SQLite
  * Markdown

---

## Results

### Establishing Organizational Scale
To understand the baseline scale of the company's workforce, distinct aggregate queries were executed to identify total career history vs. active operational staff.
* **Total Employees (Historical Archive):** There are **300,024** unique employee profiles on record.
* **Total Departments:** There are **9** distinct functional business units.
* **Total Currently Active Employees:** There are **240,124** employees actively on current payroll records (determined by filtering `to_date = '9999-01-01'`).

```sql
-- Query to identify total currently active workforce
SELECT COUNT(DISTINCT emp_no) AS [Total Current Employees]
FROM dept_emp
WHERE to_date = '9999-01-01';
```

### Department Headcount & Payroll Map
By joining active department records with active pay schedules, we mapped headcounts and average salaries to identify where corporate payroll capital is concentrated.

<img width="422" height="482" alt="Screenshot 2026-07-14 at 11 45 10 PM" src="https://github.com/user-attachments/assets/30a3575d-7e11-44ae-8d54-999087fd461d" />

* **Highest Paid Department:** Sales averages $89,005.79 across 12,735 active employees.

* **Lowest Paid Department:** Human Resources averages $63,643.26 across 4,449 active employees.

* **Strategic Finding:** Functional operational departments like Development (20,866 headcount) and Production (18,248 headcount) house the absolute largest portions of the company's workforce while staying highly cost-optimized near $67,700 averages.



### Top Earning Employees
To identify outliers and high-value individual contributors, active title and salary tables were joined to extract the top 20 highest-compensated individuals currently in the organization.

```sql
SELECT
	e.first_name,
	e.last_name,
	d.dept_name,
	t.title,
	s.salary
FROM employees AS e
JOIN dept_emp AS de ON e.emp_no = de.emp_no
JOIN departments AS d ON de.dept_no = d.dept_no
JOIN titles AS t ON e.emp_no = t.emp_no
JOIN salaries AS s ON e.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
  AND t.to_date = '9999-01-01'
  AND s.to_date = '9999-01-01'
ORDER BY s.salary DESC
LIMIT 20;
```
**Key Discovery:** The top-tier salary brackets are dominated by individuals holding Senior Staff and Manager titles within the Sales and Marketing divisions, hitting maximum thresholds above $140,000.

<img width="425" height="506" alt="Screenshot 2026-07-14 at 11 45 29 PM" src="https://github.com/user-attachments/assets/778fa5e6-5d74-4e0a-b8c3-b0ed126d1ef6" />

### Management Continuity Audit
A critical governance and operational risk check was run to identify any department currently operating without a manager assigned to active records.

**Result:** 0 departments currently lack an active manager. Every single business unit has a designated leader assigned on active record (to_date = '9999-01-01'), ensuring structural alignment.

<img width="171" height="69" alt="Screenshot 2026-07-14 at 11 45 42 PM" src="https://github.com/user-attachments/assets/ef7fde55-bc69-4016-a1aa-834b7266aa00" />

### Evaluating the "Legacy Cohort" Retention Risk
To test the hypothesis that specific departments are top-heavy with aging legacy talent, we defined "Long-Tenured" employees as any active staff member hired prior to January 1st, 1987.

```sql
SELECT
    SUM(CASE WHEN e.hire_date < '1987-01-01' THEN 1 ELSE 0 END) AS [Long Tenured Count],
    COUNT(DISTINCT de.emp_no) AS [Total Current Count],
    ROUND(100.0 * SUM(CASE WHEN e.hire_date < '1987-01-01' THEN 1 ELSE 0 END) / COUNT(DISTINCT de.emp_no), 2) AS [Percentage Long Tenured]
FROM dept_emp AS de
JOIN employees AS e ON de.emp_no = e.emp_no
WHERE de.to_date = '9999-01-01';
```
**Result:** 23.79% of the company’s current active workforce is classified as highly long-tenured, representing 57,115 core veterans who have been with the company since 1986 or earlier.

<img width="577" height="245" alt="Screenshot 2026-07-14 at 11 46 20 PM" src="https://github.com/user-attachments/assets/e39027c1-526d-446f-9b1d-381c61733450" />

### Summary & Strategic HR Insights
When breaking down long-tenured rates department-by-department, the data yielded an unexpected but disappointing bland pattern. Rather than certain departments holding heavily skewed legacy populations, tenure is almost completely uniform across all the departments.

**Interpretation:** Because legacy tenure is uniformly distributed around ~23.7% across every single functional business unit, length of service can be officially eliminated as a variable for departmental performance gaps or abnormal turnover spikes. If one department is losing talent faster than another, it is driven by local management practices, career progression bottlenecks, or compensation tiers rather than a retirement-heavy cohort structure.

### Financial Spend & Compensation Tiers
To help Corporate Finance standardize salary adjustments and control human capital spend, we compiled the departments into a structured pay-tier framework based on average salary profiles:

```sql
SELECT
	d.dept_name,
	COUNT(DISTINCT de.emp_no) AS [Total Current Employees],
	ROUND(AVG(s.salary),2) AS [Average Salary],
	CASE
		WHEN ROUND(AVG(s.salary),2) >= 80000 THEN 'High Pay Tier'
		WHEN ROUND(AVG(s.salary),2) >= 67000 THEN 'Medium Pay Tier'
		ELSE 'Low Pay Tier'
	END AS pay_tier
FROM dept_emp AS de
JOIN departments AS d ON de.dept_no = d.dept_no
JOIN salaries AS s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01' AND s.to_date = '9999-01-01'
GROUP BY d.dept_name
ORDER BY [Average Salary] DESC;
```
#### The Compensation Hierarchy:
* **High Pay Tier (>= $80,000):** Sales ($89,005.79)

* **Medium Pay Tier ($67,000 - $79,999):** Marketing ($79,879.18), Finance ($78,075.46), Research ($68,134.69), Production ($67,772.53), Development ($67,729.76), Customer Service ($67,199.35)

* **Low Pay Tier (< $67,000):** Quality Management ($65,516.97), Human Resources ($63,643.26)

### Reusable Business View
To allow HR leaders to easily monitor this compensation distribution on-demand as hiring profiles shift, the logic was permanently committed as an operational database VIEW:

```sql
CREATE VIEW DepartmentCompensationSnapshot AS
SELECT
	d.dept_name,
	COUNT(DISTINCT de.emp_no) AS employee_count,
	ROUND(AVG(s.salary), 2) AS avg_salary,
	CASE
		WHEN ROUND(AVG(s.salary), 2) >= 80000 THEN 'High Pay Tier'
		WHEN ROUND(AVG(s.salary), 2) >= 67000 THEN 'Medium Pay Tier'
		ELSE 'Low Pay Tier'
	END AS pay_tier
FROM dept_emp AS de
JOIN departments AS d ON de.dept_no = d.dept_no
JOIN salaries AS s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01' AND s.to_date = '9999-01-01'
GROUP BY d.dept_name;
```
