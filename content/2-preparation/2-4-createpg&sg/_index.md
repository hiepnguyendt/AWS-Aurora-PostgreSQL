---
title : "Create Subnet Group and Parameter Group"
date :  "`r Sys.Date()`" 
weight : 4
chapter : false
pre : " <b> 2.4. </b> "
---


#### To create a DB subnet group on AWS, follow these steps:

1. Open the Amazon RDS [console](https://console.aws.amazon.com/rds/)
2. In the navigation pane, choose **Subnet groups** and click on **Create DB Subnet Group**.
    ![Create SG](/images/1/1.1/1.1.png)

3. For **Name** and **Description**, type in a name and description for your DB subnet group.
4. For **VPC**, select the VPC in which you want to create your DB subnet group.
    ![Create SG](/images/1/1.1/1.2.png)

5. Select the subnets that you want to include in your DB subnet group. Make sure to select subnets in at least two different Availability Zones (AZs).
    ![Create SG](/images/1/1.1/1.3.png)

6. Click **Create**.

Your DB subnet group will be created and will be displayed in the list of DB subnet groups.

**Here are some additional things to keep in mind when creating a DB subnet group:**
- You can only create a DB subnet group in a VPC that is in the same AWS Region as the database engine that you plan to use.
- You must include at least one subnet in each AZ in which you want to deploy your DB instance.
- You cannot modify a DB subnet group once it has been created. If you need to change the subnets in your DB subnet group, you must create a new one.
- You can use a DB subnet group to create a DB instance in any AZ in the VPC. 




#### To create a Database Parameter Group 
1. Go to the [AWS RDS console](https://us-east-1.console.aws.amazon.com/rds/home?region=us-east-1), select **Parameter Group**, choose **Create parameter group**.
    ![Create PG](/images/1/1.1/00.png)

2. In the **Parameter group details** section
- For **Parameter group family**, select **aurora-postgresql15**
- For **Type**, select **DB Parameter Group**
- For **Group Name**, type your parameter group name
- For **Description**, type your description
    ![Create PG](/images/1/1.1/0.3.png)
- Click **Create**

3. Change and enable some configurations in the parameter group
- Go to Parameter Group console, click **Action**, choose **Edit**
    ![Create PG](/images/1/1.1/000.png)

- Fill ``shared_preload_libraries`` parameter in the search bar, then select **shared_preload_libraries**
    ![Create PG](/images/1/1.1/0.4.png)
- Click **Save Changes**

**About shared_preload_libraries parameter**
{{%expand "The shared_preload_libraries parameter plays a crucial role in configuring your Aurora PostgreSQL instance. " %}}
**Purpose:**

This parameter specifies which shared libraries are preloaded when your Aurora PostgreSQL server starts. Preloading libraries reduces the overhead of loading them on-demand when needed, potentially improving performance for specific functionalities.

**What libraries are preloaded?**

**Built-in libraries**: Certain core PostgreSQL functionalities rely on shared libraries that are automatically preloaded by default. You don't need to configure them in shared_preload_libraries.
**Custom libraries**: You can specify additional shared libraries to be preloaded for specific needs. These could be:
**PostgreSQL extensions**: For features like full-text search or geospatial data handling.
**Custom modules**: Developed by you or third-party vendors for unique functionalities.
Important Notes:

**Performance impact**: Preloading unnecessary libraries can consume memory and negatively affect startup times. Only preload libraries actively used by your applications.
**Security considerations**: Be cautious when adding custom libraries due to potential security vulnerabilities. Ensure they are from trusted sources and vetted carefully.
**Restart requirement**: Modifying shared_preload_libraries requires restarting your Aurora PostgreSQL instance for the changes to take effect.{{% /expand%}}


#### To create a Database Cluster Parameter Group 
1. Go to the [AWS RDS console](https://us-east-1.console.aws.amazon.com/rds/home?region=us-east-1), select **Parameter Group**, choose **Create parameter group**.
    ![Create PG](/images/1/1.1/00.png)

2. In the **Parameter group details** section
- For **Parameter group family**, select **aurora-postgresql15**
- For **Type**, select **DB Cluster Parameter Group**
- For **Group Name**, type your parameter group name
- For **Description**, type your description
    ![Create PG](/images/1/1.1/0.png)
- Click **Create**
3. Change and enable some configurations in the parameter group
- Go to Parameter Group console, click **Action**, choose **Edit**
    ![Create PG](/images/1/1.1/0001.png)

- Fill ``log_rotation`` parameter in the search bar, 
- Edit **log_rotation_age** value: ``1440``
- Edit **log_rotation_size** value: ``102400``

    ![Create PG](/images/1/1.1/0.2.png)
- Click **Save Changes**

**About log_rotation_age & log_rotation_size parameter**

{{%expand "log_rotation_age" %}}
**Function**:

log_rotation_age defines the maximum age in minutes for individual log files within the cluster. Once a file reaches this age, it's automatically rotated and a new one is created. This parameter helps manage disk space by preventing log files from growing indefinitely.

**Configuration**:

Unlike a standalone instance where you can set log_rotation_age in the postgresql.conf file or via command line, this parameter needs to be configured through a custom Aurora PostgreSQL parameter group. You can set the desired value within the parameter group and apply it to your cluster.

**Impact**:

Setting a shorter log_rotation_age value results in more frequent rotations and fresher log files, but can also increase disk I/O activity and potentially impact performance. A longer age reduces file rotations but retains older logs, which might not be necessary for your needs.

**Important Notes**:

RDS log rotation feature: While the RDS console lists log_rotation_age as a configurable parameter for its built-in log rotation feature, it currently has no effect on Aurora PostgreSQL clusters. You still need to use a custom parameter group to control file age rotation.
CloudWatch Logs integration: Aurora PostgreSQL automatically streams logs to CloudWatch Logs by default. You can configure age-based retention policies within CloudWatch to manage the overall lifespan of log data, regardless of file rotations.

**Recommendations**:

- Choose a log_rotation_age value that balances the need for disk space management with keeping sufficient log history for troubleshooting and analysis.
- Consider monitoring your cluster performance and adjusting the parameter value if necessary.
- Utilize CloudWatch Logs for long-term log retention and analysis beyond the file rotations managed by log_rotation_age.

{{% /expand%}}

{{%expand "log_rotation_size" %}}
**Function**:

log_rotation_size specifies the maximum size (in kilobytes) for an individual log file before it's automatically rotated and a new one is created. This helps prevent excessive log growth and keeps the log directory manageable.

**Configuration**:

Similar to log_rotation_age, you need to configure this parameter through a custom Aurora PostgreSQL parameter group. Set the desired size in kilobytes within the parameter group and apply it to your cluster.

**Impact**:

Choosing a smaller log_rotation_size value will trigger more frequent rotations, meaning smaller and fresher log files. However, this can increase disk I/O activity and impact performance slightly. Conversely, a larger size leads to fewer rotations and potentially larger logs, but may consume more disk space.

**Important Notes**:

- Automatic file naming: As files are rotated, Aurora PostgreSQL adds timestamps or sequence numbers to their filenames to maintain historical context.
- RDS log rotation feature: Similar to log_rotation_age, the RDS log rotation feature doesn't currently control size-based rotation in Aurora PostgreSQL clusters. The custom parameter group approach is necessary.
- CloudWatch Logs integration: You can use CloudWatch Logs with its size-based retention policies to archive or delete rotated log files after exceeding a specific size.

**Recommendations**:

- Select a log_rotation_size value that balances disk space management with your log analysis needs. Consider the volume and size of your typical logs to estimate appropriate rotation intervals.
- Monitor your cluster performance and adjust the parameter value if necessary to avoid excessive rotations or large log files.
- Leverage CloudWatch Logs for long-term log retention and management, independent of rotations controlled by log_rotation_size.
- Remember, optimizing both log_rotation_age and log_rotation_size allows you to effectively manage your Aurora PostgreSQL cluster's log files, ensuring sufficient data for analysis while limiting disk usage and potential performance impacts.

{{% /expand%}}


