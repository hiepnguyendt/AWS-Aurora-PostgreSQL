---
title : "Query Plan Management"
date :  "`r Sys.Date()`" 
weight : 4 
chapter : false
pre : " <b> 4. </b> "
---

Với query plan management (QPM), bạn có thể kiểm soát các kế hoạch thực hiện cho một tập hợp các câu lệnh mà bạn muốn quản lý. Bạn có thể làm như sau:
- Cải thiện tính ổn định của kế hoạch bằng cách buộc trình tối ưu hóa chọn từ một số ít các kế hoạch tốt đã biết.
- Tối ưu hóa kế hoạch tập trung và sau đó phân phối các kế hoạch tốt nhất trên toàn cầu.
- Xác định các chỉ mục không được sử dụng và đánh giá tác động của việc tạo hoặc xóa chỉ mục.
- Tự động phát hiện kế hoạch chi phí tối thiểu mới được trình tối ưu hóa phát hiện.
- Thử nghiệm các tính năng tối ưu hóa mới với ít rủi ro hơn vì bạn có thể chọn chỉ phê duyệt những thay đổi trong kế hoạch nhằm cải thiện hiệu suất.

Để biết thêm chi tiết về Query Plan Management vui lòng tham khảo tài liệu chính thức [Managing Query Execution Plans for Aurora PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Optimize.html).

Cách nhanh nhất để kích hoạt QPM là sử dụng chức năng tự động ghi lại kế hoạch, cho phép ghi lại kế hoạch cho tất cả các câu lệnh SQL chạy ít nhất hai lần. Trong thí nghiệm này, chúng ta sẽ đi qua quy trình kích hoạt QPM với việc ghi lại kế hoạch tự động, cải tiến các kế hoạch truy vấn bằng cách chấp nhận chúng theo cách thủ công và sửa các kế hoạch truy vấn bằng cách sử dụng gợi ý tối ưu hóa.


#### Bắt đầu nhanh việc sử dụng QPM với automatic capture

Dưới đây là các bước để cấu hình và kích hoạt QPM trên cụm Aurora PostgreSQL của bạn để tự động nắm bắt và kiểm soát các kế hoạch thực thi cho một tập hợp câu lệnh SQL.

1. Tùy chỉnh Amazon Aurora DB Cluster Parameters liên quan đến QPM.
- Truy cập [Amazon RDS service console Parameters group section](https://console.aws.amazon.com/rds/home?#parameter-group-list:)  nằm bên trái của RDS console.

- Trong danh sách, hãy chọn parameter group cho Aurora PostgreSQL DB cluster của bạn. Cụm DB phải sử dụng nhóm tham số khác với mặc định vì bạn không thể thay đổi giá trị trong nhóm tham số mặc định. Để biết thêm thông tin, xem [Creating a DB Cluster Parameter Group](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_WorkingWithParamGroups.html#USER_WorkingWithParamGroups.CreatingCluster).

- Nhấp vào **Edit** bên dưới **Action**.
       ![QMP](/images/4.1/1.png)

- Trong trường lọc Parametr, nhập ``rds.enable_plan_management``. Đặt value của **rds.enable_plan_management** thành 1 và nhấp vào Save changes.
       ![QMP](/images/4.1/2.png)

- Nhấp vào tên nhóm tham số cơ sở dữ liệu **DB instance parameter group** và nhấp vào Edit.
       ![QMP](/images/4.1/3.png)

- Chúng ta cần thay đổi hai tham số:
  - Sửa giá trị của tham số ``apg_plan_mgmt.capture_plan_baselines`` thành ``automatic``
  - Sửa giá trị của ``apg_plan_mgmt.use_plan_baselines`` thành ``true``
  - Bấm **Save Changes** để lưu thay đổi
       ![QMP](/images/4.1/4.png)

- Nhấp vào **Databases** trên bảng điều hướng bên trái và đợi trạng thái của instance thay đổi thành **available**. Các thay đổi tham số sẽ có hiệu lực sau khi khởi động lại như được đề xuất trên tab cấu hình của Aurora writer và reader instances
- Khởi động lại writer và reader nodes bằng cách chọn vào nó và đi tới **Actions** menu.
- Đợi trạng thái của writer và reader nodes trở nên **Available**.

2. Tạo và xác minh `apg_plan_mgmt` extension cho DB instance.

- Mở Cloud9 terminal bằng cách sau [Open Cloud9 Terminal Window](https://catalog.us-east-1.prod.workshops.aws/workshops/098605dc-8eee-4e84-85e9-c5c6c9e43de2/en-US/lab1- 5-client/cloud9-terminal/) và tạo **apg_plan_mgmt** extension cho DB instance của bạn.

       ```
       psql
       CREATE EXTENSION apg_plan_mgmt;
       select extname,extversion from pg_extension where extname='apg_plan_mgmt';

       ```
Bạn sẽ thấy đầu ra tương tự như sau. Extension version sẽ khác nhau tùy thuộc vào Aurora PostgreSQL instance.

       ![QMP](/images/4.1/5.png)
- Xem lại tất cả các tham số liên quan đến QPM được sửa đổi thành giá trị phù hợp bằng cách chạy các truy vấn sau.

       ```
       show apg_plan_mgmt.capture_plan_baselines;
       show apg_plan_mgmt.use_plan_baselines;
       \q
       ```
       ![QMP](/images/4.1/6.png)

3. Chạy synthetic workload với automatic capture.
- Mở một trong Cloud9 terminal và chạy pgbench (một công cụ đo điểm chuẩn của PostgreSQL) để tạo một workload mô phỏng chạy các truy vấn tương tự trong một khoảng thời gian cụ thể. Khi bật tính năng thu nạp tự động, QPM sẽ ghi lại các gói cho mỗi truy vấn chạy ít nhất hai lần.

       ```
       pgbench --progress-timestamp -M prepared -n -T 100 -P 1  -c 100 -j 100 -b tpcb-like@1 -b select-only@20
       # The following pgbench command runs for 100 seconds with 100 clients/db sessions and 100 job threads emitting progress every 1 second
       ```
*Đợi lệnh trên kết thúc.*

- Mở một terminal khác trên Cloud9 để truy vấn bảng ``apg_plan_mgmt.dba_plans`` để xem các câu lệnh được quản lý và kế hoạch thực thi. Sau đó chạy các lệnh sau:

```
psql

SELECT sql_hash, 
       plan_hash, 
       status, 
       enabled, 
       sql_text 
FROM   apg_plan_mgmt.dba_plans;
```
![QMP](/images/4.1/7.png)

- Tắt tính năng automatic capture các gói truy vấn. Việc thu thập tất cả các gói bằng tính năng automatic capture có ít chi phí thời gian chạy và có thể được kích hoạt trong production. Chúng ta đang tắt tính năng automatic capture để đảm bảo rằng chúng ta không thu thập các câu lệnh SQL bên ngoài pgbench workload. Bạn có thể tắt tính năng này bằng cách đặt tham số **apg_plan_mgmt.capture_plan_baselines** thành ``off`` từ DB parameter group.
![QMP](/images/4.1/8.png)

- Xác minh cài đặt parameter bằng PSQL. Vì **apg_plan_mgmt.capture_plan_baselines** là một tham số động nên nó không cần khởi động lại phiên bản để có hiệu lực. Sẽ mất 5-10 giây để giá trị tham số thay đổi.

```
show apg_plan_mgmt.capture_plan_baselines;
```
![QMP](/images/4.1/9.png)

- Hãy xác minh rằng kế hoạch thực hiện cho một trong các câu lệnh được quản lý có giống với kế hoạch được QPM nắm bắt hay không. Thực hiện explain plan trên một trong các câu lệnh được quản lý. Output của explain plan cho thấy hàm băm SQL và hàm băm kế hoạch khớp với kế hoạch được QPM phê duyệt cho câu lệnh đó.

```
explain (hashes true) UPDATE pgbench_tellers SET tbalance = tbalance + 100 WHERE tid = 200; 
# (hashes true): This is likely part of a specific testing or benchmarking framework and doesn't directly affect the UPDATE statement itself. It might indicate a particular flag or configuration within the framework.
```
![QMP](/images/4.1/10.png)

{{% notice note %}}
Ngoài việc automatic plan capture, QPM còn có khả năng manual plan capture, cung cấp cơ chế nắm bắt các kế hoạch thực hiện cho các truy vấn có vấn đề đã biết. Nói chung, việc nắm bắt các kế hoạch một cách tự động được khuyến khích. Tuy nhiên, có những tình huống mà việc thu thập kế hoạch theo cách thủ công sẽ là lựa chọn tốt nhất, chẳng hạn như:
- Bạn không muốn kích hoạt quản lý kế hoạch ở cấp Cơ sở dữ liệu, nhưng bạn chỉ muốn kiểm soát một vài câu lệnh SQL quan trọng.
- Bạn muốn lưu kế hoạch cho một tập hợp chữ hoặc giá trị tham số cụ thể đang gây ra sự cố về hiệu suất
{{% /notice %}}

#### Khả năng thích ứng của QPM Plan với cơ chế plan evolution

- Nếu kế hoạch được tạo bởi trình tối ưu hóa không phải là kế hoạch được lưu trữ thì trình tối ưu hóa sẽ thu thập và lưu trữ nó dưới dạng kế hoạch mới chưa được phê duyệt để duy trì sự ổn định cho các câu lệnh SQL do QPM quản lý. Quản lý kế hoạch truy vấn cung cấp các kỹ thuật và chức năng để thêm, duy trì và cải thiện các kế hoạch thực hiện và do đó cung cấp khả năng thích ứng của Kế hoạch. Người dùng có thể hướng dẫn QPM theo yêu cầu hoặc định kỳ phát triển tất cả các gói được lưu trữ để xem liệu có gói chi phí tối thiểu nào tốt hơn bất kỳ gói nào được phê duyệt hay không.

- QPM cung cấp chức năng **apg_plan_mgmt.evolve_plan_baselines** để so sánh các gói dựa trên hiệu suất thực tế của chúng. Tùy thuộc vào kết quả thử nghiệm hiệu suất, bạn có thể thay đổi trạng thái của kế hoạch từ **unapproved** thành **approved** hoặc **rejected**. Thay vào đó, bạn có thể quyết định sử dụng chức năng **apg_plan_mgmt.evolve_plan_baselines** để tạm thời vô hiệu hóa một gói nếu gói đó không đáp ứng yêu cầu của bạn. Để biết thêm thông tin chi tiết về QPM Plan evolution, hãy xem [Evaluating Plan Performance](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Optimize.Maintenance.html#AuroraPostgreSQL.Optimize.Maintenance.EvaluatingPerformance) .

- Đối với trường hợp sử dụng đầu tiên, chúng ta sẽ xem qua một ví dụ về cách QPM giúp đảm bảo sự ổn định của kế hoạch trong đó các thay đổi khác nhau có thể dẫn đến sự suy giảm của kế hoạch.

- Trong hầu hết các trường hợp, bạn thiết lập QPM để ghi lại kế hoạch cho tất cả các câu lệnh chạy hai lần trở lên. uy nhiên, bạn cũng có thể ghi lại kế hoạch cho một tập hợp cụ thể các câu lệnh mà bạn chỉ định theo cách thủ công. Để thực hiện việc này, bạn đặt **apg_plan_mgmt.capture_plan_baselines = off** trong DB parameter group (là mặc định) và **apg_plan_mgmt.capture_plan_baselines = manual**

1. Bật tính năng chụp kế hoạch thủ công để hướng dẫn QPM ghi lại kế hoạch thực hiện của các câu lệnh SQL mong muốn theo cách thủ công.
```
SET apg_plan_mgmt.capture_plan_baselines = manual;
```

2. Chạy explain plan cho một truy vấn cụ thể để QPM có thể ghi lại được kế hoạch thực hiện (đầu ra sau đây cho explain plan được cắt bớt để ngắn gọn).

```
explain (analyze, summary, hashes)
SELECT Sum(delta),
               Sum(bbalance)
FROM   pgbench_history h,
              pgbench_branches b
WHERE  b.bid = h.bid
       AND b.bid IN ( 1, 2, 3 );

```
![QMP](/images/4.1/11.png)

3. Tắt tính năng thu thập thủ công các câu lệnh SQL mới cùng với các kế hoạch của chúng sau khi bạn nắm bắt kế hoạch thực hiện cho câu lệnh SQL mong muốn.

{{% notice note %}}
QPM tiếp tục nắm bắt các kế hoạch mới cho các câu lệnh SQL được quản lý ngay cả sau khi tắt apg_plan_mgmt.capture_plan_baselines.
{{% /notice %}}

```
SET apg_plan_mgmt.capture_plan_baselines = off;
```

4. Xem kế hoạch truy vấn đã thu thập cho truy vấn mà bạn đã chạy trước đó. Cột plan_outline trong bảng ``apg_plan_mgmt.dba_plans`` hiển thị toàn bộ kế hoạch cho SQL. Để cho ngắn gọn, plan_outline không được hiển thị ở đây.
```
SELECT sql_hash,
                plan_hash,
               status,
               estimated_total_cost "cost",
               sql_text
FROM apg_plan_mgmt.dba_plans;
```
![QMP](/images/4.1/12.png)

5. Để hướng dẫn tối ưu hóa truy vấn sử dụng các gói đã chụp được phê duyệt hoặc ưu tiên cho các câu lệnh được quản lý của bạn, hãy đặt tham số **apg_plan_mgmt.use_plan_baselines** thành **true**.

```
SET apg_plan_mgmt.use_plan_baselines = true;
```

6. Để xem đầu ra của lệnh "explain plan" và xác nhận rằng kế hoạch được QPM chấp nhận được sử dụng bởi trình tối ưu truy vấn, bạn có thể thực hiện các bước sau:

```
explain (analyze, summary, hashes)
SELECT Sum(delta),
               Sum(bbalance)
FROM   pgbench_history h,
              pgbench_branches b
WHERE  b.bid = h.bid
       AND b.bid IN ( 1, 2, 3 ); 
```
![QMP](/images/4.1/13.png)

7. Để tạo một chỉ mục mới trên cột "bid" trong bảng "pgbench_history" và thay đổi cấu hình trình tối ưu truy vấn để buộc trình tối ưu truy vấn tạo ra một kế hoạch mới, bạn có thể thực hiện các bước sau:

```
create index pgbench_hist_bid on pgbench_history(bid);
```

8. Xem đầu ra của explain plan để thấy rằng QPM phát hiện một kế hoạch mới nhưng vẫn sử dụng kế hoạch đã được phê duyệt và duy trì sự ổn định của kế hoạch. Lưu ý dòng ***An Approved plan was used instead of the minimum cost plan***.

```
explain (analyze, summary, hashes)
SELECT Sum(delta),
               Sum(bbalance)
FROM   pgbench_history h,
              pgbench_branches b
WHERE  b.bid = h.bid
       AND b.bid IN ( 1, 2, 3 );

```
![QMP](/images/4.1/14.png)

9. Chạy truy vấn SQL sau để xem kế hoạch mới và trạng thái của kế hoạch. Để đảm bảo sự ổn định của kế hoạch, QPM lưu trữ tất cả các kế hoạch mới được tạo cho truy vấn được quản lý trong QPM dưới dạng các kế hoạch chưa được phê duyệt.

- Kết quả đầu ra sau đây cho thấy có hai kế hoạch thực thi khác nhau được lưu trữ cho cùng một câu lệnh được quản lý, được thể hiện bằng hai giá trị plan_hash khác nhau. Mặc dù phương án thực hiện mới có chi phí tối thiểu (thấp hơn kế hoạch được phê duyệt) nhưng QPM vẫn tiếp tục bỏ qua các phương án chưa được phê duyệt để duy trì tính ổn định của kế hoạch.

- Cột plan_outline trong bảng ``apg_plan_mgmt.dba_plans`` hiển thị toàn bộ kế hoạch cho SQL. Để cho ngắn gọn, plan_outline không được hiển thị ở đây.

```
SELECT sql_hash,
                plan_hash,
               status,
               estimated_total_cost "cost",
               sql_text
FROM apg_plan_mgmt.dba_plans;
```
![QMP](/images/4.1/15.png)

- Sau đây là ví dụ về khả năng thích ứng của kế hoạch với QPM. Ví dụ này đánh giá kế hoạch chưa được phê duyệt dựa trên hệ số tăng tốc tối thiểu. Nó phê duyệt bất kỳ kế hoạch nào chưa được phê duyệt được ghi lại nhanh hơn ít nhất 10 phần trăm so với kế hoạch được phê duyệt. Để biết thêm thông tin chi tiết, hãy xem [Evaluating Plan Performance in the Aurora documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Optimize.Maintenance.html#AuroraPostgreSQL.Optimize.Maintenance.EvaluatingPerformance).

```
SELECT apg_plan_mgmt.Evolve_plan_baselines (sql_hash, plan_hash, 1.1,'approve')
FROM   apg_plan_mgmt.dba_plans
WHERE  status = 'Unapproved'; 

```
![QMP](/images/4.1/16.png)

- Sau khi QPM đánh giá kế hoạch dựa trên yếu tố tốc độ, trạng thái kế hoạch sẽ thay đổi từ **không được phê duyệt** thành **được phê duyệt**. Tại thời điểm này, trình tối ưu hóa có thể chọn gói chi phí thấp hơn mới được phê duyệt cho báo cáo được quản lý đó.

```
SELECT sql_hash,
                plan_hash,
               status,
               estimated_total_cost "cost",
               sql_text
FROM apg_plan_mgmt.dba_plans;
```
![QMP](/images/4.1/17.png)

10. Xem đầu ra của explain plan để xem liệu truy vấn có đang sử dụng kế hoạch chi phí tối thiểu mới được phê duyệt hay không.

```
explain (analyze, summary, hashes)
SELECT Sum(delta),
               Sum(bbalance)
FROM   pgbench_history h,
              pgbench_branches b
WHERE  b.bid = h.bid
       AND b.bid IN ( 1, 2, 3 );
```
![QMP](/images/4.1/18.png)