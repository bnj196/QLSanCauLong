-- =============================================
-- BADMINTON CLUB MANAGEMENT DATABASE
-- Đáp ứng yêu cầu: 7 bảng, Chuẩn hóa 3NF, Dữ liệu mẫu
-- =============================================

USE master;
GO
IF DB_ID('BadmintonClubDB') IS NOT NULL
    DROP DATABASE BadmintonClubDB;
GO
CREATE DATABASE BadmintonClubDB;
GO
USE BadmintonClubDB;
GO

-- =============================================
-- 1. TẠO BẢNG (7 TABLES) - Đạt chuẩn 3NF
-- =============================================

-- Bảng 1: Members (Hội viên)
CREATE TABLE Members (
    MemberID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender NVARCHAR(10) CHECK (Gender IN N'Nam', N'Nữ'),
    Phone VARCHAR(15) UNIQUE,
    JoinDate DATE DEFAULT GETDATE(),
    MembershipType NVARCHAR(20) CHECK (MembershipType IN N'Tháng', N'Năm', N'Vãng lai')
);

-- Bảng 2: Courts (Sân cầu)
CREATE TABLE Courts (
    CourtID INT PRIMARY KEY IDENTITY(1,1),
    CourtName NVARCHAR(50) NOT NULL,
    FloorLevel INT NOT NULL,
    HourlyRate DECIMAL(10,0) NOT NULL,
    Status NVARCHAR(20) DEFAULT N'Available' CHECK (Status IN N'Available', N'Maintenance', N'Booked')
);

-- Bảng 3: Coaches (Huấn luyện viên)
CREATE TABLE Coaches (
    CoachID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Specialty NVARCHAR(50), -- Chuyên môn: Đơn, Đôi, Người mới
    ExperienceYears INT,
    Phone VARCHAR(15),
    Salary DECIMAL(10,0)
);

-- Bảng 4: Bookings (Đặt sân)
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    MemberID INT FOREIGN KEY REFERENCES Members(MemberID),
    CourtID INT FOREIGN KEY REFERENCES Courts(CourtID),
    BookingDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    TotalAmount DECIMAL(10,0),
    Status NVARCHAR(20) DEFAULT N'Pending' CHECK (Status IN N'Pending', N'Confirmed', N'Cancelled', N'Completed')
);

-- Bảng 5: CoachingSessions (Buổi tập huấn)
CREATE TABLE CoachingSessions (
    SessionID INT PRIMARY KEY IDENTITY(1,1),
    MemberID INT FOREIGN KEY REFERENCES Members(MemberID),
    CoachID INT FOREIGN KEY REFERENCES Coaches(CoachID),
    SessionDate DATE NOT NULL,
    DurationHours INT,
    Fee DECIMAL(10,0),
    Notes NVARCHAR(255)
);

-- Bảng 6: Equipment (Trang thiết bị)
CREATE TABLE Equipment (
    EquipmentID INT PRIMARY KEY IDENTITY(1,1),
    ItemName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50), -- Vợt, Cầu, Giày
    Quantity INT,
    Price DECIMAL(10,0),
    PurchaseDate DATE
);

-- Bảng 7: Payments (Thanh toán)
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT FOREIGN KEY REFERENCES Bookings(BookingID),
    MemberID INT FOREIGN KEY REFERENCES Members(MemberID),
    Amount DECIMAL(10,0) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(20) CHECK (PaymentMethod IN N'Tiền mặt', N'Chuyển khoản', N'Thẻ')
);

-- =============================================
-- 2. NHẬP DỮ LIỆU (Tối thiểu 20 bản ghi mỗi bảng)
-- =============================================

-- Insert Members (25 records)
DECLARE @i INT = 1;
WHILE @i <= 25
BEGIN
    INSERT INTO Members (FullName, DOB, Gender, Phone, JoinDate, MembershipType)
    VALUES (N'Hội viên ' + CAST(@i AS NVARCHAR), DATEADD(YEAR, -@i*2, GETDATE()), 
            CASE WHEN @i % 2 = 0 THEN N'Nam' ELSE N'Nữ' END,
            '090' + RIGHT('00000000' + CAST(@i AS VARCHAR), 8),
            DATEADD(DAY, -@i, GETDATE()),
            CASE WHEN @i % 3 = 0 THEN N'Năm' WHEN @i % 3 = 1 THEN N'Tháng' ELSE N'Vãng lai' END);
    SET @i = @i + 1;
END

-- Insert Courts (20 records)
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Courts (CourtName, FloorLevel, HourlyRate, Status)
    VALUES (N'Sân A' + CAST(@i AS NVARCHAR), (@i % 3) + 1, 100000 + (@i * 5000), 
            CASE WHEN @i % 5 = 0 THEN N'Maintenance' ELSE N'Available' END);
    SET @i = @i + 1;
END

-- Insert Coaches (20 records)
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Coaches (FullName, Specialty, ExperienceYears, Phone, Salary)
    VALUES (N'HLV ' + CAST(@i AS NVARCHAR), 
            CASE WHEN @i % 3 = 0 THEN N'Đơn' WHEN @i % 3 = 1 THEN N'Đôi' ELSE N'Người mới' END,
            (@i % 10) + 1, '091' + RIGHT('00000000' + CAST(@i AS VARCHAR), 8),
            5000000 + (@i * 200000));
    SET @i = @i + 1;
END

-- Insert Equipment (20 records)
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Equipment (ItemName, Category, Quantity, Price, PurchaseDate)
    VALUES (N'Trang bị ' + CAST(@i AS NVARCHAR), 
            CASE WHEN @i % 3 = 0 THEN N'Vợt' WHEN @i % 3 = 1 THEN N'Cầu' ELSE N'Giày' END,
            10 + @i, 50000 + (@i * 2000), DATEADD(MONTH, -@i, GETDATE()));
    SET @i = @i + 1;
END

-- Insert Bookings (25 records)
SET @i = 1;
WHILE @i <= 25
BEGIN
    DECLARE @amt DECIMAL(10,0) = 200000 + (@i * 10000);
    INSERT INTO Bookings (MemberID, CourtID, BookingDate, StartTime, EndTime, TotalAmount, Status)
    VALUES ((@i % 25) + 1, (@i % 20) + 1, DATEADD(DAY, @i, GETDATE()), 
            '08:00', '10:00', @amt,
            CASE WHEN @i % 4 = 0 THEN N'Cancelled' WHEN @i % 4 = 1 THEN N'Completed' ELSE N'Confirmed' END);
    SET @i = @i + 1;
END

-- Insert CoachingSessions (20 records)
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO CoachingSessions (MemberID, CoachID, SessionDate, DurationHours, Fee, Notes)
    VALUES ((@i % 25) + 1, (@i % 20) + 1, DATEADD(DAY, @i*2, GETDATE()), 2, 300000, N'Buổi tập cơ bản');
    SET @i = @i + 1;
END

-- Insert Payments (25 records)
SET @i = 1;
WHILE @i <= 25
BEGIN
    INSERT INTO Payments (BookingID, MemberID, Amount, PaymentDate, PaymentMethod)
    VALUES ((@i % 25) + 1, (@i % 25) + 1, 200000 + (@i * 5000), DATEADD(HOUR, @i, GETDATE()),
            CASE WHEN @i % 3 = 0 THEN N'Thẻ' WHEN @i % 3 = 1 THEN N'Chuyển khoản' ELSE N'Tiền mặt' END);
    SET @i = @i + 1;
END

-- =============================================
-- 3. 40 CÂU TRUY VẤN (QUERIES)
-- =============================================

-- a. Truy vấn đơn giản (5 câu)
-- Q1: Danh sách hội viên
SELECT * FROM Members;
-- Q2: Danh sách sân còn trống
SELECT * FROM Courts WHERE Status = N'Available';
-- Q3: Thông tin HLV có kinh nghiệm > 5 năm
SELECT * FROM Coaches WHERE ExperienceYears > 5;
-- Q4: Danh sách thiết bị loại 'Vợt'
SELECT * FROM Equipment WHERE Category = N'Vợt';
-- Q5: Các booking đã hoàn thành
SELECT * FROM Bookings WHERE Status = N'Completed';

-- b. Truy vấn với Aggregate Functions (7 câu)
-- Q6: Tổng số hội viên
SELECT COUNT(*) AS TotalMembers FROM Members;
-- Q7: Tổng doanh thu từ thanh toán
SELECT SUM(Amount) AS TotalRevenue FROM Payments;
-- Q8: Số lượng sân trên mỗi tầng
SELECT FloorLevel, COUNT(*) AS NumCourts FROM Courts GROUP BY FloorLevel;
-- Q9: Trung bình phí thuê sân
SELECT AVG(HourlyRate) AS AvgRate FROM Courts;
-- Q10: Số buổi tập tối đa của một HLV
SELECT MAX(DurationHours) AS MaxDuration FROM CoachingSessions;
-- Q11: Tổng số giờ đặt sân của từng thành viên
SELECT MemberID, SUM(DATEDIFF(HOUR, StartTime, EndTime)) AS TotalHours 
FROM Bookings GROUP BY MemberID;
-- Q12: Số lượng thiết bị theo danh mục
SELECT Category, SUM(Quantity) AS TotalQty FROM Equipment GROUP BY Category;

-- c. Truy vấn với mệnh đề HAVING (5 câu)
-- Q13: Thành viên đặt sân nhiều hơn 2 lần
SELECT MemberID, COUNT(*) AS BookingCount 
FROM Bookings GROUP BY MemberID HAVING COUNT(*) > 2;
-- Q14: Sân có giá thuê trung bình > 120000 (Giả sử nhóm sân)
SELECT FloorLevel, AVG(HourlyRate) AS AvgRate 
FROM Courts GROUP BY FloorLevel HAVING AVG(HourlyRate) > 120000;
-- Q15: HLV có tổng giờ dạy > 5 giờ
SELECT CoachID, SUM(DurationHours) AS TotalHours 
FROM CoachingSessions GROUP BY CoachID HAVING SUM(DurationHours) > 5;
-- Q16: Phương thức thanh toán có tổng tiền > 1000000
SELECT PaymentMethod, SUM(Amount) AS TotalAmt 
FROM Payments GROUP BY PaymentMethod HAVING SUM(Amount) > 1000000;
-- Q17: Loại hội viên có số lượng > 5 người
SELECT MembershipType, COUNT(*) AS CountMem 
FROM Members GROUP BY MembershipType HAVING COUNT(*) > 5;

-- d. Truy vấn lớn nhất, nhỏ nhất (4 câu)
-- Q18: Hội viên tham gia sớm nhất
SELECT TOP 1 * FROM Members ORDER BY JoinDate ASC;
-- Q19: Sân có giá thuê cao nhất
SELECT TOP 1 * FROM Courts ORDER BY HourlyRate DESC;
-- Q20: Khoản thanh toán nhỏ nhất
SELECT TOP 1 * FROM Payments ORDER BY Amount ASC;
-- Q21: HLV có lương cao nhất
SELECT TOP 1 * FROM Coaches ORDER BY Salary DESC;

-- e. Truy vấn Không/chưa có (Not In, Left/Right Join) (5 câu)
-- Q22: Hội viên chưa từng đặt sân
SELECT * FROM Members WHERE MemberID NOT IN (SELECT DISTINCT MemberID FROM Bookings);
-- Q23: Sân chưa từng được đặt
SELECT C.* FROM Courts C LEFT JOIN Bookings B ON C.CourtID = B.CourtID WHERE B.BookingID IS NULL;
-- Q24: HLV chưa có buổi dạy nào
SELECT C.* FROM Coaches C LEFT JOIN CoachingSessions CS ON C.CoachID = CS.CoachID WHERE CS.SessionID IS NULL;
-- Q25: Thiết bị chưa từng được mua (giả sử có bảng lịch sử mua riêng, ở đây mock bằng số lượng = 0)
SELECT * FROM Equipment WHERE Quantity = 0;
-- Q26: Thành viên chưa thanh toán khoản nào
SELECT M.* FROM Members M LEFT JOIN Payments P ON M.MemberID = P.MemberID WHERE P.PaymentID IS NULL;

-- f. Truy vấn Hợp/Giao/Trừ (3 câu)
-- Q27: Union - Danh sách tên người (Member và Coach)
SELECT FullName FROM Members UNION SELECT FullName FROM Coaches;
-- Q28: Except - Sân đã đặt trừ sân đang bảo trì
SELECT CourtID FROM Bookings EXCEPT SELECT CourtID FROM Courts WHERE Status = N'Maintenance';
-- Q29: Intersect - Thành viên vừa đặt sân vừa đi học (có trong cả 2 bảng)
SELECT MemberID FROM Bookings INTERSECT SELECT MemberID FROM CoachingSessions;

-- g. Truy vấn Update, Delete (7 câu)
-- Q30: Update trạng thái sân sang Available
UPDATE Courts SET Status = N'Available' WHERE Status = N'Maintenance' AND CourtID < 5;
-- Q31: Update giá thuê tăng 10% cho sân tầng 1
UPDATE Courts SET HourlyRate = HourlyRate * 1.1 WHERE FloorLevel = 1;
-- Q32: Update ghi chú buổi tập
UPDATE CoachingSessions SET Notes = N'Đã hoàn thành tốt' WHERE SessionID = 1;
-- Q33: Delete các booking đã hủy quá 30 ngày (Giả lập)
DELETE FROM Bookings WHERE Status = N'Cancelled' AND BookingID = 4; 
-- Q34: Delete thiết bị hết hàng
DELETE FROM Equipment WHERE Quantity = 0 AND EquipmentID = 20;
-- Q35: Update phương thức thanh toán
UPDATE Payments SET PaymentMethod = N'Chuyển khoản' WHERE PaymentID = 1;
-- Q36: Update loại hội viên thành 'Năm' cho thành viên cũ
UPDATE Members SET MembershipType = N'Năm' WHERE JoinDate < DATEADD(MONTH, -6, GETDATE()) AND MemberID < 10;

-- h. Truy vấn sử dụng phép Chia (Relational Division) (4 câu)
-- Ý tưởng: Tìm thành viên đã đặt TẤT CẢ các sân ở tầng 1
-- Q37: Tìm Member đã đặt tất cả sân tầng 1
SELECT M.MemberID, M.FullName 
FROM Members M
WHERE NOT EXISTS (
    SELECT C.CourtID FROM Courts C WHERE C.FloorLevel = 1
    EXCEPT
    SELECT B.CourtID FROM Bookings B WHERE B.MemberID = M.MemberID
);

-- Ý tưởng: Tìm HLV dạy tất cả các thành viên nam (khó xảy ra thực tế nhưng đúng logic chia)
-- Q38: Tìm HLV dạy ít nhất 1 buổi cho tất cả các thành viên loại 'Năm'
SELECT C.CoachID, C.FullName
FROM Coaches C
WHERE NOT EXISTS (
    SELECT M.MemberID FROM Members M WHERE M.MembershipType = N'Năm'
    EXCEPT
    SELECT CS.MemberID FROM CoachingSessions CS WHERE CS.CoachID = C.CoachID
);

-- Q39: Tìm thành viên đã thanh toán bằng tất cả các phương thức hiện có (Tiền mặt, CK, Thẻ)
SELECT P1.MemberID
FROM Payments P1
GROUP BY P1.MemberID
HAVING COUNT(DISTINCT P1.PaymentMethod) = (SELECT COUNT(DISTINCT PaymentMethod) FROM Payments);

-- Q40: Tìm sân được đặt bởi tất cả các thành viên giới tính 'Nam' (Logic chia ngược)
SELECT CT.CourtID
FROM Courts CT
WHERE NOT EXISTS (
    SELECT M.MemberID FROM Members M WHERE M.Gender = N'Nam'
    EXCEPT
    SELECT B.MemberID FROM Bookings B WHERE B.CourtID = CT.CourtID
);

-- =============================================
-- 4. STORED PROCEDURES (7 SP)
-- =============================================

-- SP1: Thêm hội viên mới
CREATE PROC USP_AddMember
    @FullName NVARCHAR(100), @DOB DATE, @Gender NVARCHAR(10), @Phone VARCHAR(15), @Type NVARCHAR(20)
AS
BEGIN
    INSERT INTO Members (FullName, DOB, Gender, Phone, MembershipType) 
    VALUES (@FullName, @DOB, @Gender, @Phone, @Type);
END
GO

-- SP2: Đặt sân và tính tiền tự động
CREATE PROC USP_MakeBooking
    @MemberID INT, @CourtID INT, @Date DATE, @Start TIME, @End TIME
AS
BEGIN
    DECLARE @Rate DECIMAL(10,0);
    SELECT @Rate = HourlyRate FROM Courts WHERE CourtID = @CourtID;
    
    DECLARE @Hours INT = DATEDIFF(HOUR, @Start, @End);
    DECLARE @Total DECIMAL(10,0) = @Hours * @Rate;

    INSERT INTO Bookings (MemberID, CourtID, BookingDate, StartTime, EndTime, TotalAmount, Status)
    VALUES (@MemberID, @CourtID, @Date, @Start, @End, @Total, N'Confirmed');
END
GO

-- SP3: Báo cáo doanh thu theo tháng
CREATE PROC USP_GetRevenueByMonth
    @Month INT, @Year INT
AS
BEGIN
    SELECT SUM(Amount) AS TotalRevenue 
    FROM Payments 
    WHERE MONTH(PaymentDate) = @Month AND YEAR(PaymentDate) = @Year;
END
GO

-- SP4: Cập nhật thông tin HLV
CREATE PROC USP_UpdateCoach
    @CoachID INT, @Salary DECIMAL(10,0)
AS
BEGIN
    UPDATE Coaches SET Salary = @Salary WHERE CoachID = @CoachID;
END
GO

-- SP5: Xóa booking và hoàn tiền (Logic giả lập)
CREATE PROC USP_CancelBooking
    @BookingID INT
AS
BEGIN
    UPDATE Bookings SET Status = N'Cancelled' WHERE BookingID = @BookingID;
    -- Có thể thêm logic insert vào bảng Refunds nếu có
END
GO

-- SP6: Tìm kiếm booking theo khoảng ngày
CREATE PROC USP_SearchBookings
    @FromDate DATE, @ToDate DATE
AS
BEGIN
    SELECT * FROM Bookings WHERE BookingDate BETWEEN @FromDate AND @ToDate;
END
GO

-- SP7: Thống kê số lượng hội viên theo loại
CREATE PROC USP_CountMembersByType
AS
BEGIN
    SELECT MembershipType, COUNT(*) AS Count FROM Members GROUP BY MembershipType;
END
GO

-- =============================================
-- 5. FUNCTIONS (8 FUNCTIONS)
-- =============================================

-- Func1: Tính tuổi hội viên
CREATE FUNCTION FN_CalculateAge(@DOB DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @DOB, GETDATE());
END
GO

-- Func2: Tính tổng tiền một member đã trả
CREATE FUNCTION FN_GetMemberTotalPaid(@MemberID INT)
RETURNS DECIMAL(10,0)
AS
BEGIN
    DECLARE @Total DECIMAL(10,0);
    SELECT @Total = ISNULL(SUM(Amount), 0) FROM Payments WHERE MemberID = @MemberID;
    RETURN @Total;
END
GO

-- Func3: Kiểm tra sân trống vào giờ cụ thể
CREATE FUNCTION FN_IsCourtAvailable(@CourtID INT, @Date DATE, @Time TIME)
RETURNS BIT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Bookings 
    WHERE CourtID = @CourtID AND BookingDate = @Date AND Status != N'Cancelled'
    AND @Time BETWEEN StartTime AND EndTime;
    
    IF @Count > 0 RETURN 0;
    RETURN 1;
END
GO

-- Func4: Lấy tên đầy đủ kèm loại hội viên
CREATE FUNCTION FN_GetMemberInfo(@MemberID INT)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @Info NVARCHAR(200);
    SELECT @Info = FullName + N' (' + MembershipType + N')' FROM Members WHERE MemberID = @MemberID;
    RETURN @Info;
END
GO

-- Func5: Tính thuế phí (10%)
CREATE FUNCTION FN_CalculateTax(@Amount DECIMAL(10,0))
RETURNS DECIMAL(10,0)
AS
BEGIN
    RETURN @Amount * 0.1;
END
GO

-- Func6: Số buổi tập của một cặp HLV-Member
CREATE FUNCTION FN_CountSessions(@CoachID INT, @MemberID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Cnt INT;
    SELECT @Cnt = COUNT(*) FROM CoachingSessions WHERE CoachID = @CoachID AND MemberID = @MemberID;
    RETURN @Cnt;
END
GO

-- Func7: Ngày đặt sân gần nhất của Member
CREATE FUNCTION FN_LastBookingDate(@MemberID INT)
RETURNS DATE
AS
BEGIN
    DECLARE @Dt DATE;
    SELECT TOP 1 @Dt = BookingDate FROM Bookings WHERE MemberID = @MemberID ORDER BY BookingDate DESC;
    RETURN @Dt;
END
GO

-- Func8: Đánh giá mức độ thân thiết (Dựa trên tổng chi tiêu)
CREATE FUNCTION FN_GetMemberTier(@MemberID INT)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Total DECIMAL(10,0) = dbo.FN_GetMemberTotalPaid(@MemberID);
    IF @Total > 5000000 RETURN N'Kim Cương';
    IF @Total > 2000000 RETURN N'Vàng';
    RETURN N'Bạc';
END
GO

-- =============================================
-- 6. TRIGGERS (5 TRIGGERS)
-- =============================================

-- Trigger 1: Tự động cập nhật Status sân khi có Booking mới
CREATE TRIGGER TRG_UpdateCourtStatusOnBooking
ON Bookings
AFTER INSERT
AS
BEGIN
    UPDATE Courts SET Status = N'Booked'
    WHERE CourtID IN (SELECT CourtID FROM inserted);
END
GO

-- Trigger 2: Ngăn xóa Member nếu còn Booking
CREATE TRIGGER TRG_PreventDeleteMemberWithBookings
ON Members
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted d JOIN Bookings b ON d.MemberID = b.MemberID)
    BEGIN
        RAISERROR (N'Không thể xóa thành viên còn lịch đặt!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE M FROM Members M JOIN deleted d ON M.MemberID = d.MemberID;
    END
END
GO

-- Trigger 3: Log thay đổi giá sân vào bảng log (Giả sử tạo bảng log nhanh)
IF OBJECT_ID('PriceChangeLog') IS NULL
CREATE TABLE PriceChangeLog (LogID INT IDENTITY, CourtID INT, OldPrice DECIMAL, NewPrice DECIMAL, ChangeDate DATETIME);
GO

CREATE TRIGGER TRG_LogCourtPriceChange
ON Courts
AFTER UPDATE
AS
BEGIN
    IF UPDATE(HourlyRate)
    BEGIN
        INSERT INTO PriceChangeLog (CourtID, OldPrice, NewPrice, ChangeDate)
        SELECT d.CourtID, d.HourlyRate, i.HourlyRate, GETDATE()
        FROM deleted d JOIN inserted i ON d.CourtID = i.CourtID;
    END
END
GO

-- Trigger 4: Tự động tạo Payment khi Booking chuyển sang Completed (Giả lập)
CREATE TRIGGER TRG_AutoPaymentOnComplete
ON Bookings
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Status)
    BEGIN
        INSERT INTO Payments (BookingID, MemberID, Amount, PaymentMethod)
        SELECT i.BookingID, i.MemberID, i.TotalAmount, N'Tiền mặt'
        FROM inserted i
        WHERE i.Status = N'Completed'
        AND NOT EXISTS (SELECT 1 FROM Payments p WHERE p.BookingID = i.BookingID);
    END
END
GO

-- Trigger 5: Kiểm tra trùng lịch đặt (Chồng giờ)
CREATE TRIGGER TRG_CheckBookingOverlap
ON Bookings
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Bookings b ON i.CourtID = b.CourtID AND i.BookingDate = b.BookingDate
        WHERE b.Status != N'Cancelled'
        AND (
            (i.StartTime >= b.StartTime AND i.StartTime < b.EndTime) OR
            (i.EndTime > b.StartTime AND i.EndTime <= b.EndTime) OR
            (i.StartTime <= b.StartTime AND i.EndTime >= b.EndTime)
        )
    )
    BEGIN
        RAISERROR (N'Sân đã được đặt trong khung giờ này!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Bookings (MemberID, CourtID, BookingDate, StartTime, EndTime, TotalAmount, Status)
        SELECT MemberID, CourtID, BookingDate, StartTime, EndTime, TotalAmount, Status FROM inserted;
    END
END
GO

-- =============================================
-- 7. USER & PERMISSIONS (5 USERS)
-- =============================================

-- Lưu ý: Chạy phần này cần quyền Admin trên SQL Server
-- Tạo Login
CREATE LOGIN User_QuanTri WITH PASSWORD = '123456';
CREATE LOGIN User_LeTan WITH PASSWORD = '123456';
CREATE LOGIN User_Ketoan WITH PASSWORD = '123456';
CREATE LOGIN User_HLV WITH PASSWORD = '123456';
CREATE LOGIN User_Xem WITH PASSWORD = '123456';

-- Tạo User trong DB
CREATE USER U_QuanTri FOR LOGIN User_QuanTri;
CREATE USER U_LeTan FOR LOGIN User_LeTan;
CREATE USER U_Ketoan FOR LOGIN User_Ketoan;
CREATE USER U_HLV FOR LOGIN User_HLV;
CREATE USER U_Xem FOR LOGIN User_Xem;

-- Phân quyền (Grant/Deny/Revoke)

-- 1. Quan Tri: Full quyền
EXEC sp_addrolemember 'db_owner', 'U_QuanTri';

-- 2. Le Tan (Lễ tân): Thêm sửa xóa Booking, Member. Xem Courts.
GRANT SELECT, INSERT, UPDATE ON Members TO U_LeTan;
GRANT SELECT, INSERT, UPDATE, DELETE ON Bookings TO U_LeTan;
GRANT SELECT ON Courts TO U_LeTan;
DENY DELETE ON Members TO U_LeTan; -- Không được xóa member

-- 3. Ketoan: Chỉ xem và insert Payment, xem báo cáo
GRANT SELECT ON Members, Bookings, Payments TO U_Ketoan;
GRANT INSERT ON Payments TO U_Ketoan;
DENY UPDATE, DELETE ON Payments TO U_Ketoan;

-- 4. HLV: Xem lịch dạy, cập nhật ghi chú buổi tập
GRANT SELECT ON CoachingSessions, Members TO U_HLV;
GRANT UPDATE ON CoachingSessions TO U_HLV; -- Chỉ được sửa ghi chú
DENY INSERT, DELETE ON CoachingSessions TO U_HLV;

-- 5. User Xem: Chỉ được Select
GRANT SELECT ON ALL SCHEMA OBJECTS TO U_Xem;

-- Ví dụ Revoke quyền
-- REVOKE INSERT ON Bookings TO U_Xem; 

PRINT 'HOAN THANH CAU HINH DATABASE!';
