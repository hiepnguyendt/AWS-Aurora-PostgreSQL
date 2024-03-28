---
title : "Các bước chuẩn bị"
date :  "`r Sys.Date()`" 
weight : 2 
chapter : false
pre : " <b> 2. </b> "
---

Các bước chuẩn bị sử dụng một số dịch vụ sau:
- [Amazon VPC](https://000003.awsstudygroup.com/1-introduce/)  network configuration with [public and private subnets](https://000003.awsstudygroup.com/1-introduce/1.1-subnets/)
- [Database subnet group](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html#USER_VPC.Subnets)  and relevant [security groups](https://000003.awsstudygroup.com/2-firewallinvpc/)  for the Aurora PostgreSQL cluster and AWS Cloud9 environment
- [AWS Cloud9](https://000049.awsstudygroup.com/)  configured with the software components needed for the labs
- Custom cluster and [DB instance parameter groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html)  for the Amazon Aurora PostgreSQL cluster, enabling some extensions and useful parameters
- The master database credentials will be store in [AWS Secrets Manager](https://000096.awsstudygroup.com/vi)



### Nội dung
 1. [Tạo VPC](2-1-createvpc/)
 2. [Tạo Security Group](2-2-createsg/)
 3. [Tạo EC2](2-3-createec2/)
 4. [Tạo Subnet Group và Parameter Group](2-4-createpg&sg/)
 5. [Tạo Aurora PostgreSQL Cluster](2-5-Createaupg/)
 6. [Cấu hình Cloud9 và Initialize Database](2-6-configurecloud9andinitializedatabase/)

