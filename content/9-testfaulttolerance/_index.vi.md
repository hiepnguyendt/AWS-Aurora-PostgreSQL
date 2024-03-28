---
title : "Test Fault Tolerance"
date :  "`r Sys.Date()`" 
weight : 9
chapter : false
pre : " <b> 9. </b> "
---


**An Aurora DB cluster** được thiết kế để chịu lỗi. Cluster volume được trải để trên 3 Availability Zones trong một AWS Region, và mỗi khu vực có 2 bản sao dữ liệu. Chức năng này đồng nghĩa với việc cụm DB của bạn có thể chịu được sự cố xảy ra trong một Availability Zones mà không mất dữ liệu và chỉ có một gián đoạn ngắn trong dịch vụ

Nếu DB cluster sử dụng single-master replication gặp sự cố, Aurora tự động thực hiện chuyển đổi (failover) sang một instance chính mới theo hai cách sau đây:

- Bằng cách thăng cấp (promote) một Aurora Replica hiện có thành instance chính mới.
- Bằng cách tạo ra một instance chính mới. 
#### In this lab, we will simulate a failover of the Aurora PostgreSQL cluster, and observe the change in writer and reader roles. This lab contains the following tasks:

1. [Thiết lập thông báo sự kiện failover](9-1-setupfailovereventnotifications/)
2. [Test a manual DB cluster failover](9-2-testamanualdbclusterfailover/)
3. [Kiểm tra các truy vấn gây lỗi](9-3-testingfaultinjectionqueries/)
