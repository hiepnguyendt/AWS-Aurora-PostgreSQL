---
title : "Query Plan Management"
date :  "`r Sys.Date()`" 
weight : 4 
chapter : false
pre : " <b> 4. </b> "
---

With query plan management (QPM), you can control execution plans for a set of statements that you want to manage. You can do the following:

- Improve plan stability by forcing the optimizer to choose from a small number of known, good plans.
- Optimize plans centrally and then distribute the best plans globally.
- Identify indexes that aren't used and assess the impact of creating or dropping an index.
- Automatically detect a new minimum-cost plan discovered by the optimizer.
- Try new optimizer features with less risk, because you can choose to approve only the plan changes that improve performance.

For additional details on the Query Plan Management please refer official documentation [Managing Query Execution Plans for Aurora PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Optimize.html) .

The quickest way to enable QPM is to use the automatic plan capture, which enables the plan capture for all SQL statements that run at least two times. In this lab, we will walk through the process of enabling QPM with automatic plan capture, evolving captured query plans to manually accept them and fixing query plans by using optimizer hints.


#### Quick start guide on using QPM with automatic capture

Here are the steps to configure and enable QPM on your Aurora PostgreSQL cluster to automatically capture and control execution plans for a set of SQL statements.

1. Modify the Amazon Aurora DB Cluster Parameters related to the QPM.
- Open the [Amazon RDS service console Parameters group section](https://console.aws.amazon.com/rds/home?#parameter-group-list:)  located on left-hand panel of RDS console.

- In the list, choose the parameter group for your Aurora PostgreSQL DB cluster. The DB cluster must use a parameter group other than the default, because you can't change values in a default parameter group. For more information, see [Creating a DB Cluster Parameter Group](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_WorkingWithParamGroups.html#USER_WorkingWithParamGroups.CreatingCluster).

- Click **Edit** under the **Actions** menu.

       ![QMP](/images/4.1/1.png)

- In Parameter Filter field, enter ``rds.enable_plan_management`` without any spaces to reveal the filtered parameter. Set value of **rds.enable_plan_management** to 1 and click on Save changes.

       ![QMP](/images/4.1/2.png)

- Click on the database parameter group name **DB instance parameter group** and click Edit.

       ![QMP](/images/4.1/3.png)

- We need to change two paramaters:
  - Modify the value for ``apg_plan_mgmt.capture_plan_baselines`` parameter to automatic
  - Modify the value for ``apg_plan_mgmt.use_plan_baselines`` to true
  - Click **Save** Changes to save changes

       ![QMP](/images/4.1/4.png)

- Click **Databases** on the left navigation panel and wait for the status of the instance to change to **available**. The parameter changes will take effect after reboot as suggested on the configuration tab of the Aurora writer and reader instances.
- Reboot the writer and reader nodes by selecting it and going to the **Actions** menu.
- Wait for the Status of Writer and Reader nodes to become Available.

2. Create and verify the apg_plan_mgmt extension for your DB instance.

- Open a Cloud9 terminal window by referring [Open Cloud9 Terminal Window](https://catalog.us-east-1.prod.workshops.aws/workshops/098605dc-8eee-4e84-85e9-c5c6c9e43de2/en-US/lab1-5-client/cloud9-terminal/) section and create the **apg_plan_mgmt** extension for your DB instance.

       ```
       psql
       CREATE EXTENSION apg_plan_mgmt;
       select extname,extversion from pg_extension where extname='apg_plan_mgmt';

       ```
You should see output similar to the following. The extension version will vary depending on the Aurora PostgreSQL version.

       ![QMP](/images/4.1/5.png)
- Review all QPM related parameters are modified to the appropriate value by pasting the following queries.

       ```
       show apg_plan_mgmt.capture_plan_baselines;
       show apg_plan_mgmt.use_plan_baselines;
       \q
       ```

       ![QMP](/images/4.1/6.png)

3. Run synthetic workload with automatic capture.
- Open a terminal window in Cloud9 and run pgbench (a PostgreSQL benchmarking tool) to generate a simulated workload, which runs same queries for a specified period. With automatic capture enabled, QPM captures plans for each query that runs at least twice.

       ```
       pgbench --progress-timestamp -M prepared -n -T 100 -P 1  -c 100 -j 100 -b tpcb-like@1 -b select-only@20
       # The following pgbench command runs for 100 seconds with 100 clients/db sessions and 100 job threads emitting progress every 1 second
       ```
*Wait for the above command to finish.*

- Open another terminal window on Cloud9 to query ``apg_plan_mgmt.dba_plans`` table to view the managed statements and the execution plans for the SQL statements started with the pgbench tool. Then run the following commands:

```
psql

SELECT sql_hash, 
       plan_hash, 
       status, 
       enabled, 
       sql_text 
FROM   apg_plan_mgmt.dba_plans;
```

![QMP](/images/4.1/7.png)

- Turn off automatic capture of query plans. Capturing all plans with automatic capture has little runtime overhead and can be enabled in production. We are turning off the automatic capture to make sure that we don’t capture SQL statements outside the pgbench workload. This can be turned off by setting the **apg_plan_mgmt.capture_plan_baselines** parameter to ``off`` from the DB parameter group.

![QMP](/images/4.1/8.png)

- Verify parameter settings using PSQL. As **apg_plan_mgmt.capture_plan_baselines** is a dynamic parameter, it doesn't need an instance reboot to take effect. It will take a 5-10 seconds for the parameter value to change.

```
show apg_plan_mgmt.capture_plan_baselines;
```

![QMP](/images/4.1/9.png)

- Let’s verify that the execution plan for one of the managed statements is same as the plan captured by QPM. Execute explain plan on one of the managed statements. The explain plan output shows that the SQL hash and the plan hash matches with the QPM approved plan for that statement.

```
explain (hashes true) UPDATE pgbench_tellers SET tbalance = tbalance + 100 WHERE tid = 200; 
# (hashes true): This is likely part of a specific testing or benchmarking framework and doesn't directly affect the UPDATE statement itself. It might indicate a particular flag or configuration within the framework.
```

![QMP](/images/4.1/10.png)

{{% notice note %}}
In addition to automatic plan capture, QPM has manual plan capture capability, which offers a mechanism to capture execution plans for known problematic queries. Capturing the plans automatically is recommended generally. However, there are situations where capturing plans manually would be the best option, such as:
- You don't want to enable plan management at the Database level, but you do want to control a few critical SQL statements only.
- You want to save the plan for a specific set of literals or parameter values that are causing a performance proble
{{% /notice %}}

#### QPM Plan adaptability with plan evolution mechanism

- If the optimizer's generated plan is not a stored plan, the optimizer captures and stores it as a new unapproved plan to preserve stability for the QPM-managed SQL statements. Query plan management provides techniques and functions to add, maintain, and improve execution plans and thus provides Plan adaptability. Users can instruct QPM on demand or periodically to evolve all the stored plans to see if there is a better minimum cost plan available than any of the approved plans.

- QPM provides **apg_plan_mgmt.evolve_plan_baselines** function to compare plans based on their actual performance. Depending on the outcome of your performance experiments, you can change a plan's status from **unapproved** to either **approved** or **rejected**. You can instead decide to use the **apg_plan_mgmt.evolve_plan_baselines** function to temporarily disable a plan if it does not meet your requirements. For additional details about the QPM Plan evolution, see [Evaluating Plan Performance](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Optimize.Maintenance.html#AuroraPostgreSQL.Optimize.Maintenance.EvaluatingPerformance) .

- For the first use case, we’ll walk through an example on how QPM helps ensure plan stability where various changes can result in plan regression.

- In most cases, you set up QPM to use automatic plan capture so that plans are captured for all statements that run two or more times. However, you can also capture plans for a specific set of statements that you specify manually. To do this, you set **apg_plan_mgmt.capture_plan_baselines = off** in the DB parameter group (which is the default) and **apg_plan_mgmt.capture_plan_baselines = manual** at the session level.

1. Enable manual plan capture to instruct QPM to capture the execution plan of the desired SQL statements manually.

```
SET apg_plan_mgmt.capture_plan_baselines = manual;
```

2. Run explain plan for a specific query so that QPM can capture the execution plan (the following output for the explain plan is truncated for brevity).

```
explain (analyze, summary, hashes)
SELECT Sum(delta),
               Sum(bbalance)
FROM   pgbench_history h,
              pgbench_branches b
WHERE  b.bid = h.bid
       AND b.bid IN ( 1, 2, 3 );

```

![QMP](/images/4.1/11.png)

3. Disable manual capture of new SQL statements with their plans after you capture the execution plan for the desired SQL statement.

{{% notice note %}}
QPM continues to capture new plans for managed SQL statements even after setting apg_plan_mgmt.capture_plan_baselines to off.
{{% /notice %}}

```
SET apg_plan_mgmt.capture_plan_baselines = off;
```

4. View captured query plan for the specific query that you ran previously. The plan_outline column in the table ``apg_plan_mgmt.dba_plans`` shows the entire plan for the SQL. For brevity, the plan_outline isn't shown here.

```
SELECT sql_hash,
                plan_hash,
               status,
               estimated_total_cost "cost",
               sql_text
FROM apg_plan_mgmt.dba_plans;
```

![QMP](/images/4.1/12.png)

5. To instruct the query optimizer to use the approved or preferred captured plans for your managed statements, set the parameter **apg_plan_mgmt.use_plan_baselines** to true.

```
SET apg_plan_mgmt.use_plan_baselines = true;
```

6. View the explain plan output to see that the QPM approved plan is used by the query optimizer.

```
explain (analyze, summary, hashes)
SELECT Sum(delta),
               Sum(bbalance)
FROM   pgbench_history h,
              pgbench_branches b
WHERE  b.bid = h.bid
       AND b.bid IN ( 1, 2, 3 ); 
```

![QMP](/images/4.1/13.png)

7. Create a new index on the pgbench_history table column bid to change the planner configuration and force the query optimizer to generate a new plan.

```
create index pgbench_hist_bid on pgbench_history(bid);
```

8. View the explain plan output to see that QPM detects a new plan but still uses the approved plan and maintains the plan stability. Note the line ***An Approved plan was used instead of the minimum cost plan***. in the explain plan output.

```
explain (analyze, summary, hashes)
SELECT Sum(delta),
               Sum(bbalance)
FROM   pgbench_history h,
              pgbench_branches b
WHERE  b.bid = h.bid
       AND b.bid IN ( 1, 2, 3 );

```

![QMP](/images/4.1/14.png)

9. Run the following SQL query to view the new plan and status of the plan. To ensure plan stability, QPM stores all the newly generated plans for a managed query in QPM as unapproved plans.

- The following output shows that there are two different execution plans stored for the same managed statement, as shown by the two different plan_hash values. Although the new execution plan has the minimum cost (lower than the approved plan), QPM continues to ignore the unapproved plans to maintain plan stability.

- The plan_outline column in the table ``apg_plan_mgmt.dba_plans`` shows the entire plan for the SQL. For brevity, the plan_outline is not shown here.

```
SELECT sql_hash,
                plan_hash,
               status,
               estimated_total_cost "cost",
               sql_text
FROM apg_plan_mgmt.dba_plans;
```

![QMP](/images/4.1/15.png)

- The following is an example of plan adaptability with QPM. This example evaluates the unapproved plan based on the minimum speedup factor. It approves any captured unapproved plan that is faster by at least 10 percent than the best approved plan for the statement. For additional details, see [Evaluating Plan Performance in the Aurora documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Optimize.Maintenance.html#AuroraPostgreSQL.Optimize.Maintenance.EvaluatingPerformance).

```
SELECT apg_plan_mgmt.Evolve_plan_baselines (sql_hash, plan_hash, 1.1,'approve')
FROM   apg_plan_mgmt.dba_plans
WHERE  status = 'Unapproved'; 

```

![QMP](/images/4.1/16.png)

- After QPM evaluates the plan based on the speed factor, the plan status changes from **unapproved** to **approved**. At this point, the optimizer can choose the newly approved lower cost plan for that managed statement.

```
SELECT sql_hash,
                plan_hash,
               status,
               estimated_total_cost "cost",
               sql_text
FROM apg_plan_mgmt.dba_plans;
```
![QMP](/images/4.1/17.png)

10. View the explain plan output to see whether the query is using the newly approved minimum cost plan.

```
explain (analyze, summary, hashes)
SELECT Sum(delta),
               Sum(bbalance)
FROM   pgbench_history h,
              pgbench_branches b
WHERE  b.bid = h.bid
       AND b.bid IN ( 1, 2, 3 );
```

![QMP](/images/4.1/18.png)