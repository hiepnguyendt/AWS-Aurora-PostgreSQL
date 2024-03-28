---
title : "RDS Performance Insights"
date :  "`r Sys.Date()`" 
weight : 7
chapter : false
pre : " <b> 7. </b> "
---

Phần thực hành này sẽ thể hiện việc sử dụng Amazon RDS Performance Insights. Amazon RDS Performance Insights (RDS PI) giám sát tải của các Amazon RDS DB instance của bạn để bạn có thể phân tích và khắc phục sự cố về hiệu suất cơ sở dữ liệu.

Lab này bao gồm các tasks sau:

- Tải dữ liệu mẫu vào cụm cơ sở dữ liệu Aurora PostgreSQL
- Tìm hiểu giao diện RDS Performance Insights
- Sử dụng RDS Performance Insights để xác định vấn đề về hiệu suất
    - Insert một lượng lớn dữ liệu vào cụm Aurora DB bằng cách sử dụng pgbench
    - Update một lượng lớn dữ liệu vào cụm Aurora DB bằng cách sử dụng pgbench

#### Tải dữ liệu mẫu vào cụm cơ sở dữ liệu Aurora PostgreSQL
1. Đầu tiên, tải về tất cả các script cần thiết được sử dụng trong lab này. Mở một terminal Cloud9 và dán các lệnh dưới đây.
    ```
    cd
    wget wget https://aupg-fcj-assets.s3.us-west-2.amazonaws.com/lab-scripts/aupg-scripts.zip
    unzip aupg-scripts.zip

    ```
    ![PI](/images/7/1.png)

2. Tạo một schema HR mẫu bằng cách chạy các lệnh sau trên terminal Cloud9:

    ```
    cd /home/ec2-user/aupg-scripts/scripts
    psql -f postgres-hr.sql # runs a PostgreSQL script named postgres-hr.sql

    ```   
    ![PI](/images/7/2.png)

#### Tìm hiểu giao diện RDS Performance Insights
1. Trong khi lệnh đang chạy, hãy mở Amazon RDS service [console](https://console.aws.amazon.com/rds/)  trên một tab mới, nếu chưa mở trước đó.

    ![PI](/images/7/3.png)

2. Tiếp theo, chọn **DB instance** mong muốn để tải các chỉ số hiệu suất. Đối với các cụm Aurora DB, các chỉ số hiệu suất được đưa ra dựa trên từng DB instance cụ thể. Các DB instance khác nhau trong cụm có thể chạy các mẫu công việc khác nhau và có thể không có Performance Insights được kích hoạt cho tất cả các DB instance. Trong lab này, chúng ta chỉ tạo tải trên DB instance Writer (Primary) duy nhất.
    ![PI](/images/7/4.png)

3. Sau khi chọn một DB instance, bạn sẽ thấy giao diện chính của bảng điều khiển RDS Performance Insights. Bảng điều khiển được chia thành hai phần, cho phép bạn điều chỉnh từ các chỉ số hiệu suất cấp cao xuống đến từng individual waits, queries, users và hosts generating load.
    ![PI](/images/7/7.png)
     ![PI](/images/7/8.png)

4. Các chỉ số hiệu suất được hiển thị trên bảng điều khiển là một cửa sổ thời gian thay đổi. Bạn có thể điều chỉnh kích thước của cửa sổ thời gian bằng cách nhấp vào thời gian hiển thị ở góc trên bên phải của giao diện và chọn một khoảng thời gian tương đối (5m, 1h, 5h, 24h, 1w, custom range) hoặc chỉ định một khoảng thời gian tuyệt đối. Bạn cũng có thể phóng to vào một khoảng thời gian cụ thể bằng cách chọn và kéo chuột qua đồ thị.

{{% notice note %}}
Tất cả các chế độ xem trên bảng điều khiển được đồng bộ hóa theo thời gian. Phóng to sẽ điều chỉnh tất cả các chế độ xem, bao gồm cả phần chi tiết tìm hiểu chi tiết ở phía dưới.
{{% /notice %}}

***Dưới đây là một tóm tắt về tất cả các phần của RDS Performance Insights console:***

|Section|Filters|Description|
|-------|-------|-----------|
| Database load|Load can be sliced by waits (default), application, database, hosts, session types, SQL commands and users|This metric is designed to correlate aggregate load (sliced by the selected dimension) with the available compute capacity on that DB instance (number of vCPUs). Load is aggregated and normalized using the Average Active Session (AAS) metric. A number of AAS that exceeds the compute capacity of the DB instance is a leading indicator of performance problems.|
|Granular Session Activity|Sort by **Waits, SQL (default), Hosts, Users, Session types, applications and databases**|Drill down capability that allows you to get detailed performance data down to the individual commands. Amazon Aurora PostgreSQL specific wait events are documented in the Amazon Aurora PostgreSQL Reference [guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Reference.html#AuroraPostgreSQL.Reference.Waitevents).|
|Metrics Dashboard|Click **Metrics-new** tab beside **Dimensions** to view counter metrics|This section plots OS metrics, database metrics and CloudWatch metrics all in one place, such as number of rows read or written, transactions committed, etc. These metrics are useful to identify causes of abnormal behavior.|

5. Giao diện của metric dashboard.

    ![PI](/images/7/5.png)

#### Sử dụng RDS Performance Insights để xác định vấn đề về hiệu suất
Trong phần này, chúng ta sẽ tìm hiểu cách sử dụng Performance Insights và các PostgreSQL extension để phân tích các top wait events và vấn đề hiệu suất. Chúng ta sẽ chạy một số trường hợp thử nghiệm tải ghi và cập nhật bằng cách sử dụng tiện ích pgbench trên bảng employees trong schema HR.
1. Tạo pg_stat_statements extension
    
     Trong một session psql mới, kết nối vào cơ sở dữ liệu "mylab" và chạy lệnh SQL sau:
    {{% notice note %}}
Hãy chắc chắn sử dụng một session psql mới, nếu không, view pg_stat_statements của bạn sẽ được tạo trong schema hr.
{{% /notice %}}
 
    ```
    psql
    CREATE EXTENSION pg_stat_statements;
    \q

    ```
![PI](/images/7/6.png)
    Bây giờ, chúng ta đã sẵn sàng để chạy một số tải lên Aurora Instance để hiểu về khả năng của RDS Performance Insights.

2. Insert một lượng lớn dữ liệu vào cụm Aurora DB bằng cách sử dụng pgbench
- Trên cửa sổ terminal của Cloud9, chạy lệnh pgbench workload bằng câu lệnh dưới đây:
    ```
    pgbench -n -c 10 -T 300 -f /home/ec2-user/aupg-scripts/scripts/hrload1.sql  > /tmp/pgload1-run1.log

    ```

    Tập lệnh SQL **hrload1.sql** sẽ đưa vào cơ sở dữ liệu các bản ghi nhân viên bằng cách sử dụng hàm **PL/pgSQL add_employee_data**. Hàm này sử dụng **employee_seq** để tạo ra **employee_id** tiếp theo, tạo dữ liệu ngẫu nhiên bao gồm **first_name**, mức lương với **department_id** từ bảng departments. Mỗi lần gọi hàm sẽ chèn vào 5 bản ghi. Thử nghiệm này sẽ được thực hiện trong vòng 5 phút với 10 client.

- Xem xét PI dashboard (Performance Insights) và kiểm tra các top wait events, AAS (Average Active Sessions) trong suốt thời gian.
    ![PI](/images/7/7.png)
    ![PI](/images/7/8.png)

    Dưới đây là danh sách top 3 wait events:

    - **IO:XactSync** - Trong sự kiện chờ này, một phiên đang thực hiện lệnh **COMMIT** hoặc **ROLLBACK**, đòi hỏi các thay đổi của giao dịch hiện tại được lưu trữ. Aurora đang chờ đợi Aurora storage xác nhận việc lưu trữ.

    - **CPU**

    - **LWLock:Buffer_content** - Trong sự kiện chờ này, một phiên đang chờ đợi để đọc hoặc ghi một trang dữ liệu trong bộ nhớ trong khi phiên khác đang khóa trang đó để ghi.
- Ghi lại các chỉ số chính trong kết quả pgbench như độ trễ trung bình (latency average) và tps (số giao dịch trên giây).
    ```
    cat /tmp/pgload1-run1.log

    ```
    
    ![PI](/images/7/9.png)

- Bây giờ, hãy kiểm tra 5 truy vấn hàng đầu theo thời gian thực thi và CPU tiêu thụ. Chạy câu lệnh SQL dưới đây để hiểu tải công việc do pgbench trên gây ra bằng cách sử dụng pg_stat_statements extension.
    ```
    psql -c "SELECT  substring(query, 1, 50) AS short_query, round(total_exec_time::numeric, 2) AS total_exec_time, calls, round(mean_exec_time::numeric, 2) AS mean_exec_time, round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 5;"

    ```
    
    {{%expand "Explain psql command" %}}
    **psql -c**: Executes a SQL command directly from the command line.\
**SELECT**: Begins the SQL query.\
**substring(query, 1, 50) AS short_query**: Displays the first 50 characters of each query for brevity.\
**round(total_exec_time::numeric, 2)** AS total_exec_time: Shows the total execution time for each query, rounded to two decimal places.\
**calls**: Indicates the number of times each query has been executed.\
**round(mean_exec_time::numeric, 2) AS mean_exec_time**: Shows the average execution time per call for each query.\
**round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu**: Calculates the percentage of total CPU time consumed by each query.\
**FROM pg_stat_statements**: Accesses the pg_stat_statements view, which stores query execution statistics.\
**ORDER BY total_exec_time DESC**: Sorts the results by total execution time in descending order (most resource-intensive queries first).\
**LIMIT 5**: Restricts the output to the top 5 results.
    {{% /expand%}}
 ![PI](/images/7/10.png)

- Hãy chạy lại hàm tương tự nhưng với 50 lệnh INSERT trong mỗi lần thực thi và kiểm tra ảnh hưởng lên các sự kiện chờ. Sử dụng tập lệnh **hrload2.sql** cho lần chạy này.

    ```
    pgbench -n -c 10 -T 300 -f /home/ec2-user/aurora-scripts/scripts/hrload2.sql >  /tmp/pgload1-run2.log

    ```
- Hãy truy cập vào PI dashboard (Performance Insights) và kiểm tra lại các top wait events và các truy vấn SQL hàng đầu hiện tại để xem có sự thay đổi nào không.
{{% notice tip %}}
Nếu bạn không thấy hoạt động mới nào trong phần tải cơ sở dữ liệu, hãy thay đổi khoảng thời gian thành **5 phút** và nhấp vào **Apply**. Sau đó, đổi lại thành **1 giờ** và nhấp vào **Apply** một lần nữa.
{{% /notice %}}
    ![PI](/images/7/11.png)
   ![PI](/images/7/12.png)

- Hãy chạy lại truy vấn **pg_stat_statements** để kiểm tra sự tiêu thụ tài nguyên hiện tại.
    ```
    psql -c "SELECT  substring(query, 1, 50) AS short_query, round(total_exec_time::numeric, 2) AS total_exec_time, calls, round(mean_exec_time::numeric, 2) AS mean_exec_time, round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 5;"

    ```
    ![PI](/images/7/13.png)
    
- Nếu bạn so sánh các sự kiện chờ hàng giữa hai lần chạy pgbench, bạn sẽ nhận thấy rằng các sự kiện chờ liên quan đến IO:XactSync đã giảm trong lần chạy mới nhất.
- Bạn có thể xác minh xem thông lượng tổng thể (về số lần inserts) có tăng hay không bằng cách so sánh thông lượng và độ trễ được báo cáo bởi pgbench giữa các lần chạy?

    ```
    cat /tmp/pgload1-run2.log

    ```
    ![PI](/images/7/14.png)

3. Update một lượng lớn dữ liệu vào cụm Aurora DB bằng cách sử dụng pgbench
Trong phần này, chúng ta sẽ chạy các câu lệnh UPDATE trên bảng employee bằng cách sử dụng các hàm **update_employee_data_fname** và **update_employee_data_empid**.

- Trên terminal của Cloud9, hãy chạy pgbench update workload bằng cách sử dụng lệnh dưới đây:

    ```
    pgbench -n -c 10  -T 180 -f /home/ec2-user/aurora-scripts/scripts/hrupdname.sql > /tmp/pgload2-run1.log
    ```

    Tập lệnh SQL **hrupdname.sql** sẽ cập nhật thông tin lương của nhân viên trong bảng employees bằng cách sử dụng hàm **PL/pgSQL update_employee_data_fname**. Hàm này sẽ ngẫu nhiên chọn các bản ghi nhân viên và kiểm tra xem mức lương của họ có nằm trong khoảng (mức lương tối thiểu và tối đa của công việc của họ) hay không. Nếu không, hàm sẽ cập nhật mức lương của nhân viên bằng cách sử dụng **first_name** của họ. Mỗi lần gọi hàm sẽ chọn ngẫu nhiên 5 bản ghi. Thử nghiệm này sẽ được thực hiện trong 3 phút với 10 clients.

- Hãy truy cập vào RDS PI dashboard (Performance Insights). Kiểm tra các top wait events và AAS (Average Active Sessions) trong suốt thời gian chạy của quá trình
    ![PI](/images/7/15.png)
    ![PI](/images/7/16.png)

    Top wait event is:

    **CPU**

    Hãy kiểm tra các chỉ số sử dụng CPU (CPU utilization) trên các đồ thị CloudWatch cho cụm Aurora bằng cách thực hiện các bước sau:
    ![PI](/images/7/17.png)

    Hãy cập nhật đồ thị để hiển thị giá trị trung bình trong 1 phút. Như bạn có thể thấy, CPUUtilization đạt đến khoảng ~100% trong suốt quá trình thử nghiệm tải cập nhật.
    ![PI](/images/7/18.png)

- Hãy xem xét các thống kê hiệu suất bằng cách sử dụng pg_stat_statements extension.

    Hãy chạy lệnh dưới đây và quan sát 5 câu truy vấn hàng đầu tiêu thụ CPU.
    ```
    psql -c "SELECT  substring(query, 1, 50) AS short_query, round(total_exec_time::numeric, 2) AS total_exec_time, calls, round(mean_exec_time::numeric, 2) AS mean_exec_time, round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 5;"

    ```
    ![PI](/images/7/19.png)

    Hãy xem explain plan được sử dụng bởi các câu lệnh SQL trong hàm PL/pgSQL. Để ghi lại explain plan trong nhật ký (logs), hãy thiết lập các thông số cơ sở dữ liệu (DB parameters) dưới đây ở mức phiên làm việc của bạn.

    ```
    psql
    set auto_explain.log_nested_statements=1;
    set auto_explain.log_min_duration=10;  

    ```
    Điều này sẽ ghi lại bất kỳ câu lệnh SQL nào, bao gồm cả các câu lệnh SQL lồng nhau, mà mất nhiều hơn 10ms trong tệp error/postgres.log cùng với explain plan tương ứng.

- Hãy chạy lệnh EXPLAIN ANALYZE để ghi lại explain plan cũng như thực thi câu truy vấn.

    ```
    EXPLAIN ANALYZE SELECT  hr.update_employee_data_fname(10);
    \q
    # hr.update_employee_data_fname(10): Calls the function update_employee_data_fname within the hr schema, passing the argument 10
    ```
    ![PI](/images/7/20.png)

- Bây giờ, hãy chạy lại tải công việc bằng cách sử dụng Tập lệnh SQL **hrupdid.sql** để sử dụng cột **employee_id** để cập nhật bảng employees.
- Trên terminal của Cloud9, hãy chạy pgbench workload bằng cách sử dụng lệnh dưới đây.

    ```
    pgbench -n -c 10  -T 180 -f /home/ec2-user/aurora-scripts/scripts/hrupdid.sql > /tmp/pgload2-run2.log

    ```

    Điều này sẽ cập nhật thông tin lương của nhân viên trong bảng employees bằng cách sử dụng hàm PL/pgSQL update_employee_data_empid. Hàm này sẽ ngẫu nhiên chọn các bản ghi nhân viên và kiểm tra xem mức lương của họ có nằm trong khoảng (mức lương tối thiểu và tối đa công việc của họ) hay không. Nếu không, hàm sẽ cập nhật mức lương của nhân viên bằng cách sử dụng employee_id của họ. Mỗi lần gọi hàm sẽ chọn ngẫu nhiên 5 bản ghi. Thử nghiệm này sẽ được thực hiện trong 3 phút với 10 clients.

- So sánh kết quả thực thi bằng cách sử dụng câu truy vấn pg_stat_statements.

    ```
    psql -c "SELECT  substring(query, 1, 50) AS short_query, round(total_exec_time::numeric, 2) AS total_exec_time, calls, round(mean_exec_time::numeric, 2) AS mean_exec_time, round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 5;"

    ```
    ![PI](/images/7/22.png)

- So sánh thống kê về throughput và độ trễ được báo cáo bởi pgbench giữa các lần chạy.
    ```
    cat /tmp/pgload2-run1.log
    cat /tmp/pgload2-run2.log

    ```
    ![PI](/images/7/23.png)