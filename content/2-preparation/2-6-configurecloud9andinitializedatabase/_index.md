---
title : " Create, Configure Cloud9 and Initialize Database"
date :  "`r Sys.Date()`" 
weight :  6
chapter : false
pre : " <b> 2.6.</b> "
---

#### To create a Cloud9 enviroment, follow these steps:

1. Open the **Amazon Cloud9** [console](https://console.aws.amazon.com/cloud9/), then click **Create enviroment**

    ![Create Cloud9 instance](/images/1/14.png)

2. Enter a name for your environment and select the **Existing compute** option for enviroment type.

    ![Create Cloud9 instance](/images/1/15.png)

3. Under the Existing compute, click on button **Copy key to clipboard**

    ![Create Cloud9 instance](/images/1/16.png)

4. Connect to EC2 instance via MobaXterm
- Following command below to save **Public SSH key** into file **authorized_keys**

    ```
    cd .ssh
    nano authorized_keys

    ```

    ![Create Cloud9 instance](/images/1/17.1.png)
    ![Create Cloud9 instance](/images/1/17.2.png)
-  Install Nodejs with command below

    ```
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
    . ~/.nvm/nvm.sh
    nvm install 16

    ```

    ![Create Cloud9 instance](/images/1/17.png)

- Create folder ``cloud9_env``

    ```
    mkdir cloud9_env
    ```

    ![Create Cloud9 instance](/images/1/18.png)

- Check path of Nodejs

    ```
    which node
    ```

    ![Create Cloud9 instance](/images/1/19.png)


    - Install **jq** packages
    ```
    sudo yum install jq
    ```

    ![Create Cloud9 instance](/images/1/17.3.png)

5. Go back step **Create Cloud9 instance**

- For **User**, enter ``EC2 user``
- For **Host**, enter your EC2 host 

    ![Create Cloud9 instance](/images/1/16.png)

6. Under **Additional details - optional**

- For **Environment path**, type ``~/cloud9_env``
- For **Path to Node.js binary**, type the path that you have checked in previous step 

7. Then click **Create**
8. After **Successfully create Cloud9**, click **Open**

    ![Create Cloud9 instance](/images/1/20.png)

9. C9 install
- Click **Next** 

    ![Create Cloud9 instance](/images/1/21.png)

- Click **Next** and leave everything ticked

    ![Create Cloud9 instance](/images/1/22.png)

- Click **Finish**

    ![Create Cloud9 instance](/images/1/24.png)

Now, you have successfully **created Cloud9 instance with existing compute** 


 ![CreateCloud9instance](/images/1/25.png)



#### Configure the Cloud9 workstation
1. Configure your AWS CLI with command below:
    ```
    aws configure

    ```

- Input your **AWS Access Key ID**
- Input your **AWS Secret Access Key ID**
- Input your **Region name** that you have handed-on lab
- Input **Output format**

2. In the Cloud9 terminal window, paste and run the following commands.

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
A notice disclaimerConfirm that you have output for the DBENDP and DBUSER variables. If not, you may not have named your Aurora cluster aupg-fcj-labs or tagged your Secret with Key:Name and Value: aupg-fcj-labs-DBMasterUser-secret. In that case, please set the DBENDP, DBUSER, and DBPASS variables manually in your terminal window before continuing.
{{% /notice %}}

3. Now run these commands to save these variables to your local environment configuration file

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

***Now, you have saved the PostgreSQL specific environment variables in your Cloud9 Bash startup file which will make it convenient to login to Aurora PostgreSQL Cluster using psql.***


#### Connect, Verify and Initialize Database Instance

    {{% notice note %}}
Let's make sure your Cloud9 environment and Aurora PostgreSQL database has been setup correctly.
{{% /notice %}}

1. Connect to the **aupglab** database that was setup in the Aurora PostgreSQL cluster and verify the version of the database engine by running the following command in your Cloud9 terminal window.

    ```
    psql -c 'select version(),AURORA_VERSION();'

    ```

    If you had setup your Cloud9 environment correctly, you should see output similar to the following:

    ![Initialize db](/images/2/3.png)

2. Now lets verify the user, database, host and port we are connecting to using the following command:

    ```
    psql
    select current_user, current_database(), :'HOST' host, inet_server_port() port;
    \q

    ```

    ![Initialize db](/images/2/4.png)


3. Since we are using the Aurora cluster endpoint to connect, we are connecting to the primary/writer DB instance of the Aurora PostgreSQL Cluster. Run the following commands in your Cloud9 terminal window to initialize the PostgreSQL database and make it ready for subsequent labs.

    ```
    # Ignore the ERROR messages below.
    psql aupglab -f /home/ec2-user/clone_setup.sql > /home/ec2-user/clone_setup.output
    nohup pgbench -i --fillfactor=100 --scale=100 mylab &>> /tmp/nohup.out

    ```
    
    Ignore the table doesn't exist error messages below:

    ![Initialize db](/images/2/5.png)

***pgbench will take a minute or so to initialize the database. Once it completes, you are good to proceed to the next lab.***