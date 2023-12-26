---
title : "Configure the database client"
date :  "`r Sys.Date()`" 
weight : 1 
chapter : false
pre : " <b> 4.1. </b> "
---

 After Amazon RDS provisions your DB instance, you can use any standard SQL client application to connect to the instance. Before you can connect, the DB instance must be available and accessible. Whether you can connect to the instance from outside the VPC depends on how you created the Amazon RDS DB instance:
 - If you created your DB instance as **public**, **devices and Amazon EC2 instances outside** the VPC can connect to your database.
 - If you created your DB instance as **private**, **only Amazon EC2 instances and devices inside** the Amazon VPC can connect to your database.

 {{% notice note%}}---
title : "Setup KMS for Database Activity Streaming"
date :  "`r Sys.Date()`" 
weight : 1 
chapter : false
pre : " <b> 6.1. </b> "
---

**Database Activity Streaming** requires a Master Key to encrypt the key that in turn encrypts the logged database activity. The Default AWS RDS KMS key can’t be used as the Master key. Therefore, we need to create a new customer managed KMS key to configure the Database Activity Streaming.

#### Create KMS Key
1. Open [KMS console](https://console.aws.amazon.com/kms/home)  and select **Customer Managed Keys** on the left-hand side and click on **Create Key**:
2. On the next screen under Configure key choose **Symmetric** key type and click **Next**:

![DAS](/images/6/6.1/1.png)

3. On the next screen, under **Add Labels** give a name for the key under the field **Alias** such as ``cmk-apg-lab``.

- Under Description field, type a description for the key such as ``Customer managed Key for Aurora PostgreSQL Database Activity Streaming (DAS) lab`` and click Next.

![DAS](/images/6/6.1/2.png)

4. On the next screen under **Define Key Administrative permissions** and  **Define key usage permissions**, leave with default setting.

5. On the next screen, review the policy and click **Finish**.

![DAS](/images/6/6.1/3.png)

6. Verify the newly created KMS key on the KMS dashboard.

![DAS](/images/6/6.1/4.png)
 In this chapter, we will use **pgAdmin4** to connect to a RDS for PostgreSQL DB instance, so we need create DB as public.\
 You can use the open-source tool **pgAdmin4** to connect to your RDS for PostgreSQL DB instance. You can download and install pgAdmin from http://www.pgadmin.org/ without having a local instance of PostgreSQL on your client computer
 {{% /notice %}}


 1.Launch the **pgAdmin4** application on your client computer.\
 2.On the **Dashboard** tab, choose **Add New Server.**
 ![connecting](/images/4/4-1/14.png)
 3.In the **Create - Server** dialog box, type a name on the **General** tab to identify the server in pgAdmin4. 
 ![connecting](/images/4/4-1/1.png)
 
 4.In the **Connection** tab, type the following information from your DB instance:
 - For **Host**, type the endpoint you have retrieve in the [step 3.2](3-2-retrievebdinstancendpoint/), for example mypostgresql.c6c8dntfzzhgv0.us-east-2.rds.amazonaws.com.
 - For **Port**, type the assigned port.
 - For **Username**, type the user name that you entered when you created the DB instance. 
 - For **Password**, type the password that you entered when you created the DB instance.

 ![connecting](/images/4/4-1/2.png)
 
 5.Choose **Save**.
 ![connecting](/images/4/4-1/6.png)

 {{% notice tip%}}
 If you have any problems connecting, see [Troubleshooting connections to your RDS for PostgreSQL instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToPostgreSQLInstance.html#USER_ConnectToPostgreSQLInstance.Troubleshooting).
 {{% /notice %}}