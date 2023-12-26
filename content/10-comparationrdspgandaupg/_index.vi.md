---
title : "Comparison RDS PostgreSQL and Aurora PostgreSQL"
date :  "`r Sys.Date()`" 
weight : 10
chapter : false
pre : " <b> 10. </b> "
---

{{%expand "What is AWS RDS PostgreSQL ?" %}}

**RDS PostgreSQL** is a managed database service offered by Amazon Web Services (AWS) that makes it easy to set up, operate, and scale PostgreSQL deployments in the cloud. It handles many of the complex administrative tasks involved in managing a PostgreSQL database, allowing you to focus on developing and using your applications.

Here's how it works:

- **Deployment**: You choose the desired PostgreSQL version, instance size (compute and memory resources), storage type, and other configuration options.
- **Provisioning**: AWS handles the provisioning of the database instance, including installation, setup, and configuration.
- **Management**: RDS PostgreSQL automatically manages tasks like:
    - Software patching and updates
    - Backups and recovery
    - Storage management
    - Replication for high availability and read scaling
    - Monitoring and performance tuning
- **Access**: You connect to your RDS PostgreSQL database using standard PostgreSQL clients and tools.
- **Scaling**: You can easily scale your database instance up or down as your needs change, without downtime.

Key benefits of using RDS PostgreSQL:

- **Ease of use**: Sets up in minutes with simple configuration options.
- **Managed operations**: Automates time-consuming administrative tasks.
- **Cost-effectiveness**: Offers pay-as-you-go pricing with no upfront costs.
- **Scalability**: Easily scales up or down to meet changing demands.
- **High availability**: Provides replication for failover and read scaling.
- **Security**: Secures data with encryption at rest and in transit.
- **Compatibility**: Works with standard PostgreSQL tools and applications.

Common use cases for RDS PostgreSQL:

- Web and mobile applications
- Data warehousing and analytics
- Enterprise resource planning (ERP)
- Customer relationship management (CRM)
- Content management systems (CMS)
- Internet of Things (IoT) applications
{{% /expand%}}

{{%expand "What is AWS Aurora PostgreSQL ?" %}}


**Aurora PostgreSQL**, offered by Amazon Web Services (AWS), is a fully managed, highly scalable, and high-performance relational database service that's fully compatible with PostgreSQL. It combines the best of both worlds: the simplicity and cost-effectiveness of open-source PostgreSQL with the speed, reliability, and advanced features of high-end commercial databases.

Here's a breakdown of its key features:

- **Scalability**:

    - Scales virtually infinitely for both storage and compute capacity, unlike RDS PostgreSQL which has limitations.
    - Automatically scales in increments of 10 GB for optimal performance.
    - Read replicas are near real-time and minimize impact on the primary instance.
- **Performance**:

    - Up to 5x faster than standard PostgreSQL, especially for read-heavy workloads.
    - Offers low latency read replicas across multiple Availability Zones.
    - Features like global database and cluster cache further boost performance.
- **Durability and Availability**:

    - Highly durable with automatic backups and continuous replication.
    - Automated failover to replicas in case of primary instance failure.
    - Global database allows automatic failover across regions for disaster recovery.
- **Other Features**:

    - Serverless compute allows paying only for what you use.
    - Up to 15 read replicas can be attached for increased read scalability.
    - Integrates with other AWS services for simplified data management.
    - Enhanced security features like encryption at rest and in transit.

{{% /expand%}}

#### Performance:

**Aurora PostgreSQL**: Up to 5x faster than traditional PostgreSQL and 3x faster than RDS PostgreSQL. Scales seamlessly without downtime.
**RDS PostgreSQL**: Good performance for smaller workloads, but can struggle with high traffic or complex queries. Scaling requires downtime.

#### Benchmarks
1. Configure
|    |Aurora PostgreSQL|RDS PostgreSQL|
|---|:--:|:--:|
|Instance type	| db.m1.lar5ge (2vCPU + 7.5Gb)|db.m1.lar5ge (2vCPU + 7.5Gb)|
|Region|	us-west-2a|	us-west-2a|
|Client Side (running pgbench)|	EC2 instance in us-west-2a|	EC2 instance in us-west-2a|
|Installed PG version|	15.x|15.x|
|Storage Encryption|	Enabled|	Enabled|
|Multi-AZ/ Replication/ High-availability|	Disabled|	Disabled|

2. Benchmark details

    Following command below:

    ```
    pgbench -c 10 -j 10 -t 500 -h [your endpoint] -U [your username] [dbname]
    ```


#### Scalability:

- **Aurora PostgreSQL**: Scales automatically and continuously, without performance impact. Can handle massive datasets and millions of concurrent connections.
- **RDS PostgreSQL**: Requires manual scaling with limited options, leading to downtime and performance bottlenecks.
#### Availability and Durability:

- **Aurora PostgreSQL**: Extremely high availability with automatic failover and multi-AZ backups. Provides point-in-time recovery up to the last five minutes.
- **RDS PostgreSQL**: Offers single-AZ deployments and manual backups. Failover requires configuration and potential data loss.
#### Cost:

- **Aurora PostgreSQL**: Can be more expensive than RDS PostgreSQL, especially for low-traffic applications. However, cost savings can come from improved performance and reduced scaling needs.
- **RDS PostgreSQL**: Generally cheaper than Aurora PostgreSQL, but costs can quickly increase as you scale or require higher performance.
#### Additional Factors:

- **Features**: Aurora PostgreSQL supports some features not available in **RDS PostgreSQL**, such as Babelfish for database migration and global databases.
- **Compatibility**: Both are compatible with PostgreSQL applications, but Aurora PostgreSQL has limitations on supported versions.
- **Management**: Both are fully managed services, but Aurora PostgreSQL handles more tasks automatically.


#### Best practices

- **Choose Aurora PostgreSQL for**: high-traffic applications, scalability requirements, mission-critical databases, strict availability needs.
- **Choose RDS PostgreSQL for**: budget-sensitive applications, simple workloads, specific PostgreSQL features not available in Aurora, need for wider range of supported versions.