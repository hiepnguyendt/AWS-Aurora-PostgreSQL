---
title : "Set up failover event notifications"
date :  "`r Sys.Date()`" 
weight : 1
chapter : false
pre : " <b> 9.1. </b> "
---


To receive notifications when failover events occur with your DB cluster, you will create an Amazon Simple Notification Service (SNS) topic, subscribe your email address to the SNS topic, create an RDS event subscription publishing events to the SNS topic and registering the DB cluster as an event source.

1. Open a Cloud9 terminal window by referring [Open Cloud9 Terminal](https://catalog.us-east-1.prod.workshops.aws/workshops/098605dc-8eee-4e84-85e9-c5c6c9e43de2/en-US/lab1-5-client/cloud9-terminal/) Window section and paste the following command to create an SNS topic.

    ```
    aws sns create-topic \
    --name auroralab-cluster-failovers

    ```
    If successful, the command will respond back with a TopicArn identifier, you will need this value in the next command.
    ![failover](/images/9/9.1/1.png)

2. Next, subscribe your email address to the SNS topic using the command below, changing the placeholder [YourEmail] with your email address:

    ```
    aws sns subscribe \
    --topic-arn $(aws sns list-topics --query 'Topics[?contains(TopicArn,`auroralab-cluster-failovers`)].TopicArn' --output text) \
    --protocol email \
    --notification-endpoint '[YourEmail]'

    ```

    You should see Output similar to the following:
    ![failover](/images/9/9.1/2.png)

3. You will receive a verification email on that address, please confirm the subscription by following the instructions in the email.
    ![failover](/images/9/9.1/3.png)

    Once you click **Confirm subscription** in the email, you'll see a browser window with a confirmation message as follows:
    ![failover](/images/9/9.1/4.png)

4. Once confirmed, or while you are waiting for the verification email to arrive, create an RDS event subscription and register the DB cluster as an event source using the command below:

    {{% notice note %}}
If your Aurora cluster name is different than aupg-labs-cluster, update the command below accordingly.
{{% /notice %}}

    ```
    aws rds create-event-subscription \
    --subscription-name auroralab-cluster-failovers \
    --sns-topic-arn $(aws sns list-topics --query 'Topics[?contains(TopicArn,`auroralab-cluster-failovers`)].TopicArn' --output text) \
    --source-type db-cluster \
    --event-categories '["failover"]' \
    --enabled
    ```
![failover](/images/9/9.1/5.png)

![failover](/images/9/9.1/6.png)  
    ```
    aws rds add-source-identifier-to-subscription \
    --subscription-name auroralab-cluster-failovers \
    --source-identifier aupg-fcj-labs

    ```
    


At this time the event notifications have been configured. Ensure you have verified your email address before proceeding to the next section.