---
title : "So sánh giữa RDS PostgreSQL và Aurora PostgreSQL"
date :  "`r Sys.Date()`" 
weight : 10
chapter : false
pre : " <b> 10. </b> "
---

{{%expand "AWS RDS PostgreSQL là gì ?" %}}

**RDS PostgreSQL** là một dịch vụ cơ sở dữ liệu quản lý được cung cấp bởi Amazon Web Services (AWS) giúp việc thiết lập, vận hành và mở rộng các phiên bản PostgreSQL trên nền tảng đám mây trở nên dễ dàng. Nó xử lý nhiều nhiệm vụ quản trị phức tạp liên quan đến việc quản lý cơ sở dữ liệu PostgreSQL, cho phép bạn tập trung vào việc phát triển và sử dụng ứng dụng của mình.

Dưới đây là cách hoạt động:

- **Deployment**: Bạn có thể lựa chọn phiên bản PostgreSQL mong muốn, kích thước instance (tài nguyên tính toán và bộ nhớ), loại lưu trữ và các tùy chọn cấu hình khác.
- **Provisioning**: AWS xử lý việc cung cấp các instance cơ sở dữ liệu, bao gồm cài đặt, thiết lập và cấu hình.
- **Management**: RDS PostgreSQL tự động quản lý các nhiệm vụ như:
    - Software patching and updates
    - Backups and recovery
    - Storage management
    - Replication for high availability and read scaling
    - Monitoring and performance tuning
- **Access**: Bạn có thể kết nối đến cơ sở dữ liệu RDS PostgreSQL của mình bằng cách sử dụng các công cụ thông thường của PostgreSQL.
- **Scaling**: Bạn có thể dễ dàng thay đổi kích thước của instance cơ sở dữ liệu mà không gây gián đoạn dịch vụ khi nhu cầu của bạn thay đổi.

Các lợi ích chính khi sử dụng RDS PostgreSQL là:

- **Ease of use**: Cài đặt trong vài phút với các tùy chọn cấu hình đơn giản.
- **Managed operations**: Tự động hóa các tác vụ quản trị tốn thời gian.
- **Cost-effectiveness**: Cung cấp mô hình giá theo nhu cầu sử dụng với không có chi phí ban đầu.
- **Scalability**: Dễ dàng mở rộng hoặc thu nhỏ để đáp ứng nhu cầu thay đổi.
- **High availability**: Cung cấp sao chép (replication) để đảm bảo hoạt động không bị gián đoạn và mở rộng đọc.
- **Security**: Bảo mật dữ liệu bằng mã hóa khi lưu trữ và truyền tải.
- **Compatibility**: RDS PostgreSQL hoạt động với các công cụ và ứng dụng tiêu chuẩn của PostgreSQL.

Các trường hợp sử dụng phổ biến cho RDS PostgreSQL!

- Web and mobile applications
- Data warehousing and analytics
- Enterprise resource planning (ERP)
- Customer relationship management (CRM)
- Content management systems (CMS)
- Internet of Things (IoT) applications
{{% /expand%}}

{{%expand "AWS Aurora PostgreSQL là gì ?" %}}


**Aurora PostgreSQL** là một dịch vụ cơ sở dữ liệu quan hệ được quản lý hoàn toàn, có khả năng mở rộng cao và hiệu suất cao, hoàn toàn tương thích với PostgreSQL. Nó kết hợp những ưu điểm tốt nhất: sự đơn giản và hiệu quả về chi phí của PostgreSQL mã nguồn mở với tốc độ, độ tin cậy và tính năng tiên tiến của các cơ sở dữ liệu thương mại cao cấp

Đây là bảng phân tích các tính năng chính của nó:
- **Scalability**:

    - Quy mô gần như vô hạn cho cả khả năng lưu trữ và tính toán, không giống như RDS PostgreSQL có những hạn chế.
    - Tự động chia tỷ lệ theo mức tăng 10 GB để có hiệu suất tối ưu.
    - Read replicas gần như theo thời gian thực và giảm thiểu tác động đến instance chính.
- **Performance**:

    - Nhanh hơn tới 5 lần so với PostgreSQL, đặc biệt đối với khối lượng công việc đọc nhiều.
    - Cung cấp bản sao đọc có độ trễ thấp trên nhiều Availability Zones.
    - Các tính năng như cơ sở dữ liệu toàn cầu và bộ đệm cụm tăng thêm hiệu suất.
- **Durability and Availability**:

    - Độ bền cao với khả năng sao lưu tự động và sao chép liên tục.
    - Tự động chuyển đổi dự phòng sang bản sao trong trường hợp phiên bản chính bị lỗi
    - Global database cho phép tự động chuyển đổi dự phòng giữa các vùng để khắc phục thảm họa.
- **Tính năng khác**:

    - Serverless compute cho phép trả tiền cho những gì bạn sử dụng.
    - Có thể đính kèm tối đa 15 read replica để tăng khả năng mở rộng đọc.
    - Tích hợp với các dịch vụ AWS khác để đơn giản hóa việc quản lý dữ liệu
    - Các tính năng bảo mật nâng cao như mã hóa at rest and in transit.

{{% /expand%}}

#### Hiệu năng:

**Aurora PostgreSQL**: Nhanh hơn tới 5 lần so với PostgreSQL truyền thống và nhanh hơn 3 lần so với RDS PostgreSQL. Scale liên tục mà không có downtime.
**RDS PostgreSQL**: Hiệu suất tốt cho khối lượng công việc nhỏ hơn nhưng có thể gặp khó khăn với lưu lượng truy cập cao hoặc các truy vấn phức tạp. Mở rộng quy mô đòi hỏi downtime.

#### Benchmarks
1. Cấu hình
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

- **Aurora PostgreSQL**: Scale tự động và liên tục, không ảnh hưởng đến hiệu suất. Có thể xử lý các bộ dữ liệu lớn và hàng triệu kết nối đồng thời.
- **RDS PostgreSQL**: Yêu cầu mở rộng quy mô thủ công với các tùy chọn hạn chế, dẫn đến downtime và ảnh hưởng đến hiệu suất.
#### Availability and Durability:

- **Aurora PostgreSQL**: Tính sẵn sàng cực cao với khả năng chuyển đổi dự phòng tự động và sao lưu đa AZ. Cung cấp khả năng phục hồi tại thời điểm tối đa năm phút cuối cùng.
- **RDS PostgreSQL**: Cung cấp triển khai một AZ và sao lưu thủ công. Chuyển đổi dự phòng yêu cầu cấu hình và có khả năng mất dữ liệu.
#### Cost:

- **Aurora PostgreSQL**: Có thể đắt hơn RDS PostgreSQL, đặc biệt đối với các ứng dụng có lưu lượng truy cập thấp. Tuy nhiên, tiết kiệm chi phí có thể đến từ hiệu suất được cải thiện và giảm nhu cầu mở rộng quy mô.
- **RDS PostgreSQL**: Thường rẻ hơn Aurora PostgreSQL nhưng chi phí có thể tăng nhanh khi bạn mở rộng quy mô hoặc yêu cầu hiệu suất cao hơn.
#### Additional Factors:

- **Features**: Aurora PostgreSQL hỗ trợ một số tính năng không có trong **RDS PostgreSQL**, chẳng hạn như Babelfish để di chuyển cơ sở dữ liệu và global databases..
- **Compatibility**: Cả hai đều tương thích với các ứng dụng PostgreSQL, nhưng Aurora PostgreSQL có những hạn chế về các phiên bản được hỗ trợ.
- **Management**: Cả hai đều là dịch vụ được quản lý hoàn toàn nhưng Aurora PostgreSQL tự động xử lý nhiều tác vụ hơn.


#### Best practices

- **Choose Aurora PostgreSQL for**: high-traffic applications, scalability requirements, mission-critical databases, strict availability needs.
- **Choose RDS PostgreSQL for**: budget-sensitive applications, simple workloads, specific PostgreSQL features not available in Aurora, need for wider range of supported versions.