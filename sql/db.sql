
-- ============================================================
-- HỆ THỐNG QUẢN LÝ SÂN CẦU LÔNG
-- DBMS: SQL Server (SSMS)
-- Chuẩn 3NF+
-- ============================================================

-- 1. TẠO DATABASE
-- ============================================================
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SanCauLongDB')
    DROP DATABASE SanCauLongDB;
GO

CREATE DATABASE SanCauLongDB;
GO

USE SanCauLongDB;
GO

-- 2. TẠO BẢNG (7+ BẢNG - CHUẨN 3NF)
-- ============================================================

-- 2.1 BẢNG LOẠI_SÂN: Phân loại sân (Thường, VIP, Có máy lạnh)
CREATE TABLE LOAI_SAN (
    MaLoaiSan INT PRIMARY KEY IDENTITY(1,1),
    TenLoaiSan NVARCHAR(50) NOT NULL,
    MoTa NVARCHAR(200),
    PhuPhi DECIMAL(10,2) DEFAULT 0  -- Phụ phí so với giá cơ bản
);
GO

-- 2.2 BẢNG SÂN: Thông tin từng sân cầu lông
CREATE TABLE SAN (
    MaSan INT PRIMARY KEY IDENTITY(1,1),
    TenSan NVARCHAR(50) NOT NULL,
    MaLoaiSan INT NOT NULL,
    TrangThai NVARCHAR(20) DEFAULT N'Trống' 
        CHECK (TrangThai IN (N'Trống', N'Đang sử dụng', N'Bảo trì')),
    GhiChu NVARCHAR(200),
    FOREIGN KEY (MaLoaiSan) REFERENCES LOAI_SAN(MaLoaiSan)
);
GO

-- 2.3 BẢNG KHÁCH_HÀNG: Thông tin khách hàng
CREATE TABLE KHACH_HANG (
    MaKH INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15) UNIQUE NOT NULL,
    Email VARCHAR(100),
    NgaySinh DATE,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    HangThanhVien NVARCHAR(20) DEFAULT N'Thường' 
        CHECK (HangThanhVien IN (N'Thường', N'Bạc', N'Vàng', N'Kim cương')),
    DiemTichLuy INT DEFAULT 0,
    NgayDangKy DATE DEFAULT GETDATE(),
    TrangThai NVARCHAR(20) DEFAULT N'Hoạt động'
        CHECK (TrangThai IN (N'Hoạt động', N'Khóa', N'Ngừng'))
);
GO

-- 2.4 BẢNG BẢNG_GIÁ: Giá thuê theo khung giờ
CREATE TABLE BANG_GIA (
    MaGia INT PRIMARY KEY IDENTITY(1,1),
    MaLoaiSan INT NOT NULL,
    ThuTrongTuan INT CHECK (ThuTrongTuan BETWEEN 1 AND 7), -- 1=CN, 2=T2, ..., 7=T7
    GioBatDau TIME NOT NULL,
    GioKetThuc TIME NOT NULL,
    DonGia DECIMAL(10,2) NOT NULL CHECK (DonGia > 0),
    MoTa NVARCHAR(100),
    FOREIGN KEY (MaLoaiSan) REFERENCES LOAI_SAN(MaLoaiSan),
    CONSTRAINT UQ_BangGia UNIQUE (MaLoaiSan, ThuTrongTuan, GioBatDau, GioKetThuc)
);
GO

-- 2.5 BẢNG ĐẶT_SÂN: Lịch đặt sân
CREATE TABLE DAT_SAN (
    MaDatSan INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT NOT NULL,
    MaSan INT NOT NULL,
    NgayDat DATE NOT NULL,
    GioBatDau TIME NOT NULL,
    GioKetThuc TIME NOT NULL,
    LoaiDat NVARCHAR(20) DEFAULT N'Vãng lai' 
        CHECK (LoaiDat IN (N'Vãng lai', N'Cố định', N'Công ty', N'Giải đấu')),
    TrangThai NVARCHAR(20) DEFAULT N'Chờ check-in'
        CHECK (TrangThai IN (N'Chờ check-in', N'Đang chơi', N'Hoàn thành', N'Hủy', N'No-show')),
    SoTien DECIMAL(10,2) NOT NULL,
    TienCoc DECIMAL(10,2) DEFAULT 0,
    GhiChu NVARCHAR(200),
    NgayTao DATETIME DEFAULT GETDATE(),
    NguoiTao NVARCHAR(50),
    FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH),
    FOREIGN KEY (MaSan) REFERENCES SAN(MaSan),
    CONSTRAINT CHK_GioKetThuc CHECK (GioKetThuc > GioBatDau)
);
GO

-- 2.6 BẢNG DỊCH_VỤ: Danh mục dịch vụ phụ trợ
CREATE TABLE DICH_VU (
    MaDV INT PRIMARY KEY IDENTITY(1,1),
    TenDV NVARCHAR(100) NOT NULL,
    LoaiDV NVARCHAR(50) 
        CHECK (LoaiDV IN (N'Nước uống', N'Thuê vợt', N'Thuê giày', N'Đan lưới', N'Phụ kiện', N'Khác')),
    DonGia DECIMAL(10,2) NOT NULL CHECK (DonGia >= 0),
    DonViTinh NVARCHAR(20) DEFAULT N'Cái',
    SoLuongTon INT DEFAULT 0 CHECK (SoLuongTon >= 0),
    MoTa NVARCHAR(200),
    TrangThai NVARCHAR(20) DEFAULT N'Còn hàng'
        CHECK (TrangThai IN (N'Còn hàng', N'Hết hàng', N'Ngừng bán'))
);
GO

-- 2.7 BẢNG CHI_TIẾT_DỊCH_VỤ: Dịch vụ đi kèm mỗi lần đặt sân
CREATE TABLE CHI_TIET_DICH_VU (
    MaCTDV INT PRIMARY KEY IDENTITY(1,1),
    MaDatSan INT NOT NULL,
    MaDV INT NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    DonGiaLucBan DECIMAL(10,2) NOT NULL, -- Lưu giá tại thời điểm bán
    ThanhTien AS (SoLuong * DonGiaLucBan),
    GhiChu NVARCHAR(200),
    FOREIGN KEY (MaDatSan) REFERENCES DAT_SAN(MaDatSan) ON DELETE CASCADE,
    FOREIGN KEY (MaDV) REFERENCES DICH_VU(MaDV)
);
GO

-- 2.8 BẢNG THANH_TOÁN: Lịch sử thanh toán
CREATE TABLE THANH_TOAN (
    MaTT INT PRIMARY KEY IDENTITY(1,1),
    MaDatSan INT NOT NULL,
    SoTien DECIMAL(10,2) NOT NULL,
    PhuongThuc NVARCHAR(30) 
        CHECK (PhuongThuc IN (N'Tiền mặt', N'VNPay', N'Momo', N'ZaloPay', N'Chuyển khoản')),
    LoaiTT NVARCHAR(20) 
        CHECK (LoaiTT IN (N'Đặt cọc', N'Thanh toán', N'Hoàn tiền', N'Gia hạn')),
    TrangThaiTT NVARCHAR(20) DEFAULT N'Thành công'
        CHECK (TrangThaiTT IN (N'Thành công', N'Đang xử lý', N'Thất bại')),
    MaGiaoDich VARCHAR(100),
    NgayTT DATETIME DEFAULT GETDATE(),
    NguoiThu NVARCHAR(50),
    FOREIGN KEY (MaDatSan) REFERENCES DAT_SAN(MaDatSan)
);
GO

-- 2.9 BẢNG GÓI_CỐ_ĐỊNH: Khách thuê gói tháng
CREATE TABLE GOI_CO_DINH (
    MaGoi INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT NOT NULL,
    MaSan INT NOT NULL,
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    ThuTrongTuan INT CHECK (ThuTrongTuan BETWEEN 2 AND 8), -- 8 = T2+T4+T6
    GioBatDau TIME NOT NULL,
    GioKetThuc TIME NOT NULL,
    TongTien DECIMAL(10,2) NOT NULL,
    TrangThai NVARCHAR(20) DEFAULT N'Hoạt động'
        CHECK (TrangThai IN (N'Hoạt động', N'Hết hạn', N'Hủy')),
    FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH),
    FOREIGN KEY (MaSan) REFERENCES SAN(MaSan),
    CONSTRAINT CHK_NgayKetThuc CHECK (NgayKetThuc > NgayBatDau)
);
GO

-- 2.10 BẢNG NHÂN_VIÊ: Quản lý nhân viên (cho phân quyền)
CREATE TABLE NHAN_VIEN (
    MaNV INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15) UNIQUE,
    ChucVu NVARCHAR(30) 
        CHECK (ChucVu IN (N'Lễ tân', N'Quản lý', N'Chủ sân', N'Huấn luyện viên')),
    TenDangNhap VARCHAR(50) UNIQUE NOT NULL,
    MatKhau VARCHAR(255) NOT NULL, -- Hash trong thực tế
    TrangThai NVARCHAR(20) DEFAULT N'Hoạt động'
);
GO

-- 2.11 BẢNG LỊCH_SỬ_HOẠT_ĐỘNG: Audit log
CREATE TABLE LICH_SU_HOAT_DONG (
    MaLS INT PRIMARY KEY IDENTITY(1,1),
    BangBiThayDoi NVARCHAR(50) NOT NULL,
    MaBanGhi INT,
    HanhDong NVARCHAR(20) CHECK (HanhDong IN (N'INSERT', N'UPDATE', N'DELETE')),
    DuLieuCu NVARCHAR(MAX),
    DuLieuMoi NVARCHAR(MAX),
    NguoiThayDoi NVARCHAR(50),
    NgayThayDoi DATETIME DEFAULT GETDATE()
);
GO

-- 3. TẠO INDEX TỐI ƯU TRUY VẤN
-- ============================================================
CREATE INDEX IX_DatSan_Ngay ON DAT_SAN(NgayDat);
CREATE INDEX IX_DatSan_TrangThai ON DAT_SAN(TrangThai);
CREATE INDEX IX_KH_SDT ON KHACH_HANG(SoDienThoai);
CREATE INDEX IX_ThanhToan_Ngay ON THANH_TOAN(NgayTT);
CREATE INDEX IX_CTDV_MaDatSan ON CHI_TIET_DICH_VU(MaDatSan);
GO

-- 4. NHẬP DỮ LIỆU MẪU (TỐI THIỂU 20 BẢN GHI/BẢNG)
-- ============================================================

-- 4.1 LOAI_SAN (3 bản ghi)
INSERT INTO LOAI_SAN (TenLoaiSan, MoTa, PhuPhi) VALUES
(N'Sân thường', N'Sân tiêu chuẩn, không máy lạnh', 0),
(N'Sân VIP', N'Sân có máy lạnh, ghế ngồi, khăn lạnh', 20000),
(N'Sân sự kiện', N'Sân dành cho giải đấu, có bảng điểm', 50000);
GO

-- 4.2 SAN (6 bản ghi)
INSERT INTO SAN (TenSan, MaLoaiSan, TrangThai, GhiChu) VALUES
(N'Sân A1', 1, N'Trống', N'Gần quầy lễ tân'),
(N'Sân A2', 1, N'Trống', NULL),
(N'Sân B1', 2, N'Trống', N'Có máy lạnh 2 chiều'),
(N'Sân B2', 2, N'Trống', N'View đẹp'),
(N'Sân C1', 3, N'Trống', N'Sân chính thi đấu'),
(N'Sân C2', 3, N'Bảo trì', N'Đang sửa lưới');
GO

-- 4.3 KHACH_HANG (25 bản ghi)
INSERT INTO KHACH_HANG (HoTen, SoDienThoai, Email, NgaySinh, GioiTinh, HangThanhVien, DiemTichLuy, NgayDangKy) VALUES
(N'Nguyễn Văn An', '0901234567', 'an.nguyen@gmail.com', '1990-05-15', N'Nam', N'Kim cương', 1500, '2024-01-10'),
(N'Trần Thị Bình', '0912345678', 'binh.tran@yahoo.com', '1995-08-20', N'Nữ', N'Vàng', 800, '2024-02-15'),
(N'Lê Văn Cường', '0923456789', 'cuong.le@gmail.com', '1988-12-03', N'Nam', N'Bạc', 350, '2024-03-01'),
(N'Phạm Thị Dung', '0934567890', NULL, '1992-04-25', N'Nữ', N'Thường', 50, '2024-03-20'),
(N'Hoàng Văn Em', '0945678901', 'em.hoang@gmail.com', '1985-09-10', N'Nam', N'Vàng', 620, '2024-04-05'),
(N'Vũ Thị Phương', '0956789012', 'phuong.vu@gmail.com', '1998-01-18', N'Nữ', N'Thường', 20, '2024-04-12'),
(N'Đặng Văn Giang', '0967890123', NULL, '1991-07-30', N'Nam', N'Bạc', 280, '2024-05-01'),
(N'Bùi Thị Hoa', '0978901234', 'hoa.bui@yahoo.com', '1994-11-05', N'Nữ', N'Thường', 80, '2024-05-15'),
(N'Ngô Văn Inh', '0989012345', 'inh.ngo@gmail.com', '1989-03-22', N'Nam', N'Kim cương', 1200, '2024-06-01'),
(N'Dương Thị Kim', '0990123456', NULL, '1996-06-14', N'Nữ', N'Bạc', 420, '2024-06-20'),
(N'Lý Văn Long', '0901122334', 'long.ly@gmail.com', '1987-10-08', N'Nam', N'Thường', 30, '2024-07-01'),
(N'Mai Thị Mai', '0912233445', 'mai.mai@yahoo.com', '1993-02-28', N'Nữ', N'Vàng', 550, '2024-07-15'),
(N'Phan Văn Nam', '0923344556', NULL, '1990-08-16', N'Nam', N'Thường', 10, '2024-08-01'),
(N'Quách Thị Oanh', '0934455667', 'oanh.quach@gmail.com', '1997-12-01', N'Nữ', N'Bạc', 310, '2024-08-10'),
(N'Sơn Văn Phúc', '0945566778', NULL, '1986-05-20', N'Nam', N'Kim cương', 1800, '2024-09-01'),
(N'Tô Thị Quyên', '0956677889', 'quyen.to@gmail.com', '1999-09-09', N'Nữ', N'Thường', 5, '2024-09-15'),
(N'Uông Văn Rỡ', '0967788990', NULL, '1984-01-12', N'Nam', N'Bạc', 260, '2024-10-01'),
(N'Vương Thị San', '0978899001', 'san.vuong@yahoo.com', '1992-07-07', N'Nữ', N'Vàng', 700, '2024-10-20'),
(N'Xa Văn Tiến', '0989900112', NULL, '1988-11-19', N'Nam', N'Thường', 40, '2024-11-01'),
(N'Yên Thị Uyên', '0990011223', 'uyen.yen@gmail.com', '1995-03-03', N'Nữ', N'Bạc', 380, '2024-11-15'),
(N'Nguyễn Văn Bảo', '0902233445', 'bao.nguyen@gmail.com', '1991-09-25', N'Nam', N'Vàng', 480, '2024-12-01'),
(N'Trần Thị Cẩm', '0913344556', NULL, '1998-05-17', N'Nữ', N'Thường', 15, '2024-12-10'),
(N'Lê Văn Đức', '0924455667', 'duc.le@yahoo.com', '1983-12-30', N'Nam', N'Kim cương', 2100, '2025-01-05'),
(N'Phạm Thị Hạnh', '0935566778', NULL, '1990-02-14', N'Nữ', N'Bạc', 290, '2025-01-20'),
(N'Hoàng Văn Khôi', '0946677889', 'khoi.hoang@gmail.com', '1994-08-08', N'Nam', N'Thường', 60, '2025-02-01');
GO

-- 4.4 BANG_GIA (21 bản ghi)
INSERT INTO BANG_GIA (MaLoaiSan, ThuTrongTuan, GioBatDau, GioKetThuc, DonGia, MoTa) VALUES
-- Sân thường - Thứ 2-6
(1, 2, '06:00', '17:00', 60000, N'Sáng chiều thường'),
(1, 2, '17:00', '21:00', 100000, N'Giờ vàng T2'),
(1, 3, '06:00', '17:00', 60000, N'Sáng chiều thường'),
(1, 3, '17:00', '21:00', 100000, N'Giờ vàng T3'),
(1, 4, '06:00', '17:00', 60000, N'Sáng chiều thường'),
(1, 4, '17:00', '21:00', 100000, N'Giờ vàng T4'),
(1, 5, '06:00', '17:00', 60000, N'Sáng chiều thường'),
(1, 5, '17:00', '21:00', 100000, N'Giờ vàng T5'),
(1, 6, '06:00', '17:00', 60000, N'Sáng chiều thường'),
(1, 6, '17:00', '21:00', 110000, N'Giờ vàng T6 (cao điểm)'),
(1, 7, '06:00', '12:00', 80000, N'Sáng cuối tuần'),
(1, 7, '12:00', '22:00', 120000, N'Chiều tối cuối tuần'),
-- Sân VIP - Thứ 2-6
(2, 2, '06:00', '17:00', 80000, N'VIP sáng chiều'),
(2, 2, '17:00', '21:00', 120000, N'VIP giờ vàng'),
(2, 3, '06:00', '17:00', 80000, N'VIP sáng chiều'),
(2, 3, '17:00', '21:00', 120000, N'VIP giờ vàng'),
(2, 7, '06:00', '12:00', 100000, N'VIP sáng cuối tuần'),
(2, 7, '12:00', '22:00', 140000, N'VIP chiều tối cuối tuần'),
-- Sân sự kiện
(3, 7, '06:00', '22:00', 200000, N'Sự kiện cuối tuần'),
(3, 2, '06:00', '22:00', 180000, N'Sự kiện ngày thường'),
(3, 3, '06:00', '22:00', 180000, N'Sự kiện ngày thường');
GO

-- 4.5 DAT_SAN (25 bản ghi)
INSERT INTO DAT_SAN (MaKH, MaSan, NgayDat, GioBatDau, GioKetThuc, LoaiDat, TrangThai, SoTien, TienCoc, GhiChu, NguoiTao) VALUES
(1, 1, '2026-04-01', '18:00', '20:00', N'Vãng lai', N'Hoàn thành', 200000, 100000, NULL, N'Lễ tân A'),
(2, 3, '2026-04-01', '19:00', '21:00', N'Vãng lai', N'Hoàn thành', 240000, 120000, N'Khách VIP', N'Lễ tân A'),
(3, 1, '2026-04-02', '17:00', '19:00', N'Vãng lai', N'Hoàn thành', 200000, 0, NULL, N'Lễ tân B'),
(4, 2, '2026-04-02', '18:00', '20:00', N'Vãng lai', N'Hủy', 200000, 50000, N'Hủy muộn', N'Lễ tân A'),
(5, 3, '2026-04-03', '19:00', '21:00', N'Vãng lai', N'Hoàn thành', 240000, 240000, NULL, N'Lễ tân B'),
(6, 1, '2026-04-03', '06:00', '08:00', N'Vãng lai', N'Hoàn thành', 120000, 0, N'Sáng sớm', N'Lễ tân A'),
(7, 2, '2026-04-04', '17:00', '19:00', N'Vãng lai', N'Hoàn thành', 200000, 100000, NULL, N'Lễ tân B'),
(8, 1, '2026-04-04', '19:00', '21:00', N'Vãng lai', N'No-show', 200000, 100000, N'Khách không đến', N'Lễ tân A'),
(9, 3, '2026-04-05', '18:00', '20:00', N'Vãng lai', N'Hoàn thành', 240000, 240000, NULL, N'Lễ tân B'),
(10, 1, '2026-04-05', '07:00', '09:00', N'Vãng lai', N'Hoàn thành', 120000, 0, NULL, N'Lễ tân A'),
(11, 2, '2026-04-06', '18:00', '20:00', N'Vãng lai', N'Hoàn thành', 200000, 100000, NULL, N'Lễ tân B'),
(12, 3, '2026-04-06', '19:00', '21:00', N'Vãng lai', N'Hoàn thành', 240000, 120000, NULL, N'Lễ tân A'),
(13, 1, '2026-04-07', '17:00', '19:00', N'Vãng lai', N'Hủy', 200000, 0, N'Hủy sớm', N'Lễ tân B'),
(14, 2, '2026-04-07', '18:00', '20:00', N'Vãng lai', N'Hoàn thành', 200000, 100000, NULL, N'Lễ tân A'),
(15, 3, '2026-04-08', '19:00', '21:00', N'Vãng lai', N'Hoàn thành', 240000, 240000, NULL, N'Lễ tân B'),
(1, 1, '2026-04-08', '18:00', '20:00', N'Cố định', N'Hoàn thành', 200000, 200000, N'Gói T2-T4-T6', N'Lễ tân A'),
(3, 1, '2026-04-09', '17:00', '19:00', N'Cố định', N'Hoàn thành', 200000, 200000, N'Gói tháng 4', N'Lễ tân B'),
(5, 3, '2026-04-09', '19:00', '21:00', N'Vãng lai', N'Đang chơi', 240000, 240000, NULL, N'Lễ tân A'),
(7, 2, '2026-04-10', '18:00', '20:00', N'Vãng lai', N'Chờ check-in', 200000, 100000, NULL, N'Lễ tân B'),
(9, 1, '2026-04-10', '06:00', '08:00', N'Vãng lai', N'Chờ check-in', 120000, 0, N'Sáng sớm', N'Lễ tân A'),
(11, 2, '2026-04-11', '17:00', '20:00', N'Công ty', N'Chờ check-in', 300000, 150000, N'Công ty ABC', N'Lễ tân B'),
(13, 3, '2026-04-11', '19:00', '21:00', N'Giải đấu', N'Chờ check-in', 400000, 200000, N'Giải nội bộ', N'Lễ tân A'),
(15, 1, '2026-04-12', '18:00', '20:00', N'Vãng lai', N'Chờ check-in', 200000, 100000, NULL, N'Lễ tân B'),
(17, 2, '2026-04-12', '19:00', '21:00', N'Vãng lai', N'Chờ check-in', 200000, 100000, NULL, N'Lễ tân A');
GO

-- 4.6 DICH_VU (20 bản ghi)
INSERT INTO DICH_VU (TenDV, LoaiDV, DonGia, DonViTinh, SoLuongTon, MoTa, TrangThai) VALUES
(N'Nước suối Lavie', N'Nước uống', 15000, N'Chai', 200, N'500ml', N'Còn hàng'),
(N'Nước ngọt Coca', N'Nước uống', 20000, N'Lon', 150, N'330ml', N'Còn hàng'),
(N'Nước ngọt Pepsi', N'Nước uống', 20000, N'Lon', 150, N'330ml', N'Còn hàng'),
(N'Nước tăng lực Red Bull', N'Nước uống', 25000, N'Lon', 100, N'250ml', N'Còn hàng'),
(N'Bia Heineken', N'Nước uống', 35000, N'Lon', 80, N'330ml', N'Còn hàng'),
(N'Vợt cầu lông Yonex chính hãng', N'Thuê vợt', 50000, N'Cái/Giờ', 10, N'Dòng Astrox', N'Còn hàng'),
(N'Vợt cầu lông Lining', N'Thuê vợt', 40000, N'Cái/Giờ', 8, N'Dòng Windstorm', N'Còn hàng'),
(N'Vợt cầu lông Victor', N'Thuê vợt', 45000, N'Cái/Giờ', 6, N'Dòng Jetspeed', N'Còn hàng'),
(N'Giày cầu lông Yonex', N'Thuê giày', 30000, N'Đôi/Giờ', 15, N'Size 39-44', N'Còn hàng'),
(N'Giày cầu lông Victor', N'Thuê giày', 25000, N'Đôi/Giờ', 12, N'Size 38-43', N'Còn hàng'),
(N'Đan lưới Yonex BG65', N'Đan lưới', 100000, N'Cái', 0, N'Lưới bền, độ căng tốt', N'Còn hàng'),
(N'Đan lưới Yonex BG80', N'Đan lưới', 120000, N'Cái', 0, N'Lưới đánh nhanh', N'Còn hàng'),
(N'Đan lưới Lining No.1', N'Đan lưới', 90000, N'Cái', 0, N'Lưới cơ bản', N'Còn hàng'),
(N'Quấn cán vợt', N'Phụ kiện', 30000, N'Cái', 50, N'Nhiều màu', N'Còn hàng'),
(N'Túi đựng vợt 2 ngăn', N'Phụ kiện', 150000, N'Cái', 20, N'Chống nước', N'Còn hàng'),
(N'Túi đựng vợt 3 ngăn', N'Phụ kiện', 250000, N'Cái', 15, N'Có ngăn giày riêng', N'Còn hàng'),
(N'Quả cầu lông Yonex AS-30', N'Phụ kiện', 350000, N'Hộp/12 quả', 30, N'Thi đấu chuẩn', N'Còn hàng'),
(N'Quả cầu lông Victor Gold', N'Phụ kiện', 280000, N'Hộp/12 quả', 25, N'Tập luyện tốt', N'Còn hàng'),
(N'Băng cổ tay', N'Phụ kiện', 50000, N'Cái', 40, N'Thấm mồ hôi', N'Còn hàng'),
(N'Băng đầu gối', N'Phụ kiện', 80000, N'Cái', 30, N'Bảo vệ đầu gối', N'Còn hàng');
GO

-- 4.7 CHI_TIET_DICH_VU (25 bản ghi)
INSERT INTO CHI_TIET_DICH_VU (MaDatSan, MaDV, SoLuong, DonGiaLucBan, GhiChu) VALUES
(1, 1, 2, 15000, N'Nước suối'),
(1, 6, 2, 50000, N'Thuê vợt'),
(2, 2, 4, 20000, N'Nước ngọt'),
(2, 9, 2, 30000, N'Thuê giày'),
(3, 1, 4, 15000, NULL),
(5, 3, 6, 20000, N'Nước ngọt nhóm'),
(5, 7, 4, 40000, N'Thuê vợt nhóm'),
(6, 1, 2, 15000, NULL),
(7, 4, 2, 25000, N'Nước tăng lực'),
(9, 2, 4, 20000, NULL),
(9, 10, 2, 25000, N'Thuê giày'),
(10, 1, 2, 15000, NULL),
(11, 5, 2, 35000, N'Bia'),
(12, 2, 4, 20000, NULL),
(12, 6, 2, 50000, N'Vợt cao cấp'),
(14, 1, 2, 15000, NULL),
(15, 3, 4, 20000, NULL),
(15, 9, 2, 30000, NULL),
(17, 1, 2, 15000, NULL),
(17, 14, 2, 30000, N'Quấn cán mới'),
(19, 2, 2, 20000, NULL),
(20, 1, 2, 15000, NULL),
(21, 3, 8, 20000, N'Nước ngọt công ty'),
(21, 7, 4, 40000, N'Thuê vợt công ty'),
(22, 4, 10, 25000, N'Nước tăng lực giải đấu');
GO

-- 4.8 THANH_TOAN (30 bản ghi)
INSERT INTO THANH_TOAN (MaDatSan, SoTien, PhuongThuc, LoaiTT, TrangThaiTT, MaGiaoDich, NgayTT, NguoiThu) VALUES
(1, 100000, N'Tiền mặt', N'Đặt cọc', N'Thành công', NULL, '2026-04-01 10:00', N'Lễ tân A'),
(1, 100000, N'Momo', N'Thanh toán', N'Thành công', N'MOMO001', '2026-04-01 18:00', N'Lễ tân A'),
(2, 120000, N'VNPay', N'Đặt cọc', N'Thành công', N'VNP002', '2026-04-01 09:30', N'Lễ tân A'),
(2, 120000, N'VNPay', N'Thanh toán', N'Thành công', N'VNP003', '2026-04-01 19:00', N'Lễ tân A'),
(3, 200000, N'Tiền mặt', N'Thanh toán', N'Thành công', NULL, '2026-04-02 17:00', N'Lễ tân B'),
(4, 50000, N'Tiền mặt', N'Đặt cọc', N'Thành công', NULL, '2026-04-02 16:00', N'Lễ tân A'),
(5, 240000, N'ZaloPay', N'Thanh toán', N'Thành công', N'ZALO005', '2026-04-03 18:30', N'Lễ tân B'),
(6, 120000, N'Tiền mặt', N'Thanh toán', N'Thành công', NULL, '2026-04-03 06:00', N'Lễ tân A'),
(7, 100000, N'Momo', N'Đặt cọc', N'Thành công', N'MOMO008', '2026-04-04 15:00', N'Lễ tân B'),
(7, 100000, N'Momo', N'Thanh toán', N'Thành công', N'MOMO009', '2026-04-04 17:00', N'Lễ tân B'),
(8, 100000, N'Tiền mặt', N'Đặt cọc', N'Thành công', NULL, '2026-04-04 12:00', N'Lễ tân A'),
(9, 240000, N'VNPay', N'Thanh toán', N'Thành công', N'VNP012', '2026-04-05 17:30', N'Lễ tân B'),
(10, 120000, N'Tiền mặt', N'Thanh toán', N'Thành công', NULL, '2026-04-05 07:00', N'Lễ tân A'),
(11, 100000, N'ZaloPay', N'Đặt cọc', N'Thành công', N'ZALO015', '2026-04-06 14:00', N'Lễ tân B'),
(11, 100000, N'ZaloPay', N'Thanh toán', N'Thành công', N'ZALO016', '2026-04-06 18:00', N'Lễ tân B'),
(12, 120000, N'Tiền mặt', N'Đặt cọc', N'Thành công', NULL, '2026-04-06 16:00', N'Lễ tân A'),
(12, 120000, N'Tiền mặt', N'Thanh toán', N'Thành công', NULL, '2026-04-06 19:00', N'Lễ tân A'),
(13, 50000, N'Momo', N'Đặt cọc', N'Thành công', N'MOMO019', '2026-04-07 10:00', N'Lễ tân B'),
(14, 100000, N'VNPay', N'Đặt cọc', N'Thành công', N'VNP020', '2026-04-07 11:00', N'Lễ tân A'),
(14, 100000, N'VNPay', N'Thanh toán', N'Thành công', N'VNP021', '2026-04-07 18:00', N'Lễ tân A'),
(15, 240000, N'ZaloPay', N'Thanh toán', N'Thành công', N'ZALO022', '2026-04-08 18:00', N'Lễ tân B'),
(17, 200000, N'Tiền mặt', N'Thanh toán', N'Thành công', NULL, '2026-04-08 17:30', N'Lễ tân A'),
(19, 100000, N'Momo', N'Đặt cọc', N'Thành công', N'MOMO025', '2026-04-09 15:00', N'Lễ tân B'),
(20, 50000, N'Tiền mặt', N'Đặt cọc', N'Thành công', NULL, '2026-04-10 05:30', N'Lễ tân A'),
(21, 150000, N'Chuyển khoản', N'Đặt cọc', N'Thành công', N'CK026', '2026-04-10 09:00', N'Lễ tân B'),
(22, 200000, N'Chuyển khoản', N'Đặt cọc', N'Thành công', N'CK027', '2026-04-10 14:00', N'Lễ tân A'),
(4, 50000, N'Tiền mặt', N'Hoàn tiền', N'Thành công', NULL, '2026-04-02 20:00', N'Lễ tân A'),
(8, 50000, N'Tiền mặt', N'Hoàn tiền', N'Thành công', NULL, '2026-04-05 08:00', N'Lễ tân A'),
(13, 50000, N'Momo', N'Hoàn tiền', N'Thành công', N'MOMO030', '2026-04-07 16:00', N'Lễ tân B');
GO

-- 4.9 GOI_CO_DINH (15 bản ghi)
INSERT INTO GOI_CO_DINH (MaKH, MaSan, NgayBatDau, NgayKetThuc, ThuTrongTuan, GioBatDau, GioKetThuc, TongTien, TrangThai) VALUES
(1, 1, '2026-04-01', '2026-06-30', 2, '18:00', '20:00', 1200000, N'Hoạt động'),
(3, 1, '2026-04-01', '2026-04-30', 4, '17:00', '19:00', 600000, N'Hoạt động'),
(5, 3, '2026-03-01', '2026-05-31', 6, '19:00', '21:00', 1440000, N'Hoạt động'),
(7, 2, '2026-04-15', '2026-07-15', 3, '18:00', '20:00', 1200000, N'Hoạt động'),
(9, 1, '2026-02-01', '2026-04-30', 5, '18:00', '20:00', 1200000, N'Hết hạn'),
(11, 2, '2026-04-01', '2026-06-30', 2, '17:00', '19:00', 1200000, N'Hoạt động'),
(13, 3, '2026-04-01', '2026-05-31', 4, '19:00', '21:00', 960000, N'Hoạt động'),
(15, 1, '2026-03-15', '2026-06-15', 6, '18:00', '20:00', 1200000, N'Hoạt động'),
(17, 2, '2026-04-01', '2026-04-30', 3, '19:00', '21:00', 600000, N'Hoạt động'),
(19, 3, '2026-04-01', '2026-07-01', 5, '17:00', '19:00', 1200000, N'Hoạt động'),
(21, 1, '2026-04-01', '2026-06-30', 2, '18:00', '20:00', 1200000, N'Hoạt động'),
(2, 3, '2026-01-01', '2026-03-31', 4, '19:00', '21:00', 1440000, N'Hết hạn'),
(4, 2, '2026-02-01', '2026-02-28', 6, '18:00', '20:00', 400000, N'Hết hạn'),
(6, 1, '2026-03-01', '2026-05-31', 3, '06:00', '08:00', 720000, N'Hoạt động'),
(8, 2, '2026-04-01', '2026-04-30', 5, '19:00', '21:00', 600000, N'Hủy');
GO

-- 4.10 NHAN_VIEN (8 bản ghi)
INSERT INTO NHAN_VIEN (HoTen, SoDienThoai, ChucVu, TenDangNhap, MatKhau, TrangThai) VALUES
(N'Nguyễn Văn Lễ Tân A', '0901111111', N'Lễ tân', N'letan_a', N'password123', N'Hoạt động'),
(N'Trần Thị Lễ Tân B', '0912222222', N'Lễ tân', N'letan_b', N'password123', N'Hoạt động'),
(N'Lê Văn Quản Lý', '0923333333', N'Quản lý', N'quanly', N'password123', N'Hoạt động'),
(N'Phạm Thị Chủ Sân', '0934444444', N'Chủ sân', N'chusan', N'password123', N'Hoạt động'),
(N'Hoàng Văn HLV 1', '0945555555', N'Huấn luyện viên', N'hlv1', N'password123', N'Hoạt động'),
(N'Vũ Thị HLV 2', '0956666666', N'Huấn luyện viên', N'hlv2', N'password123', N'Hoạt động'),
(N'Đặng Văn Lễ Tân C', '0967777777', N'Lễ tân', N'letan_c', N'password123', N'Hoạt động'),
(N'Bùi Thị Quản Lý 2', '0978888888', N'Quản lý', N'quanly2', N'password123', N'Hoạt động');
GO

PRINT N'===== HOÀN TẤT TẠO DATABASE VÀ NHẬP DỮ LIỆU =====';
GO




-- ============================================================
-- PHẦN 3: 40 CÂU TRUY VẤN (40 ĐIỂM)
-- ============================================================
USE SanCauLongDB;
GO

-- ============================================================
-- a. TRUY VẤN ĐƠN GIẢN: 5 CÂU (5 Đ)
-- ============================================================

-- Câu 1: Liệt kê tất cả sân cầu lông và loại sân
SELECT s.MaSan, s.TenSan, ls.TenLoaiSan, s.TrangThai
FROM SAN s
JOIN LOAI_SAN ls ON s.MaLoaiSan = ls.MaLoaiSan;
GO

-- Câu 2: Tìm khách hàng có hạng thành viên "Kim cương"
SELECT MaKH, HoTen, SoDienThoai, DiemTichLuy, NgayDangKy
FROM KHACH_HANG
WHERE HangThanhVien = N'Kim cương';
GO

-- Câu 3: Liệt kê các dịch vụ thuộc loại "Nước uống" còn hàng
SELECT MaDV, TenDV, DonGia, SoLuongTon
FROM DICH_VU
WHERE LoaiDV = N'Nước uống' AND TrangThai = N'Còn hàng';
GO

-- Câu 4: Xem lịch đặt sân trong ngày 2026-04-01
SELECT ds.MaDatSan, kh.HoTen, s.TenSan, ds.GioBatDau, ds.GioKetThuc, ds.TrangThai
FROM DAT_SAN ds
JOIN KHACH_HANG kh ON ds.MaKH = kh.MaKH
JOIN SAN s ON ds.MaSan = s.MaSan
WHERE ds.NgayDat = '2026-04-01';
GO

-- Câu 5: Liệt kê nhân viên làm lễ tân đang hoạt động
SELECT MaNV, HoTen, SoDienThoai, TenDangNhap
FROM NHAN_VIEN
WHERE ChucVu = N'Lễ tân' AND TrangThai = N'Hoạt động';
GO

-- ============================================================
-- b. TRUY VẤN VỚI AGGREGATE FUNCTIONS: 7 CÂU (7 Đ)
-- ============================================================

-- Câu 6: Tổng doanh thu từ đặt sân
SELECT SUM(SoTien) AS TongDoanhThuDatSan
FROM DAT_SAN
WHERE TrangThai = N'Hoàn thành';
GO

-- Câu 7: Số lượng khách hàng theo từng hạng thành viên
SELECT HangThanhVien, COUNT(*) AS SoLuongKH, AVG(DiemTichLuy) AS DiemTB
FROM KHACH_HANG
GROUP BY HangThanhVien;
GO

-- Câu 8: Tổng số tiền thanh toán theo từng phương thức
SELECT PhuongThuc, COUNT(*) AS SoGiaoDich, SUM(SoTien) AS TongTien
FROM THANH_TOAN
WHERE TrangThaiTT = N'Thành công'
GROUP BY PhuongThuc;
GO

-- Câu 9: Tổng doanh thu dịch vụ phụ trợ theo từng loại
SELECT dv.LoaiDV, COUNT(ct.MaCTDV) AS SoLuotBan, SUM(ct.ThanhTien) AS DoanhThu
FROM CHI_TIET_DICH_VU ct
JOIN DICH_VU dv ON ct.MaDV = dv.MaDV
GROUP BY dv.LoaiDV;
GO

-- Câu 10: Số giờ chơi trung bình của mỗi khách hàng
SELECT kh.MaKH, kh.HoTen, 
       COUNT(ds.MaDatSan) AS SoLanDat, 
       AVG(DATEDIFF(MINUTE, ds.GioBatDau, ds.GioKetThuc))/60.0 AS SoGioTB
FROM KHACH_HANG kh
LEFT JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH AND ds.TrangThai = N'Hoàn thành'
GROUP BY kh.MaKH, kh.HoTen;
GO

-- Câu 11: Tổng tồn kho theo loại dịch vụ
SELECT LoaiDV, SUM(SoLuongTon) AS TongTonKho, COUNT(*) AS SoMatHang
FROM DICH_VU
WHERE TrangThai = N'Còn hàng'
GROUP BY LoaiDV;
GO

-- Câu 12: Doanh thu đặt sân theo ngày trong tháng 4/2026
SELECT NgayDat, COUNT(*) AS SoLuotDat, SUM(SoTien) AS DoanhThuNgay
FROM DAT_SAN
WHERE NgayDat BETWEEN '2026-04-01' AND '2026-04-30'
  AND TrangThai = N'Hoàn thành'
GROUP BY NgayDat
ORDER BY NgayDat;
GO

-- ============================================================
-- c. TRUY VẤN VỚI MỆNH ĐỀ HAVING: 5 CÂU (5 Đ)
-- ============================================================

-- Câu 13: Khách hàng có tổng chi tiêu > 500,000đ
SELECT kh.MaKH, kh.HoTen, SUM(ds.SoTien) AS TongChiTieu
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
WHERE ds.TrangThai = N'Hoàn thành'
GROUP BY kh.MaKH, kh.HoTen
HAVING SUM(ds.SoTien) > 500000;
GO

-- Câu 14: Sân được đặt nhiều hơn 3 lần trong tháng 4/2026
SELECT s.MaSan, s.TenSan, COUNT(ds.MaDatSan) AS SoLuotDat
FROM SAN s
JOIN DAT_SAN ds ON s.MaSan = ds.MaSan
WHERE ds.NgayDat BETWEEN '2026-04-01' AND '2026-04-30'
GROUP BY s.MaSan, s.TenSan
HAVING COUNT(ds.MaDatSan) > 3;
GO

-- Câu 15: Ngày có doanh thu đặt sân > 400,000đ
SELECT NgayDat, COUNT(*) AS SoLuot, SUM(SoTien) AS DoanhThu
FROM DAT_SAN
WHERE TrangThai = N'Hoàn thành'
GROUP BY NgayDat
HAVING SUM(SoTien) > 400000;
GO

-- Câu 16: Dịch vụ có tổng doanh thu > 100,000đ
SELECT dv.MaDV, dv.TenDV, SUM(ct.ThanhTien) AS DoanhThu
FROM DICH_VU dv
JOIN CHI_TIET_DICH_VU ct ON dv.MaDV = ct.MaDV
GROUP BY dv.MaDV, dv.TenDV
HAVING SUM(ct.ThanhTien) > 100000;
GO

-- Câu 17: Khách hàng đặt sân nhiều hơn 1 lần và có điểm tích lũy > 100
SELECT kh.MaKH, kh.HoTen, COUNT(ds.MaDatSan) AS SoLanDat, kh.DiemTichLuy
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
GROUP BY kh.MaKH, kh.HoTen, kh.DiemTichLuy
HAVING COUNT(ds.MaDatSan) > 1 AND kh.DiemTichLuy > 100;
GO

-- ============================================================
-- d. TRUY VẤN LỚN NHẤT, NHỎ NHẤT: 4 CÂU (4 Đ)
-- ============================================================

-- Câu 18: Khách hàng có điểm tích lũy cao nhất
SELECT TOP 1 MaKH, HoTen, DiemTichLuy, HangThanhVien
FROM KHACH_HANG
ORDER BY DiemTichLuy DESC;
GO

-- Câu 19: Sân có giá thuê cao nhất theo khung giờ
SELECT TOP 1 bg.MaGia, ls.TenLoaiSan, bg.ThuTrongTuan, bg.GioBatDau, bg.GioKetThuc, bg.DonGia
FROM BANG_GIA bg
JOIN LOAI_SAN ls ON bg.MaLoaiSan = ls.MaLoaiSan
ORDER BY bg.DonGia DESC;
GO

-- Câu 20: Khách hàng có số lần đặt sân ít nhất (ít nhất 1 lần)
SELECT TOP 1 kh.MaKH, kh.HoTen, COUNT(ds.MaDatSan) AS SoLanDat
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
GROUP BY kh.MaKH, kh.HoTen
ORDER BY COUNT(ds.MaDatSan) ASC;
GO

-- Câu 21: Dịch vụ có đơn giá thấp nhất
SELECT TOP 1 MaDV, TenDV, LoaiDV, DonGia
FROM DICH_VU
WHERE TrangThai = N'Còn hàng'
ORDER BY DonGia ASC;
GO

-- ============================================================
-- e. TRUY VẤN KHÔNG/CHƯA CÓ (NOT IN, LEFT/RIGHT JOIN): 5 CÂU (5 Đ)
-- ============================================================

-- Câu 22: Khách hàng CHƯA TỪNG đặt sân (LEFT JOIN + IS NULL)
SELECT kh.MaKH, kh.HoTen, kh.SoDienThoai, kh.NgayDangKy
FROM KHACH_HANG kh
LEFT JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
WHERE ds.MaDatSan IS NULL;
GO

-- Câu 23: Sân CHƯA TỪNG được đặt trong tháng 4/2026 (NOT IN)
SELECT MaSan, TenSan, TrangThai
FROM SAN
WHERE MaSan NOT IN (
    SELECT DISTINCT MaSan 
    FROM DAT_SAN 
    WHERE NgayDat BETWEEN '2026-04-01' AND '2026-04-30'
);
GO

-- Câu 24: Dịch vụ CHƯA TỪNG được bán (LEFT JOIN)
SELECT dv.MaDV, dv.TenDV, dv.LoaiDV
FROM DICH_VU dv
LEFT JOIN CHI_TIET_DICH_VU ct ON dv.MaDV = ct.MaDV
WHERE ct.MaCTDV IS NULL;
GO

-- Câu 25: Ngày trong tháng 4 CHƯA có đơn đặt sân nào (NOT IN với calendar)
-- Sử dụng recursive CTE tạo danh sách ngày
WITH NgayThang4 AS (
    SELECT CAST('2026-04-01' AS DATE) AS Ngay
    UNION ALL
    SELECT DATEADD(DAY, 1, Ngay)
    FROM NgayThang4
    WHERE Ngay < '2026-04-30'
)
SELECT Ngay FROM NgayThang4
WHERE Ngay NOT IN (SELECT DISTINCT NgayDat FROM DAT_SAN WHERE NgayDat BETWEEN '2026-04-01' AND '2026-04-30')
OPTION (MAXRECURSION 31);
GO

-- Câu 26: Khách hàng có đặt sân nhưng CHƯA TỪNG mua dịch vụ phụ trợ (RIGHT JOIN)
SELECT DISTINCT kh.MaKH, kh.HoTen
FROM CHI_TIET_DICH_VU ct
RIGHT JOIN DAT_SAN ds ON ct.MaDatSan = ds.MaDatSan
JOIN KHACH_HANG kh ON ds.MaKH = kh.MaKH
WHERE ct.MaCTDV IS NULL;
GO

-- ============================================================
-- f. TRUY VẤN HỢP/GIAO/TRỪ: 3 CÂU (3 Đ)
-- ============================================================

-- Câu 27: HỢP (UNION): Danh sách khách hàng đặt sân hoặc mua dịch vụ
SELECT DISTINCT kh.MaKH, kh.HoTen, N'Đặt sân' AS LoaiHoatDong
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
UNION
SELECT DISTINCT kh.MaKH, kh.HoTen, N'Mua dịch vụ'
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
JOIN CHI_TIET_DICH_VU ct ON ds.MaDatSan = ct.MaDatSan;
GO

-- Câu 28: GIAO (INTERSECT): Khách hàng vừa đặt sân VIP vừa đặt sân thường
SELECT kh.MaKH, kh.HoTen
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
JOIN SAN s ON ds.MaSan = s.MaSan
WHERE s.MaLoaiSan = 2 -- VIP
INTERSECT
SELECT kh.MaKH, kh.HoTen
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
JOIN SAN s ON ds.MaSan = s.MaSan
WHERE s.MaLoaiSan = 1; -- Thường
GO

-- Câu 29: TRỪ (EXCEPT): Khách đặt sân nhưng chưa từng thanh toán online
SELECT DISTINCT kh.MaKH, kh.HoTen
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
EXCEPT
SELECT DISTINCT kh.MaKH, kh.HoTen
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
JOIN THANH_TOAN tt ON ds.MaDatSan = tt.MaDatSan
WHERE tt.PhuongThuc IN (N'VNPay', N'Momo', N'ZaloPay');
GO

-- ============================================================
-- g. TRUY VẤN UPDATE, DELETE: 7 CÂU (7 Đ)
-- ============================================================

-- Câu 30: UPDATE - Nâng hạng thành viên khách có điểm > 1000 lên "Kim cương"
UPDATE KHACH_HANG
SET HangThanhVien = N'Kim cương'
WHERE DiemTichLuy > 1000 AND HangThanhVien != N'Kim cương';
GO

-- Câu 31: UPDATE - Tăng giá nước uống lên 10%
UPDATE DICH_VU
SET DonGia = DonGia * 1.1
WHERE LoaiDV = N'Nước uống';
GO

-- Câu 32: UPDATE - Cập nhật trạng thái sân bảo trì về "Trống"
UPDATE SAN
SET TrangThai = N'Trống'
WHERE MaSan = 6 AND TrangThai = N'Bảo trì';
GO

-- Câu 33: UPDATE - Cộng điểm tích lũy cho khách đặt sân trong tháng 4
UPDATE KHACH_HANG
SET DiemTichLuy = DiemTichLuy + 50
WHERE MaKH IN (
    SELECT DISTINCT MaKH FROM DAT_SAN 
    WHERE NgayDat BETWEEN '2026-04-01' AND '2026-04-30'
      AND TrangThai = N'Hoàn thành'
);
GO

-- Câu 34: DELETE - Xóa chi tiết dịch vụ của đơn đã hủy
DELETE FROM CHI_TIET_DICH_VU
WHERE MaDatSan IN (
    SELECT MaDatSan FROM DAT_SAN WHERE TrangThai = N'Hủy'
);
GO

-- Câu 35: DELETE - Xóa lịch sử thanh toán thất bại cách đây > 30 ngày
DELETE FROM THANH_TOAN
WHERE TrangThaiTT = N'Thất bại' AND NgayTT < DATEADD(DAY, -30, GETDATE());
GO

-- Câu 36: UPDATE + DELETE trong transaction - Hủy gói cố định và cập nhật trạng thái
BEGIN TRANSACTION;
UPDATE GOI_CO_DINH
SET TrangThai = N'Hủy'
WHERE MaGoi = 15;

DELETE FROM DAT_SAN
WHERE MaKH = (SELECT MaKH FROM GOI_CO_DINH WHERE MaGoi = 15)
  AND LoaiDat = N'Cố định'
  AND NgayDat >= GETDATE()
  AND TrangThai = N'Chờ check-in';
COMMIT;
GO

-- ============================================================
-- h. TRUY VẤN SỬ DỤNG PHÉP CHIA: 4 CÂU (4 Đ)
-- ============================================================

-- Câu 37: Khách hàng đã đặt TẤT CẢ các loại sân (Phép chia)
-- Cách 1: Dùng GROUP BY + HAVING COUNT(DISTINCT)
SELECT kh.MaKH, kh.HoTen
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
JOIN SAN s ON ds.MaSan = s.MaSan
WHERE ds.TrangThai = N'Hoàn thành'
GROUP BY kh.MaKH, kh.HoTen
HAVING COUNT(DISTINCT s.MaLoaiSan) = (SELECT COUNT(*) FROM LOAI_SAN);
GO

-- Câu 38: Khách hàng đã chơi ở TẤT CẢ các sân (Phép chia)
SELECT kh.MaKH, kh.HoTen
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
WHERE ds.TrangThai = N'Hoàn thành'
GROUP BY kh.MaKH, kh.HoTen
HAVING COUNT(DISTINCT ds.MaSan) = (SELECT COUNT(*) FROM SAN WHERE TrangThai != N'Bảo trì');
GO

-- Câu 39: Khách hàng đã sử dụng TẤT CẢ các loại dịch vụ (Phép chia)
SELECT kh.MaKH, kh.HoTen
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
JOIN CHI_TIET_DICH_VU ct ON ds.MaDatSan = ct.MaDatSan
JOIN DICH_VU dv ON ct.MaDV = dv.MaDV
GROUP BY kh.MaKH, kh.HoTen
HAVING COUNT(DISTINCT dv.LoaiDV) = (SELECT COUNT(DISTINCT LoaiDV) FROM DICH_VU);
GO

-- Câu 40: Khách hàng đã thanh toán bằng TẤT CẢ các phương thức (Phép chia)
SELECT kh.MaKH, kh.HoTen
FROM KHACH_HANG kh
JOIN DAT_SAN ds ON kh.MaKH = ds.MaKH
JOIN THANH_TOAN tt ON ds.MaDatSan = tt.MaDatSan
WHERE tt.TrangThaiTT = N'Thành công'
GROUP BY kh.MaKH, kh.HoTen
HAVING COUNT(DISTINCT tt.PhuongThuc) = (SELECT COUNT(DISTINCT PhuongThuc) FROM THANH_TOAN WHERE TrangThaiTT = N'Thành công');
GO

PRINT N'===== HOÀN TẤT 40 CÂU TRUY VẤN =====';
GO



-- ============================================================
-- PHẦN 4: 7 THỦ TỤC, 8 HÀM, 5 TRIGGER (25 Đ)
-- ============================================================
USE SanCauLongDB;
GO

-- ============================================================
-- A. 7 THỦ TỤC (STORED PROCEDURES) - CÓ VÍ DỤ MINH HỌA
-- ============================================================

-- SP 1: Thêm đặt sân mới + tính tiền tự động
CREATE PROCEDURE sp_ThemDatSan
    @MaKH INT,
    @MaSan INT,
    @NgayDat DATE,
    @GioBatDau TIME,
    @GioKetThuc TIME,
    @LoaiDat NVARCHAR(20) = N'Vãng lai',
    @GhiChu NVARCHAR(200) = NULL,
    @NguoiTao NVARCHAR(50),
    @MaDatSan INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DonGia DECIMAL(10,2), @SoTien DECIMAL(10,2);
    DECLARE @Thu INT = DATEPART(WEEKDAY, @NgayDat); -- 1=CN, 2=T2...
    DECLARE @MaLoaiSan INT;

    -- Lấy loại sân
    SELECT @MaLoaiSan = MaLoaiSan FROM SAN WHERE MaSan = @MaSan;

    -- Tính đơn giá theo bảng giá
    SELECT @DonGia = DonGia FROM BANG_GIA 
    WHERE MaLoaiSan = @MaLoaiSan AND ThuTrongTuan = @Thu
      AND @GioBatDau >= GioBatDau AND @GioKetThuc <= GioKetThuc;

    IF @DonGia IS NULL
        SET @DonGia = 100000; -- Giá mặc định

    -- Tính tổng tiền
    SET @SoTien = @DonGia * DATEDIFF(MINUTE, @GioBatDau, @GioKetThuc) / 60.0;

    -- Kiểm tra trùng lịch
    IF EXISTS (
        SELECT 1 FROM DAT_SAN 
        WHERE MaSan = @MaSan AND NgayDat = @NgayDat
          AND TrangThai NOT IN (N'Hủy', N'No-show')
          AND ((@GioBatDau >= GioBatDau AND @GioBatDau < GioKetThuc)
            OR (@GioKetThuc > GioBatDau AND @GioKetThuc <= GioKetThuc))
    )
    BEGIN
        RAISERROR(N'Sân đã có người đặt trong khung giờ này!', 16, 1);
        RETURN;
    END

    INSERT INTO DAT_SAN (MaKH, MaSan, NgayDat, GioBatDau, GioKetThuc, LoaiDat, TrangThai, SoTien, TienCoc, GhiChu, NguoiTao)
    VALUES (@MaKH, @MaSan, @NgayDat, @GioBatDau, @GioKetThuc, @LoaiDat, N'Chờ check-in', @SoTien, @SoTien * 0.5, @GhiChu, @NguoiTao);

    SET @MaDatSan = SCOPE_IDENTITY();
    PRINT N'Đã thêm đặt sân thành công. Mã: ' + CAST(@MaDatSan AS VARCHAR);
END;
GO

-- VÍ DỤ MINH HỌA SP 1:
DECLARE @MaDatSanMoi INT;
EXEC sp_ThemDatSan 
    @MaKH = 1, 
    @MaSan = 2, 
    @NgayDat = '2026-04-15', 
    @GioBatDau = '18:00', 
    @GioKetThuc = '20:00',
    @LoaiDat = N'Vãng lai',
    @GhiChu = N'Test thủ tục',
    @NguoiTao = N'Lễ tân A',
    @MaDatSan = @MaDatSanMoi OUTPUT;
SELECT @MaDatSanMoi AS MaDatSanVuaTao;
GO

-- SP 2: Check-in sân
CREATE PROCEDURE sp_CheckInSan
    @MaDatSan INT,
    @NguoiCheckIn NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM DAT_SAN WHERE MaDatSan = @MaDatSan AND TrangThai = N'Chờ check-in')
    BEGIN
        RAISERROR(N'Đặt sân không tồn tại hoặc không ở trạng thái chờ check-in!', 16, 1);
        RETURN;
    END

    UPDATE DAT_SAN
    SET TrangThai = N'Đang chơi'
    WHERE MaDatSan = @MaDatSan;

    UPDATE SAN
    SET TrangThai = N'Đang sử dụng'
    WHERE MaSan = (SELECT MaSan FROM DAT_SAN WHERE MaDatSan = @MaDatSan);

    PRINT N'Check-in thành công cho đặt sân #' + CAST(@MaDatSan AS VARCHAR);
END;
GO

-- VÍ DỤ MINH HỌA SP 2:
EXEC sp_CheckInSan @MaDatSan = 20, @NguoiCheckIn = N'Lễ tân A';
GO

-- SP 3: Thanh toán đơn đặt sân
CREATE PROCEDURE sp_ThanhToan
    @MaDatSan INT,
    @SoTien DECIMAL(10,2),
    @PhuongThuc NVARCHAR(30),
    @LoaiTT NVARCHAR(20),
    @MaGiaoDich VARCHAR(100) = NULL,
    @NguoiThu NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO THANH_TOAN (MaDatSan, SoTien, PhuongThuc, LoaiTT, TrangThaiTT, MaGiaoDich, NgayTT, NguoiThu)
    VALUES (@MaDatSan, @SoTien, @PhuongThuc, @LoaiTT, N'Thành công', @MaGiaoDich, GETDATE(), @NguoiThu);

    -- Nếu thanh toán đủ, cập nhật trạng thái đặt sân
    DECLARE @TongTT DECIMAL(10,2), @TongTien DECIMAL(10,2);
    SELECT @TongTT = SUM(SoTien) FROM THANH_TOAN WHERE MaDatSan = @MaDatSan AND TrangThaiTT = N'Thành công' AND LoaiTT != N'Hoàn tiền';
    SELECT @TongTien = SoTien FROM DAT_SAN WHERE MaDatSan = @MaDatSan;

    IF @TongTT >= @TongTien
        UPDATE DAT_SAN SET TrangThai = N'Hoàn thành' WHERE MaDatSan = @MaDatSan AND TrangThai = N'Đang chơi';

    PRINT N'Thanh toán thành công!';
END;
GO

-- VÍ DỤ MINH HỌA SP 3:
EXEC sp_ThanhToan 
    @MaDatSan = 20, 
    @SoTien = 70000, 
    @PhuongThuc = N'Tiền mặt', 
    @LoaiTT = N'Thanh toán',
    @NguoiThu = N'Lễ tân A';
GO

-- SP 4: Báo cáo doanh thu theo khoảng thời gian
CREATE PROCEDURE sp_BaoCaoDoanhThu
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ds.NgayDat,
        COUNT(*) AS SoLuotDat,
        SUM(ds.SoTien) AS DoanhThuSan,
        ISNULL(SUM(ctdv.ThanhTien), 0) AS DoanhThuDV,
        SUM(ds.SoTien) + ISNULL(SUM(ctdv.ThanhTien), 0) AS TongDoanhThu
    FROM DAT_SAN ds
    LEFT JOIN CHI_TIET_DICH_VU ctdv ON ds.MaDatSan = ctdv.MaDatSan
    WHERE ds.NgayDat BETWEEN @TuNgay AND @DenNgay
      AND ds.TrangThai = N'Hoàn thành'
    GROUP BY ds.NgayDat
    ORDER BY ds.NgayDat;
END;
GO

-- VÍ DỤ MINH HỌA SP 4:
EXEC sp_BaoCaoDoanhThu @TuNgay = '2026-04-01', @DenNgay = '2026-04-10';
GO

-- SP 5: Cập nhật hạng thành viên tự động
CREATE PROCEDURE sp_CapNhatHangThanhVien
    @MaKH INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TongChiTieu DECIMAL(10,2), @HangMoi NVARCHAR(20);

    SELECT @TongChiTieu = SUM(SoTien) 
    FROM DAT_SAN 
    WHERE MaKH = @MaKH AND TrangThai = N'Hoàn thành'
      AND NgayDat >= DATEADD(MONTH, -1, GETDATE());

    SET @HangMoi = CASE
        WHEN @TongChiTieu >= 10000000 THEN N'Kim cương'
        WHEN @TongChiTieu >= 5000000 THEN N'Vàng'
        WHEN @TongChiTieu >= 2000000 THEN N'Bạc'
        ELSE N'Thường'
    END;

    UPDATE KHACH_HANG
    SET HangThanhVien = @HangMoi
    WHERE MaKH = @MaKH;

    PRINT N'Đã cập nhật hạng thành viên: ' + @HangMoi;
END;
GO

-- VÍ DỤ MINH HỌA SP 5:
EXEC sp_CapNhatHangThanhVien @MaKH = 1;
GO

-- SP 6: Hủy đặt sân + hoàn tiền
CREATE PROCEDURE sp_HuyDatSan
    @MaDatSan INT,
    @LyDo NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NgayDat DATE, @GioBatDau TIME, @TienCoc DECIMAL(10,2), @MaKH INT;

    SELECT @NgayDat = NgayDat, @GioBatDau = GioBatDau, @TienCoc = TienCoc, @MaKH = MaKH
    FROM DAT_SAN WHERE MaDatSan = @MaDatSan;

    -- Tính thời gian đến giờ chơi
    DECLARE @ThoiGianConLai INT = DATEDIFF(HOUR, GETDATE(), CAST(@NgayDat AS DATETIME) + CAST(@GioBatDau AS DATETIME));

    UPDATE DAT_SAN
    SET TrangThai = N'Hủy', GhiChu = ISNULL(GhiChu + N' | ', N'') + N'Hủy: ' + @LyDo
    WHERE MaDatSan = @MaDatSan;

    -- Hoàn tiền cọc nếu hủy trước 24h
    IF @ThoiGianConLai >= 24
    BEGIN
        INSERT INTO THANH_TOAN (MaDatSan, SoTien, PhuongThuc, LoaiTT, TrangThaiTT, NguoiThu)
        VALUES (@MaDatSan, @TienCoc, N'Tiền mặt', N'Hoàn tiền', N'Thành công', N'Hệ thống');
        PRINT N'Đã hoàn tiền cọc: ' + CAST(@TienCoc AS VARCHAR);
    END
    ELSE
        PRINT N'Hủy muộn, không hoàn tiền cọc.';
END;
GO

-- VÍ DỤ MINH HỌA SP 6:
EXEC sp_HuyDatSan @MaDatSan = 25, @LyDo = N'Khách bận đột xuất';
GO

-- SP 7: Thêm dịch vụ vào đơn đặt sân
CREATE PROCEDURE sp_ThemDichVu
    @MaDatSan INT,
    @MaDV INT,
    @SoLuong INT,
    @GhiChu NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DonGia DECIMAL(10,2), @TonKho INT;

    SELECT @DonGia = DonGia, @TonKho = SoLuongTon FROM DICH_VU WHERE MaDV = @MaDV;

    IF @TonKho < @SoLuong
    BEGIN
        RAISERROR(N'Không đủ hàng trong kho!', 16, 1);
        RETURN;
    END

    INSERT INTO CHI_TIET_DICH_VU (MaDatSan, MaDV, SoLuong, DonGiaLucBan, GhiChu)
    VALUES (@MaDatSan, @MaDV, @SoLuong, @DonGia, @GhiChu);

    UPDATE DICH_VU SET SoLuongTon = SoLuongTon - @SoLuong WHERE MaDV = @MaDV;

    PRINT N'Đã thêm dịch vụ thành công!';
END;
GO

-- VÍ DỤ MINH HỌA SP 7:
EXEC sp_ThemDichVu @MaDatSan = 1, @MaDV = 3, @SoLuong = 2, @GhiChu = N'Test thêm DV';
GO

-- ============================================================
-- B. 8 HÀM (FUNCTIONS) - CÓ VÍ DỤ MINH HỌA
-- ============================================================

-- Hàm 1: Tính tổng tiền của một đơn đặt sân (bao gồm dịch vụ)
CREATE FUNCTION fn_TinhTongTienDon (@MaDatSan INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TienSan DECIMAL(10,2), @TienDV DECIMAL(10,2);
    SELECT @TienSan = SoTien FROM DAT_SAN WHERE MaDatSan = @MaDatSan;
    SELECT @TienDV = SUM(ThanhTien) FROM CHI_TIET_DICH_VU WHERE MaDatSan = @MaDatSan;
    RETURN ISNULL(@TienSan, 0) + ISNULL(@TienDV, 0);
END;
GO

-- VÍ DỤ MINH HỌA HÀM 1:
SELECT MaDatSan, SoTien AS TienSan, dbo.fn_TinhTongTienDon(MaDatSan) AS TongTien
FROM DAT_SAN WHERE MaDatSan = 1;
GO

-- Hàm 2: Lấy giá thuê theo sân và thời gian
CREATE FUNCTION fn_LayGiaThue (@MaSan INT, @NgayDat DATE, @GioBatDau TIME)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @MaLoaiSan INT, @Thu INT, @DonGia DECIMAL(10,2);
    SET @Thu = DATEPART(WEEKDAY, @NgayDat);
    SELECT @MaLoaiSan = MaLoaiSan FROM SAN WHERE MaSan = @MaSan;

    SELECT @DonGia = DonGia FROM BANG_GIA 
    WHERE MaLoaiSan = @MaLoaiSan AND ThuTrongTuan = @Thu
      AND @GioBatDau >= GioBatDau AND @GioBatDau < GioKetThuc;

    RETURN ISNULL(@DonGia, 100000);
END;
GO

-- VÍ DỤ MINH HỌA HÀM 2:
SELECT dbo.fn_LayGiaThue(1, '2026-04-15', '18:00') AS GiaThue;
GO

-- Hàm 3: Kiểm tra sân trống
CREATE FUNCTION fn_KiemTraSanTrong (@MaSan INT, @NgayDat DATE, @GioBatDau TIME, @GioKetThuc TIME)
RETURNS BIT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM DAT_SAN 
        WHERE MaSan = @MaSan AND NgayDat = @NgayDat
          AND TrangThai NOT IN (N'Hủy', N'No-show')
          AND ((@GioBatDau >= GioBatDau AND @GioBatDau < GioKetThuc)
            OR (@GioKetThuc > GioBatDau AND @GioKetThuc <= GioKetThuc))
    )
        RETURN 0;
    RETURN 1;
END;
GO

-- VÍ DỤ MINH HỌA HÀM 3:
SELECT dbo.fn_KiemTraSanTrong(1, '2026-04-01', '18:00', '20:00') AS SanTrong;
GO

-- Hàm 4: Tính điểm tích lũy từ số tiền chi tiêu
CREATE FUNCTION fn_TinhDiemTichLuy (@SoTien DECIMAL(10,2))
RETURNS INT
AS
BEGIN
    RETURN CAST(@SoTien / 1000 AS INT);
END;
GO

-- VÍ DỤ MINH HỌA HÀM 4:
SELECT dbo.fn_TinhDiemTichLuy(250000) AS DiemDuocCong;
GO

-- Hàm 5: Lấy danh sách sân trống theo ngày
CREATE FUNCTION fn_DanhSachSanTrong (@NgayDat DATE)
RETURNS TABLE
AS
RETURN
    SELECT s.MaSan, s.TenSan, ls.TenLoaiSan, ls.PhuPhi
    FROM SAN s
    JOIN LOAI_SAN ls ON s.MaLoaiSan = ls.MaLoaiSan
    WHERE s.TrangThai = N'Trống'
      AND s.MaSan NOT IN (
          SELECT MaSan FROM DAT_SAN 
          WHERE NgayDat = @NgayDat AND TrangThai NOT IN (N'Hủy', N'No-show')
      );
GO

-- VÍ DỤ MINH HỌA HÀM 5:
SELECT * FROM dbo.fn_DanhSachSanTrong('2026-04-20');
GO

-- Hàm 6: Tính tổng doanh thu của khách hàng
CREATE FUNCTION fn_DoanhThuKhachHang (@MaKH INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Tong DECIMAL(10,2);
    SELECT @Tong = SUM(SoTien) FROM DAT_SAN WHERE MaKH = @MaKH AND TrangThai = N'Hoàn thành';
    RETURN ISNULL(@Tong, 0);
END;
GO

-- VÍ DỤ MINH HỌA HÀM 6:
SELECT MaKH, HoTen, dbo.fn_DoanhThuKhachHang(MaKH) AS TongChiTieu
FROM KHACH_HANG WHERE MaKH = 1;
GO

-- Hàm 7: Lấy lịch sử đặt sân của khách
CREATE FUNCTION fn_LichSuDatSan (@MaKH INT)
RETURNS TABLE
AS
RETURN
    SELECT ds.MaDatSan, s.TenSan, ds.NgayDat, ds.GioBatDau, ds.GioKetThuc, 
           ds.TrangThai, ds.SoTien
    FROM DAT_SAN ds
    JOIN SAN s ON ds.MaSan = s.MaSan
    WHERE ds.MaKH = @MaKH
    ORDER BY ds.NgayDat DESC, ds.GioBatDau DESC;
GO

-- VÍ DỤ MINH HỌA HÀM 7:
SELECT * FROM dbo.fn_LichSuDatSan(1);
GO

-- Hàm 8: Tính số giờ chơi còn lại trong gói cố định
CREATE FUNCTION fn_SoGioConLaiGoi (@MaGoi INT)
RETURNS INT
AS
BEGIN
    DECLARE @TongGio INT, @DaChoi INT;
    SELECT @TongGio = DATEDIFF(MINUTE, GioBatDau, GioKetThuc) / 60 * 
        (DATEDIFF(DAY, NgayBatDau, NgayKetThuc) / 7 + 1)
    FROM GOI_CO_DINH WHERE MaGoi = @MaGoi;

    SELECT @DaChoi = COUNT(*) FROM DAT_SAN 
    WHERE MaKH = (SELECT MaKH FROM GOI_CO_DINH WHERE MaGoi = @MaGoi)
      AND LoaiDat = N'Cố định' AND TrangThai = N'Hoàn thành';

    RETURN ISNULL(@TongGio, 0) - ISNULL(@DaChoi, 0);
END;
GO

-- VÍ DỤ MINH HỌA HÀM 8:
SELECT MaGoi, dbo.fn_SoGioConLaiGoi(MaGoi) AS SoGioConLai
FROM GOI_CO_DINH WHERE MaGoi = 1;
GO

-- ============================================================
-- C. 5 TRIGGER
-- ============================================================

-- Trigger 1: Tự động tích điểm khi đặt sân hoàn thành
CREATE TRIGGER trg_TichDiemDatSan
ON DAT_SAN
AFTER UPDATE
AS
BEGIN
    IF UPDATE(TrangThai)
    BEGIN
        UPDATE kh
        SET kh.DiemTichLuy = kh.DiemTichLuy + (i.SoTien / 1000)
        FROM KHACH_HANG kh
        JOIN inserted i ON kh.MaKH = i.MaKH
        JOIN deleted d ON i.MaDatSan = d.MaDatSan
        WHERE i.TrangThai = N'Hoàn thành' AND d.TrangThai != N'Hoàn thành';
    END
END;
GO

-- Trigger 2: Ghi audit log khi cập nhật giá dịch vụ
CREATE TRIGGER trg_AuditGiaDichVu
ON DICH_VU
AFTER UPDATE
AS
BEGIN
    IF UPDATE(DonGia)
    BEGIN
        INSERT INTO LICH_SU_HOAT_DONG (BangBiThayDoi, MaBanGhi, HanhDong, DuLieuCu, DuLieuMoi, NguoiThayDoi)
        SELECT N'DICH_VU', d.MaDV, N'UPDATE', 
               N'Giá cũ: ' + CAST(d.DonGia AS VARCHAR),
               N'Giá mới: ' + CAST(i.DonGia AS VARCHAR),
               SUSER_SNAME()
        FROM deleted d
        JOIN inserted i ON d.MaDV = i.MaDV
        WHERE d.DonGia != i.DonGia;
    END
END;
GO

-- Trigger 3: Cập nhật tồn kho khi bán dịch vụ
CREATE TRIGGER trg_CapNhatTonKho
ON CHI_TIET_DICH_VU
AFTER INSERT
AS
BEGIN
    UPDATE dv
    SET dv.SoLuongTon = dv.SoLuongTon - i.SoLuong
    FROM DICH_VU dv
    JOIN inserted i ON dv.MaDV = i.MaDV;

    -- Cảnh báo nếu tồn kho thấp
    IF EXISTS (SELECT 1 FROM DICH_VU WHERE SoLuongTon < 10 AND LoaiDV = N'Nước uống')
        PRINT N'CẢNH BÁO: Tồn kho nước uống dưới ngưỡng an toàn!';
END;
GO

-- Trigger 4: Ngăn xóa đơn đặt sân đã hoàn thành
CREATE TRIGGER trg_NganXoaDonHoanThanh
ON DAT_SAN
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE TrangThai = N'Hoàn thành')
    BEGIN
        RAISERROR(N'Không thể xóa đơn đặt sân đã hoàn thành! Chỉ có thể hủy.', 16, 1);
        RETURN;
    END

    DELETE FROM DAT_SAN WHERE MaDatSan IN (SELECT MaDatSan FROM deleted);
END;
GO

-- Trigger 5: Tự động cập nhật trạng thái sân khi check-out
CREATE TRIGGER trg_CapNhatTrangThaiSan
ON DAT_SAN
AFTER UPDATE
AS
BEGIN
    IF UPDATE(TrangThai)
    BEGIN
        -- Khi đơn chuyển sang Hoàn thành, cập nhật sân về Trống
        UPDATE s
        SET s.TrangThai = N'Trống'
        FROM SAN s
        JOIN inserted i ON s.MaSan = i.MaSan
        WHERE i.TrangThai = N'Hoàn thành';
    END
END;
GO

PRINT N'===== HOÀN TẤT THỦ TỤC, HÀM, TRIGGER =====';
GO



-- ============================================================
-- PHẦN 5: PHÂN QUYỀN NGƯỜI DÙNG (10 Đ)
-- ============================================================
USE SanCauLongDB;
GO

-- Xóa user cũ nếu tồn tại (để chạy lại được)
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'LeTan_User')
    DROP LOGIN LeTan_User;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'QuanLy_User')
    DROP LOGIN QuanLy_User;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'ChuSan_User')
    DROP LOGIN ChuSan_User;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'HLV_User')
    DROP LOGIN HLV_User;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'KeToan_User')
    DROP LOGIN KeToan_User;
GO

-- Xóa user trong database
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'LeTan_User')
    DROP USER LeTan_User;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'QuanLy_User')
    DROP USER QuanLy_User;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ChuSan_User')
    DROP USER ChuSan_User;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'HLV_User')
    DROP USER HLV_User;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'KeToan_User')
    DROP USER KeToan_User;
GO

-- ============================================================
-- 1. TẠO 5 LOGIN (TÀI KHOẢN ĐĂNG NHẬP SERVER)
-- ============================================================
CREATE LOGIN LeTan_User WITH PASSWORD = N'Letan@123';
CREATE LOGIN QuanLy_User WITH PASSWORD = N'Quanly@123';
CREATE LOGIN ChuSan_User WITH PASSWORD = N'Chusan@123';
CREATE LOGIN HLV_User WITH PASSWORD = N'Hlv@123';
CREATE LOGIN KeToan_User WITH PASSWORD = N'Ketoan@123';
GO

-- ============================================================
-- 2. TẠO 5 USER TRONG DATABASE
-- ============================================================
CREATE USER LeTan_User FOR LOGIN LeTan_User;
CREATE USER QuanLy_User FOR LOGIN QuanLy_User;
CREATE USER ChuSan_User FOR LOGIN ChuSan_User;
CREATE USER HLV_User FOR LOGIN HLV_User;
CREATE USER KeToan_User FOR LOGIN KeToan_User;
GO

-- ============================================================
-- 3. TẠO CÁC ROLE TÙY CHỈNH
-- ============================================================
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Role_LeTan')
    DROP ROLE Role_LeTan;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Role_QuanLy')
    DROP ROLE Role_QuanLy;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Role_ChuSan')
    DROP ROLE Role_ChuSan;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Role_HLV')
    DROP ROLE Role_HLV;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Role_KeToan')
    DROP ROLE Role_KeToan;
GO

CREATE ROLE Role_LeTan;
CREATE ROLE Role_QuanLy;
CREATE ROLE Role_ChuSan;
CREATE ROLE Role_HLV;
CREATE ROLE Role_KeToan;
GO

-- ============================================================
-- 4. CẤP QUYỀN CHO TỪNG ROLE
-- ============================================================

-- === ROLE LỄ TÂN: Chỉ được thêm/sửa đặt sân, bán dịch vụ, thu tiền ===
-- Không được xóa, không được xem báo cáo tài chính, không được sửa giá
GRANT SELECT ON DAT_SAN TO Role_LeTan;
GRANT INSERT ON DAT_SAN TO Role_LeTan;
GRANT UPDATE ON DAT_SAN TO Role_LeTan;

GRANT SELECT ON KHACH_HANG TO Role_LeTan;
GRANT INSERT ON KHACH_HANG TO Role_LeTan;
GRANT UPDATE ON KHACH_HANG TO Role_LeTan;

GRANT SELECT ON SAN TO Role_LeTan;
GRANT UPDATE ON SAN TO Role_LeTan; -- Cập nhật trạng thái sân

GRANT SELECT ON DICH_VU TO Role_LeTan;
GRANT SELECT ON CHI_TIET_DICH_VU TO Role_LeTan;
GRANT INSERT ON CHI_TIET_DICH_VU TO Role_LeTan;

GRANT SELECT ON THANH_TOAN TO Role_LeTan;
GRANT INSERT ON THANH_TOAN TO Role_LeTan;

GRANT SELECT ON BANG_GIA TO Role_LeTan; -- Chỉ xem giá, không sửa

GRANT EXECUTE ON sp_ThemDatSan TO Role_LeTan;
GRANT EXECUTE ON sp_CheckInSan TO Role_LeTan;
GRANT EXECUTE ON sp_ThanhToan TO Role_LeTan;
GRANT EXECUTE ON sp_ThemDichVu TO Role_LeTan;
GRANT EXECUTE ON sp_HuyDatSan TO Role_LeTan;

-- Từ chối quyền xóa
DENY DELETE ON DAT_SAN TO Role_LeTan;
DENY DELETE ON KHACH_HANG TO Role_LeTan;
DENY DELETE ON THANH_TOAN TO Role_LeTan;
DENY DELETE ON CHI_TIET_DICH_VU TO Role_LeTan;

-- Từ chối xem báo cáo doanh thu
DENY SELECT ON GOI_CO_DINH TO Role_LeTan;
DENY SELECT ON NHAN_VIEN TO Role_LeTan;
GO

-- === ROLE QUẢN LÝ: Được phép quản lý toàn bộ vận hành ===
-- Được thêm/sửa/xóa giá, dịch vụ, xem báo cáo, không được xóa nhân viên
GRANT SELECT, INSERT, UPDATE, DELETE ON DAT_SAN TO Role_QuanLy;
GRANT SELECT, INSERT, UPDATE, DELETE ON KHACH_HANG TO Role_QuanLy;
GRANT SELECT, INSERT, UPDATE, DELETE ON SAN TO Role_QuanLy;
GRANT SELECT, INSERT, UPDATE, DELETE ON DICH_VU TO Role_QuanLy;
GRANT SELECT, INSERT, UPDATE, DELETE ON CHI_TIET_DICH_VU TO Role_QuanLy;
GRANT SELECT, INSERT, UPDATE, DELETE ON BANG_GIA TO Role_QuanLy;
GRANT SELECT, INSERT, UPDATE ON THANH_TOAN TO Role_QuanLy;
GRANT SELECT, INSERT, UPDATE, DELETE ON GOI_CO_DINH TO Role_QuanLy;
GRANT SELECT ON NHAN_VIEN TO Role_QuanLy;
GRANT SELECT ON LICH_SU_HOAT_DONG TO Role_QuanLy;

-- Quyền thực thi tất cả SP và hàm
GRANT EXECUTE TO Role_QuanLy;

-- Từ chối quyền xóa nhân viên và audit log
DENY DELETE ON NHAN_VIEN TO Role_QuanLy;
DENY DELETE ON LICH_SU_HOAT_DONG TO Role_QuanLy;
GO

-- === ROLE CHỦ SÂN: Toàn quyền xem, không được sửa dữ liệu trực tiếp ===
-- Chủ sân chỉ xem báo cáo, không can thiệp vận hành hàng ngày
GRANT SELECT ON DAT_SAN TO Role_ChuSan;
GRANT SELECT ON KHACH_HANG TO Role_ChuSan;
GRANT SELECT ON SAN TO Role_ChuSan;
GRANT SELECT ON DICH_VU TO Role_ChuSan;
GRANT SELECT ON CHI_TIET_DICH_VU TO Role_ChuSan;
GRANT SELECT ON THANH_TOAN TO Role_ChuSan;
GRANT SELECT ON BANG_GIA TO Role_ChuSan;
GRANT SELECT ON GOI_CO_DINH TO Role_ChuSan;
GRANT SELECT ON NHAN_VIEN TO Role_ChuSan;
GRANT SELECT ON LICH_SU_HOAT_DONG TO Role_ChuSan;
GRANT SELECT ON LOAI_SAN TO Role_ChuSan;

-- Được chạy báo cáo
GRANT EXECUTE ON sp_BaoCaoDoanhThu TO Role_ChuSan;

-- Từ chối TẤT CẢ quyền sửa đổi
DENY INSERT, UPDATE, DELETE ON DAT_SAN TO Role_ChuSan;
DENY INSERT, UPDATE, DELETE ON KHACH_HANG TO Role_ChuSan;
DENY INSERT, UPDATE, DELETE ON SAN TO Role_ChuSan;
DENY INSERT, UPDATE, DELETE ON DICH_VU TO Role_ChuSan;
DENY INSERT, UPDATE, DELETE ON THANH_TOAN TO Role_ChuSan;
DENY INSERT, UPDATE, DELETE ON BANG_GIA TO Role_ChuSan;
DENY INSERT, UPDATE, DELETE ON NHAN_VIEN TO Role_ChuSan;
GO

-- === ROLE HLV: Chỉ xem lịch dạy, thông tin cơ bản ===
GRANT SELECT ON KHACH_HANG TO Role_HLV; -- Xem học viên
GRANT SELECT ON DAT_SAN TO Role_HLV;    -- Xem lịch sân
GRANT SELECT ON SAN TO Role_HLV;

-- Từ chối xem tài chính, giá, thanh toán
DENY SELECT ON THANH_TOAN TO Role_HLV;
DENY SELECT ON BANG_GIA TO Role_HLV;
DENY SELECT ON CHI_TIET_DICH_VU TO Role_HLV;
DENY SELECT ON DICH_VU TO Role_HLV;
DENY SELECT ON GOI_CO_DINH TO Role_HLV;
DENY SELECT ON NHAN_VIEN TO Role_HLV;
DENY SELECT ON LICH_SU_HOAT_DONG TO Role_HLV;

-- Từ chối mọi quyền sửa đổi
DENY INSERT, UPDATE, DELETE ON DAT_SAN TO Role_HLV;
DENY INSERT, UPDATE, DELETE ON KHACH_HANG TO Role_HLV;
GO

-- === ROLE KẾ TOÁN: Chỉ xem báo cáo tài chính, không can thiệp vận hành ===
GRANT SELECT ON THANH_TOAN TO Role_KeToan;
GRANT SELECT ON DAT_SAN TO Role_KeToan;
GRANT SELECT ON CHI_TIET_DICH_VU TO Role_KeToan;
GRANT SELECT ON DICH_VU TO Role_KeToan;
GRANT SELECT ON KHACH_HANG TO Role_KeToan;
GRANT SELECT ON GOI_CO_DINH TO Role_KeToan;
GRANT SELECT ON BANG_GIA TO Role_KeToan;
GRANT SELECT ON NHAN_VIEN TO Role_KeToan;

-- Được chạy báo cáo
GRANT EXECUTE ON sp_BaoCaoDoanhThu TO Role_KeToan;

-- Từ chối mọi quyền sửa đổi
DENY INSERT, UPDATE, DELETE ON THANH_TOAN TO Role_KeToan;
DENY INSERT, UPDATE, DELETE ON DAT_SAN TO Role_KeToan;
DENY INSERT, UPDATE, DELETE ON CHI_TIET_DICH_VU TO Role_KeToan;
DENY INSERT, UPDATE, DELETE ON DICH_VU TO Role_KeToan;
DENY INSERT, UPDATE, DELETE ON KHACH_HANG TO Role_KeToan;
DENY INSERT, UPDATE, DELETE ON GOI_CO_DINH TO Role_KeToan;
DENY INSERT, UPDATE, DELETE ON BANG_GIA TO Role_KeToan;
DENY INSERT, UPDATE, DELETE ON NHAN_VIEN TO Role_KeToan;
GO

-- ============================================================
-- 5. GÁN USER VÀO CÁC ROLE
-- ============================================================
ALTER ROLE Role_LeTan ADD MEMBER LeTan_User;
ALTER ROLE Role_QuanLy ADD MEMBER QuanLy_User;
ALTER ROLE Role_ChuSan ADD MEMBER ChuSan_User;
ALTER ROLE Role_HLV ADD MEMBER HLV_User;
ALTER ROLE Role_KeToan ADD MEMBER KeToan_User;
GO

-- ============================================================
-- 6. KIỂM TRA PHÂN QUYỀN (VÍ DỤ MINH HỌA)
-- ============================================================

-- Kiểm tra quyền của Lễ tân
EXECUTE AS USER = 'LeTan_User';
SELECT SUSER_SNAME() AS DangNhapVoiTuCach;
-- Thử đọc bảng DAT_SAN (ĐƯỢC)
SELECT TOP 1 * FROM DAT_SAN;
-- Thử đọc bảng THANH_TOAN (ĐƯỢC - chỉ xem)
SELECT TOP 1 * FROM THANH_TOAN;
-- Thử xóa DAT_SAN (BỊ TỪ CHỐI)
-- DELETE FROM DAT_SAN WHERE MaDatSan = 1; -- Sẽ báo lỗi
REVERT;
GO

-- Kiểm tra quyền của Chủ sân
EXECUTE AS USER = 'ChuSan_User';
SELECT SUSER_SNAME() AS DangNhapVoiTuCach;
-- Thử đọc báo cáo (ĐƯỢC)
SELECT TOP 1 * FROM DAT_SAN;
-- Thử sửa giá (BỊ TỪ CHỐI)
-- UPDATE BANG_GIA SET DonGia = 999999 WHERE MaGia = 1; -- Sẽ báo lỗi
REVERT;
GO

-- Kiểm tra quyền của Quản lý
EXECUTE AS USER = 'QuanLy_User';
SELECT SUSER_SNAME() AS DangNhapVoiTuCach;
-- Thử sửa giá (ĐƯỢC)
UPDATE BANG_GIA SET DonGia = DonGia WHERE MaGia = 1;
-- Thử xóa nhân viên (BỊ TỪ CHỐI)
-- DELETE FROM NHAN_VIEN WHERE MaNV = 1; -- Sẽ báo lỗi
REVERT;
GO

-- ============================================================
-- 7. BẢNG TỔNG HỢP PHÂN QUYỀN
-- ============================================================
SELECT 
    dp.name AS NguoiDung,
    r.name AS VaiTro,
    dp2.name AS Quyen,
    p.state_desc AS TrangThai,
    OBJECT_NAME(p.major_id) AS DoiTuong
FROM sys.database_permissions p
JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
JOIN sys.database_principals dp2 ON p.grantor_principal_id = dp2.principal_id
LEFT JOIN sys.database_role_members rm ON dp.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE dp.name IN ('LeTan_User', 'QuanLy_User', 'ChuSan_User', 'HLV_User', 'KeToan_User')
ORDER BY dp.name, p.state_desc;
GO

PRINT N'===== HOÀN TẤT PHÂN QUYỀN =====';
GO


