---
title : "Cấu hình KMS cho Database Activity Streaming"
date :  "`r Sys.Date()`" 
weight : 1 
chapter : false
pre : " <b> 6.1. </b> "
---

**Database Activity Streaming** yêu cầu một Master Key để mã hóa khóa sau đó mã hóa hoạt động cơ sở dữ liệu đã đăng nhập. Khóa AWS RDS KMS mặc định không thể được sử dụng làm Master key. Do đó, chúng ta cần tạo một khóa KMS quản lý bởi khách hàng mới để cấu hình Database Activity Streaming.
#### Tạo KMS Key
1. Truy cập giao diện [KMS console](https://console.aws.amazon.com/kms/home)  và chọn **Customer Managed Keys** ở phía bên trái và nhấp vào **Create Key**:
2. Ở màn hình tiếp theo bên dưới **Configure key**, chọn **Symmetric** và nhấp vào **Next**:
    ![DAS](/images/6/6.1/1.png)

3. Ở màn hình tiếp theo, bên dưới **Add Labels** đặt tên cho khóa trong trường **Alias**, chẳng hạn như ``cmk-apg-lab``.

- Trong trường Mô tả, hãy nhập mô tả cho khóa, chẳng hạn như ``Customer managed Key for Aurora PostgreSQL Database Activity Streaming (DAS) lab`` và nhấp vào **Next**.
    ![DAS](/images/6/6.1/2.png)

4. Trên màn hình tiếp theo trong **Define Key Administrative permissions** và **Define key usage permissions**, hãy giữ cài đặt mặc định.
5. Trên màn hình tiếp theo, hãy xem lại policy và nhấp vào **Finish**.
    ![DAS](/images/6/6.1/3.png)

6. Xác minh khóa KMS mới được tạo trên KMS console.
    ![DAS](/images/6/6.1/4.png)