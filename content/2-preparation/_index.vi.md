---
title : "Preparation Steps"
date :  "`r Sys.Date()`" 
weight : 1 
chapter : false
---

The preparation steps using several components:
- [Amazon VPC](https://000003.awsstudygroup.com/1-introduce/)  network configuration with [public and private subnets](https://000003.awsstudygroup.com/1-introduce/1.1-subnets/)
- [Database subnet group](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html#USER_VPC.Subnets)  and relevant [security groups](https://000003.awsstudygroup.com/2-firewallinvpc/)  for the Aurora PostgreSQL cluster and AWS Cloud9 environment
- [AWS Cloud9](https://000049.awsstudygroup.com/)  configured with the software components needed for the labs
- Custom cluster and [DB instance parameter groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html)  for the Amazon Aurora PostgreSQL cluster, enabling some extensions and useful parameters
- The master database credentials will be store in [AWS Secrets Manager](https://000096.awsstudygroup.com/vi)


### Content
 1. [Create VPC](1-createvpc/)
 2. [Create Security Group](2-createsg/)
 3. [Create EC2](3-createec2/)
 4. [Create Aurora PostgreSQL Cluster](4-Createaupg/)
 5. [Configure Cloud9 and Initialize Database](5-configurecloud9andinitializedatabase/)

