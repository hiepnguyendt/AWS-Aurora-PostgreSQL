---
title : "Create Aurora PostgreSQL Database"
date :  "`r Sys.Date()`" 
weight : 5
chapter : false
pre : " <b> 2.5. </b> "
---


#### To create an Aurora PostgreSQL DB, follow these steps:

1. Open the **Amazon RDS** [console](https://console.aws.amazon.com/rds/).

![Create Aupg](/images/1/1.1/1.png)

2. Click **Create database**.
3. For **Database engine**, select **PostgreSQL**.
4. For **Version**, select the version of PostgreSQL that you want to use.

![Create Aupg](/images/1/1.1/2.png)

5. For **Template**, select a template for your DB instance. A template is a pre-configured configuration for a DB instance.

![Create Aupg](/images/1/1.1/3.png)

6. For **Availability** and **Durability**, For DB instance identifier, enter a name for your DB instance.

![Create Aupg](/images/1/1.1/7.png)

7. For **DB instance identifier**, enter a unique name for your database instance.
8. For **Master username**, enter the username for the master user of your database instance.
9. For **Master password**, enter a strong password for the master user of your database instance.

![Create Aupg](/images/1/1.1/4.png)

10. For **Cluster storage configuration**, select the amount of storage that you want to allocate for your database instance.

![Create Aupg](/images/1/1.1/5.png)

11. For **Instance configuration**, select the DB instance class that you want to use for your database instance. The instance class will determine the amount of CPU and memory that is allocated to your database instance.

![Create Aupg](/images/1/1.1/6.png)


12. For **Connectivity**, 
- Leave the **Compute resource** and **Network type** options at their Default values.
- Make sure the cluster Publicly accessible option is set to No.
- Leave Create an RDS Proxy option unchecked.
![Create Aupg](/images/1/1.1/8.png)

13. For **DB subnet group**, select the DB subnet group that you want to use for your DB instance.
14. For **VPC security groups**, select the security groups that you want to use for your DB instance.

![Create Aupg](/images/1/1.1/9.png)

15. Expand **Additional configuration**, Enter **5432** for **database port**
16. Leave the **Babelfish settings** and **Database authentication** options at their default values.

![Create Aupg](/images/1/1.1/10.png)

17. For **Monitoring**, 
- Check the box to Turn on Performance Insights with a Retention period for Performance Insights of 7 days (free tier) and use the (default) aws/rds AWS KMS key for monitoring data encryption.

![Create Aupg](/images/1/1.1/11.png)
- Next, expand the **Additional configuration - Enhanced Monitoring** section and check the Enable Enhanced Monitoring box, and select a Granularity of 1 second.

![Create Aupg](/images/1/1.1/12.png)
18. Expand **Additional configuration**:
- Set the Initial database name to ``aupglab``.
- Select the DB cluster parameter group with name **aupg-parametergroup** . 
- For DB parameter group selectors, choose **aupg-pg**
- Choose a 7 days Backup retention period.
- Check the box to Enable encryption and select the (default) aws/rds for the Master key.
- For Log exports check the PostgreSQL log box.
- Leave the Maintenance options at their default values.
![Create Aupg](/images/1/1.1/13.png)

![Create Aupg](/images/1/1.1/14.png)


19. Click **Create database**.


***It will take 5-10 minutes to create the Aurora cluster with a writer and a reader node.***

{{%expand "Show me summary of configuration options selected" %}}
- Aurora PostgreSQL 15.3 compatible cluster on a db.r6g.large DB instance class
- Cluster composed of a writer and a reader DB instance in different availability zones (highly available)
- Uses Aurora Standard storage configuration in which I/Os are charged on a pay-per-request basis
- Deployed in the VPC in private subnets using the network configuration of the lab environment
- Attached with custom cluster and DB parameter groups
- Automatically backed up continuously, retaining backups for 7 days
- Using data at rest encryption
- With Enhanced Monitoring and Performance Insights enabled
- With PostgreSQL database log being exported to CloudWatch
- Created with an initial database called mylab
- With deletion protection turned off
{{% /expand%}}

#### Store Aurora PostgreSQL credentials in AWS Secrets Manager
{{%expand "What is the AWS Secrets Manager?" %}}
**AWS Secrets Manager** helps you manage, retrieve, and rotate database credentials, application credentials, OAuth tokens, API keys, and other secrets throughout their lifecycles. Many AWS services store and use secrets in Secrets Manager.

**Secrets Manager** helps you improve your security posture, because you no longer need hard-coded credentials in application source code. Storing the credentials in Secrets Manager helps avoid possible compromise by anyone who can inspect your application or the components. You replace hard-coded credentials with a runtime call to the Secrets Manager service to retrieve credentials dynamically when you need them.

With **Secrets Manager**, you can configure an automatic rotation schedule for your secrets. This enables you to replace long-term secrets with short-term ones, significantly reducing the risk of compromise. Since the credentials are no longer stored with the application, rotating credentials no longer requires updating your applications and deploying changes to application clients.

For other types of secrets you might have in your organization:

- AWS credentials – We recommend AWS Identity and Access Management.

- Encryption keys – We recommend AWS Key Management Service.

- SSH keys – We recommend Amazon EC2 Instance Connect.

Private keys and certificates – We recommend AWS Certificate Manager.
{{% /expand%}}

1. Open the Secrets Manager [console](https://console.aws.amazon.com/secretsmanager/), then choose **Store a new secret**.

![Create Aupg](/images/1/1.1/16.png)

2. On the **Secret type**, choose  **Credential for Amazon RDS database**
3. On the **Credential**,  input the User name (should be masteruser) and Password that you provided when you created the DB cluster previously

![Create Aupg](/images/1/1.1/17.png)

4. Leave the **Encryption Key** options at their default values.
5. On the **Database**, choose the DB instance identifier you assigned to your instance (e.g. aupg-fcj-labs). 
6. Click Next.

![Create Aupg](/images/1/1.1/18.png)

7. Name the secret ``aupg-fcj-labs-DBMateruser-secret`` and provide a relevant description for the secret, then click **Next**.

![Create Aupg](/images/1/1.1/19.png)

8. Finally, in the **Configure automatic rotation** section, leave the option of **Disable automatic rotation** selected. In a production environment you will want to use database credentials that rotate automatically for additional security. Click **Next**.

9. In the **Review** section you have the ability to check the configuration parameters for your secret, before it gets created. Additionally, you can retrieve sample code in popular programming languages, so you can easily retrieve secrets into your application. Click **Store** at the bottom of the screen.
