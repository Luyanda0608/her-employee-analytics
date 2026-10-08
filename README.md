# HR & Employee Analytics — SQL Project 2

## Project Overview
This project analyzes employee data for a fictional South African company using SQL. It focuses on workforce structure, salaries, performance, tenure, promotion, compensation, and retention.

## Business Questions
1. Workforce overview by department
2. Employees above department salary average
3. High performers above company average
4. Performance ranking by department
5. High performance + low pay
6. Performance classification
7. Salary classification
8. Promotion analysis
9. Salary difference from department average
10. Salary ranking by department
11. Salary vs performance ranking
12. Promotion shortlist
13. Department salary equity
14. Employee tenure analysis
15. Workforce tenure by department
16. Department workforce insights
17. High-value employees
18. Retention / turnover risk
19. Final management department summary

## Database Schema
### employees
employee_id, employee_name, department_id, job_id, hire_date, city

### departments
department_id, department_name

### jobs
job_id, job_title

### salaries
employee_id, salary, effective_date

### performance_reviews
review_id, employee_id, review_date, performance_score

## SQL Skills Demonstrated
- SELECT, WHERE, ORDER BY
- INNER JOIN
- GROUP BY
- COUNT, AVG, SUM
- CASE WHEN
- CTEs
- Window functions
- RANK()
- TIMESTAMPDIFF()
- Conditional aggregation
- Department benchmarking
- Business-rule classification
- Multi-stage aggregation

## Final Department Summary

| Department | Employees | Avg Salary | Avg Performance | High Performers | Long-term |
|---|---:|---:|---:|---:|---:|
| Human Resources | 2 | 52,000 | 91.0 | 2 | 1 |
| Marketing | 2 | 53,500 | 87.0 | 1 | 1 |
| Data Analytics | 3 | 48,000 | 86.0 | 2 | 1 |
| Finance | 3 | 38,333.33 | 77.0 | 1 | 0 |
| Operations | 2 | 53,500 | 75.5 | 0 | 1 |

## Management Insights
- Human Resources has the highest average performance.
- Data Analytics combines strong performance with the largest workforce.
- Finance has the lowest average salary and below-top-tier performance.
- Operations has the lowest average performance.
- Salary and performance benchmarks can help identify promotion and compensation-review opportunities.

## Repository Structure
```text
hr-employee-analytics/
├── README.md
└── hr_employee_analytics.sql
```

## Tools
SQL, MySQL, GitHub

## Author
Luyanda Mthethwa
