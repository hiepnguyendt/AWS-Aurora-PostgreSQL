---
title : "Setup KMS for Database Activity Streaming"
date :  "`r Sys.Date()`" 
weight : 1 
chapter : false
pre : " <b> 6.1. </b> "
---

**Database Activity Streaming** requires a Master Key to encrypt the key that in turn encrypts the logged database activity. The Default AWS RDS KMS key can’t be used as the Master key. Therefore, we need to create a new customer managed KMS key to configure the Database Activity Streaming.

#### Create KMS Key
1. Open [KMS console](https://console.aws.amazon.com/kms/home)  and select **Customer Managed Keys** on the left-hand side and click on **Create Key**:
2. On the next screen under Configure key choose **Symmetric** key type and click **Next**:
    ![DAS](/images/6/6.1/1.png)

3. On the next screen, under **Add Labels** give a name for the key under the field **Alias** such as ``cmk-apg-lab``.

- Under Description field, type a description for the key such as ``Customer managed Key for Aurora PostgreSQL Database Activity Streaming (DAS) lab`` and click Next.
    ![DAS](/images/6/6.1/2.png)

4. On the next screen under **Define Key Administrative permissions** and  **Define key usage permissions**, leave with default setting.

5. On the next screen, review the policy and click **Finish**.
    ![DAS](/images/6/6.1/3.png)

6. Verify the newly created KMS key on the KMS dashboard.
    ![DAS](/images/6/6.1/4.png)