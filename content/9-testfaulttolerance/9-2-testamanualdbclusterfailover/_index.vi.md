---
title : "Test a manual DB cluster failover"
date :  "`r Sys.Date()`" 
weight : 2
chapter : false
pre : " <b> 9.2. </b> "
---


In this test, we will use a Python script to connect to the cluster endpoint and continuously run a monitoring query.

1. You will need to open an additional Cloud9 terminal window as shown below. You will execute commands in one and see the results in the other session.

2. Download the failover test script with command below:

    ```
    wget https://aupg-fcj-assets.s3.us-west-2.amazonaws.com/lab-scripts/simple_failover.py
    ```
3. In one of the two terminal windows, run the failover test script using the following command:

    ```
     python /home/ec2-user/simple_failover.py -e $DBENDP -u $DBUSER -p $DBPASS -d $PGDATABASE
    ```

4. In the second cloud9 window, execute the command to initiate the failover

    ```
    aws rds failover-db-cluster --db-cluster-identifier aupg-fcj-labs

    ```

5. Initially the script would be connecting to the writer node and executing the query. You will see a slight pause and a message "waiting for failover" when the failover is initiated. Subsequently the time elapsed to re-connect and the new writer node information is printed.

    ![test](/images/9/9.2/2.png)

    Since we are using the cluster endpoint for the connection, there is a slight delay to propagate the DNS record changes for the new writer node. You will see that for a few seconds after the failover, we are still connected to the old writer node which is now the new reader node. Once the DNS record change for the cluster endpoint is propagated to the client machine (in this case the Cloud9 workstation), the script will indicate that it is connected to the Writer node.


6. You will receive two event notification emails for each failover you initiate, one indicating that a failover has started, and one indicating that it has completed.

    ![test](/images/9/9.2/4.png)
    ![test](/images/9/9.2/5.png)

