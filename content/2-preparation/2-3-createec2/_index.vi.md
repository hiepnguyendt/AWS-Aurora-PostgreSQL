---
title : "Create a EC2 instance"
date :  "`r Sys.Date()`" 
weight : 3
chapter : false
pre : " <b> 2.3. </b> "
---
#### To create an EC2 instance for an Cloud9 enviroment, follow these steps:

1. Open the **Amazon EC2** [console](https://console.aws.amazon.com/ec2/).
2. Click **Launch Instance**.

![Create EC2 instance](/images/1/8.png)

3. Enter name your EC2 instance. Choose an **AMI**. For an app server, you can choose a **Linux AMI**, such as **Amazon Linux 2**.
4. Choose an **instance type**. The instance type that you choose will depend on the requirements of your app server. For example, if you are running a high-traffic website, you will need a larger instance type with more CPU and memory.

![Create EC2 instance](/images/1/9.png)
![Create EC2 instance](/images/1/10.png)
![Create EC2 instance](/images/1/11.png)
5. For **Key Pair**,choose your keypair you have created or click **Create new key pair** 

![Create EC2 instance](/images/1/12.png)
Configure the instance details. This includes things like the number of instances to launch, the network configuration, and the storage configuration.

7.  For **Network settings**
- Choose **VPC** which contains EC2 app server
- Choose **Subnet**
- **Enable** Auto-assign public IP
- Add a **security group** for EC2 app server that you have created easier step . *A security group is a firewall that controls incoming and outgoing traffic to your instance.* 

![Create EC2 instance](/images/1/13.png)

8. **Review** and **launch** the instance

*Once the instance is launched, you can connect to it using an SSH client, such as MobaXterm or Putty. Once you are connected, you can install your app server and deploy your application.*