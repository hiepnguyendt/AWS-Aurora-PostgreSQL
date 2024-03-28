---
title : "Tạo VPC"
date :  "`r Sys.Date()`" 
weight : 1 
chapter : false
pre : " <b> 2.1. </b> "
---
 


1. Truy cập giao diện [VPC console](https://console.aws.amazon.com/vpc/) và chọn **Create VPC**.
    ![Create a VPC](/images/1/1.png)

2. Tại mục **Resources to create**, chọn **VPC and more**.
3. Đặt tên cho VPC và chọn **CIDR block**. Khối CIDR là dải địa chỉ IP sẽ có sẵn cho VPC của bạn. Đảm bảo chọn khối CIDR đủ lớn cho nhu cầu của bạn nhưng không lớn đến mức gây lãng phí địa chỉ IP.
    ![Create a VPC](/images/1/2.png)

4. Chọn giá trị cho **Number of public subnets**, **Number of private subnets** và **NAT Gateway**.

5. Xem lại cấu hình của VPC và Click **Create VPC**
    ![Create a VPC](/images/1/3.png)

