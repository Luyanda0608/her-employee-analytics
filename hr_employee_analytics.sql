-- ============================================================
-- HR & EMPLOYEE ANALYTICS — SQL PROJECT 2
-- ============================================================

-- Q1. Workforce overview by department
SELECT
    departments.department_name,
    COUNT(employees.employee_id) AS number_of_employees,
    AVG(salaries.salary) AS average_salary,
    AVG(performance_reviews.performance_score) AS average_performance_score
FROM employees
JOIN salaries ON employees.employee_id = salaries.employee_id
JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
JOIN departments ON employees.department_id = departments.department_id
GROUP BY departments.department_name;

-- Q2. Employees above department salary average
WITH employees_salaries AS (
    SELECT employees.employee_name, departments.department_name, salaries.salary
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
),
benchmarks AS (
    SELECT employee_name, department_name, salary,
           AVG(salary) OVER (PARTITION BY department_name) AS department_average_salary
    FROM employees_salaries
)
SELECT employee_name, department_name, salary, department_average_salary
FROM benchmarks
WHERE salary > department_average_salary;

-- Q3. High performers above company average
WITH employees_performance AS (
    SELECT employees.employee_name, departments.department_name,
           performance_reviews.performance_score
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
),
benchmarks AS (
    SELECT employee_name, department_name, performance_score,
           AVG(performance_score) OVER () AS company_average_score
    FROM employees_performance
)
SELECT employee_name, department_name, performance_score, company_average_score
FROM benchmarks
WHERE performance_score > company_average_score;

-- Q4. Performance ranking within department
SELECT employees.employee_name, departments.department_name,
       performance_reviews.performance_score,
       RANK() OVER (
           PARTITION BY departments.department_name
           ORDER BY performance_reviews.performance_score DESC
       ) AS department_rank
FROM employees
JOIN departments ON employees.department_id = departments.department_id
JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id;

-- Q5. High performance + low pay
WITH employee_data AS (
    SELECT employees.employee_name, departments.department_name,
           salaries.salary, performance_reviews.performance_score
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
),
benchmarks AS (
    SELECT employee_name, department_name, salary, performance_score,
           AVG(salary) OVER () AS company_average_salary,
           AVG(performance_score) OVER () AS company_average_performance
    FROM employee_data
)
SELECT employee_name, department_name, salary, performance_score,
       company_average_salary, company_average_performance
FROM benchmarks
WHERE performance_score > company_average_performance
  AND salary < company_average_salary;

-- Q6. Performance classification
WITH employee_performance AS (
    SELECT employees.employee_name, departments.department_name,
           performance_reviews.performance_score
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
)
SELECT employee_name, department_name, performance_score,
       CASE
           WHEN performance_score >= 90 THEN 'Excellent'
           WHEN performance_score >= 80 THEN 'Good'
           ELSE 'Need_Improvement'
       END AS performance_category
FROM employee_performance;

-- Q7. Salary classification
WITH employee_salary AS (
    SELECT employees.employee_name, departments.department_name, salaries.salary
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
)
SELECT employee_name, department_name, salary,
       CASE
           WHEN salary >= 60000 THEN 'High'
           WHEN salary >= 40000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_category
FROM employee_salary;

-- Q8. Promotion analysis
WITH employee_data AS (
    SELECT employees.employee_name, departments.department_name,
           employees.hire_date, performance_reviews.performance_score,
           TIMESTAMPDIFF(YEAR, employees.hire_date, '2025-06-30') AS years_employed
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
)
SELECT employee_name, department_name, performance_score, hire_date, years_employed,
       CASE
           WHEN performance_score >= 85 AND years_employed >= 3 THEN 'Qualifies'
           ELSE 'Does Not Qualify'
       END AS promotion_candidate
FROM employee_data;

-- Q9. Salary difference from department average
WITH employees_salaries AS (
    SELECT employees.employee_name, departments.department_name, salaries.salary
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
),
benchmarks AS (
    SELECT employee_name, department_name, salary,
           AVG(salary) OVER (PARTITION BY department_name) AS department_average_salary
    FROM employees_salaries
)
SELECT employee_name, department_name, salary, department_average_salary,
       salary - department_average_salary AS salary_difference
FROM benchmarks
WHERE salary > department_average_salary;

-- Q10. Salary ranking by department
WITH employees_salaries AS (
    SELECT employees.employee_name, departments.department_name, salaries.salary
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
)
SELECT employee_name, department_name, salary,
       RANK() OVER (PARTITION BY department_name ORDER BY salary DESC) AS salary_rank
FROM employees_salaries;

-- Q11. Salary vs performance ranking
WITH employees_data AS (
    SELECT employees.employee_name, departments.department_name,
           salaries.salary, performance_reviews.performance_score
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
)
SELECT employee_name, department_name, salary, performance_score,
       RANK() OVER (PARTITION BY department_name ORDER BY salary DESC) AS salary_rank,
       RANK() OVER (PARTITION BY department_name ORDER BY performance_score DESC) AS performance_rank
FROM employees_data;

-- Q12. Promotion shortlist
WITH employees_data AS (
    SELECT employees.employee_name, departments.department_name,
           salaries.salary, performance_reviews.performance_score
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
),
employees_ranked AS (
    SELECT employee_name, department_name, salary, performance_score,
           RANK() OVER (PARTITION BY department_name ORDER BY salary DESC) AS salary_rank,
           RANK() OVER (PARTITION BY department_name ORDER BY performance_score DESC) AS performance_rank
    FROM employees_data
)
SELECT employee_name, department_name, salary, performance_score,
       salary_rank, performance_rank
FROM employees_ranked
WHERE performance_rank = 1 AND salary_rank > 1;

-- Q13. Department salary equity
WITH employees_data AS (
    SELECT employees.employee_name, departments.department_name, salaries.salary,
           AVG(salaries.salary) OVER (
               PARTITION BY departments.department_name
           ) AS department_average_salary
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
),
x AS (
    SELECT employee_name, department_name, salary, department_average_salary,
           salary - department_average_salary AS salary_difference
    FROM employees_data
)
SELECT employee_name, department_name, salary, department_average_salary,
       salary_difference,
       CASE
           WHEN salary > department_average_salary THEN 'Above_Average'
           WHEN salary = department_average_salary THEN 'At_Average'
           ELSE 'Below_Average'
       END AS salary_position
FROM x
WHERE salary < department_average_salary;

-- Q14. Employee tenure analysis
WITH employees_years AS (
    SELECT employees.employee_name, departments.department_name,
           employees.hire_date,
           TIMESTAMPDIFF(YEAR, employees.hire_date, '2025-06-30') AS years_employed
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
)
SELECT employee_name, department_name, hire_date, years_employed,
       CASE
           WHEN years_employed >= 5 THEN 'Long_Term'
           WHEN years_employed >= 2 THEN 'Established'
           ELSE 'New'
       END AS tenure_category
FROM employees_years;

-- Q15. Workforce tenure by department
WITH employee_years AS (
    SELECT employees.employee_name, departments.department_name,
           TIMESTAMPDIFF(YEAR, employees.hire_date, '2025-06-30') AS years_employed
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
)
SELECT department_name,
       COUNT(*) AS number_of_employees,
       AVG(years_employed) AS average_years_employed,
       SUM(CASE WHEN years_employed >= 5 THEN 1 ELSE 0 END) AS long_term_employees
FROM employee_years
GROUP BY department_name
ORDER BY average_years_employed DESC;

-- Q16. Department workforce insights
WITH employee_data AS (
    SELECT employees.employee_id, departments.department_name,
           salaries.salary, performance_reviews.performance_score
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
)
SELECT department_name,
       COUNT(*) AS number_of_employees,
       AVG(salary) AS average_salary,
       AVG(performance_score) AS average_performance_score,
       SUM(CASE WHEN performance_score >= 85 THEN 1 ELSE 0 END) AS high_performers
FROM employee_data
GROUP BY department_name
ORDER BY average_performance_score DESC;

-- Q17. High-value employees
WITH employees_salaries AS (
    SELECT employees.employee_name, departments.department_name,
           salaries.salary, performance_reviews.performance_score,
           AVG(salaries.salary) OVER (
               PARTITION BY departments.department_name
           ) AS department_average_salary
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
)
SELECT employee_name, department_name, salary, performance_score,
       department_average_salary,
       salary - department_average_salary AS salary_difference
FROM employees_salaries
WHERE performance_score >= 85
  AND salary < department_average_salary
ORDER BY salary_difference ASC;

-- Q18. Employee retention / turnover risk
WITH employee_data AS (
    SELECT employees.employee_name, departments.department_name,
           salaries.salary, performance_reviews.performance_score,
           TIMESTAMPDIFF(YEAR, employees.hire_date, '2025-06-30') AS years_employed,
           AVG(salaries.salary) OVER (
               PARTITION BY departments.department_name
           ) AS department_average_salary
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
)
SELECT employee_name, department_name, years_employed, salary, performance_score,
       CASE
           WHEN years_employed < 3
                AND (performance_score < 80 OR salary < department_average_salary)
           THEN 'Potential Risk'
           ELSE 'Lower Risk'
       END AS retention_risk
FROM employee_data
ORDER BY retention_risk, years_employed;

-- Q19. Final management department summary
WITH employee_data AS (
    SELECT employees.employee_id, departments.department_name,
           salaries.salary, performance_reviews.performance_score,
           TIMESTAMPDIFF(YEAR, employees.hire_date, '2025-06-30') AS years_employed
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN salaries ON employees.employee_id = salaries.employee_id
    JOIN performance_reviews ON employees.employee_id = performance_reviews.employee_id
)
SELECT department_name,
       COUNT(*) AS number_of_employees,
       AVG(salary) AS average_salary,
       AVG(performance_score) AS average_performance_score,
       SUM(CASE WHEN performance_score >= 85 THEN 1 ELSE 0 END) AS high_performers,
       SUM(CASE WHEN years_employed >= 5 THEN 1 ELSE 0 END) AS long_term_employees
FROM employee_data
GROUP BY department_name
ORDER BY average_performance_score DESC;
