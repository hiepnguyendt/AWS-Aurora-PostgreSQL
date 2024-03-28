---
title : "Test a manual DB cluster failover"
date :  "`r Sys.Date()`" 
weight : 2
chapter : false
pre : " <b> 9.2. </b> "
---


Trong lab này, chúng ta sẽ sử dụng một script Python để kết nối tới cluster endpoint và liên tục thực thi một truy vấn giám sát..

1. Bạn sẽ cần mở một terminal Cloud9. Bạn sẽ thực thi các lệnh và xem kết quả.

2. Tải failover test script, sử dụng lệnh sau:

    ```
    wget https://aupg-fcj-assets.s3.us-west-2.amazonaws.com/lab-scripts/simple_failover.py
    ```
3. TỊ một trong hai terminal, hãy chạy script kiểm tra failover bằng lệnh sau:

    ```
     python /home/ec2-user/simple_failover.py -e $DBENDP -u $DBUSER -p $DBPASS -d $PGDATABASE
    ```

4. Trong terminal Cloud9 thứ hai, hãy thực thi lệnh để bắt đầu quá trình failover.

    ```
    aws rds failover-db-cluster --db-cluster-identifier aupg-fcj-labs

    ```

5. Ban đầu, script sẽ kết nối tới writer node và thực thi truy vấn. Bạn sẽ thấy một dừng nhẹ và một thông báo "đang chờ failover" khi quá trình failover được khởi tạo. Sau đó, thời gian mất để kết nối lại và thông tin về nút ghi mới sẽ được in ra.
    ![test](/images/9/9.2/2.png)

    Vì chúng ta đang sử dụng cluster endpoint để kết nối, sẽ có một độ trễ nhỏ để truyền các thay đổi bản ghi DNS cho writer node mới. Bạn sẽ thấy rằng trong vài giây sau failover, chúng ta vẫn đang kết nối với writer node cũ, hiện nay là reader node mới. Khi thay đổi bản ghi DNS cho cluster endpoint được truyền đến máy khách (trong trường hợp này là máy làm việc Cloud9), script sẽ cho biết nó đang kết nối với writer node.

6. Bạn sẽ nhận được hai email thông báo sự kiện cho mỗi failover mà bạn khởi tạo, một email cho biết rằng quá trình failover đã bắt đầu và một email cho biết rằng quá trình đã hoàn thành.
    ![test](/images/9/9.2/4.png)
    ![test](/images/9/9.2/5.png)

