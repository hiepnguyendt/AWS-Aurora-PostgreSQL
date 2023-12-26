---
title : "Test Fault Tolerance"
date :  "`r Sys.Date()`" 
weight : 9
chapter : false
pre : " <b> 9. </b> "
---


**An Aurora DB cluster** is fault tolerant by design. The cluster volume spans 3 Availability Zones in a single AWS Region, and each Availability Zone contains 2 copies of the data. This functionality means that your DB cluster can tolerate a failure of an Availability Zone without any loss of data and only a brief interruption of service.

If the primary instance in a DB cluster using single-master replication fails, Aurora automatically fails over to a new primary instance in one of two ways:

By promoting an existing Aurora Replica to the new primary instance
By creating a new primary instance

#### In this lab, we will simulate a failover of the Aurora PostgreSQL cluster, and observe the change in writer and reader roles. This lab contains the following tasks:

1. [Setup Failover event notifications](9-1-setupfailovereventnotifications/)
2. [Test a manual DB cluster failover](9-2-testamanualdbclusterfailover/)
3. [Testing fault injection queries](9-3-testingfaultinjectionqueries/)
