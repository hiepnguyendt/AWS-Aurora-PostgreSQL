---
title : "Testing fault injection queries"
date :  "`r Sys.Date()`" 
weight : 3
chapter : false
pre : " <b> 9.3 </b> "
---


In this test you will simulate a crash of the database engine service on the DB instance. This type of crash can be encountered in real circumstances as a result of out-of-memory conditions, or other unexpected circumstances.

{{%expand "Learn more about fault injection queries" %}}
Fault injection queries provide a mechanism to simulate a variety of faults in the operation of the DB cluster. They are used to test the tolerance of client applications to such faults. They can be used to:

- Simulate crashes of the critical services running on the DB instance. These do not typically result in a failover to a reader, but will result in a restart of the relevant services.
- Simulate disk subsystem degradation or congestion, whether transient in nature or more persistent.
- Simulate read replica failures

{{% /expand%}}

1. In one of the two terminal windows, run the failover test script using the following command:

    ```
     python /home/ec2-user/simple_failover.py -e $DBENDP -u $DBUSER -p $DBPASS -d $PGDATABASE
    ```
    Since we are using the cluster endpoint to connect, the motioning script is connected to the current writer node.

2. On the other Cloud9 terminal window, issue the following fault injection command. A crash of the PostgreSQL-compatible database for the Amazon Aurora instance will be simulated.

    ```
    psql -c "SELECT aurora_inject_crash ('instance');"

    ```

    ![test](/images/9/9.2/1.png)

2. Wait and observe the monitoring script output. Once the crash is triggered, you should see an output similar to the example below.

    ![test](/images/9/9.2/2.png)

As you see above, the instance was restarted and the monitoring script reconnected after a brief interruption.