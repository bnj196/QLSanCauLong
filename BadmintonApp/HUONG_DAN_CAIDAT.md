# HƯỚNG DẪN CÀI ĐẶT CHƯƠNG TRÌNH QUẢN LÝ CÂU LẠC BỘ CẦU LÔNG

## I. YÊU CẦU HỆ THỐNG

### 1. Phần mềm cần cài đặt:
- **Microsoft SQL Server** (2016 trở lên) hoặc **SQL Server Express**
- **.NET 6.0 SDK** trở lên (để chạy ứng dụng WinForms)
- **Visual Studio 2022** (khuyến nghị) hoặc Visual Studio Code

### 2. Cấu hình đề nghị:
- Hệ điều hành: Windows 10/11
- RAM: Tối thiểu 4GB
- Dung lượng ổ cứng: 500MB trống

---

## II. CÁC BƯỚC CÀI ĐẶT

### Bước 1: Cài đặt Database

1. Mở **SQL Server Management Studio (SSMS)**
2. Kết nối đến SQL Server instance của bạn
3. Mở file `BadmintonClub.sql` trong SSMS
4. Nhấn **Execute** (F5) để chạy toàn bộ script

Script sẽ tự động thực hiện:
- Tạo database `BadmintonClubDB`
- Tạo 7 bảng (Members, Courts, Coaches, Bookings, CoachingSessions, Equipment, Payments)
- Insert dữ liệu mẫu (20+ bản ghi mỗi bảng)
- Tạo 40 câu truy vấn mẫu
- Tạo 7 Stored Procedures
- Tạo 8 Functions
- Tạo 5 Triggers
- Tạo 5 Users và phân quyền

### Bước 2: Cấu hình Connection String

1. Mở file `MainForm.cs` trong thư mục `BadmintonClubApp`
2. Tìm dòng khai báo connection string:
```csharp
private string connectionString = "Server=localhost;Database=BadmintonClubDB;Integrated Security=true;";
```
3. Chỉnh sửa nếu cần:
   - `Server=localhost`: Thay bằng tên server SQL của bạn (ví dụ: `DESKTOP-ABC\SQLEXPRESS`)
   - Nếu dùng SQL Authentication, thay thành:
   ```csharp
   private string connectionString = "Server=TÊN_SERVER;Database=BadmintonClubDB;User ID=sa;Password=MẬT_KHẨU;";
   ```

### Bước 3: Build và Chạy Ứng dụng

**Cách 1: Sử dụng Visual Studio**
1. Mở Visual Studio 2022
2. Chọn **File > Open > Project/Solution**
3. Chọn file `BadmintonClubApp.csproj`
4. Nhấn **F5** để chạy chương trình

**Cách 2: Sử dụng Command Line**
```bash
cd BadmintonApp/BadmintonClubApp
dotnet restore
dotnet build
dotnet run
```

---

## III. CHỨC NĂNG CHƯƠNG TRÌNH

### 1. Tab Hội Viên
- Xem danh sách tất cả hội viên
- Thêm hội viên mới (Tên, Ngày sinh, Giới tính, SĐT, Loại membership)
- Sửa thông tin hội viên
- Xóa hội viên

### 2. Tab Sân Đấu
- Xem danh sách sân
- Thêm sân mới (Tên sân, Tầng, Giá thuê/giờ, Trạng thái)
- Cập nhật trạng thái sân

### 3. Tab Huấn Luyện Viên
- Xem danh sách HLV
- Thêm HLV mới (Tên, Chuyên môn, Kinh nghiệm, Lương)

### 4. Tab Đặt Sân
- Đặt sân sử dụng Stored Procedure `USP_MakeBooking`
- Tự động tính tiền dựa trên giờ thuê và giá sân
- Xem lịch sử đặt sân

### 5. Tab Thanh Toán
- Ghi nhận thanh toán từ hội viên
- Hỗ trợ nhiều phương thức: Tiền mặt, Chuyển khoản, Thẻ

### 6. Tab Báo Cáo & Thống Kê
Các báo cáo có sẵn:
- Doanh thu theo tháng
- Thống kê thành viên theo loại (Tháng/Năm/Vãng lai)
- Sử dụng sân theo tầng
- Top 5 thành viên chi tiêu nhiều nhất
- Trạng thái đặt sân
- Số buổi tập theo HLV
- Thiết bị theo danh mục

---

## IV. KIỂM TRA DATABASE

### 1. Kiểm tra số lượng bản ghi:
```sql
USE BadmintonClubDB;
SELECT 'Members' AS TableName, COUNT(*) AS RecordCount FROM Members
UNION ALL
SELECT 'Courts', COUNT(*) FROM Courts
UNION ALL
SELECT 'Coaches', COUNT(*) FROM Coaches
UNION ALL
SELECT 'Bookings', COUNT(*) FROM Bookings
UNION ALL
SELECT 'CoachingSessions', COUNT(*) FROM CoachingSessions
UNION ALL
SELECT 'Equipment', COUNT(*) FROM Equipment
UNION ALL
SELECT 'Payments', COUNT(*) FROM Payments;
```

### 2. Kiểm tra Stored Procedures:
```sql
-- Danh sách SP
SELECT name FROM sys.procedures;

-- Chạy thử SP
EXEC USP_CountMembersByType;
EXEC USP_GetRevenueByMonth @Month = 1, @Year = 2024;
```

### 3. Kiểm tra Functions:
```sql
-- Test function tính tuổi
SELECT dbo.FN_CalculateAge('2000-01-01') AS Age;

-- Test function tính tổng tiền đã trả
SELECT dbo.FN_GetMemberTotalPaid(1) AS TotalPaid;
```

### 4. Kiểm tra Triggers:
```sql
-- Test trigger tự động tạo payment khi booking completed
UPDATE Bookings SET Status = N'Completed' WHERE BookingID = 1;
SELECT * FROM Payments WHERE BookingID = 1;
```

### 5. Kiểm tra Users và Permissions:
```sql
-- Xem danh sách users
SELECT * FROM sys.database_principals WHERE type = 'S';

-- Xem permissions
SELECT * FROM sys.database_permissions;
```

---

## V. DANH SÁCH THÀNH VIÊN NHÓM

| STT | Họ và Tên | MSSV | Nhiệm vụ |
|-----|-----------|------|----------|
| 1 | [Tên thành viên 1] | [MSSV] | Thiết kế Database, Viết SQL Script |
| 2 | [Tên thành viên 2] | [MSSV] | Lập trình WinForms, Giao diện |
| 3 | [Tên thành viên 3] | [MSSV] | Báo cáo, Testing, Documentation |

*Lưu ý: Điền thông tin thành viên nhóm vào bảng trên*

---

## VI. XỬ LÝ SỰ CỐ THƯỜNG GẶP

### Lỗi 1: Cannot connect to database
**Nguyên nhân:** SQL Server chưa chạy hoặc connection string sai
**Giải pháp:** 
- Kiểm tra SQL Server Service đang chạy
- Kiểm tra lại connection string trong code

### Lỗi 2: Login failed for user
**Nguyên nhân:** Thông tin đăng nhập không đúng
**Giải pháp:** 
- Dùng Windows Authentication (Integrated Security=true)
- Hoặc kiểm tra lại username/password

### Lỗi 3: Invalid object name
**Nguyên nhân:** Database chưa được tạo hoặc chọn sai database
**Giải pháp:** 
- Chạy lại file SQL script
- Đảm bảo đang kết nối đúng database `BadmintonClubDB`

### Lỗi 4: .NET runtime not found
**Nguyên nhân:** Chưa cài .NET 6.0 SDK
**Giải pháp:** 
- Tải và cài đặt từ: https://dotnet.microsoft.com/download/dotnet/6.0

---

## VII. FILE TRONG DỰ ÁN

```
BadmintonApp/
├── BadmintonClub.sql          # Script SQL tạo DB, tables, data, SP, functions, triggers
├── BadmintonClubApp/
│   ├── BadmintonClubApp.csproj  # File project .NET
│   ├── Program.cs               # Entry point
│   └── MainForm.cs              # Form chính với tất cả chức năng
└── README.md                    # File hướng dẫn này
```

---

## VIII. LIÊN HỆ

Nếu gặp vấn đề trong quá trình cài đặt, vui lòng liên hệ trưởng nhóm để được hỗ trợ.

---

**Chúc các bạn thành công!**
