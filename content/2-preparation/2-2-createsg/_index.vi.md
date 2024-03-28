---
title : "Tạo Security Group "
date :  "`r Sys.Date()`" 
weight : 2 
chapter : false
pre : " <b> 2.2. </b> "
---


#### Tạo EC2 security group trong AWS console

1. Truy cập giao diện [EC2 console](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Home:).
2. Tại ngăn điều hướng, chọn **Security Groups**.
3. Chọn **Create Security Group**.
4. Tại mục **VPC**, chọn VPC mà bạn muốn tạo security group.
5. Tại mục **Security group name**, đặt tên cho security group.
6. Tại mục **Description**, nhập mô tả cho security group.
    ![Create EC2 SG](/images/1/4.png)

7. Chỉnh sửa Inbound Rule & Outbound Rule
    ![Create EC2 SG](/images/1/5.png)

9. Click **Create**.
Bạn đã tạo thành công security group cho EC2 instance

#### Tạo Database security group trong AWS console:

1. Truy cập giao diện [EC2 console](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Home:).
2. Tại ngăn điều hướng, chọn **Security Groups**.
3. Chọn **Create Security Group.**
4. Tại mục **VPC**, chọn VPC mà bạn muốn tạo security group.
5. Tại mục **Security group name**, đặt tên cho security group.
6. Tại mục **Description**, nhập mô tả cho security group.
    ![Create EC2 SG](/images/1/6.png)

7. Chỉnh sửa Inbound Rule & Outbound Rule
    ![Create EC2 SG](/images/1/7.png)

9. Click **Create**.
Bạn đã tạo thành công security group cho Aurora PostgreSQL