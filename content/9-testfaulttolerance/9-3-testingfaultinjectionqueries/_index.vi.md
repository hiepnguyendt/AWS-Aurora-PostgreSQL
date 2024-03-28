---
title : "Kiểm tra các truy vấn gây lỗi (fault injection queries)"
date :  "`r Sys.Date()`" 
weight : 3
chapter : false
pre : " <b> 9.3 </b> "
---


Trong bài kiểm tra này, bạn sẽ mô phỏng một sự cố xảy ra khi dịch vụ cơ sở dữ liệu trên DB instance bị sập. Loại sự cố này có thể xảy ra trong các trường hợp thực tế do điều kiện hết bộ nhớ hoặc các tình huống không mong đợi khác.

{{%expand "Learn more about fault injection queries" %}}
Các truy vấn gây lỗi (fault injection queries) cung cấp một cơ chế để mô phỏng các lỗi khác nhau trong hoạt động của cụm DB. Chúng được sử dụng để kiểm tra khả năng chịu lỗi của các ứng dụng khách hàng đối với các lỗi như vậy. Chúng có thể được sử dụng để:

- Mô phỏng sự cố của các dịch vụ quan trọng đang chạy trên DB instance. Thông thường, điều này không dẫn đến việc chuyển đổi sang chế độ đọc (reader), nhưng sẽ dẫn đến việc khởi động lại các dịch vụ liên quan.
- Mô phỏng sự suy giảm hoặc tắc nghẽn của hệ thống, có thể là tạm thời hoặc ổn định hơn.
- Mô phỏng lỗi của read replica.

{{% /expand%}}

1. Tại một trong hai terminal, chạy script kiểm thử failover bằng cách sử dụng lệnh sau:

    ```
     python /home/ec2-user/simple_failover.py -e $DBENDP -u $DBUSER -p $DBPASS -d $PGDATABASE
    ```
    Vì chúng ta đang sử dụng cluster endpoint để kết nối, script giám sát đang kết nối với writer node hiện tại.

2. Trên terminal Cloud9 khác, thực hiện lệnh gây lỗi sau đây. Một lỗi của cơ sở dữ liệu tương thích PostgreSQL cho phiên bản Amazon Aurora sẽ được mô phỏng.
    ```
    psql -c "SELECT aurora_inject_crash ('instance');"

    ```

    ![test](/images/9/9.2/1.png)

2. Vui lòng đợi và quan sát đầu ra của script giám sát. Khi lỗi được kích hoạt, bạn sẽ thấy một đầu ra tương tự như ví dụ dưới đây.

    ![test](/images/9/9.2/2.png)

Như bạn đã thấy ở trên, DB instance đã được khởi động lại và script giám sát đã kết nối lại sau một khoảng thời gian gián đoạn ngắn.