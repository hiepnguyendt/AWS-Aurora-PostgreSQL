---
title : "Tạo dataset và Auto Scale"
date :  "`r Sys.Date()`" 
weight : 8 
chapter : false
pre : " <b> 8. </b> "
---

**Aurora Auto Scaling** cho phép cụm cơ sở dữ liệu Aurora của bạn xử lý tăng trưởng đột ngột về kết nối hoặc khối lượng công việc bằng cách tự động điều chỉnh số lượng Aurora Replicas cho một cụm cơ sở dữ liệu Aurora được cung cấp. Khi kết nối hoặc khối lượng công việc giảm, Aurora Auto Scaling loại bỏ các Aurora Replicas không cần thiết để bạn không phải trả tiền cho các DB instances không sử dụng.

Trong lab này, chúng ta sẽ tìm hiểu cách Aurora read replica auto scaling hoạt động trong thực tế bằng cách sử dụng một tập lệnh tạo tải (load generator script).

Lab này bao gồm các task sau:
- Cấu hình Aurora Replica Auto Scaling
- Khởi tạo pgbench và Tạo tập dữ liệu
- Chạy read-only workload

1. Tạo replica auto scaling policy
- Bạn sẽ thêm cấu hình tự động mở rộng cho read replica vào cụm cơ sở dữ liệu (DB cluster). Điều này cho phép cụm DB tự động điều chỉnh số lượng read instance trong cụm tại bất kỳ thời điểm nào dựa trên workload.

- Nhấp vào tên cụm Aurora và chuyển đến tab **Logs & events**. Nhấp vào **Add auto scaling** để thêm policy.

    ![ACL](/images/8/1.png)

- Nhập ``auroralab-autoscale-readers`` vào trường **Policy Name**. Đối với **Target metric**, chọn **Average CPU utilization of Aurora Replicas**. Nhập **Target value** là 20%. Trong môi trường production, giá trị này có thể được đặt cao hơn nhiều, nhưng chúng ta đang sử dụng một giá trị thấp cho mục đích thử nghiệm.

- Tiếp theo, mở rộng phần **Additional configuration**, và thay đổi cả **Scale in cooldown period** và **Scale out cooldown period** thành giá trị 180 giây. Điều này sẽ giảm thời gian bạn phải chờ đợi giữa các hoạt động tự động mở rộng trong các lab tiếp theo.
    ![ACL](/images/8/2.png)

- Trong phần **Cluster capacity details**, đặt **Minimum capacity** thành 1 và **Maximum capacity** thành 2. Trong môi trường production, bạn có thể cần sử dụng các giá trị khác nhau. Tuy nhiên, cho mục đích thử nghiệm và để giới hạn chi phí liên quan đến các lab, chúng ta giới hạn số lượng reader là 2.
    ![ACL](/images/8/3.png)

- Tiếp theo click **Add policy**.


2. Khởi tạo pgbench và tạo a Dataset
- Vui lòng mở một terminal Cloud9, sau đó khởi tạo pgbench để bắt đầu tạo Dataset bằng cách dán lệnh dưới đây vào terminal của bạn.
    ```
    pgbench -i --scale=1000

    ```

     Quá trình tải dữ liệu có thể mất vài phút, sau khi hoàn thành, bạn sẽ nhận được đầu ra tương tự:
    ![ACL](/images/8/4.png)

3. Chạy read-only workload
- Sau khi quá trình tải dữ liệu hoàn tất thành công, bạn có thể chạy read-only workload trên cụm (để chúng ta có thể kích hoạt chính sách tự động mở rộng) và quan sát hiệu ứng lên topology của cụm cơ sở dữ liệu.

- Trong bước này, bạn sẽ sử dụng **Reader Endpoint** của cụm. Bạn có thể tìm thấy **reader endpoint** bằng cách truy cập vào phần **RDS Console - Databases**, nhấp vào tên cụm Aurora và chuyển đến tab **Connectivity & security**.

- Hãy chạy load generation scrip từ terminal Cloud9 của bạn bằng cách thay thế dòng lệnh sau:
[readerEndpoint] placeholder with the actual Aurora cluster reader endpoint:

    ```
    pgbench -h [readerEndpoint] -c 100 --select-only -T 600 -C

    ```

- Bây giờ, truy cập giao diện Amazon RDS management [console](https://console.aws.amazon.com/rds/home?#databases:)  ở tab trình duyệt khác.

- Lưu ý rằng reader node hiện đang nhận tải. Có thể mất một phút hoặc hơn để các số liệu thể hiện đầy đủ.
- Sau vài phút, quay lại danh sách các instance và lưu ý rằng một reader mới đang được triển khai trong cụm của bạn.
    ![ACL](/images/8/5.png)

- Việc thêm một bản sao mới có thể mất từ 5 đến 7 phút. Khi bản sao mới trở thành khả dụng, lưu ý rằng tải được phân phối và ổn định (có thể mất vài phút để ổn định).
    ![ACL](/images/8/6.png)

- Bây giờ bạn có thể chuyển lại terminal Cloud9 của mình và nhấn CTRL+C để dừng công việc pgbench đang chạy.