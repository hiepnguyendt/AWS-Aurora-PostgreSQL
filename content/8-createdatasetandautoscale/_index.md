---
title : "Create dataset and Auto Scale"
date :  "`r Sys.Date()`" 
weight : 8 
chapter : false
pre : " <b> 8. </b> "
---

**Aurora Auto Scaling** enables your Aurora DB cluster to handle sudden increases in connectivity or workload by dynamically adjusting the number of Aurora Replicas for a provisioned Aurora DB cluster. When the connectivity or workload decreases, Aurora Auto Scaling removes unnecessary Aurora Replicas so that you don't pay for unused DB instances.

In this lab, we will walk through how Aurora read replica auto scaling works in practice using a load generator script.

This lab contains the following tasks:

- Configure aurora replica auto scaling
- Initialize pgbench and Create a Dataset
- Run a read-only workload

1. Create a replica auto scaling policy
- You will add a read replica auto scaling configuration to the DB cluster. This will allow the DB cluster to scale the number of reader DB instances that operate in the DB cluster at any given point in time based on the load.

- Click on the Aurora cluster name and go to **Logs & events** tab. Click on the **Add auto scaling** policy button.

    ![ACL](/images/8/1.png)

- Enter ``auroralab-autoscale-readers`` as the **Policy Name**. For the **Target metric** choose **Average CPU utilization of Aurora Replicas**. Enter a **Target value of 20%**. In a production use case this value may need to be set much higher, but we are using a lower value for demonstration purposes.

- Next, expand the **Additional configuration** section, and change both the **Scale in cooldown period** and **Scale out cooldown period** to a value of **180 seconds**. This will reduce the time you have to wait between scaling operations in subsequent labs.
    ![ACL](/images/8/2.png)

- In the **Cluster capacity details** section, set the **Minimum capacity** to **1** and **Maximum capacity** to **2**. In a production use case you may need to use different values, but for demonstration purposes, and to limit the cost associated with the labs we limit the number of readers to two.
    ![ACL](/images/8/3.png)

- Next click **Add policy**.


2. Initialize pgbench and Create a Dataset
- Open a Cloud9 terminal window by referring [Open Cloud9 Terminal Window](https://catalog.us-east-1.prod.workshops.aws/workshops/098605dc-8eee-4e84-85e9-c5c6c9e43de2/en-US/lab1-5-client/cloud9-terminal/) section and initialize pgbench to start the creation of dataset by pasting the command below in your terminal window.

    ```
    pgbench -i --scale=1000

    ```

     Data loading may take several minutes, you will receive similar output once complete:
    ![ACL](/images/8/4.png)

3. Run a read-only workload
- Once the data load completes successfully, you can run a read-only workload on the cluster (so that we can trigger our auto scaling policy). You will also observe the effects on the DB cluster topology.

- For this step you will use the **Reader Endpoint** of the cluster. You can find the reader endpoint by going to the [RDS Console - Databases](https://console.aws.amazon.com/rds/home?#databases:) section  , clicking the name of the Aurora cluster and going to the **Connectivity & security** tab.

- Run the load generation script from your Cloud9 terminal window, replacing the 
[readerEndpoint] placeholder with the actual Aurora cluster reader endpoint:

    ```
    pgbench -h [readerEndpoint] -c 100 --select-only -T 600 -C

    ```

- Now, open the Amazon RDS management [console](https://console.aws.amazon.com/rds/home?#databases:)  in a different browser tab.

- Take note that the reader node is currently receiving load. It may take a minute or more for the metrics to fully reflect the incoming load.

- After several minutes return to the list of instances and notice that a new reader is being provisioned in your cluster.
    ![ACL](/images/8/5.png)

- It will take 5-7 minutes to add a new replica. Once the new replica becomes available, note that the load distributes and stabilizes (it may take a few minutes to stabilize).
    ![ACL](/images/8/6.png)

- You can now toggle back to your Cloud9 terminal window, and press CTRL+C to quit the running pgbench job. After a while the additional reader will be removed automatically.

