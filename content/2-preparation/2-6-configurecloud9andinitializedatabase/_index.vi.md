---
title : "Tạo, cấu hình Cloud9 và khởi tạo cơ sở dữ liệu"
date :  "`r Sys.Date()`" 
weight :  6
chapter : false
pre : " <b> 2.6.</b> "
---

#### Để tạo môi trường Cloud9, hãy làm theo các bước sau:

1. Truy cập giao diện [Amazon Cloud console](https://console.aws.amazon.com/cloud9/), sau đó click **Create enviroment**
    ![Create Cloud9 instance](/images/1/14.png)

2. Nhập tên cho môi trường của bạn và chọn tùy chọn **Existing compute**.
    ![Create Cloud9 instance](/images/1/15.png)

3. Trong phần Existing compute, nhấp vào **Copy key to clipboard**
    ![Create Cloud9 instance](/images/1/16.png)

4. Kết nối đến EC2 instance qua MobaXterm
- Thực hiện theo lệnh bên dưới để lưu **Public SSH key** vào tệp **authorized_keys**

    ```
    cd .ssh
    nano authorized_keys

    ```
    ![Create Cloud9 instance](/images/1/17.1.png)
    ![Create Cloud9 instance](/images/1/17.2.png)
-  Cài đặt Nodejs bằng lệnh bên dưới

    ```
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
    . ~/.nvm/nvm.sh
    nvm install 16

    ```
    ![Create Cloud9 instance](/images/1/17.png)

- Tạo folder ``cloud9_env``

    ```
    mkdir cloud9_env
    ```

    ![Create Cloud9 instance](/images/1/18.png)

- Kiểm tra đường dẫn của Nodejs

    ```
    which node
    ```
    ![Create Cloud9 instance](/images/1/19.png)


    - Install **jq** packages
    ```
    sudo yum install jq
    ```
    ![Create Cloud9 instance](/images/1/17.3.png)

5. Trở lại bước **Create Cloud9 instance**

- Tại mục **User**, nhập ``EC2 user``
- Tại mục **Host**, nhập EC2 host 
    ![Create Cloud9 instance](/images/1/16.png)

6. Trong **Additional details - optional**

- Tại mục **Environment path**, nhập ``~/cloud9_env``
- Tại mục **Path to Node.js binary**, nhập đường dẫn mà bạn đã kiểm tra ở bước trước

7. Sau đó click **Create**
8. Sau khi **Successfully create Cloud9**, click **Open**
    ![Create Cloud9 instance](/images/1/20.png)

9. C9 install
- Click **Next** 
    ![Create Cloud9 instance](/images/1/21.png)

- Click **Next** and leave everything ticked
    ![Create Cloud9 instance](/images/1/22.png)

- Click **Finish**
    ![Create Cloud9 instance](/images/1/24.png)

Bây giờ bạn đã thành công **created Cloud9 instance with existing compute** 


 ![CreateCloud9instance](/images/1/25.png)



#### Cấu hình Cloud9 workstation
1. Cấu hình AWS CLI của bạn bằng lệnh bên dưới:
    ```
    aws configure

    ```

- Nhập **AWS Access Key ID**
- Nhập **AWS Secret Access Key ID**
- Nhập **Region name** that you have handed-on lab
- Nhập **Output format**

2. Trong terminal Cloud9, dán và chạy các lệnh sau.

    ```
    export AWSREGION=`aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]'`

    # Replace your --db-cluster-identifier
    export DBENDP=`aws rds describe-db-clusters --db-cluster-identifier aupg-fcj-labs --region $AWSREGION --query 'DBClusters[*].Endpoint' | jq -r '.[0]'`

    # This assumes a "Name" tag was added to your secret with value aupg-fcj-labs-DBMasterUser-secret
    SECRETARN=`aws secretsmanager list-secrets --filters Key="name",Values="aupg-fcj-labs-DBMasterUser-secret" --query 'SecretList[*].ARN' | jq -r '.[0]'`

    # If below command doesnt show you the secret ARN, you should manually set the SECRETARN variable by referring it from the AWS Secrets manager console
    echo $SECRETARN

    CREDS=`aws secretsmanager get-secret-value --secret-id $SECRETARN --region $AWSREGION | jq -r '.SecretString'`

    export DBUSER="`echo $CREDS | jq -r '.username'`"
    export DBPASS="`echo $CREDS | jq -r '.password'`"

    echo DBENDP: $DBENDP
    echo DBUSER: $DBUSER

    ```
    ![Configure Cloud9](/images/2/1.png)

    {{% notice note %}}
    Hãy xác nhận rằng bạn đã có kết quả cho các biến DBENDP và DBUSER. Nếu không, có thể là bạn chưa đặt tên Aurora cluster của mình là "aupg-fcj-labs" hoặc gắn thẻ bí mật của bạn với Key:Name và Value: aupg-fcj-labs-DBMasterUser-secret. Trong trường hợp đó, hãy thiết lập các biến DBENDP, DBUSER và DBPASS bằng cách thủ công trong cửa sổ dòng lệnh trước khi tiếp tục.
    {{% /notice %}}

3. Bây giờ hãy chạy các lệnh này để lưu các biến này vào tệp cấu hình môi trường của bạn
    ```
    export PGHOST=$DBENDP
    export PGUSER=$DBUSER
    export PGPASSWORD="$DBPASS"
    export PGDATABASE=aupglab

    echo "export DBPASS=\"$DBPASS\"" >> /home/ec2-user/.bashrc
    echo "export DBUSER=$DBUSER" >> /home/ec2-user/.bashrc
    echo "export DBENDP=$DBENDP" >> /home/ec2-user/.bashrc
    echo "export AWSREGION=$AWSREGION" >> /home/ec2-user/.bashrc
    echo "export PGUSER=$DBUSER" >> /home/ec2-user/.bashrc
    echo "export PGPASSWORD=\"$DBPASS\"" >> /home/ec2-user/.bashrc
    echo "export PGHOST=$DBENDP" >> /home/ec2-user/.bashrc
    echo "export PGDATABASE=aupglab" >> /home/ec2-user/.bashrc

    ```
    ![Configure Cloud9](/images/2/2.png)

***Bây giờ, bạn đã lưu các biến môi trường cụ thể của PostgreSQL trong tệp khởi động Cloud9 Bash, điều này sẽ giúp việc đăng nhập vào Aurora PostgreSQL Cluster bằng psql trở nên thuận tiện hơn.***


#### Kết nối, xác minh và khởi tạo phiên bản cơ sở dữ liệu

    {{% notice note %}}
Hãy đảm bảo môi trường Cloud9 và cơ sở dữ liệu Aurora PostgreSQL của bạn đã được thiết lập chính xác.
{{% /notice %}}

1. Kết nối với cơ sở dữ liệu **aupglab** đã được thiết lập trong cụm Aurora PostgreSQL và xác minh version của database engine bằng cách chạy lệnh sau trong terminal Cloud9 của bạn.
    ```
    psql -c 'select version(),AURORA_VERSION();'

    ```

    Nếu đã thiết lập chính xác môi trường Cloud9 của mình, bạn sẽ thấy kết quả đầu ra tương tự như sau:
    ![Initialize db](/images/2/3.png)

2. Bây giờ, hãy xác minh user, database, host và port mà chúng tôi đang kết nối bằng lệnh sau:

    ```
    psql
    select current_user, current_database(), :'HOST' host, inet_server_port() port;
    \q

    ```
    ![Initialize db](/images/2/4.png)


3. Vì chúng tôi đang sử dụng Aurora cluster endpoint để kết nối nên chúng tôi đang kết nối với primary/writer DB instance của Aurora PostgreSQL cluster. Chạy các lệnh sau trong terminal Cloud9 của bạn để khởi tạo cơ sở dữ liệu PostgreSQL và chuẩn bị sẵn sàng cho các bước thực hành tiếp theo.

    ```
    # Bỏ qua các thông báo LỖI bên dưới.
    psql aupglab -f /home/ec2-user/clone_setup.sql > /home/ec2-user/clone_setup.output
    nohup pgbench -i --fillfactor=100 --scale=100 mylab &>> /tmp/nohup.out

    ```
    
    Bỏ qua bảng không tồn tại các thông báo lỗi bên dưới:
    ![Initialize db](/images/2/5.png)

***pgbench sẽ mất khoảng một phút để khởi tạo cơ sở dữ liệu. Sau khi hoàn thành, bạn có thể chuyển sang phòng thí nghiệm tiếp theo.***