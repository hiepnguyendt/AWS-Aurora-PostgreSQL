---
title : "Create Aurora PostgreSQL Database"
date :  "`r Sys.Date()`" 
weight : 5
chapter : false
pre : " <b> 2.5. </b> "
---


#### Để tạo Aurora PostgreSQL DB, hãy làm theo các bước sau:

1. Truy cập giao diện [Amazon RDS console](https://console.aws.amazon.com/rds/).
    ![Create Aupg](/images/1/1.1/1.png)

2. Click **Create database**.
3. Tại mục **Database engine**, chon **PostgreSQL**.
4. Tại mục **Version**, chọn phiên bản PostgreSQL mà bạn muốn sử dụng.
    ![Create Aupg](/images/1/1.1/2.png)

5. Tại mục **Template**, chọn một template cho DB instance của bạn. template  là cấu hình được định cấu hình sẵn cho DB instance.
    ![Create Aupg](/images/1/1.1/3.png)

6. Tại mục **Availability** và **Durability**, tại mục **DB instance identifier**, đặt tên cho DB instance.
    ![Create Aupg](/images/1/1.1/7.png)

7. Tại mục **DB instance identifier**, đặt tên cho database instance.
8. Tại mục **Master username**, đặt tên cho người dùng chính của database instance.
9. Tại mục **Master password**, đặt mật khẩu database instance.
    ![Create Aupg](/images/1/1.1/4.png)

10. Tại mục **Cluster storage configuration**, chọn dung lượng lưu trữ mà bạn muốn phân bổ cho database instance của mình.
    ![Create Aupg](/images/1/1.1/5.png)

11. Tại mục **Instance configuration**, chọn DB instance class mà bạn muốn sử dụng cho DB instance của mình. DB instance class sẽ xác định lượng CPU và bộ nhớ được phân bổ cho DB instancecủa bạn.
    ![Create Aupg](/images/1/1.1/6.png)


12. Tại mục **Connectivity**, 
- Để các tùy chọn **Compute resource** và **Network type** ở giá trị mặc định.
- Đảm bảo tùy chọn cluster Publicly accessible được đặt thành **No**.
- Bỏ chọn tùy chọn Tạo proxy RDS.
    ![Create Aupg](/images/1/1.1/8.png)

13. Tại mục **DB subnet group**, chọn DB subnet group mà bạn muốn sử dụng cho DB instance của mình.
14. Tại mục **VPC security groups**, chọn security groups mà bạn muốn sử dụng cho DB instance của mình.
    ![Create Aupg](/images/1/1.1/9.png)

15. Mở rộng **Additional configuration**, Nhập **5432** cho **database port**
16. Để các tùy chọn **Babelfish settings** và **Database authentication** ở giá trị mặc định.
    ![Create Aupg](/images/1/1.1/10.png)

17. Tại mục **Monitoring**, 
- Chọn hộp Bật Thông tin chi tiết về hiệu suất với thời gian lưu giữ cho Thông tin chi tiết về hiệu suất trong 7 ngày (bậc miễn phí) và sử dụng khóa AWS KMS aws/rds (mặc định) để theo dõi mã hóa dữ liệu.
    ![Create Aupg](/images/1/1.1/11.png)
- Tiếp theo, mở rộng phần **Additional configuration - Enhanced Monitoring** và chọn enable **Enhanced Monitoring** và chọn **Granularity of 1 second**.
    ![Create Aupg](/images/1/1.1/12.png)
18. Mở rộng **Additional configuration**:
- Đặt tên cho database là ``aupglab``.
- Chọn DB cluster parameter group có tên **aupg-parametergroup** . 
- Tại mục DB parameter group, chọn **aupg-pg**
- Chọn khoảng thời gian Backup là 7 ngày.
- Chọn Enable encryption và chọn aws/rds (mặc định) cho Master key.
- Để truy xuất Log, hãy chọn PostgreSQL log.
- Để các tùy chọn Maintenance ở giá trị mặc định.
    ![Create Aupg](/images/1/1.1/13.png)
    ![Create Aupg](/images/1/1.1/14.png)


19. Click **Create database**.


***Sẽ mất 5-10 phút để tạo Aurora cluster với nút ghi và nút đọc.***

{{%expand "Hiển thị bản tóm tắt các tùy chọn cấu hình đã chọn" %}}
- Aurora PostgreSQL 15.3 compatible cluster với DB class instance là db.r6g.large
- Cụm bao gồm writer and a reader DB instance ở các AZ khác nhau (có tính sẵn sàng cao)
- Sử dụng cấu hình lưu trữ Aurora Standard trong đó I/O được tính phí trên cơ sở trả cho mỗi request
- Được triển khai trong VPC với private subnets 
- Kèm theo custom cluster và DB parameter groups
- Tự động sao lưu, giữ lại bản sao lưu trong 7 ngày
- Sử dụng rest encryption cho dữ liệu
- Đã bật tính năng Enhanced Monitoring và Performance Insights
- Với PostgreSQL database log đang được truy xuất sang CloudWatch
- Được tạo bằng cơ sở dữ liệu ban đầu có tên mylab
- Đã tắt tính năng deletion protection
{{% /expand%}}

#### Lưu trữ thông tin xác thực Aurora PostgreSQL trong AWS Secrets Manager
{{%expand "AWS Secrets Manager là gì?" %}}
**AWS Secrets Manager** giúp bạn quản lý, truy xuất và xoay vòng thông tin xác thực cơ sở dữ liệu, thông tin xác thực ứng dụng, OAuth tokens, API keys và các thông tin bảo mật khác trong suốt vòng đời của chúng.

**Secrets Manager** giúp bạn cải thiện tình trạng bảo mật của mình vì bạn không còn cần hard-coded thông tin xác thực trong mã nguồn ứng dụng nữa. Việc lưu trữ thông tin xác thực Secrets Manage giúp tránh khả năng bị xâm phạm bởi bất kỳ ai có ý đồ xấu. Bạn thay thế thông tin xác thực được hard-coded bằng lệnh gọi tới dịch vụ Secrets Manager để truy xuất thông tin xác thực khi bạn cần.

Với **Secrets Manager**, bạn có thể cấu hình lịch xoay vòng tự động cho các secrets của mình. Điều này cho phép bạn thay thế secrets dài hạn bằng secrets ngắn hạn, giảm đáng kể nguy cơ bị xâm phạm. Vì thông tin xác thực không còn được lưu trữ cùng với ứng dụng nên thông tin xác thực luân phiên không còn yêu cầu cập nhật ứng dụng của bạn và triển khai các thay đổi đối với ứng dụng khách.

Đối với các loại secrets khác mà bạn có thể có trong tổ chức của mình:

- AWS credentials – Chúng tôi khuyên dùng AWS Identity and Access Management.

- Encryption keys – Chúng tôi khuyên dùng AWS Key Management Service.

- SSH keys – Chúng tôi khuyên dùng Amazon EC2 Instance Connect.

Private keys and certificates – Chúng tôi khuyên dùng AWS Certificate Manager.
{{% /expand%}}

1. Truy cập giao dienen [Secrets Manager console](https://console.aws.amazon.com/secretsmanager/), sau đó chọn **Store a new secret**.
    ![Create Aupg](/images/1/1.1/16.png)

2. Ở mục **Secret type**, chọn  **Credential for Amazon RDS database**
3. Ở mục **Credential**,  nhập User name (nên đặt là masteruser) và password mà bạn đã cung cấp khi tạo cụm DB trước đó
    ![Create Aupg](/images/1/1.1/17.png)

4. Để các tùy chọn **Khóa mã hóa** ở giá trị mặc định.
5. Tại **Database**, chọn mã định danh phiên bản DB mà bạn đã gán cho phiên bản của mình (ví dụ: aupg-fcj-labs).
6. Click Next.
    ![Create Aupg](/images/1/1.1/18.png)

7. Đặt tên secret là ``aupg-fcj-labs-DBMateruser-secret`` và nhập mô tả có liên quan cho secret đó, sau đó click **Next**.
    ![Create Aupg](/images/1/1.1/19.png)

8. Cuối cùng, trong phần **Configure automatic rotation**, hãy chọn tùy chọn **Disable automatic rotation**. Click **Next**.

9. Trong phần **Review**, bạn có thể kiểm tra các tham số cấu hình cho secret của mình trước khi nó được tạo. Ngoài ra, bạn có thể truy xuất code bằng các ngôn ngữ lập trình phổ biến để bạn có thể dễ dàng truy xuất các secret vào ứng dụng của mình. Nhấp vào **Store** ở cuối màn hình.