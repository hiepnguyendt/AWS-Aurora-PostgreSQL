---
title : "Setup cluster cache management"
date :  "`r Sys.Date()`" 
weight : 1 
chapter : false
pre : " <b> 5.1. </b> "
---

#### Configuring Cluster Cache Management (CCM)

Following are the steps to configure and enable the use of CCM on your Aurora PostgreSQL cluster

1. Modify the Amazon Aurora DB Cluster Parameters related to CCM.

- Sign in to the AWS Management Console and select [Parameter Groups](https://console.aws.amazon.com/rds/home?#parameter-group-list:)  on the Amazon RDS console.

- In the list, choose the DB cluster parameter group for your Aurora PostgreSQL DB cluster. The DB cluster must use a parameter group other than the default, because you can't change values in a default parameter group. For more information, see [Creating a DB Cluster Parameter Group](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_WorkingWithParamGroups.html#USER_WorkingWithParamGroups.CreatingCluster).
- Click **Edit** under the **Actions** menu.
- Set the value of the ``apg_ccm_enabled`` cluster parameter to 1 and click on **Save Changes**.

    ![CCM](/images/5/5.1/1.png)

2. For cluster cache management, make sure that the promotion priority is **tier-0** for the writer DB instance of the Aurora PostgreSQL DB cluster. The promotion tier priority is a value that specifies the order in which an Aurora reader is promoted to the writer DB instance after a failure. Valid values are 0–15, where 0 is the first priority and 15 is the last priority.

- Select [Databases](https://console.aws.amazon.com/rds/home?#databases:)  in the Amazon RDS console.

- Choose the Writer DB instance of the Aurora PostgreSQL DB cluster and click on *Modify*

    ![CCM](/images/5/5.1/2.png)

- The Modify DB Instance page appears. Under **Additional configuration**, choose **tier-0** for Failover Priority.

    ![CCM](/images/5/5.1/3.png)

- Choose **Continue** and check the summary of modifications.
- To apply the changes immediately after you save them, choose **Apply immediately** and click **Modify DB Instance** to save your changes. For more information about setting the promotion tier, see [Modify a DB Instance in a DB Cluster and the Promotion tier setting](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Modifying.html#Aurora.Modifying.Instance) . See also [Fault Tolerance for an Aurora DB Cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Backups.html#Aurora.Managing.FaultTolerance).

    ![CCM](/images/5/5.1/4.png)

3. Next, set one reader DB instance for cluster cache management. To do so, choose a reader from the Aurora PostgreSQL cluster that is the same instance class and size as the writer DB instance. For example, if the writer uses db.r5.xlarge, choose a reader that uses this same instance class type and size. Then set its promotion tier priority to **0**. The promotion tier priority is a value that specifies the order in which an Aurora replica is promoted to the primary DB instance after a failure. Valid values are 0 to 15, where 0 is the highest and 15 the lowest priority.

- In the navigation pane, choose **Databases**.
- Choose the Reader DB instance of the Aurora PostgreSQL DB cluster and click on **Modify**

    ![CCM](/images/5/5.1/5.png)

- The Modify DB Instance page appears. Under **Additional configuration**, choose tier-0 for **Failover Priority**.
- Choose **Continue** and check the summary of modifications.
- To apply the changes immediately after you save them, choose **Apply immediately** and click **Modify DB Instance** to save your changes.

    ![CCM](/images/5/5.1/6.png)
    ![CCM](/images/5/5.1/7.png)

#### Verifying if CCM is enabled

- Click on the DB identifier with the cluster name you created as a part of the CloudFormation stack or manually.

- Under **Connectivity and Security** section, you will notice 2 different endpoints. The one with type **Writer** is the cluster endpoint (for read-write connections) and the one with type **Reader** is the reader endpoint (for read-only connections).

    ![CCM](/images/5/5.1/8.png)

- Open a cloud9 terminal window by referring Open Cloud9 Terminal Window section and using psql command line connect to the Aurora PostgreSQL DB cluster writer end point. Run the following SQL commands to check the cluster cache management status:

    ```
    psql 
    \x
    select * from aurora_ccm_status();

    ```

    ![CCM](/images/5/5.1/9.png)

{{% notice note %}}
If the Cluster Cache management is not enabled, querying aurora_ccm_status() will display the below output:
**aupglab=> \x \
Expanded display is on.\
mylab=> select * from aurora_ccm_status();\
ERROR:  Cluster Cache Manager is disabled**
{{% /notice %}}

