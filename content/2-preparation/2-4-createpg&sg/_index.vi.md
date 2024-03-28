---
title : "Tạo Subnet Group và Parameter Group"
date :  "`r Sys.Date()`" 
weight : 4
chapter : false
pre : " <b> 2.4. </b> "
---


#### Để tạo DB subnet group trên AWS, hãy làm theo các bước sau:

1. Truy cập giao diện Amazon RDS [console](https://console.aws.amazon.com/rds/)
2. Trong ngăn điều hướng, chọn **Subnet groups** và click vào **Create DB Subnet Group**.
    ![Create SG](/images/1/1.1/1.1.png)

3. Tại mục **Name** và **Description**, nhập tên và mô tả cho DB group.
4. Tại mục **VPC**, chọn VPC mà bạn muốn tạo DB group.
    ![Create SG](/images/1/1.1/1.2.png)

5. Chọn các subnet mà bạn muốn đưa vào DB subnet group của mình. Đảm bảo chọn subnet ở ít nhất hai Availability Zones (AZ) khác nhau.
    ![Create SG](/images/1/1.1/1.3.png)

6. Chọn **Create**.

DB subnet group của bạn sẽ được tạo và hiển thị trong danh sách của DB subnet groups.

**Dưới đây là một số điều bổ sung cần lưu ý khi tạo DB subnet groups:**
- Bạn chỉ có thể tạo DB subnet group trong VPC nằm trong cùng AWS Region với cơ sở dữ liệu mà bạn định sử dụng.
- Bạn phải có ít nhất một subnet trong mỗi AZ mà bạn muốn triển khai DB instance của mình.
- Bạn không thể sửa đổi DB subnet group sau khi nó đã được tạo. Nếu bạn cần thay đổi các subnet trong DB subnet group của mình, bạn phải tạo một subnet mới.
- Bạn có thể sử dụng DB subnet group để tạo DB instance ở bất kỳ AZ nào trong VPC.




#### Tạo Database Parameter Group 
1. Truy cập giap diện [AWS RDS console](https://us-east-1.console.aws.amazon.com/rds/home?region=us-east-1), chọn **Parameter Group**, chọn **Create parameter group**.
    ![Create PG](/images/1/1.1/00.png)

2. Tại phần **Parameter group details** 
- Tại mục **Parameter group family**, chọn **aurora-postgresql15**
- Tại mục **Type**, chọn **DB Parameter Group**
- Tại mục **Group Name**, đặt tên cho parameter group
- Tại mục **Description**, nhập mô tả
    ![Create PG](/images/1/1.1/0.3.png)
- Click **Create**

3. Thay đổi và kích hoạt một số cấu hình trong Parameter Group 
- Truy cập Parameter Group console, click **Action**, chọn **Edit**
    ![Create PG](/images/1/1.1/000.png)

- Nhập ``shared_preload_libraries`` trong thanh tìm  kiếm parameter, sau đó chọn **shared_preload_libraries**
    ![Create PG](/images/1/1.1/0.4.png)
- Click **Save Changes**

**Về shared_preload_libraries parameter**
{{%expand "Tham số Shared_preload_libraries đóng vai trò quan trọng trong việc định cấu hình phiên bản Aurora PostgreSQL của bạn. " %}}
**Mục đích:**

Tham số này chỉ định thư viện dùng chung nào được tải trước khi Aurora PostgreSQL server của bạn khởi động. Việc tải trước các thư viện giúp giảm chi phí tải chúng theo yêu cầu khi cần, có khả năng cải thiện hiệu suất cho các chức năng cụ thể.

- **Những thư viện nào được tải sẵn?**
    - **Built-in libraries**: Một số chức năng cốt lõi nhất định của PostgreSQL dựa vào các thư viện dùng chung được tự động tải theo mặc định. Bạn không cần cấu hình chúng trong ***Shared_preload_libraries***.
    - **Custom libraries**: Bạn có thể chỉ định các thư viện chia sẻ bổ sung để được tải trước cho các nhu cầu cụ thể. Các thư viện này có thể là:
    - **PostgreSQL extensions**: Dành cho các tính năng như full-text search hoặc xử lý dữ liệu không gian (geospatial data handling).
    - **Custom modules**: Được phát triển bởi bạn hoặc các nhà cung cấp bên thứ ba cho các chức năng độc lập.
- Lưu ý quan trọng:
    - **Performance impact**: Việc tải trước các thư viện không cần thiết có thể tiêu tốn bộ nhớ và ảnh hưởng tiêu cực đến thời gian khởi động. Chỉ nên tải trước các thư viện được sử dụng tích cực bởi ứng dụng của bạn.
    - **Security considerations**: Hãy cẩn thận khi thêm các thư viện tùy chỉnh do tiềm ẩn các lỗ hổng về bảo mật. Đảm bảo rằng chúng đến từ các nguồn đáng tin cậy và được kiểm tra kỹ lưỡng.
    - **Restart requirement**: Sửa đổi shared_preload_libraries yêu cầu khởi động lại phiên bản Aurora PostgreSQL của bạn để thay đổi có hiệu lực.
{{% /expand%}}


#### Tạo Database Cluster Parameter Group 
1. Truy cập giao diện [AWS RDS console](https://us-east-1.console.aws.amazon.com/rds/home?region=us-east-1), chọn **Parameter Group**, chọn **Create parameter group**.
    ![Create PG](/images/1/1.1/00.png)

2. Ở phần **Parameter group details**
- Tại mục **Parameter group family**, chọn **aurora-postgresql15**
- Tại mục **Type**, chọn **DB Cluster Parameter Group**
- Tại mục **Group Name**, đặt tên cho parameter
- Tại mục **Description**, nhập mô tả cho parameter
    ![Create PG](/images/1/1.1/0.png)
- Chọn **Create**
3. Thay đổi và kích hoạt một số cấu hình cho parameter group
- Đi đến Parameter Group console, click **Action**, chọn **Edit**
    ![Create PG](/images/1/1.1/0001.png)

- Nhập ``log_rotation`` ở thanh tìm kiếm parameter, 
- Tùy chỉnh **log_rotation_age** value: ``1440``
- Tùy chỉnh **log_rotation_size** value: ``102400``

    ![Create PG](/images/1/1.1/0.2.png)
- Click **Save Changes**

**About log_rotation_age & log_rotation_size parameter**

{{%expand "log_rotation_age" %}}
**Function**:

- log_rotation_age xác định số lần xoay tối đa tính bằng phút cho các tệp nhật ký riêng lẻ trong cụm. Khi tệp đạt đến giới hạn này, nó sẽ tự động được thay đổi và một tệp mới sẽ được tạo. Tham số này giúp quản lý dung lượng ổ đĩa bằng cách ngăn chặn các tệp nhật ký phát triển vô thời hạn.

**Configuration**:

- Không giống như standalone instance nơi bạn có thể đặt log_rotation_age trong tệp postgresql.conf hoặc thông qua dòng lệnh, tham số này cần được đặt cấu hình thông qua tùy chỉnh Aurora PostgreSQL parameter group. Bạn có thể đặt giá trị mong muốn trong nhóm tham số và áp dụng nó cho cụm của mình.

**Impact**:

- Việc đặt giá trị log_rotation_age ngắn hơn sẽ dẫn đến việc thay đổi thường xuyên hơn và tệp nhật ký mới hơn nhưng cũng có thể tăng hoạt động I/O của ổ đĩa và có khả năng ảnh hưởng đến hiệu suất. số lần xoay dài hơn làm giảm việc thay đổi tệp nhưng vẫn giữ lại các nhật ký cũ hơn, điều này có thể không cần thiết cho nhu cầu của bạn.

**Important Notes**:

- RDS log rotation feature: Mặc dù RDS console liệt kê log_rotation_age dưới dạng tham số có thể định cấu hình cho tính năng xoay vòng nhật ký tích hợp nhưng bảng điều khiển này hiện không có tác dụng trên các cụm Aurora PostgreSQL. Bạn vẫn cần sử dụng nhóm tham số tùy chỉnh để kiểm soát việc xoay vòng của tệp.
- CloudWatch Logs integration: Aurora PostgreSQL tự động truyền nhật ký tới CloudWatch Logs theo mặc định. Bạn có thể định cấu hình các chính sách lưu giữ theo số lần xoay trong CloudWatch để quản lý tổng số lần xoay vòng nhật ký sử dụng của dữ liệu, bất kể xoay vòng tệp.
**Recommendations**:

- Chọn giá trị log_rotation_age cân bằng giữa nhu cầu quản lý dung lượng ổ đĩa với việc lưu giữ đủ lịch sử nhật ký để khắc phục sự cố và phân tích.
- Hãy cân nhắc việc theo dõi hiệu suất cụm của bạn và điều chỉnh giá trị tham số nếu cần.
- Sử dụng CloudWatch Logs để lưu giữ và phân tích nhật ký lâu dài ngoài các chế độ xoay tệp do log_rotation_age quản lý.

{{% /expand%}}

{{%expand "log_rotation_size" %}}
**Function**:

- log_rotation_size chỉ định kích thước tối đa (tính bằng kilobyte) cho một tệp nhật ký riêng lẻ trước khi nó tự động xoay và một tệp mới được tạo. Điều này giúp ngăn chặn sự phát triển quá mức của nhật ký và giữ cho thư mục nhật ký có thể quản lý được.

**Configuration**:

- Tương tự như log_rotation_age, bạn cần định cấu hình tham số này thông qua tùy chỉnh Aurora PostgreSQL parameter group. Đặt kích thước mong muốn tính bằng kilobyte trong nhóm tham số và áp dụng nó cho cụm của bạn.

**Impact**:

- Việc chọn giá trị log_rotation_size nhỏ hơn sẽ kích hoạt việc xoay vòng thường xuyên hơn, nghĩa là các tệp nhật ký nhỏ hơn và mới hơn. Tuy nhiên, điều này có thể làm tăng hoạt động I/O của đĩa và ảnh hưởng một chút đến hiệu suất. Ngược lại, kích thước lớn hơn dẫn đến ít vòng quay hơn và có khả năng ghi nhật ký lớn hơn nhưng có thể tiêu tốn nhiều dung lượng ổ đĩa hơn.

**Important Notes**:

- Automatic file naming: Khi xoay tệp, Aurora PostgreSQL sẽ thêm các dấu thời gian hoặc số thứ tự vào tên tệp của chúng để duy trì ngữ cảnh lịch sử.
- RDS log rotation feature:: Tương tự như log_rotation_age, tính năng xoay vòng nhật ký RDS hiện không kiểm soát việc xoay vòng dựa trên kích thước trong các cụm Aurora PostgreSQL. Cách tiếp cận nhóm thông số tùy chỉnh là cần thiết.
- CloudWatch Logs integration: Bạn có thể sử dụng CloudWatch Logs với các chính sách lưu giữ dựa trên kích thước để lưu trữ hoặc xóa các tệp nhật ký đã xoay sau khi vượt quá một kích thước cụ thể.

**Recommendations**:

- Chọn giá trị log_rotation_size cân bằng giữa việc quản lý dung lượng ổ đĩa với nhu cầu phân tích nhật ký của bạn. Xem xét khối lượng và kích thước của các tệp điển hình của bạn để ước tính khoảng thời gian luân chuyển thích hợp.
- Theo dõi hiệu suất cụm của bạn và điều chỉnh giá trị tham số nếu cần thiết để tránh xoay quá mức hoặc tệp nhật ký lớn.
- Tận dụng CloudWatch Logs để quản lý và lưu giữ nhật ký lâu dài, không phụ thuộc vào các hoạt động xoay do log_rotation_size kiểm soát.
- Hãy nhớ rằng việc tối ưu hóa cả log_rotation_age và log_rotation_size cho phép bạn quản lý hiệu quả các tệp nhật ký của cụm Aurora PostgreSQL, đảm bảo có đủ dữ liệu để phân tích đồng thời hạn chế mức sử dụng ổ đĩa và các tác động tiềm ẩn đến hiệu suất.

{{% /expand%}}


