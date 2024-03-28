---
title : "Thiết lập thông báo sự kiện failover"
date :  "`r Sys.Date()`" 
weight : 1
chapter : false
pre : " <b> 9.1. </b> "
---


Để nhận thông báo khi xảy ra sự cố chuyển giao tự động với cụm DB của bạn, bạn sẽ tạo một chủ đề Amazon Simple Notification Service (SNS), đăng ký địa chỉ email của bạn vào chủ đề SNS, tạo một đăng ký sự kiện RDS xuất bản sự kiện vào chủ đề SNS và đăng ký cụm DB làm nguồn sự kiện.

1. Vui lòng mở một terminal Cloud9, sau đó dán lệnh sau để tạo một SNS Topic.

    ```
    aws sns create-topic \
    --name auroralab-cluster-failovers

    ```
    Nếu thành công, lệnh sẽ phản hồi lại với một định danh TopicArn, bạn sẽ cần giá trị này trong lệnh tiếp theo.
    ![failover](/images/9/9.1/1.png)

2. Tiếp theo, đăng ký địa chỉ email của bạn vào SNS Topic bằng lệnh dưới đây, thay thế giá trị [YourEmail] bằng địa chỉ email của bạn:
    ```
    aws sns subscribe \
    --topic-arn $(aws sns list-topics --query 'Topics[?contains(TopicArn,`auroralab-cluster-failovers`)].TopicArn' --output text) \
    --protocol email \
    --notification-endpoint '[YourEmail]'

    ```

    Bạn sẽ thấy đầu ra tương tự như sau:
    ![failover](/images/9/9.1/2.png)

3. Bạn sẽ nhận được một email xác minh tại địa chỉ đó, vui lòng xác nhận đăng ký bằng cách làm theo hướng dẫn trong email.
    ![failover](/images/9/9.1/3.png)

    Sau khi bạn nhấp vào **Confirm subscription** trong email, bạn sẽ thấy một cửa sổ trình duyệt với thông báo xác nhận như sau:
    ![failover](/images/9/9.1/4.png)

4. Sau khi xác nhận hoặc trong khi bạn đang chờ email xác minh đến, hãy tạo một đăng ký sự kiện RDS và đăng ký cụm DB làm nguồn sự kiện bằng lệnh dưới đây:
    {{% notice note %}}
Nếu tên cụm Aurora của bạn khác với "aupg-labs-cluster", hãy cập nhật lệnh dưới đây tương ứng
{{% /notice %}}

    ```
    aws rds create-event-subscription \
    --subscription-name auroralab-cluster-failovers \
    --sns-topic-arn $(aws sns list-topics --query 'Topics[?contains(TopicArn,`auroralab-cluster-failovers`)].TopicArn' --output text) \
    --source-type db-cluster \
    --event-categories '["failover"]' \
    --enabled
    ```
![failover](/images/9/9.1/5.png)

![failover](/images/9/9.1/6.png)  
    ```
    aws rds add-source-identifier-to-subscription \
    --subscription-name auroralab-cluster-failovers \
    --source-identifier aupg-fcj-labs

    ```
    


Lúc này, các thông báo sự kiện đã được cấu hình. Hãy đảm bảo rằng bạn đã xác minh địa chỉ email của mình trước khi tiếp tục sang phần tiếp theo.