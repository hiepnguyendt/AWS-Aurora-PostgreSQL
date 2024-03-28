---
title : "Fast Cloning"
date :  "`r Sys.Date()`" 
weight : 3 
chapter : false
pre : " <b> 3. </b> "
---

**Fast Cloning là gì ?**
{{%expand "The Fast Cloning" %}}

**Fast cloning** đề cập đến một tính năng cho phép bạn tạo bản sao chính xác của cơ sở dữ liệu một cách nhanh chóng và hiệu quả. Bản sao này ban đầu chia sẻ cùng một bộ lưu trữ cơ bản với cơ sở dữ liệu gốc, giúp quá trình này nhanh hơn và tiết kiệm chi phí hơn nhiều so với các phương pháp truyền thống như sao lưu toàn bộ cơ sở dữ liệu hoặc khôi phục snapshot.

***Dưới đây là một số điểm chính về fast cloning for Aurora PostgreSQL:***

- **Speed**: Không giống như các phương pháp truyền thống, có thể mất hàng giờ hoặc thậm chí vài ngày đối với cơ sở dữ liệu lớn, fast cloning có thể tạo bản sao chỉ trong vài phút, ngay cả đối với cơ sở dữ liệu nhiều terabyte.

- **Efficiency**: Bản sao ban đầu chia sẻ bộ lưu trữ với cơ sở dữ liệu nguồn, nghĩa là không cần sao chép dữ liệu vật lý. Điều này giúp tiết kiệm dung lượng và giảm chi phí lưu trữ.

- **Copy-on-write**: Khi thực hiện thay đổi đối với cơ sở dữ liệu nguồn hoặc bản sao, các trang dữ liệu mới sẽ được tạo thay vì sửa đổi các trang hiện có. Điều này đảm bảo tính nhất quán của dữ liệu và giảm thiểu tác động lên cả hai cơ sở dữ liệu.

**Multiple uses**: Fast cloning hữu ích cho nhiều tình huống khác nhau, bao gồm phát triển và thử nghiệm ứng dụng, cập nhật cơ sở dữ liệu, triển khai blue/green và chạy truy vấn phân tích mà không ảnh hưởng đến hoạt động sản xuất.
Dưới đây là một số tài nguyên mà bạn có thể tìm hiểu thêm về Fast cloning cho Aurora PostgreSQL:
******

[Amazon Aurora documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Clone.html)
[Amazon Aurora PostgreSQL blue/green deployment using fast database cloning](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/blue-green-deployments-overview.html)
[Amazon Aurora Fast Database Cloning](https://aws.amazon.com/blogs/aws/amazon-aurora-fast-database-cloning/)
{{% /expand%}}

Trong phần thực hành này, chúng ta sẽ tìm hiểu quy trình tạo Fast Cloning Aurora. Chúng tôi sẽ quan sát sự khác biệt của dữ liệu và so sánh hiệu suất giữa cụm Aurora gốc và cụm sao chép.

#### Thiết lập thử nghiệm Fast Clone

Hãy xem lại các bảng chúng ta đã tạo trong bước **Tạo, Cấu hình Cloud9 và Khởi tạo cơ sở dữ liệu**, bước này sẽ được sử dụng trong phần thực hành này.

| Resoures name | Value|
|---------------|------|
|cloneeventtest	|Table to store the counter and the timestamp|
|statusflag	    |Table to store the status flag which controls the start/stop counter|
|eventerrormsg	|Table to store error messages|
|cloneeventproc	|Function to add data to the cloneeventtest table based on the start counter flag|

#### Tạo và xác minh ảnh hưởng của fast cloning đến hiệu năng

1. Chạy pgbench wordload trên cụm chính

    Trước khi tạo Fast Clone của primary cluster, chúng tôi sẽ bắt đầu kiểm tra với pgbench để đo số liệu transaction per seconds (TPS) trên cụm chính. Mở Cloud9 terminal (terminal #1) và chạy lệnh sau. Lệnh này sẽ chạy trong 30 phút.

    ```
    pgbench --progress-timestamp -M prepared -n -T 1800 -P 60 -c 8 -j 8 -b tpcb-like@1 -b select-only@20 > Primary_results.log

    ```

2. Xác minh môi trường và chạy thử nghiệm phân nhánh mẫu
- Để xác minh sự khác biệt dữ liệu trên cụm chính và cụm sao, chúng tôi sẽ thêm dữ liệu mẫu bằng cách sử dụng các bảng mẫu.
- Chúng ta cần mở thêm một cửa sổ terminal Cloud9 (terminal #2) để kết nối với Aurora và chạy chức năng. Để mở thêm một cửa sổ terminal trên môi trường Cloud9 của bạn, hãy nhấp vào menu **Window** và chọn **new Terminal**.
- Chạy các lệnh sau để xác minh cột **delflag** được đặt thành 0 trong bảng **statusflag** và không có dữ liệu nào trong bảng **cloneeventtest**. Thực thi hàm **cloneeventproc()** để bắt đầu thêm dữ liệu mẫu.

    ```
    psql
    select * from statusflag;
    select * from cloneeventtest;
    select cloneeventproc();

    ```
    ![FC](/images/3.1/2.png)

    Tại thời điểm này (chúng ta gọi là thời gian “T1”), pgbench workload đang chạy trên cụm DB nguồn và chúng ta cũng đang thêm dữ liệu mẫu vào bảng trên cụm chính cứ sau 10 giây.

3. Dừng việc tạo dữ liệu mẫu

- Đầu tiên, vào phút T1+5, chúng tôi sẽ dừng việc thực thi chức năng bằng cách đặt lại thủ công cột delflag trên table statusflag về 1. Mở thêm một terminal Cloud9 để kết nối với Aurora (terminal #3). Pgbench workload sẽ tiếp tục thực thi trên cụm nguồn chính ở terminal #1.


    ```
    psql
    update statusflag set delflag='Y';

    ```

- Quay trở lại terminal #2 nơi chúng ta đã chạy hàm cloneeventproc. Đợi ~60 giây cho đến khi bạn thấy hàm hoàn tất quá trình thực thi:

    ```
    select cloneeventproc();

    ```
    ![FC](/images/3.1/3.png)

- Hãy kiểm tra số hàng trong bảng cloneeventtest. Chúng ta sẽ thấy 5 hàng trở lên trong bảng:

    ```
    select count(*) from cloneeventtest;

    ```

    ![FC](/images/3.1/4.png)

- Hãy đặt múi giờ thích hợp và kiểm tra các hàng trong bảng cloneeventtest:

    ```
    SET timezone = 'Asia/Ho_Chi_Minh';
    select * from cloneeventtest;

    ```
    ![FC](/images/3.1/5.png)


4. Tạo Fast Clone Cluster
- Khi quá trình thực thi dừng lại (sau thời gian T1+5 phút), chúng ta sẽ bắt đầu tạo Fast Clone của the primary cluster. pgbench workload sẽ tiếp tục trên cụm chính ở terminal #1.

- Bây giờ, chúng tôi sẽ hướng dẫn bạn quy trình [cloning a DB cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Clone.html). Cloning tạo ra một cụm cơ sở dữ liệu độc lập, riêng biệt với bản sao nhất quán của dữ liệu kể từ thời điểm bạn sao chép nó. Cloning cơ sở dữ liệu sử dụng giao thức sao chép khi ghi, trong đó dữ liệu được sao chép tại thời điểm dữ liệu thay đổi, trên cơ sở dữ liệu nguồn hoặc cơ sở dữ liệu nhân bản. Hai cụm này được tách biệt và không có tác động đến hiệu suất đối với cụm DB nguồn từ các hoạt động cơ sở dữ liệu trên bản sao hoặc ngược lại.

- Sau đây là các bước để định cấu hình bản sao Cơ sở dữ liệu nhanh trên cụm Aurora PostgreSQL của bạn:

a. Đăng nhập vào AWS Management Console và truy cập [Amazon RDS console](https://console.aws.amazon.com/rds/home?#databases:) .

b. Trong ngăn điều hướng, chọn Databases và chọn DB có tên cụm mà bạn đã tạo. Nhấp vào menu **Actions** ở trên cùng và chọn **Create clone**.
    ![FC](/images/3/9.png)

c. Nhập ``aupglabs-clone`` làm **DB Instance Identifier** và Capacity type **Provisioned**.

- Tại mục **Cluster storage configuration** chọn **Aurora Standard**.

-  Tại mục **Instance configuration** chọn **Memory optimized classes** và **db.r6g.large**.
    ![FC](/images/3/10.png)
    ![FC](/images/3/11.png)
    ![FC](/images/3/12.png)


- Tại phần **Connectivity**, để lại với cài đặt mặc định

- Trong **Additional Configuration**, chọn **DB cluster parameter group** và **DB parameter groups created** trong menu thả xuống nhóm tham số cụm DB và nhóm tham số DB.
    ![FC](/images/3/14.png)

- Kích hoạt auto minor version upgrade.

- Để các trường nhập còn lại ở giá trị mặc định và click Create clone.
    ![FC](/images/3/15.png)
    ![FC](/images/3/16.png)

- Khi bạn nhấp vào “Create clone”, cột status sẽ hiển thị trạng thái như “Creating”.
    ![FC](/images/3/17.png)

- Clone cluster sẽ sẵn sàng sau khoảng 10-15 phút. Cột trạng thái sẽ hiển thị là “Có sẵn” sau khi cụm nhân bản đã sẵn sàng.

    ![FC](/images/3/18.png)


5. Bắt đầu quá trình phân nhánh dữ liệu mẫu trên cụm chính
- Sau khi quá trình tạo Clone cluster được khởi động, chúng ta sẽ bắt đầu quá trình tạo dữ liệu mẫu trên cụm chính. Mọi dữ liệu mẫu được thêm từ thời điểm này trở đi chỉ được có trên cụm chính chứ không có trên cụm sao chép.

    ```
    psql 
    truncate cloneeventtest; # This will empty the cloneeventtest table, removing all existing rows.Make sure you want to do this as it's an irreversible operation.
    update statusflag set delflag=0; 
    select count(*) from cloneeventtest;
    select cloneeventproc();

    ```
    ![FC](/images/3.1/6.png)

6. Xác minh sự phân nhánh dữ liệu trên Clone Cluster
- Clone cluster sẽ sẵn sàng sau khoảng 15 phút hoặc lâu hơn (thời gian T1+~10-15 phút).
- Bảng “cloneventtest” trên cụm được nhân bản phải có snapshot dữ liệu như nó tồn tại trên cụm chính ở ~T1+5, vì đó là thời điểm chúng ta bắt đầu tạo bản sao.

- Sao chép Writer Endpoint cho aurora cluster được nhân bản của bạn bằng cách nhấp vào tên cụm và đi tới tab **Connectivity & security**.

    ![FC](/images/3/20.png)

- Kết nối với Aurora cloned cluster từ termianl #3. Thay thế <Cloned Cluster Writer Endpoint> bên dưới bằng Writer endpoint cho Cloned Aurora cluster mà bạn đã sao chép ở trên.

    ```
    psql -h <Cloned Cluster Writer Endpoint>

    ```
    ![FC](/images/3.1/7.png)


- Và chạy lệnh sql để kiểm tra nội dung dữ liệu:

    ```
    select count(*) from cloneeventtest;
    SET timezone = 'Asia/Ho_Chi_Minh';
    select * from cloneeventtest;

    ```
    ![FC](/images/3.1/8.png)

- Dừng hàm đang chạy trên Primary aurora cluster (làm theo bước **Stop the sample data generation**) và chọn dữ liệu từ bảng cloneeventtest. Chúng ta sẽ thấy nhiều hàng hơn, như mong đợi.

7. Chạy pgbench workload trên Clone Cluster

- Chúng ta sẽ bắt đầu pgbench workload tương tự trên cụm bản sao mới được tạo như chúng tôi đã làm trên cụm chính trước đó ở bước #1. Thay thế <Cloned Cluster Endpoint> bên dưới bằng Writer Endpoint cho Cloned Aurora cluster của bạn.

    ```
    pgbench --progress-timestamp -M prepared -n -T 1800 -P 60 -c 8 -j 8 --host=<Cloned Cluster Writer Endpoint> -b tpcb-like@1 -b select-only@20 > Clone_results.log

    ```

8. Xác minh số liệu pgbench trên cụm chính và cụm sao chép.
- Sau khi pgbench workload hoàn thành trên cả cụm chính và cụm sao chép, chúng ta có thể xác minh số liệu TPS từ cả hai cụm bằng cách xem tệp đầu ra.
    ![FC](/images/3.1/9.png)
    ![FC](/images/3.1/10.png)