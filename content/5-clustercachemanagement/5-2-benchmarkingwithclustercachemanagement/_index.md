---
title : "Benchmarking with Cluster Cache management"
date :  "`r Sys.Date()`" 
weight : 2 
chapter : false
pre : " <b> 5.2. </b> "
---

#### Benchmarking with Cluster Cache management

To verify the benefits of Cluster cache management feature on the Aurora cluster we will be performing the following steps. We will explore these steps in more detail in corresponding sections below.

- With CCM enabled, we will run pgbench benchmark on the writer node.
- We'll check cached pages on both writer and reader nodes to verify that they are kept in sync.
- Then we'll Failover Aurora cluster.
- We'll run pgbench benchmark on new writer node after the failover and verify that the TPS numbers between old and new writer nodes are similar.
- Then we'll disable CCM.
- We'll clear buffer cache of both writer and reader nodes by stopping and starting the cluster.
- With CCM disabled, we'll run benchmark on writer node using pgbench again.
- We'll check cached pages on both writer and reader nodes to verify that they are not kept in sync.
- Next, we'll failover Aurora cluster one more time.
- We'll run pgbench benchmark on the new writer node after failover and verify that the TPS numbers between old and new writer nodes vary significantly.

1. Load large dataset for benchmarking
{{% notice note %}}
In order to reproduce the benchmarking used in the lab, we need to add more sample data to our benchmark. The below command is using scale factor of 10000. This optional step could take ~15-20 mins to add more data to the database, so make sure you have enough time to complete the lab before running the script below.
{{% /notice %}}

- Run the following command in your Cloud9 terminal window to connect to the writer node of the Aurora cluster using pgbench and add sample data with scale factor = 10000

  ```
  pgbench -i --fillfactor=100 --scale=10000

  ```

- Check aupglab database size using PSQL.

  ```
  psql
  SELECT pg_size_pretty( pg_database_size('aupglab'));
  ```

{{%expand "If you have used scale factor 100) in pgbench, you will see ourput similar to the following:" %}}![benchmark](/images/5/5.2/1.png)
{{% /expand%}}

{{%expand "If you ran pgbench with the scale factor 10000 in the previous step, you will see output similar to the following:" %}}![benchmark](/images/5/5.2/2.png)
{{% /expand%}}

### Benchmarking with CCM enabled
1. Run benchmark on writer node using pgbench (before failover)

- Initiate a 600 seconds pgbench benchmarking on the Aurora PostgreSQL writer node with CCM enabled using the below command on your Cloud9 terminal window.

  ```
  pgbench --progress-timestamp -M prepared -n -T 600 -P 5 -c 50 -j 50 -b tpcb-like@1 -b select-only@20 > ccm_enable_before_failover.out 
  ```

{{%expand "Explain command" %}}
**pgbench**: This is a benchmarking tool for PostgreSQL databases.\
**--progress-timestamp**: Prints a timestamp with each progress report.\
**-M prepared**: Uses prepared transactions for benchmarking.\
**-n**: Specifies a no-vacuum test, which avoids vacuuming during the benchmark.\
**-T 600**: Runs the benchmark for 600 seconds (10 minutes).\
**-P 5**: Populates the database with 5 client sessions before starting the benchmark.\
**-c 50**: Runs the benchmark with 50 concurrent client connections.\
**-j 50**: Specifies 50 threads for multi-threaded operation.\
**-b tpcb-like@1**: Uses the TPC-B-like transaction mix with a weight of 1.\
**-b select-only@20**: Uses a select-only transaction mix with a weight of 20.\
**ccm_enable_before_failover.out**: Redirects the output to a file named "ccm_enable_before_failover.out".
{{% /expand%}}

{{% notice info %}}
We are using pgbench  benchmarking option tpcb-like and using “@” to specify the probability of running read-only workload and read-write workload. In the below example, we are running tpcb-like workload with 20X read-only workload and 1x read-write workload for 600 seconds.
{{% /notice %}}

- After 600 seconds when benchmark is complete, you can verify the pgbench output on the screen or refer the output file “ccm_enable_before_failover.out”. The summary output will look like below. Please note that your output may look a little different.

  ```
  cat ccm_enable_before_failover.out
  ```

  ![benchmark](/images/5/5.2/3.png)

#### Check cached pages on both writer and reader nodes
- **Pg_buffercache** extension provides a means to look into the contents of the buffer cache. We will be leveraging the pg_buffercache view to examine the content of the buffer cache (with the CCM enabled and CCM disabled) to illustrate the effect of the CCM. We will compare the content of the buffer cache of the Writer node with the Reader node.

- With CCM enabled, the content of the buffer cache of the writer and the reader node will be similar because the writer node will periodically send buffer addresses of the frequently used buffers (defaults to usage count>3) to the reader node to be read from storage.

1. Connect to the Writer node with psql using the cluster endpoint of your cluster

- Create extension pg_buffercache on the Database.

  ```
  psql
  CREATE EXTENSION pg_buffercache;
  \dx pg_buffercache

  ```

  ![benchmark](/images/5/5.2/4.png)

- Verify that you are connected to the Writer node and query pg_buffercache to see number of cached pages for various tables.

  ```
  show transaction_read_only;
  ```

  ![benchmark](/images/5/5.2/5.png)

  ```
  SELECT c.relname, count(*) AS buffers
  FROM pg_buffercache b 
  INNER JOIN pg_class c
  ON b.relfilenode = pg_relation_filenode(c.oid) 
  AND b.reldatabase IN (0, (SELECT oid FROM pg_database WHERE datname = current_database()))
  GROUP BY c.relname
  ORDER BY 2 DESC
  LIMIT 10;
  ```

  ![benchmark](/images/5/5.2/6.png)

{{%expand "Explain scripts" %}}
|Command| Purposes|
|-------|--------|
|SELECT c.relname, count(*) AS buffers|Queries for the relation name (relname) and the number of buffers used (count(*)), labeling the count as "buffers".|
|FROM pg_buffercache b|Accesses data from the pg_buffercache system view, which holds details about buffered pages.|
|INNER JOIN pg_class c|Combines data from pg_buffercache with information about relations from the pg_class system catalog.|
|ON b.relfilenode = pg_relation_filenode(c.oid)|Links entries based on filenodes, associating buffers with their respective relations.|
|AND b.reldatabase IN (0, (SELECT oid FROM pg_database WHERE datname = current_database()))| Includes buffers for both shared system catalogs (database 0) and the current database.|
|GROUP BY c.relname|Aggregates results based on relation names.|
|ORDER BY 2 DESC|Sorts in descending order based on the number of buffers (count(*) in position 2)|
|LIMIT 10;|Restricts output to the top 10 relations.|
{{% /expand%}}

#### Connect to the Read replica
1. Open the Amazon RDS [console](https://console.aws.amazon.com/rds/home?#database:) .

2. In the navigation pane, choose Databases and click on the name of the Aurora cluster you created.

3. Under **Connectivity and Security** tab, copy the **Endpoint of type Reader**.

4. Replace <Aurora Reader EndPoint> below with the Aurora reader endpoint you copied above and using psql command line check if pg_buffercache extension is installed.

  ```
  psql -h <Aurora Reader EndPoint>
  \dx pg_buffercache
  ```
  ![benchmark](/images/5/5.2/7.png)

- Verify if you are connected to the Reader node and query pg_buffercache to see number of cached pages for various tables.

  ``` 
  show transaction_read_only;
  ```

  ![benchmark](/images/5/5.2/8.png)

  ```
  SELECT c.relname, count(*) AS buffers
    FROM pg_buffercache b INNER JOIN pg_class c
    ON b.relfilenode = pg_relation_filenode(c.oid) AND
    b.reldatabase IN (0, (SELECT oid FROM pg_database
    WHERE datname = current_database()))
    GROUP BY c.relname
    ORDER BY 2 DESC
    LIMIT 10;
  ```

  ![benchmark](/images/5/5.2/9.png)

*Notice that, after disabling CCM the buffer page count on the reader node is much less compared to the writer node for the frequently accessed tables.*
#### Failover Aurora cluster
- Now, we will initiate a failover of the Aurora cluster and after the failover is complete, we’ll run the same benchmark on the new writer node. For initiating failover go to the RDS console, select the writer instance of your Aurora cluster and click **Failover** in the **Actions** menu.

  ![benchmark](/images/5/5.2/10.png)

- Click **Failover** to confirm.

![benchmark](/images/5/5.2/11.png)

- Once the failover is complete (after about ~30 seconds), verify that the previous reader node becomes the new writer.

![benchmark](/images/5/5.2/12.png)

![benchmark](/images/5/5.2/13.png)


#### Run benchmark using pgbench on new writer node (after failover)

- Now we’ll run the same pgbench benchmark as we did earlier and we will compare the metrics observed before and after the failover.

```
pgbench --progress-timestamp -M prepared -n -T 600 -P 5  -c 50 -j 50 -b tpcb-like@1 -b select-only@20 > ccm_enable_after_failover.out

```

- After 600 seconds when benchmark is complete, you can verify the pgbench output on the screen or refer the output file “ccm_enable_after_failover.out”. The summary output will look like below. Please note that your output may look a little different.

```
cat ccm_enable_after_failover.out

```

![benchmark](/images/5/5.2/14.png)

*Notice that after disabling CCM, the tps numbers on the new writer node after failover is significantly less compared to the old writer node before the failover.*

### Benchmarking with CCM disabled
Now, we will disable CCM and perform similar tests as we did above with CCM enabled.

#### Disable CCM
Disable CCM on the Aurora PostgreSQL cluster by modifying the cluster parameter group and setting the value of **apg_ccm_enabled** parameter to 0.

1. Open the Amazon RDS console and select [Parameters groups](https://console.aws.amazon.com/rds/home?#parameter-groups:id=) .

2. In the list, choose the parameter group for your Aurora PostgreSQL DB cluster. ]

![benchmark](/images/5/5.2/14.png)

3. Click on the DB cluster parameter group selected above and then click on **Edit Parameters**.

![benchmark](/images/5/5.2/15.png)
4. Set the value of the ``apg_ccm_enabled`` cluster parameter to 0 and click on **Save changes**.

![benchmark](/images/5/5.2/16.png)

5. Verify Cluster Cache Management is disabled by querying the function aurora_ccm_status() as shown below:

```
psql
\x
select * from aurora_ccm_status();
```

![benchmark](/images/5/5.2/17.png)

#### Clear buffer cache of both writer and reader nodes
Since earlier testing with CCM already warmed the buffer cache of the reader and writer instances, we need to stop and start the Aurora cluster to empty the buffer caches before running the next benchmarking. We could also reboot both the reader and the writer instances, but this may not guarantee that the writer and reader will come up with empty buffer cache.

##### To stop the cluster
1. Verify that the cluster status is shown as “Available”, then click on the **Actions** menu and choose **Stop temporarily**.

![benchmark](/images/5/5.2/18.png)

2. Confirm the action by clicking **Stop temporarily** database.

![benchmark](/images/5/5.2/19.png)

*It will take several minutes and the cluster status will change from Stopping to Stopped.*

![benchmark](/images/5/5.2/20.png)

##### To start the cluster
1. Once the cluster status changes to ”Stopped”, click on the **Actions** menu again and choose **Start**.

![benchmark](/images/5/5.2/21.png)

*It will take several minutes and the cluster status will change from "Starting" to "Available".*

#### Run benchmark on writer node using pgbench (before failover)
1. Run benchmark using pgbench  on the Aurora cluster writer node like earlier.

```
pgbench --progress-timestamp -M prepared -n -T 600 -P 5 -c 50 -j 50 -b tpcb-like@1 -b select-only@20 > ccm_disable_before_failover.out

```

2. After 600 seconds when benchmark is complete, you can verify the pgbench output on the screen or refer the output file “ccm_disable_before_failover.out”. The summary output will look like below. Please note that your output may look a little different.

```
cat ccm_disable_before_failover.out
```

![benchmark](/images/5/5.2/22.png)


#### Check cached pages on both writer and reader nodes
1. Connect to the Writer node using the cluster endpoint of your cluster

```
psql
\dx pg_buffercache
```

![benchmark](/images/5/5.2/23.png)

2. Verify that you are connected to the Writer node and query **pg_buffercache** to see number of cached pages for various tables.

```
show transaction_read_only;

```

![benchmark](/images/5/5.2/24.png)


```
SELECT c.relname, count(*) AS buffers
 FROM pg_buffercache b INNER JOIN pg_class c
 ON b.relfilenode = pg_relation_filenode(c.oid) AND
 b.reldatabase IN (0, (SELECT oid FROM pg_database
 WHERE datname = current_database()))
 GROUP BY c.relname
 ORDER BY 2 DESC
 LIMIT 10;

```

![benchmark](/images/5/5.2/25.png)


#### Connect to the read replica
1. Connect to the reader instance using the Reader Endpoint of the Aurora PostgreSQL Cluster. Replace <Aurora Reader EndPoint> below with your Aurora reader endpoint by referring the step Connect to the Read replica.

```
psql -h  <Aurora Reader EndPoint>
\dx pg_buffercache

```

![benchmark](/images/5/5.2/26.png)

2. Verify that you are connected to the Reader node and query **pg_buffercache** to see number of cached pages for various tables.

```
show transaction_read_only;

```

![benchmark](/images/5/5.2/27.png)


```
SELECT c.relname, count(*) AS buffers
 FROM pg_buffercache b INNER JOIN pg_class c
 ON b.relfilenode = pg_relation_filenode(c.oid) AND
 b.reldatabase IN (0, (SELECT oid FROM pg_database
 WHERE datname = current_database()))
 GROUP BY c.relname
 ORDER BY 2 DESC
 LIMIT 10;

```

![benchmark](/images/5/5.2/28.png)


*Notice that, after disabling CCM the buffer page count on the reader node is much less compared to the writer node for the frequently accessed tables.*

#### Failover Aurora cluster
1. Now, we will initiate a failover of the Aurora cluster and after the failover is complete, we’ll run the same benchmark on the new writer node.

![benchmark](/images/5/5.2/29.png)

2. Confirm the action by clicking **Failover**.

*Once the failover is complete (after about ~30 seconds), verify that the previous reader node becomes the new writer.*

![benchmark](/images/5/5.2/30.png)

#### Run benchmark using pgbench on new writer node (after failover)
1. Now, we’ll run the same benchmarking as we did earlier and we will compare the pgbench metrics observed before and after the failover.

```
pgbench --progress-timestamp -M prepared -n -T 600 -P 5 -c 50 -j 50 -b tpcb-like@1 -b select-only@20 > ccm_disable_after_failover.out

```

After 600 seconds when benchmark is complete, you can verify the pgbench output on the screen or refer the output file “ccm_disable_after_failover.out”. The summary output will look like below. Please note that your output may look a little different.

```
cat ccm_disable_after_failover.out

```

![benchmark](/images/5/5.2/31.png)

*Notice that after disabling CCM, the tps numbers on the new writer node after failover is significantly less compared to the old writer node before the failover.*