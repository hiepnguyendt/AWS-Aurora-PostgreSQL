---
title : "Database Activity Streams in action"
date :  "`r Sys.Date()`" 
weight : 2 
chapter : false
pre : " <b> 6.2. </b> "
---

**Database Activity Streams** provide a near real-time data stream of the database activity in your relational database. When you integrate Database Activity Streams with third-party monitoring tools, you can monitor and audit database activity.

In this section of the lab, first we'll configure and start database activity streams, and then we'll generate some load and observe the database activity streams output.

#### Configuring Database Activity Streams
You start an activity stream at the DB cluster level to monitor database activity for all DB instances of the cluster. Any DB instances added to the cluster are also automatically monitored.

You can choose to have the database session handle database activity events either synchronously or asynchronously:

1. **Synchronous mode**: In synchronous mode, when a database session generates an activity stream event, the session blocks until the event is made durable. If the event can't be made durable for some reason, the database session returns to normal activities. However, an RDS event is sent indicating that activity stream records might be lost for some time. A second RDS event is sent after the system is back to a healthy state.

***The synchronous mode favors the accuracy of the activity stream over database performance.***

2.** Asynchronous mode**: In asynchronous mode, when a database session generates an activity stream event, the session returns to normal activities immediately. In the background, the activity stream event is made a durable record. If an error occurs in the background task, an RDS event is sent. This event indicates the beginning and end of any time windows where activity stream event records might have been lost.

***Asynchronous mode favors database performance over the accuracy of the activity stream.***

#### Start activity streams
1. Open the [Amazon RDS service console Databases section](https://console.aws.amazon.com/rds/home?#databases:) .

2. Select the **Aurora DB cluster** that was you created manually.

3. Click **Actions** menu and choose **Start activity stream**.
    ![streaming](/images/6/6.2/1.png)

4. Enter the following settings in the Database Activity Stream window:

- For **AWS KMS key**, choose the key that you created in the earlier step. If you don't see the new key - try to refresh the browser window.
- For Database activity stream mode, choose **Asynchronous**.
- Choose **Apply immediately**.
    ![streaming](/images/6/6.2/2.png)
    ![streaming](/images/6/6.2/3.png)
6. The Status column on the RDS, Database page for the cluster will start showing **configuring-activity-stream**. 
    ![streaming](/images/6/6.2/4.png)

7. Verify the activity streaming by clicking on the cluster name and clicking on configuration. You will see the Kinesis stream name to which the Database Activity Stream will be published.
    ![streaming](/images/6/6.2/5.png)

8. Wait till the status on RDS,  Database page for the cluster changes back to **Available**. It might take upto 10 minutes for the status to change.

#### Generate load on the Aurora cluster
1. Open a Cloud9 terminal window by referring Open Cloud9 Terminal Window section and run pgbench.

    ```
    pgbench --protocol=prepared --progress=60 --time=300 --client=16 --jobs=96 > results1.log

    ```
#### Sample code to view Database Activity Streams
1. Open a Cloud9 terminal window, download a sample python script das-script.py, following command below:

    ```
    wget https://aupg-fcj-assets.s3.us-west-2.amazonaws.com/lab-scripts/das-scripts.py
    ```

2. In this script, you will be required to replace the value for **REGION_NAME** as per the AWS Region you are running this lab for e.g. us-west-2 and **RESOURCE_ID** with the Aurora cluster's Resource id value 

3. Open a new Cloud9 terminal window and paste the following to edit the Python script:

    ```
    nano /home/ec2-user/das-script.py
    ```
4. Update the following variables (**REGION_NAME** and **RESOURCE_ID** ) in the script as per your actual settings
5. To save file after changes in nano editor, press C**TRL-X** , enter **Y** and then **Enter**.

6. To view the database activity stream, run the python script as shown below:

    ```
    python3 /home/ec2-user/das-script.py

    ```

You will see a lot of messages in the terminal output which is in JSON format.

#### Sample Output Activity Streaming
1. To format the Database Activity Streaming output and interpret the results, you can use a free tool like [JSON formatter](https://jsonformatter.org/) .

2. Copy a block of the **das-script.py** script output starting from **{"type"**: and ending with **}** as shown in the below screenshot and paste it into JSON formatter . Then press the **Format / Beautify** button. You should see the formatted database activity similar to the following:
    ![DAS](/images/6/6.2/6.png)

#### Stopping a Database Activity Streaming

1. Open the [Amazon RDS console](https://console.aws.amazon.com/rds/) .

2. In the navigation pane, choose Databases and select the Aurora DB cluster that you created manually.

3. Click on **Action** and select **Stop database activity stream**.
    ![DAS](/images/6/6.2/7.png)

4. Choose **Apply immediately** and click **Continue** to stop Database activity streaming on the cluster.
    ![DAS](/images/6/6.2/9.png)

5. The status column on the RDS Database home page for the cluster will start showing **configuring-activity-stream**.
    ![DAS](/images/6/6.2/10.png)

6. After some time, activity streams will be stopped and the status column on the RDS Database home page for the cluster will change back to **Available**.

