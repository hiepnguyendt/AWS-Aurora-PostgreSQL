---
title : "Thiết lập cluster cache management"
date :  "`r Sys.Date()`" 
weight : 1 
chapter : false
pre : " <b> 5.1. </b> "
---

#### Cấu hình Cluster Cache Management (CCM)

Sau đây là các bước để đặt cấu hình và kích hoạt việc sử dụng CCM trên cụm Aurora PostgreSQL của bạn

1. Tùy chỉnh Amazon Aurora DB Cluster Parameters liên quan đến CCM.

- Đăng nhập vào AWS Management Console và chọn [Parameter Groups](https://console.aws.amazon.com/rds/home?#parameter-group-list:) trên Amazon RDS console.

- Trong danh sách, hãy chọn DB cluster parameter group cho DB Aurora PostgreSQL cluster của bạn. DB cluster phải sử dụng nhóm tham số khác với mặc định vì bạn không thể thay đổi giá trị trong nhóm tham số mặc định. Để biết thêm thông tin, hãy xem [Tạo nhóm tham số cụm DB](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_WorkingWithParamGroups.html#USER_WorkingWithParamGroups.CreatingCluster).
- Click **Edit** bên dưới **Actions** menu.
- Đặt giá trị của tham số ``apg_ccm_enabled`` thành 1 và nhấp vào **Save Changes**.
    ![CCM](/images/5/5.1/1.png)

2. Để quản lý bộ nhớ cache cho cụm, hãy đảm bảo rằng độ ưu tiên thăng cấp (promotion priority) cho DB instance ghi (writer) của cụm Aurora PostgreSQL là tier-0. Độ ưu tiên thăng cấp là một giá trị xác định thứ tự mà một Aurora reader sẽ được thăng cấp lên DB instance ghi sau một sự cố. Giá trị hợp lệ là từ 0 đến 15, trong đó 0 là độ ưu tiên cao nhất và 15 là độ ưu tiên thấp nhất.

- Chọn [Databases](https://console.aws.amazon.com/rds/home?#databases:)  trong Amazon RDS console.

- Chọn Writer DB instance của DB Aurora PostgreSQL cluster và nhấp vào *Sửa đổi*
    ![CCM](/images/5/5.1/2.png)

-  Trong phần **Additional configuration**, chọn **tier-0** cho Failover Priority.
    ![CCM](/images/5/5.1/3.png)

- Chọn **Continue** và kiểm tra tóm tắt các sửa đổi.
- Để áp dụng các thay đổi ngay sau khi bạn lưu, hãy chọn **Apply immediately** và nhấp vào **Modify DB Instance** để lưu các thay đổi của bạn. Để biết thêm thông tin về cài đặt promotion tier, hãy xem [Modify a DB Instance in a DB Cluster and the Promotion tier setting](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Modifying.html# Aurora.Modifying.Instance) . Xem thêm [Fault Tolerance for an Aurora DB Cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Backups.html#Aurora.Managing.FaultTolerance)
    ![CCM](/images/5/5.1/4.png)

3. Tiếp theo, hãy thiết lập một DB instance đọc cho việc quản lý bộ nhớ cache của cụm Aurora. Để làm điều này, hãy chọn một DB instance đọc từ cụm Aurora PostgreSQL có cùng lớp và kích thước với DB instance ghi. Ví dụ, nếu DB instance ghi sử dụng lớp db.r5.xlarge, hãy chọn một DB instance đọc sử dụng cùng lớp và kích thước này. Sau đó, đặt mức ưu tiên (promotion tier) của nó thành 0. Mức ưu tiên (promotion tier) là giá trị xác định thứ tự DB instance đọc Aurora được thăng cấp thành DB instance chính sau một sự cố. Các giá trị hợp lệ là từ 0 đến 15, trong đó 0 là mức ưu tiên cao nhất và 15 là mức ưu tiên thấp nhấ

- Trong ngăn điều hướng, chọn **Databases**.
- Chọn Reader DB instance của DB Aurora PostgreSQL cluster và nhấp vào **Modify**
    ![CCM](/images/5/5.1/5.png)

- Trong **Cấu hình bổ sung**, chọn tier-0 cho **Failover Priority**.
- Chọn **Tiếp tục** và kiểm tra tóm tắt các sửa đổi.
- Để áp dụng các thay đổi ngay sau khi bạn lưu, hãy chọn **Apply immediately** và nhấp vào **Modify DB Instance** để lưu các thay đổi của bạn.
    ![CCM](/images/5/5.1/6.png)
    ![CCM](/images/5/5.1/7.png)

#### Xác minh xem CCM có được bật hay không

- Nhấp vào DB identifier mà bạn đã tạo

- Trong phần **Connectivity and Security**, bạn sẽ thấy 2 endpoints khác nhau. Endpoint với loại **Writer** là điểm cuối của cụm (cluster endpoint) dùng cho kết nối đọc-ghi, và endpoint với loại **Reader** là điểm cuối của đọc (reader endpoint) dùng cho kết nối chỉ đọc.
    ![CCM](/images/5/5.1/8.png)

- Mở một terminal Cloud9 và sử dụng lệnh psql để kết nối đến writer endpoint của cụm Aurora PostgreSQL DB. Chạy các lệnh SQL sau để kiểm tra trạng thái quản lý bộ nhớ cache của cụm:

    ```
    psql 
    \x
    select * from aurora_ccm_status();

    ```
    ![CCM](/images/5/5.1/9.png)

{{% notice note %}}
Nếu Cluster Cache management không được kích hoạt, truy vấn aurora_ccm_status() sẽ hiển thị output như dưới đây:
**aupglab=> \x \
Expanded display is on.\
mylab=> select * from aurora_ccm_status();\
ERROR:  Cluster Cache Manager is disabled**
{{% /notice %}}

