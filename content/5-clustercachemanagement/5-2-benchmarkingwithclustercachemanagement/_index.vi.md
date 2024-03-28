---
title : "Benchmarking với Cluster Cache management"
date :  "`r Sys.Date()`" 
weight : 2 
chapter : false
pre : " <b> 5.2. </b> "
---

#### Benchmarking với Cluster Cache management

Để xác minh các lợi ích của tính năng của Cluster Cache Management trên cụm Aurora, chúng ta sẽ thực hiện các bước sau. Chúng ta sẽ khám phá các bước này chi tiết hơn trong các phần tương ứng dưới đây.
- Với CCM được kích hoạt, chúng ta sẽ chạy bài đo hiệu năng pgbench trên writer node.
- Chúng ta sẽ kiểm tra các trang được lưu trữ trong bộ nhớ cache trên cả writer node và reader node để xác minh rằng chúng được đồng bộ.
- Sau đó, chúng ta sẽ thực hiện Failover trên cụm Aurora.
- Chúng ta sẽ chạy bài đo hiệu năng pgbench trên writer node mới sau sự cố và xác minh rằng các số liệu TPS (Transaction Per Second) giữa writer node cũ và mới là tương tự.
- Sau đó, chúng ta sẽ tắt CCM.
- Chúng ta sẽ xóa bộ nhớ cache đệm trên cả writer node và reader node bằng cách dừng và khởi động lại cụm.
- Với CCM bị tắt, chúng ta sẽ chạy bài đo hiệu năng trên writer node bằng cách sử dụng pgbench lại
- Chúng ta sẽ kiểm tra các trang được lưu trữ trong bộ nhớ cache trên cả writer node và reader node để xác minh rằng chúng không được đồng bộ.
- Tiếp theo, chúng ta sẽ thực hiện Failover trên cụm Aurora một lần nữa.
- Chúng ta sẽ chạy bài đo hiệu năng pgbench trên writer node mới sau sự cố và xác minh rằng các số liệu TPS giữa writer node cũ và mới biến đổi đáng kể.

1. Tải dữ liệu lớn để thực hiện bài đo hiệu năng (benchmarking):
{{% notice note %}}
Để tái tạo bài đo hiệu năng được sử dụng trong lab, chúng ta cần thêm dữ liệu mẫu vào bài đo hiệu năng. Lệnh dưới đây sử dụng yếu tố tỷ lệ (scale factor) là 10000. Bước tùy chọn này có thể mất khoảng 15-20 phút để thêm dữ liệu vào cơ sở dữ liệu, vì vậy hãy đảm bảo bạn có đủ thời gian hoàn thành lab trước khi chạy lệnh dưới đây.
{{% /notice %}}

- Chạy lệnh sau trong terminal Cloud9 của bạn để kết nối với writer node của cụm Aurora bằng pgbench và thêm dữ liệu mẫu với scale factor = 10000

  ```
  pgbench -i --fillfactor=100 --scale=10000

  ```

- Kiểm tra kích thước cơ sở dữ liệu aupglab bằng PSQL.

  ```
  psql
  SELECT pg_size_pretty( pg_database_size('aupglab'));
  ```

{{%expand "Nếu bạn đã sử dụng scale factor 100) trong pgbench, bạn sẽ thấy kết quả của chúng ta tương tự như sau:" %}}![benchmark](/images/5/5.2/1.png)
{{% /expand%}}

{{%expand "Nếu bạn chạy pgbench với hệ số tỷ lệ 10000 ở bước trước, bạn sẽ thấy kết quả đầu ra tương tự như sau:" %}}![benchmark](/images/5/5.2/2.png)
{{% /expand%}}

### Benchmarking với CCM được kích hoạt
1. Chạy bài đo hiệu năng trên nút writer bằng pgbench (trước khi thực hiện failover):

- Bắt đầu bài đo hiệu năng pgbench trong 600 giây trên writer node của Aurora PostgreSQL với CCM (Continuous Cloud Monitoring) được kích hoạt, hãy sử dụng lệnh sau trong terminal Cloud9 của bạn:

  ```
  pgbench --progress-timestamp -M prepared -n -T 600 -P 5 -c 50 -j 50 -b tpcb-like@1 -b select-only@20 > ccm_enable_before_failover.out 
  ```

{{%expand "Giải thích câu lệnh" %}}
**pgbench**: This is a benchmarking tool for PostgreSQL databases.\
**--progress-timestamp**: Prints a timestamp with each progress report.\
**-M prepared**: Uses prepared transactions for benchmarking.\
**-n**: Specifies a no-vacuum test, which avoids vacuuming during the benchmark.\
**-T 600**: Runs the benchmark for 600 seconds (10 minutes).\
**-P 5**: Populates the database with 5 client sessions before starting the benchmark.\
**-c 50**: Runs the benchmark with 50 concurrent client connections.\
**-j 50**: Specifies 50 threads for multi-threaded operation.\
**-b tpcb-like@1**: Uses the TPC-B-like transaction mix with a weight of 1.\
**-b select-only@20**: Uses a select-only transaction mix with a weight of 20.\
**ccm_enable_before_failover.out**: Redirects the output to a file named "ccm_enable_before_failover.out".
{{% /expand%}}

{{% notice info %}}
Chúng ta đang sử dụng tùy chọn tpcb-like của pgbench để thực hiện bài đo hiệu năng và sử dụng ký hiệu "@" để chỉ định xác suất chạy công việc chỉ đọc (read-only) và công việc đọc-ghi (read-write). Trong ví dụ dưới đây, chúng ta đang chạy công việc tpcb-like với 20 lần công việc chỉ đọc và 1 lần công việc đọc-ghi trong 600 giây.
{{% /notice %}}

- Sau 600 giây khi bài đo hiệu năng hoàn tất, bạn có thể xem kết quả đầu ra của pgbench trên màn hình hoặc tham khảo tệp đầu ra "ccm_enable_before_failover.out". Kết quả tóm tắt sẽ có dạng như sau. Xin lưu ý rằng đầu ra của bạn có thể khác một chút.

  ```
  cat ccm_enable_before_failover.out
  ```
  ![benchmark](/images/5/5.2/3.png)

#### Kiểm tra số trang được lưu trữ trong bộ nhớ cache trên cả writer node và các reader node trong cụm Aurora PostgreSQL
- **Pg_buffercache** extension cung cấp một phương tiện để xem nội dung của bộ đệm (buffer cache). Chúng ta sẽ dùng pg_buffercache để xem nội dung của bộ đệm (với CCM được kích hoạt và CCM bị vô hiệu hóa) để minh họa tác động của CCM (Cluster Cache Management). Chúng ta sẽ so sánh nội dung của bộ đệm trên Writer node với Reader node.
- Khi CCM được kích hoạt, nội dung của bộ đệm trên writer node và reader node sẽ tương tự nhau, vì writer node sẽ định kỳ gửi bộ đệm của các bộ đệm được sử dụng thường xuyên (mặc định là số lần sử dụng>3) cho reader node để được đọc từ bộ nhớ lưu trữ.

1. Kết nối với Writer node bằng psql sử dụng cluster endpoint 

- Tạo extension pg_buffercache trên cơ sở dữ liệu.

  ```
  psql
  CREATE EXTENSION pg_buffercache;
  \dx pg_buffercache

  ```
  ![benchmark](/images/5/5.2/4.png)

- Xác nhận rằng bạn đã kết nối với Writer node và truy vấn xem pg_buffercache để xem số trang được lưu trữ trong bộ nhớ cache cho các bảng khác nhau

  ```
  show transaction_read_only;
  ```
  ![benchmark](/images/5/5.2/5.png)

  ```
  SELECT c.relname, count(*) AS buffers
  FROM pg_buffercache b 
  INNER JOIN pg_class c
  ON b.relfilenode = pg_relation_filenode(c.oid) 
  AND b.reldatabase IN (0, (SELECT oid FROM pg_database WHERE datname = current_database()))
  GROUP BY c.relname
  ORDER BY 2 DESC
  LIMIT 10;
  ```
  ![benchmark](/images/5/5.2/6.png)

{{%expand "Giải thích scripts" %}}
|Command| Purposes|
|-------|--------|
|SELECT c.relname, count(*) AS buffers|Queries for the relation name (relname) and the number of buffers used (count(*)), labeling the count as "buffers".|
|FROM pg_buffercache b|Accesses data from the pg_buffercache system view, which holds details about buffered pages.|
|INNER JOIN pg_class c|Combines data from pg_buffercache with information about relations from the pg_class system catalog.|
|ON b.relfilenode = pg_relation_filenode(c.oid)|Links entries based on filenodes, associating buffers with their respective relations.|
|AND b.reldatabase IN (0, (SELECT oid FROM pg_database WHERE datname = current_database()))| Includes buffers for both shared system catalogs (database 0) and the current database.|
|GROUP BY c.relname|Aggregates results based on relation names.|
|ORDER BY 2 DESC|Sorts in descending order based on the number of buffers (count(*) in position 2)|
|LIMIT 10;|Restricts output to the top 10 relations.|
{{% /expand%}}

#### Kết nối tới Read replica
1. Truy cập giao diện [Amazon RDS console](https://console.aws.amazon.com/rds/home?#database:) .

2. Trong ngăn điều hướng, chọn Databases  và nhấp vào tên của cụm Aurora mà bạn đã tạo.
3. Bên dưới **Connectivity and Security**, copy **Endpoint of type Reader**.

4. Thay thế <Aurora Reader EndPoint> bên dưới bằng Aurora reader endpoint mà bạn đã sao chép ở trên và sử dụng dòng lệnh psql để kiểm tra xem extension pg_buffercache đã được cài đặt chưa.

  ```
  psql -h <Aurora Reader EndPoint>
  \dx pg_buffercache
  ```
  ![benchmark](/images/5/5.2/7.png)

- Xác minh xem bạn có được kết nối với Reader node hay không và truy vấn pg_buffercache để xem số trang được lưu trong bộ nhớ đệm cho các bảng khác nhau.

  ``` 
  show transaction_read_only;
  ```

  ![benchmark](/images/5/5.2/8.png)

  ```
  SELECT c.relname, count(*) AS buffers
    FROM pg_buffercache b INNER JOIN pg_class c
    ON b.relfilenode = pg_relation_filenode(c.oid) AND
    b.reldatabase IN (0, (SELECT oid FROM pg_database
    WHERE datname = current_database()))
    GROUP BY c.relname
    ORDER BY 2 DESC
    LIMIT 10;
  ```

  ![benchmark](/images/5/5.2/9.png)

*Lưu ý rằng, sau khi tắt CCM, số lượng trang đệm trên readeer node sẽ ít hơn nhiều so với writer node đối với các bảng được truy cập thường xuyên.*
#### Failover Aurora cluster
- Bây giờ, chúng tôi sẽ bắt đầu quá trình chuyển đổi dự phòng của cụm Aurora và sau khi quá trình chuyển đổi dự phòng hoàn tất, chúng tôi sẽ đo hiệu năng trên writer node mới. Để bắt đầu chuyển đổi dự phòng, hãy chuyển đến RDS console, chọn writer instance của cụm Aurora và nhấp vào **Failover** trong menu **Actions**.
  ![benchmark](/images/5/5.2/10.png)

- Click **Failover** để xác nhận.
![benchmark](/images/5/5.2/11.png)

- Sau khi quá trình chuyển giao hoàn tất (sau khoảng ~30 giây), hãy xác minh rằng reader node trước đó đã trở thành writer node mới.
![benchmark](/images/5/5.2/12.png)
![benchmark](/images/5/5.2/13.png)


#### Để chạy bài thử nghiệm sử dụng công cụ pgbench trên writer node mới (sau quá trình failover)

- Bây giờ chúng ta sẽ chạy bài thử nghiệm pgbench tương tự như trước và so sánh trước và sau khi failover.

```
pgbench --progress-timestamp -M prepared -n -T 600 -P 5  -c 50 -j 50 -b tpcb-like@1 -b select-only@20 > ccm_enable_after_failover.out

```

- Sau 600 giây khi bài thử nghiệm hoàn tất, bạn có thể xác minh kết quả đầu ra của pgbench trên màn hình hoặc tham khảo tệp đầu ra "ccm_enable_after_failover.out". Kết quả tóm tắt sẽ có dạng như sau. Lưu ý rằng kết quả của bạn có thể khác nhau một chút

```
cat ccm_enable_after_failover.out

```
![benchmark](/images/5/5.2/14.png)

*Nhận thấy rằng sau khi tắt CCM, số liệu tps trên writer node mới sau quá trình failover ít hơn so với writer node cũ trước khi failover.*

### Benchmarking với CCM disabled
Bây giờ, chúng ta sẽ tắt CCM và thực hiện các bài thử nghiệm tương tự như trước với CCM đã được kích hoạt.

#### Tắt CCM
Để tắt CCM trên cụm Aurora PostgreSQL, bạn cần chỉnh sửa nhóm tham số của cụm để đặt giá trị của tham số apg_ccm_enabled thành 0.

1. Truy cập giao diện Amazon RDS console và chọn [Parameters groups](https://console.aws.amazon.com/rds/home?#parameter-groups:id=) .

2. Trong danh sách, hãy chọn nhóm tham số cho cụm cơ sở dữ liệu Aurora PostgreSQL của bạn.
![benchmark](/images/5/5.2/14.png)

3. Hãy nhấp vào nhóm tham số của cụm cơ sở dữ liệu đã được chọn ở trên, sau đó click vào **Edit Parameters**.
![benchmark](/images/5/5.2/15.png)
4. Đặt giá trị ``apg_ccm_enabled`` thành 0 và nhấp vào **Save changes**
![benchmark](/images/5/5.2/16.png)

5. Để xác minh rằng Cluster Cache Management đã được tắt bằng cách truy vấn hàm aurora_ccm_status(), hãy thực hiện các bước sau:

```
psql
\x
select * from aurora_ccm_status();
```

![benchmark](/images/5/5.2/17.png)

#### Xóa bộ đệm (buffer cache) của cả writer node và reader node trên cụm Aurora PostgreSQL
Vì việc thử nghiệm trước đó với CCM đã làm tăng bộ đệm (buffer cache) của các reader instance và writer instance trên cụm Aurora, chúng ta cần dừng và khởi động lại cụm Aurora để làm trống bộ đệm trước khi chạy bài đo hiệu năng tiếp theo. Bạn cũng có thể khởi động lại cả reader instance và writer instance, nhưng điều này không đảm bảo rằng writer instance và reader instance đọc sẽ khởi động với bộ đệm trống.

##### Stop cluster
1. Xác minh rằng trạng thái cụm được hiển thị là “Available”, sau đó nhấp vào menu **Actions** và chọn **Stop temporarily**.
![benchmark](/images/5/5.2/18.png)

2. Xác nhận hành động bằng cách nhấp vào cơ sở dữ liệu **Stop temporarily**.
![benchmark](/images/5/5.2/19.png)

*Sẽ mất vài phút và trạng thái cụm sẽ thay đổi từ Stopping thành Stopped.*
![benchmark](/images/5/5.2/20.png)

##### Start cluster
1. Khi trạng thái cụm thay đổi thành **"Stopped"** (Dừng), hãy nhấp vào menu **Actions** một lần nữa và chọn **Start**.
![benchmark](/images/5/5.2/21.png)

*Quá trình khởi động cụm sẽ mất vài phút và trạng thái của cụm sẽ chuyển từ "Starting" thành "Available".*

#### Chạy bài đo hiệu năng trên writer node bằng cách sử dụng công cụ pgbench (trước khi thực hiện failover)
1. Hãy chạy bài đo hiệu năng bằng cách sử dụng pgbench trên writer node của cụm Aurora như đã thực hiện trước đó.

```
pgbench --progress-timestamp -M prepared -n -T 600 -P 5 -c 50 -j 50 -b tpcb-like@1 -b select-only@20 > ccm_disable_before_failover.out

```

2. Sau 600 giây khi bài đo hiệu năng hoàn thành, bạn có thể xác minh kết quả đầu ra của pgbench trên màn hình hoặc tham khảo tệp đầu ra "ccm_disable_before_failover.out". Đầu ra tóm tắt sẽ có dạng như sau. Lưu ý rằng đầu ra của bạn có thể khác một chút.

```
cat ccm_disable_before_failover.out
```
![benchmark](/images/5/5.2/22.png)


#### kiểm tra số trang được lưu trong bộ đệm trên cả writer và reader nodes
1. Kết nối tới writer node bằng cách sử dụng cluster endpoint.
```
psql
\dx pg_buffercache
```
![benchmark](/images/5/5.2/23.png)

2. Để xác minh rằng bạn đã kết nối thành công đến writer node và truy vấn bảng **pg_buffercache** để xem số trang được lưu trong bộ đệm cho các bảng khác nhau,
```
show transaction_read_only;

```
![benchmark](/images/5/5.2/24.png)


```
SELECT c.relname, count(*) AS buffers
 FROM pg_buffercache b INNER JOIN pg_class c
 ON b.relfilenode = pg_relation_filenode(c.oid) AND
 b.reldatabase IN (0, (SELECT oid FROM pg_database
 WHERE datname = current_database()))
 GROUP BY c.relname
 ORDER BY 2 DESC
 LIMIT 10;

```
![benchmark](/images/5/5.2/25.png)


#### Kết nối đến read replica
1. Để kết nối tới reader instance bằng cách sử dụng Reader Endpoint của Cụm Aurora PostgreSQL. Thay thế <Aurora Reader EndPoint> bên dưới với Aurora Reader EndPoint của bạn.
```
psql -h  <Aurora Reader EndPoint>
\dx pg_buffercache

```
![benchmark](/images/5/5.2/26.png)

2. Xác minh rằng bạn đã kết nối với Reader node và truy vấn **pg_buffercache** để xem số lượng trang được lưu trong bộ nhớ đệm cho các bảng khác nhau.
```
show transaction_read_only;

```
![benchmark](/images/5/5.2/27.png)


```
SELECT c.relname, count(*) AS buffers
 FROM pg_buffercache b INNER JOIN pg_class c
 ON b.relfilenode = pg_relation_filenode(c.oid) AND
 b.reldatabase IN (0, (SELECT oid FROM pg_database
 WHERE datname = current_database()))
 GROUP BY c.relname
 ORDER BY 2 DESC
 LIMIT 10;

```
![benchmark](/images/5/5.2/28.png)


*Lưu ý rằng, sau khi tắt CCM, số lượng trang đệm trên reader node sẽ ít hơn nhiều so với writer node đối với các bảng được truy cập thường xuyên.*

#### Failover Aurora cluster
1. Bây giờ, chúng tôi sẽ bắt đầu quá trình chuyển đổi dự phòng của cụm Aurora và sau khi quá trình chuyển đổi dự phòng hoàn tất, chúng tôi sẽ đo hiệu năng trên writer node mới.
![benchmark](/images/5/5.2/29.png)

2. Click vào **Failover**.

*Sau khi quá trình chuyển đổi dự phòng hoàn tất (sau khoảng ~30 giây), hãy xác minh rằng reader node trước đó sẽ trở thành writer node mới.*
![benchmark](/images/5/5.2/30.png)

#### Chạy benchmark bằng công cụ pgbench trên writer node mới (sau khi thực hiện failover)
1. Bây giờ, chúng ta sẽ chạy benchmark giống như trước đây và so sánh các chỉ số của pgbench trước và sau khi thực hiện failover.
```
pgbench --progress-timestamp -M prepared -n -T 600 -P 5 -c 50 -j 50 -b tpcb-like@1 -b select-only@20 > ccm_disable_after_failover.out

```

Sau 600 giây khi benchmark hoàn thành, bạn có thể xác minh kết quả đầu ra của pgbench trên màn hình hoặc tham khảo tệp đầu ra "ccm_disable_after_failover.out". Đầu ra tóm tắt sẽ có dạng như sau. Lưu ý rằng đầu ra của bạn có thể khác một chút.

```
cat ccm_disable_after_failover.out

```
![benchmark](/images/5/5.2/31.png)

*Lưu ý rằng sau khi tắt CCM, số liệu tps trên writer node mới sau failover thấp hơn so với writer node cũ trước khi xảy ra failover.*