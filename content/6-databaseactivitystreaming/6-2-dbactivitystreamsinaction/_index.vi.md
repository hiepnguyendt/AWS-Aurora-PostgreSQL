---
title : "Hoạt động của Database Activity Streams"
date :  "`r Sys.Date()`" 
weight : 2 
chapter : false
pre : " <b> 6.2. </b> "
---

**Database Activity Streams** cung cấp một luồng dữ liệu gần thời gian thực về hoạt động của cơ sở dữ liệu quan hệ của bạn. Khi tích hợp Database Activity Streams với các công cụ giám sát của bên thứ ba, bạn có thể theo dõi và kiểm tra hoạt động của cơ sở dữ liệu.

Trong phần này của lab, trước tiên chúng ta sẽ cấu hình và khởi động database activity streams, sau đó chúng ta sẽ tạo ra một số tải và quan sát đầu ra của database activity streams.

#### Cấu hình Database Activity Streams
Bạn bắt đầu một activity stream ở mức DB cluster để giám sát hoạt động cơ sở dữ liệu cho tất cả các DB instances trong cluster. Bất kỳ DB instances nào được thêm vào cluster cũng sẽ được giám sát tự động.

Bạn có thể lựa chọn để session cơ sở dữ liệu xử lý các sự kiện hoạt động của cơ sở dữ liệu theo cách đồng bộ hoặc không đồng bộ:


1. **Synchronous mode**: Với Synchronous mode, khi một session cơ sở dữ liệu tạo ra một sự kiện activity stream, session sẽ chặn cho đến khi sự kiện trở nên ổn định. Nếu vì một lý do nào đó sự kiện không thể trở nên ổn định, session cơ sở dữ liệu sẽ trở lại hoạt động bình thường. Tuy nhiên, một sự kiện RDS được gửi để thông báo rằng các bản ghi activity stream có thể bị mất trong một khoảng thời gian. Một sự kiện RDS thứ hai được gửi sau khi hệ thống trở lại trạng thái bình thường.

***Synchronous mode ưu tiên độ chính xác của luồng hoạt động hơn hiệu suất cơ sở dữ liệu.***

2.** Asynchronous mode**: Với asynchronous mode, khi một session cơ sở dữ liệu tạo ra một sự kiện activity stream, session sẽ trở lại hoạt động bình thường ngay lập tức. Ở nền, sự kiện activity stream được biến thành một bản ghi bền vững. Nếu xảy ra lỗi trong nhiệm vụ nền, một sự kiện RDS được gửi. Sự kiện này cho biết thời gian bắt đầu và kết thúc của bất kỳ khoảng thời gian nào có thể bị mất bản ghi sự kiện activity stream.

***Asynchronous mode ưu tiên hiệu suất cơ sở dữ liệu hơn là độ chính xác của activity stream***

#### Start activity streams
1. Truy cập giao diện [Amazon RDS service console Databases section](https://console.aws.amazon.com/rds/home?#databases:) .

2. Chọn **Aurora DB cluster** mà bạn đã tạo.

3. Click vào menu **Actions** và chọn **Start activity stream**.
    ![streaming](/images/6/6.2/1.png)

4. Nhập các thiết lập sau trong Database Activity Stream window:

- Đối với **AWS KMS key**, hãy chọn khóa mà bạn đã tạo trong bước trước đó. Nếu bạn không thấy khóa mới - hãy thử làm mới cửa sổ trình duyệt.
- Đối với Database activity stream, chọn **Asynchronous**.
- Chọn **Apply immediately**.
    ![streaming](/images/6/6.2/2.png)
    ![streaming](/images/6/6.2/3.png)
6. Cột "Status" trên trang RDS Database for cluster sẽ bắt đầu hiển thị **configuring-activity-stream** (đang cấu hình activity stream).
    ![streaming](/images/6/6.2/4.png)

7. Xác minh hoạt động streaming bằng cách nhấp vào tên cluster và nhấp vào cấu hình. Bạn sẽ thấy tên luồng Kinesis mà Database Activity Stream sẽ được tạo.
    ![streaming](/images/6/6.2/5.png)

8. Hãy đợi cho đến khi trạng thái trên trang RDS Database for cluster thay đổi trở lại thành **Available** (Đã sẵn sàng). Việc này có thể mất đến 10 phút để thay đổi trạng thái.

#### Tạo tải trên cluster Aurora
1. Mở Cloud9 terminal và chạy lệnh **pgbench**
    ```
    pgbench --protocol=prepared --progress=60 --time=300 --client=16 --jobs=96 > results1.log

    ```
#### Dưới đây là một sample code để xem Database Activity Streams:
1. Mở Cloud9 terminal, tải sample python script das-script.py, với lệnh dưới đây:

    ```
    wget https://aupg-fcj-assets.s3.us-west-2.amazonaws.com/lab-scripts/das-scripts.py
    ```

2. Trong đoạn mã này, bạn sẽ cần thay đổi giá trị cho **REGION_NAME** tùy theo AWS region mà bạn đang thực hiện lab này, ví dụ: us-west-2, và **RESOURCE_ID** với giá trị Resource ID của cluster Aurora. 

3. Mở một terminal Cloud9 mới và dán code sau để chỉnh sửa tập lệnh Python:

    ```
    nano /home/ec2-user/das-script.py
    ```
4. Cập nhật các biến sau (**REGION_NAME** và **RESOURCE_ID**) trong đoạn mã dựa trên cài đặt thực tế của bạn:
5. Để lưu tệp sau khi thay đổi trong trình soạn thảo **Nano**, nhấn **CTRL-X**, nhập **Y** và sau đó nhấn **Enter**.

6. Để xem Database Activity Stream, hãy chạy tập lệnh Python như được hiển thị dưới đây:

    ```
    python3 /home/ec2-user/das-script.py

    ```

Bạn sẽ thấy rất nhiều messages trong output terminal với định dạng JSON.

#### Sample Output Activity Streaming
1. Để định dạng đầu ra từ Database Activity Streaming và hiểu kết quả, bạn có thể sử dụng một công cụ miễn phí như [JSON formatter](https://jsonformatter.org/) .

2. Vui lòng sao chép một đoạn mã **das-script.py** bắt đầu từ **{"type":** và kết thúc bằng **}** như được hiển thị trong ảnh chụp màn hình dưới đây và dán nó vào **JSON formatter**. Sau đó, nhấn **Format / Beautify**. Bạn sẽ thấy hoạt động của cơ sở dữ liệu được định dạng tương tự như sau:
    ![DAS](/images/6/6.2/6.png)

#### Dừng Database Activity Streaming

1. Truy cập giao diện [Amazon RDS console](https://console.aws.amazon.com/rds/) .

2. Trong thanh điều hướng, chọn Databases và chọn cụm cơ sở dữ liệu Aurora mà bạn đã tạo thủ công.

3. Click vào **Action** và chọn **Stop database activity stream**.
    ![DAS](/images/6/6.2/7.png)

4. Chọn **Apply immediately** và click **Continue** để dừng Database activity streaming.
    ![DAS](/images/6/6.2/9.png)

5. Cột trạng thái trên trang chủ RDS Database cho cụm cơ sở dữ liệu sẽ bắt đầu hiển thị **configuring-activity-stream**.
    ![DAS](/images/6/6.2/10.png)

6. Sau một thời gian, hoạt động của activity stream sẽ được dừng lại và cột trạng thái trên trang chủ RDS Database cho cụm cơ sở dữ liệu sẽ chuyển về **Available**.

