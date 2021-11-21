-- Given two tables below, write a query to display the comparison result (higher/lower/same) 
-- of the average salary of employees in a department to the company’s average salary.

-- Table: salary
-- | id | employee_id | amount | pay_date   |
-- |----|-------------|--------|------------|
-- | 1  | 1           | 9000   | 2017-03-31 |
-- | 2  | 2           | 6000   | 2017-03-31 |
-- | 3  | 3           | 10000  | 2017-03-31 |
-- | 4  | 1           | 7000   | 2017-02-28 |
-- | 5  | 2           | 6000   | 2017-02-28 |
-- | 6  | 3           | 8000   | 2017-02-28 |
 

-- The employee_id column refers to the employee_id in the following table employee.
 

-- | employee_id | department_id |
-- |-------------|---------------|
-- | 1           | 1             |
-- | 2           | 2             |
-- | 3           | 2             |
 

-- So for the sample data above, the result is:
 

-- | pay_month | department_id | comparison  |
-- |-----------|---------------|-------------|
-- | 2017-03   | 1             | higher      |
-- | 2017-03   | 2             | lower       |
-- | 2017-02   | 1             | same        |
-- | 2017-02   | 2             | same        |

-- Solution 1
drop table if exists ##temp_table

select distinct pay_month, department_id case when department_average > company_average then 'higher' 
    when deparment_average < company_average then 'lower' else 'same' end as comparison ( 
select 
    LEFT(pay_date, 7) as pay_month
    department_id,
    AVG(amount) OVER (PARTITION BY LEFT(pay_date, 7), department_id) as department_average
    AVG(amount) OVER (PARTITION BY LEFT(pay_date, 7)) as company_average     
from salary a inner join employee b on a.employee_id = b.employee_id
) a 
-- Solution 2
drop table if exists ##department
select
    department_id
    LEFT(pay_date, 7) as pay_month
    AVG(amount) as pay_amount
into ##department
salary a inner join employee b 
on a.employee_id = b.employee_id
group by LEFT(pay_date, 7), department_id 

drop table if exists ##company
select 
    LEFT(pay_date, 7) as pay_month
    AVG(amount) as company_pay_amount
into ##company
group by LEFT(pay_date, 7)

select 
    a.pay_month,
    department_id,
    case when pay_amount > pay_month then 'higher' 
        when pay_amount < pay_month then 'lower'
        when pay_amount = pay_month then 'same' 
        end as comparison 
from ##department a
inner join ##company b 
on a.pay_month = b.pay_month
