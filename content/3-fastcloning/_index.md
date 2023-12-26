---
title : "Fast Cloning"
date :  "`r Sys.Date()`" 
weight : 3 
chapter : false
pre : " <b> 3. </b> "
---

**What's the Fast Cloning ?**
{{%expand "The Fast Cloning" %}}

**Fast cloning** refers to a feature that allows you to quickly and efficiently create an exact copy of your database. This clone shares the same underlying storage with the original database initially, making the process much faster and more cost-effective than traditional methods like full database backups or restoring snapshots.

***Here are some key points about fast cloning for Aurora PostgreSQL:***

**Speed**: Unlike traditional methods, which can take hours or even days for large databases, fast cloning can create a clone in a matter of minutes, even for multi-terabyte databases.

**Efficiency**: The clone initially shares the storage with the source database, meaning no physical data needs to be copied. This saves disk space and reduces storage costs.

**Copy-on-write**: When changes are made to either the source database or the clone, new data pages are created instead of modifying existing ones. This ensures data consistency and minimizes impact on both databases.

**Multiple uses**: Fast cloning is useful for various scenarios, including application development and testing, database updates, blue/green deployments, and running analytical queries without impacting production.
Here are some resources where you can learn more about fast cloning for Aurora PostgreSQL:
******

Amazon Aurora [documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Clone.html)
Amazon Aurora PostgreSQL blue/green deployment using [fast database cloning](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/blue-green-deployments-overview.html)
Amazon Aurora [Fast Database Cloning](https://aws.amazon.com/blogs/aws/amazon-aurora-fast-database-cloning/)
{{% /expand%}}

In this lab, we will walk through the process of creating an Aurora fast clone. We will observe the divergence of data and compare the performance between the original and cloned Aurora clusters.

#### Setting up the Fast Clone divergence test

Lets review the tables we have created in the **Create, Configure Cloud9 and Initialize Database** step, which will be used in this lab.

| Resoures name | Value|
|---------------|------|
|cloneeventtest	|Table to store the counter and the timestamp|
|statusflag	    |Table to store the status flag which controls the start/stop counter|
|eventerrormsg	|Table to store error messages|
|cloneeventproc	|Function to add data to the cloneeventtest table based on the start counter flag|

#### Creating and verifying performance impact of the Fast Clone

1. Running the pgbench workload on the primary cluster

    Before creating a Fast Clone of the primary cluster, we are going to start pgbench test to measure the Transaction per seconds (TPS) metrics on the primary cluster. Open a Cloud9 terminal window (terminal #1) by referring Open Cloud9 Terminal Window section and run the following command. This will run for 30 minutes.

    ```
    pgbench --progress-timestamp -M prepared -n -T 1800 -P 60 -c 8 -j 8 -b tpcb-like@1 -b select-only@20 > Primary_results.log

    ```

2. Verify the environment and run the sample divergence test


- In order to verify the data divergence on the primary and the clone cluster, we will be adding sample data using sample tables.
- We need to open one more Cloud9 terminal window (terminal #2) to connect to Aurora and run the function. To open one more terminal window on your Cloud9 environment, click on **Window** menu and select **new Terminal**.
- Run the following commands to verify the **delflag** column is set to 0 in the **statusflag** table and there is no data in the table **cloneeventtest**. Execute the function **cloneeventproc()** to start adding sample data.

    ```
    psql
    select * from statusflag;
    select * from cloneeventtest;
    select cloneeventproc();

    ```

    ![FC](/images/3.1/2.png)

    At this time (we call as time “T1”), the pgbench workload is running on the source DB cluster and also, we are adding sample data to the table on the primary cluster every 10 seconds.

3. Stop the sample data generation

- First, at T1+5 minutes we will stop the function execution by manually resetting the delflag column on the table statusflag to 1. Open one more Cloud9 terminal window to connect to Aurora (terminal #3). The pgbench workload will continue to execute on the primary source cluster in terminal #1.


    ```
    psql
    update statusflag set delflag='Y';

    ```

- Go back to terminal #2 where we ran cloneeventproc function. Wait for ~60sec until you see the function complete its execution:

    ```
    select cloneeventproc();

    ```

    ![FC](/images/3.1/3.png)

- Let’s check the number of rows in the table cloneeventtest. We should see 5 or more rows in the table:

    ```
    select count(*) from cloneeventtest;

    ```

    ![FC](/images/3.1/4.png)

- Let's set proper timezone and check rows in cloneeventtest table:

    ```
    SET timezone = 'Asia/Ho_Chi_Minh';
    select * from cloneeventtest;

    ```

    ![FC](/images/3.1/5.png)


4. Create Fast Clone Cluster

- Once the function execution is stopped (after time T1+5 minutes) we will start creating the Fast Clone of the primary cluster. The pgbench workload on the primary will continue on the primary cluster in terminal#1.

- Now, we will walk you through the process of [cloning a DB cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Clone.html). Cloning creates a separate, independent DB cluster, with a consistent copy of your data set as of the time you cloned it. Database cloning uses a copy-on-write protocol, in which data is copied at the time that data changes, either on the source databases or the clone databases. The two clusters are isolated, and there is no performance impact on the source DB cluster from database operations on the clone, or the other way around.

- Following are the steps to configure the Database Fast clone on your Aurora PostgreSQL cluster:

a. Sign in to the AWS Management Console and open the [Amazon RDS console](https://console.aws.amazon.com/rds/home?#databases:) .

b. In the navigation pane, choose Databases and select DB identifier with the cluster name you created as a part of the CloudFormation stack. Click the **Actions** menu at the top and select **Create clone**.

    ![FC](/images/3/9.png)

c. Enter ``aupglabs-clone`` as **DB Instance Identifier** and Capacity type **Provisioned**.

- For **Cluster storage configuration** select **Aurora Standard**.

- In **Instance configuration** select **Memory optimized classes** and **db.r6g.large**.

    ![FC](/images/3/10.png)

    ![FC](/images/3/11.png)

    ![FC](/images/3/12.png)


- In the **Connectivity** section, leave with default setting

- In **Additional Configuration**, pick the **DB cluster parameter group** and **DB parameter groups created** in DB cluster parameter group and DB parameter group drop down menus.

    ![FC](/images/3/14.png)

- Enable auto minor version upgrade.

- Leave rest of the input fields at their default value and click Create clone.

    ![FC](/images/3/15.png)

    ![FC](/images/3/16.png)

- Once you click on the “Create Clone” the status column will show status as “Creating”.

    ![FC](/images/3/17.png)

- The clone cluster should be ready after about 10-15 minutes or so. The status column will show as “Available” once the cloned cluster is ready.

    ![FC](/images/3/18.png)


5. Start the sample data divergence process on the primary cluster

- Once the Clone cluster creation process is kicked off, we will start the sample data generation process on the primary cluster. Any sample data added from this point onwards should only be available on the primary cluster and not on the clone cluster.

    ```
    psql 
    truncate cloneeventtest; # This will empty the cloneeventtest table, removing all existing rows.Make sure you want to do this as it's an irreversible operation.
    update statusflag set delflag=0; 
    select count(*) from cloneeventtest;
    select cloneeventproc();

    ```

    ![FC](/images/3.1/6.png)

6. Verify the data divergence on the Clone Cluster

- Clone cluster should be ready after about 15 minutes or so (time T1+~10-15 minutes).
- The table “cloneeventtest” on the cloned cluster should have the snapshot of data as it existed on the primary cluster at ~T1+5, because that is when we started creating the clone.

- Copy the Writer Endpoint for your cloned aurora cluster by clicking the cluster name and going to the **Connectivity & security** tab.

    ![FC](/images/3/20.png)

- Connect to Aurora cloned cluster from session#3 window. Replace <Cloned Cluster Writer Endpoint> below with the Writer endpoint for your Cloned Aurora cluster you copied above.

    ```
    psql -h <Cloned Cluster Writer Endpoint>

    ```

    ![FC](/images/3.1/7.png)


- And run the sql commands to check the content of the data:

    ```
    select count(*) from cloneeventtest;
    SET timezone = 'Asia/Ho_Chi_Minh';
    select * from cloneeventtest;

    ```

    ![FC](/images/3.1/8.png)

-  Stop the function run on Primary aurora cluster that is currently running (follow step **Stop the sample data generation** ) and select data from cloneeventtest table. We will see more rows, as expected.

7. Run the pgbench workload on the Clone Cluster

- We are going to start a similar pgbench workload on the newly created clone cluster as we did on the primary cluster earlier in step#1. Replace <Cloned Cluster Endpoint> below with the Writer endpoint for your Cloned Aurora cluster.

    ```
    pgbench --progress-timestamp -M prepared -n -T 1800 -P 60 -c 8 -j 8 --host=<Cloned Cluster Writer Endpoint> -b tpcb-like@1 -b select-only@20 > Clone_results.log

    ```

8. Verify the pgbench metrics on the primary and the clone cluster.

- Once the pgbench workload completes on both the primary and the clone cluster, we can verify the TPS metrics from both the clusters by looking at the output file.

    ![FC](/images/3.1/9.png)

    ![FC](/images/3.1/10.png)