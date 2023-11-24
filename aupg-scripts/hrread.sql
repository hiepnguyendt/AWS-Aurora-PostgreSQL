WITH empid AS (select max(employee_id) AS max_id, min(employee_id) AS min_id from hr.employees) select * from hr.emp_details_view where employee_id = (SELECT floor(random()*(max_id-min_id+1))+min_id FROM empid); 

