---
title : "RDS Performance Insights"
date :  "`r Sys.Date()`" 
weight : 7
chapter : false
pre : " <b> 7. </b> "
---

This lab will demonstrate the use of Amazon RDS Performance Insights . Amazon RDS Performance Insights (RDS PI) monitors your Amazon RDS DB instance load so that you can analyze and troubleshoot your database performance.

This lab contains the following tasks:

- Load sample data to the Aurora PostgreSQL DB cluster
- Understand the RDS Performance Insights interface
- Use RDS Performance Insights to identify performance issue
    - High volume insert load on the Aurora DB cluster using pgbench
    - High volume update load on the Aurora DB cluster using pgbench

#### Load sample data to the Aurora PostgreSQL DB cluster
1. First, download all the required scripts used in this lab. Open a cloud9 terminal window by referring Open Cloud9 Terminal Window section and paste the commands below.

    ```
    cd
    wget wget https://aupg-fcj-assets.s3.us-west-2.amazonaws.com/lab-scripts/aupg-scripts.zip
    unzip aupg-scripts.zip

    ```

    ![PI](/images/7/1.png)

2. Create sample HR schema by running the following commands on the Cloud9 terminal window:

    ```
    cd /home/ec2-user/aupg-scripts/scripts
    psql -f postgres-hr.sql # runs a PostgreSQL script named postgres-hr.sql

    ```   

    ![PI](/images/7/2.png)

#### Understanding the RDS Performance Insights interface
1. While the command is running, open the Amazon RDS service [console](https://console.aws.amazon.com/rds/)  in a new tab, if not already open.

    ![PI](/images/7/3.png)

2. Next, select the desired **DB instance** to load the performance metrics for. For Aurora DB clusters, performance metrics are exposed on an individual DB instance basis. The different DB instances comprising a cluster may run different workload patterns, and might not all have Performance Insights enabled. For this lab, we are generating load on the **Writer** (Primary) DB instance only. 

    ![PI](/images/7/4.png)

3. Once a DB instance is selected, you will see the main dashboard view of RDS Performance Insights. The dashboard is divided into two sections, allowing you to drill down from high level performance indicator metrics down to individual waits, queries, users and hosts generating the load.

    ![PI](/images/7/7.png)
     ![PI](/images/7/8.png)

4. The performance metrics displayed by the dashboard are a moving time window. You can adjust the size of the time window by clicking the displayed time duration at the top right hand corner of the interface and selecting a relative range **(5m, 1h, 5h, 24h, 1w, custom range)** or specifying an absolute range. You can also zoom into a specific period of time by selecting with your mouse pointer and dragging across the graph

{{% notice note %}}
All dashboard views are time synchronized. Zooming in will adjust all views, including the detailed drill-down section at the bottom.
{{% /notice %}}

***Here is a summary of all the sections of RDS Performance Insights console.***

|Section|Filters|Description|
|-------|-------|-----------|
| Database load|Load can be sliced by waits (default), application, database, hosts, session types, SQL commands and users|This metric is designed to correlate aggregate load (sliced by the selected dimension) with the available compute capacity on that DB instance (number of vCPUs). Load is aggregated and normalized using the Average Active Session (AAS) metric. A number of AAS that exceeds the compute capacity of the DB instance is a leading indicator of performance problems.|
|Granular Session Activity|Sort by **Waits, SQL (default), Hosts, Users, Session types, applications and databases**|Drill down capability that allows you to get detailed performance data down to the individual commands. Amazon Aurora PostgreSQL specific wait events are documented in the Amazon Aurora PostgreSQL Reference [guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Reference.html#AuroraPostgreSQL.Reference.Waitevents).|
|Metrics Dashboard|Click **Metrics-new** tab beside **Dimensions** to view counter metrics|This section plots OS metrics, database metrics and CloudWatch metrics all in one place, such as number of rows read or written, transactions committed, etc. These metrics are useful to identify causes of abnormal behavior.|

5. This is how the new metrics dashboard looks like.

    ![PI](/images/7/5.png)

#### Use RDS Performance Insights to identify performance issue
In this exercise, we will learn how to use Performance Insights and PostgreSQL extensions to analyze the top wait events and performance issues. We will run some insert and update load test cases using pgbench utility on employees table in the HR schema.
1. Create pg_stat_statements extension
    
     In a new psql session, connect to mylab database and run the following SQL command:

    {{% notice note %}}
Be sure to use a new psql session, otherwise your pg_stat_statements view will be created under the hr schema.
{{% /notice %}}
 
    ```
    psql
    CREATE EXTENSION pg_stat_statements;
    \q

    ```

    ![PI](/images/7/6.png)
    Now, we are ready to run some load on the Aurora Instance to understand the capabilities of RDS Performance Insights.

2. High volume insert load on the Aurora DB cluster using pgbench
- On the cloud9 terminal window, run pgbench workload using the below command:
    ```
    pgbench -n -c 10 -T 300 -f /home/ec2-user/aupg-scripts/scripts/hrload1.sql  > /tmp/pgload1-run1.log

    ```

    The ***hrload1.sql*** SQL script will ingest employee records using PL/pgSQL function ***add_employee_data***. This function uses ***employee_seq*** to generate the next ***employee_id***, randomly generate data including ***first_name***, salary with ***department_id*** from departments table. Each function call will insert 5 records. This test will be executed for 5 minutes with 10 clients.

- Review the PI dashboard and check the top wait events, **AAS (Average Active Sessions)** for the duration.

    ![PI](/images/7/7.png)
    ![PI](/images/7/8.png)

    You will find below top 3 wait events:

    - **IO:XactSync** - In this wait event, a session is issuing a COMMIT or ROLLBACK, requiring the current transaction’s changes to be persisted. Aurora is waiting for Aurora storage to acknowledge persistence.

    - **CPU**

    - **LWLock:Buffer_content** - In this wait event, a session is waiting to read or write a data page in memory while another session has that page locked for writing.
- Note down the key metrics in the pgbench output such as latency average and tps.

    ```
    cat /tmp/pgload1-run1.log

    ```
     
    ![PI](/images/7/9.png)

- Now, lets check the top 5 queries by execute time and CPU Consumption. Run the below SQL query to understand the load caused by the above pgbench run using pg_stat_statements extension.

    ```
    psql -c "SELECT  substring(query, 1, 50) AS short_query, round(total_exec_time::numeric, 2) AS total_exec_time, calls, round(mean_exec_time::numeric, 2) AS mean_exec_time, round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 5;"

    ```
    
    {{%expand "Explain psql command" %}}
    **psql -c**: Executes a SQL command directly from the command line.\
**SELECT**: Begins the SQL query.\
**substring(query, 1, 50) AS short_query**: Displays the first 50 characters of each query for brevity.\
**round(total_exec_time::numeric, 2)** AS total_exec_time: Shows the total execution time for each query, rounded to two decimal places.\
**calls**: Indicates the number of times each query has been executed.\
**round(mean_exec_time::numeric, 2) AS mean_exec_time**: Shows the average execution time per call for each query.\
**round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu**: Calculates the percentage of total CPU time consumed by each query.\
**FROM pg_stat_statements**: Accesses the pg_stat_statements view, which stores query execution statistics.\
**ORDER BY total_exec_time DESC**: Sorts the results by total execution time in descending order (most resource-intensive queries first).\
**LIMIT 5**: Restricts the output to the top 5 results.
    {{% /expand%}}

    ![PI](/images/7/10.png)

- Lets rerun the same function with 50 inserts per execution and check the impact on wait events. Use hrload2.sql for this run.

    ```
    pgbench -n -c 10 -T 300 -f /home/ec2-user/aurora-scripts/scripts/hrload2.sql >  /tmp/pgload1-run2.log

    ```
- Go to PI dashboard and check the top wait events and top SQLs now and see if there are any changes.
    {{% notice tip %}}
If you don't see any new activity in the database load section, change the time range to last **5 minutes** and click **Apply**. Then change it back to last **1 hour** and click **Apply**.
{{% /notice %}}

    ![PI](/images/7/11.png)
    ![PI](/images/7/12.png)

- Rerun the pg_stat_statements query to check resource consumption now.

    ```
    psql -c "SELECT  substring(query, 1, 50) AS short_query, round(total_exec_time::numeric, 2) AS total_exec_time, calls, round(mean_exec_time::numeric, 2) AS mean_exec_time, round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 5;"

    ```
     
    ![PI](/images/7/13.png)
    
- If you compare the wait events for the two pgbench runs, you will notice that IO:XactSync related waits have reduced in the latest run
- Can you verify whether the overall throughput (in terms of number of inserts) has increased by comparing the throughput and latencies reported by pgbench between the runs?

    ```
    cat /tmp/pgload1-run2.log

    ```

    ![PI](/images/7/14.png)

3. High volume update load on the Aurora DB cluster using pgbench
In this exercise, we will run updates on the employee table using update_employee_data_fname and update_employee_data_empid functions.

- On the cloud9 terminal window, run pgbench update workload using the below command:

    ```
    pgbench -n -c 10  -T 180 -f /home/ec2-user/aurora-scripts/scripts/hrupdname.sql > /tmp/pgload2-run1.log
    ```

    The ***hrupdname.sql*** SQL script will update employee salary details in ***employees*** table using PL/pgSQL function ***update_employee_data_fname***. This function randomly selects the employee records and checks if their salary is within a range (min and max salary of their job), if not updates their salary using their ***first_name***. Each function call will select 5 records randomly. This test will be executed for 3 minutes with 10 clients.

- Go to **RDS PI** dashboard. Check the top wait events and AAS for the run duration.
     
    ![PI](/images/7/15.png)
    ![PI](/images/7/16.png)

    Top wait event is:

    **CPU**

    Also check the **CPU utilization** Cloudwatch metrics for the Aurora cluster by selecting the **Monitoring** tab, searching for cpu and expanding the **CPUUtilization** graph.

    ![PI](/images/7/17.png)

    Update the graph to display 1 minute average. As you can see the CPUUtilization reached ~100% during the update load test.

    ![PI](/images/7/18.png)

- Let’s look at the performance stats using pg_stat_statements extensions.

    Run the below command and observe the top 5 queries consuming CPU.
    ```
    psql -c "SELECT  substring(query, 1, 50) AS short_query, round(total_exec_time::numeric, 2) AS total_exec_time, calls, round(mean_exec_time::numeric, 2) AS mean_exec_time, round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 5;"

    ```

    ![PI](/images/7/19.png)

    Let’s look at the explain plan used by the SQL statements in the PL/pgSQL function. In order to capture the explain plan in the logs, set the below DB parameters at your session level.

    ```
    psql
    set auto_explain.log_nested_statements=1;
    set auto_explain.log_min_duration=10;  

    ```
    This will log any SQL statement including nested SQL statements which are taking more than 10ms in error/postgres.log with their corresponding explain plan.

- Run EXPLAIN ANALYZE to capture the explain plan as well as execute the query.

    ```
    EXPLAIN ANALYZE SELECT  hr.update_employee_data_fname(10);
    \q
    # hr.update_employee_data_fname(10): Calls the function update_employee_data_fname within the hr schema, passing the argument 10
    ```

    ![PI](/images/7/20.png)

- Now, lets rerun the load using the SQL Script hrupdid.sql to use the employee_id column to update employees table.

- On the cloud9 terminal window, run pgbench workload using the below command.

    ```
    pgbench -n -c 10  -T 180 -f /home/ec2-user/aurora-scripts/scripts/hrupdid.sql > /tmp/pgload2-run2.log

    ```

    This will update employee salary details of employees using PL/pgSQL function ***update_employee_data_empid***. This function randomly selects the employee records and checks if their salary is within a range (min and max salary of their job), if not updates their salary using their ***employee_id***. Each function call will execute 5 records randomly. This test will be executed for 3 minutes with 10 clients.

- Compare the execution results using pg_stat_statements query again.

    ```
    psql -c "SELECT  substring(query, 1, 50) AS short_query, round(total_exec_time::numeric, 2) AS total_exec_time, calls, round(mean_exec_time::numeric, 2) AS mean_exec_time, round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 5;"

    ```

    ![PI](/images/7/22.png)

- Compare the throughput and latencies reported by pgbench between the runs.

    ```
    cat /tmp/pgload2-run1.log
    cat /tmp/pgload2-run2.log

    ```

    ![PI](/images/7/23.png)