---
title : "Cluster Cache Management"
date :  "`r Sys.Date()`" 
weight : 5 
chapter : false
pre : " <b> 5. </b> "
---

In this section, we will review Aurora Cluster Cache management (CCM) feature for Aurora PostgreSQL.
#### Fast Recovery After Failover with Cluster Cache Management for Aurora PostgreSQL
- In a typical failover situation, you might see a temporary but large performance degradation after failover. This degradation occurs because when the failover DB instance starts, the buffer cache is typically empty (Note that Amazon Aurora has a survivable cache  feature which preserves the buffer cache after DB instance reboot). An empty cache is also known as a cold cache. A cold cache degrades performance because the DB instance has to read from the slower disk, instead of taking advantage of values stored in the buffer cache.

- With cluster cache management, you set a specific reader DB instance as the failover target. Cluster cache management ensures that the data in the designated reader's cache is kept synchronized with the data in the writer DB instance's cache. The designated reader's cache with prefilled values is known as a warm cache. If a failover occurs, the designated reader uses pages in its warm cache immediately when it's promoted to the new writer DB instance. This approach provides your application much better recovery performance.

#### In the following sections, we will cover:
 1. [Setup cluster cache management](5-1-setupclustercachemanagement/)
 2. [Benchmarking with Cluster Cache management](5-2-benchmarkingwithclustercachemanagement/)
 