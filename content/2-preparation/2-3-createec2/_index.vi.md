---
title : "Tạo EC2 instance"
date :  "`r Sys.Date()`" 
weight : 3
chapter : false
pre : " <b> 2.3. </b> "
---
#### Để tạo phiên bản EC2 cho môi trường Cloud9, hãy làm theo các bước sau:

1. Truy cập giao diện [Amazon EC2 console](https://console.aws.amazon.com/ec2/).
2. Chọn **Launch Instance**.
    ![Create EC2 instance](/images/1/8.png)

3. Đặt tên cho EC2. Chọn **AMI**. Bạn có thể chọn**Linux AMI**, chẳng hạn như **Amazon Linux 2** cho app server.
4. Chọn **instance type**. Instance type bạn chọn sẽ tùy thuộc vào yêu cầu của app server. Ví dụ: nếu bạn đang chạy một trang web có lưu lượng truy cập cao, bạn sẽ cần loại phiên bản lớn hơn với nhiều CPU và bộ nhớ hơn.
    ![Create EC2 instance](/images/1/9.png)
    ![Create EC2 instance](/images/1/10.png)
    ![Create EC2 instance](/images/1/11.png)
5. Tại mục **Key Pair**,chọn keypair bạn đã tạo hoặc nhấp vào **Create new key pair** để tạo 1 keypair mới
    ![Create EC2 instance](/images/1/12.png)

6.  Tại mục **Network settings**
- Chọn **VPC** chứa EC2 app server
- Chọn **Subnet**
- **Enable** Auto-assign public IP
- Thêm **security group** cho EC2 app server.  
    ![Create EC2 instance](/images/1/13.png)

7. **Review** và **launch** instance

*Sau khi khởi chạy instance, bạn có thể kết nối với instance đó bằng ứng dụng SSH client, chẳng hạn như MobaXterm hoặc PuTTY. Sau khi kết nối, bạn có thể cài đặt app server và triển khai ứng dụng của mình.*