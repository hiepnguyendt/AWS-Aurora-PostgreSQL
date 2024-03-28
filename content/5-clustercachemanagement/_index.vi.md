---
title : "Cluster Cache Management"
date :  "`r Sys.Date()`" 
weight : 5 
chapter : false
pre : " <b> 5. </b> "
---

Trong phần này, chúng ta sẽ xem xét tính năng quản lý bộ nhớ cache của cụm Aurora (CCM) cho Aurora PostgreSQL.
#### Khôi phục nhanh sau failover với quản lý bộ nhớ cache cụm cho Aurora PostgreSQL.
- Trong tình huống failover thông thường, bạn có thể gặp sự suy giảm hiệu suất tạm thời nhưng đáng kể sau khi xảy ra failover. Sự suy giảm này xảy ra vì khi DB instance mới khởi động sau failover, bộ nhớ cache thông thường sẽ trống rỗng (Lưu ý rằng Amazon Aurora có tính năng bộ nhớ cache có khả năng tồn tại (survivable cache) để bảo tồn bộ nhớ cache sau khi DB instance khởi động lại). Một bộ nhớ cache trống rỗng còn được gọi là cold cache. Cold cache làm suy giảm hiệu suất vì DB instance phải đọc từ ổ đĩa chậm thay vì tận dụng các giá trị được lưu trữ trong bộ nhớ cache.
- Với cluster cache management, bạn đặt một DB instance đọc cụ thể làm mục tiêu failover. Cluster cache management đảm bảo rằng dữ liệu trong bộ nhớ cache của DB instance đọc được đồng bộ với dữ liệu trong bộ nhớ cache của DB writer instance . Warm cache trong DB reader instance được định danh với các giá trị được điền trước. Nếu xảy ra failover, DB reader instance được sử dụng trang trong bộ nhớ warm cache ngay khi nó được thăng cấp thành DB writer instance mới. Phương pháp này cung cấp hiệu suất khôi phục tốt hơn cho ứng dụng của bạn.

#### Nội dung:
 1. [Thiết lập cluster cache management](5-1-setupclustercachemanagement/)
 2. [Benchmarking với Cluster Cache management](5-2-benchmarkingwithclustercachemanagement/)
 