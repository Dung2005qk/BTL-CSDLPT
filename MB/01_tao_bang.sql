
IF DB_ID('CSDLPT') IS NOT NULL
BEGIN
    ALTER DATABASE CSDLPT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CSDLPT;
END
GO
CREATE DATABASE CSDLPT;
GO
USE CSDLPT;
GO

CREATE TABLE DANHMUC (
    MaDM    VARCHAR(10)    PRIMARY KEY,
    TenDM   NVARCHAR(100)  NOT NULL,
    MoTa    NVARCHAR(255)
);
GO

INSERT INTO DANHMUC (MaDM, TenDM) VALUES
('DM01', N'Điện tử'),
('DM02', N'Gia dụng'),
('DM03', N'Thời trang'),
('DM04', N'Thực phẩm'),
('DM05', N'Văn phòng phẩm'),
('DM06', N'Thể thao');
GO

CREATE TABLE SP_PUBLIC (
    MaSP    VARCHAR(10)    PRIMARY KEY,
    TenSP   NVARCHAR(100)  NOT NULL,
    GiaBan  DECIMAL(18, 2) CHECK (GiaBan > 0),
    MaDM    VARCHAR(10),
    FOREIGN KEY (MaDM) REFERENCES DANHMUC(MaDM)
);
GO

INSERT INTO SP_PUBLIC (MaSP, TenSP, MaDM, GiaBan) VALUES
('SP001', N'Laptop Dell Vostro 15',       'DM01', 18500000),
('SP002', N'Điện thoại Samsung Galaxy A54','DM01', 8990000),
('SP003', N'Tai nghe Bluetooth Sony',      'DM01', 1250000),
('SP004', N'Máy tính bảng iPad Air',       'DM01', 16900000),
('SP005', N'Ổ cứng di động WD 1TB',        'DM01', 1350000),
('SP006', N'Nồi cơm điện Sharp 1.8L',      'DM02', 890000),
('SP007', N'Quạt điều hòa Kangaroo',       'DM02', 3200000),
('SP008', N'Bàn ủi hơi nước Philips',      'DM02', 680000),
('SP009', N'Máy xay sinh tố Sunhouse',     'DM02', 450000),
('SP010', N'Bình đun siêu tốc Midea',      'DM02', 320000),
('SP011', N'Áo sơ mi nam Owen',            'DM03', 450000),
('SP012', N'Quần jean nữ Levi''s',         'DM03', 1290000),
('SP013', N'Giày thể thao Nike Air',       'DM03', 2850000),
('SP014', N'Túi xách nữ Charles',          'DM03', 1650000),
('SP015', N'Kính mát Rayban',              'DM03', 3200000),
('SP016', N'Gạo ST25 túi 5kg',            'DM04', 165000),
('SP017', N'Dầu ăn Tường An 5L',          'DM04', 145000),
('SP018', N'Sữa tươi TH True Milk 1L',    'DM04', 32000),
('SP019', N'Cà phê Trung Nguyên 500g',    'DM04', 95000),
('SP020', N'Mì Hảo Hảo thùng 30 gói',    'DM04', 115000),
('SP021', N'Bút bi Thiên Long TL-027',    'DM05', 5000),
('SP022', N'Vở Campus 200 trang',         'DM05', 18000),
('SP023', N'Bìa hồ sơ nhựa A4',          'DM05', 12000),
('SP024', N'Máy tính Casio fx-580VN',     'DM05', 650000),
('SP025', N'Kéo văn phòng Deli 170mm',    'DM05', 25000),
('SP026', N'Bóng đá Mikasa size 5',       'DM06', 350000),
('SP027', N'Vợt cầu lông Yonex',          'DM06', 890000),
('SP028', N'Thảm tập yoga TPE 6mm',       'DM06', 280000),
('SP029', N'Bình nước thể thao 750ml',    'DM06', 95000),
('SP030', N'Găng tay tập gym',            'DM06', 180000);
GO

CREATE TABLE SP_DETAIL (
    MaSP    VARCHAR(10)    PRIMARY KEY,
    MoTa    NVARCHAR(MAX)
);
GO

INSERT INTO SP_DETAIL (MaSP, MoTa) VALUES
('SP001', N'Laptop văn phòng 15.6 inch, Core i5, 8GB RAM, 256GB SSD'),
('SP002', N'Màn hình 6.4 inch, 128GB, camera 50MP'),
('SP003', N'Chống ồn chủ động, pin 30 giờ'),
('SP004', N'Chip M1, màn hình 10.9 inch'),
('SP005', N'USB 3.0, nhỏ gọn, bảo hành 3 năm'),
('SP006', N'Lòng nồi chống dính, nấu nhanh'),
('SP007', N'Công suất 120W, bình 45 lít'),
('SP008', N'Mặt đế chống dính, 2000W'),
('SP009', N'Cối thủy tinh 1.5L, 2 tốc độ'),
('SP010', N'Dung tích 1.7L, inox 304'),
('SP011', N'Vải cotton, form regular, nhiều màu'),
('SP012', N'Dáng slim fit, vải co giãn'),
('SP013', N'Đệm khí Air Max, đế cao su'),
('SP014', N'Da tổng hợp cao cấp, quai kim loại'),
('SP015', N'Tròng phân cực, gọng kim loại'),
('SP016', N'Gạo ngon nhất thế giới, dẻo thơm'),
('SP017', N'Dầu thực vật tinh luyện'),
('SP018', N'Sữa tươi tiệt trùng, ít đường'),
('SP019', N'Cà phê rang xay, hương vị đậm'),
('SP020', N'Mì tôm chua cay, thùng tiết kiệm'),
('SP021', N'Mực xanh, nét mảnh 0.5mm'),
('SP022', N'Giấy trắng, kẻ ngang'),
('SP023', N'Nhựa PP trong suốt, bền'),
('SP024', N'521 chức năng, giải phương trình'),
('SP025', N'Thép không gỉ, tay cầm nhựa'),
('SP026', N'Da PU chống nước, đạt chuẩn FIFA'),
('SP027', N'Khung carbon, trọng lượng 85g'),
('SP028', N'Chống trượt 2 mặt, không mùi'),
('SP029', N'Inox 304, giữ nhiệt 12 giờ'),
('SP030', N'Da tổng hợp, đệm lòng bàn tay');
GO

CREATE TABLE KHO (
    MaKho   VARCHAR(10)    PRIMARY KEY,
    TenKho  NVARCHAR(100)  NOT NULL,
    KhuVuc  VARCHAR(2)     CHECK (KhuVuc IN ('MB', 'MT', 'MN')),
    DiaChi  NVARCHAR(255)
);
GO

INSERT INTO KHO (MaKho, TenKho, DiaChi, KhuVuc) VALUES
('K001', N'Kho Hà Nội 1',  N'Cầu Giấy, Hà Nội',  'MB'),
('K002', N'Kho Hà Nội 2',  N'Long Biên, Hà Nội',  'MB'),
('K003', N'Kho Hải Phòng', N'Lê Chân, Hải Phòng', 'MB');
GO

CREATE TABLE KHACHHANG (
    MaKH        VARCHAR(10)    PRIMARY KEY,
    TenKH       NVARCHAR(100)  NOT NULL,
    KhuVuc      VARCHAR(2)     CHECK (KhuVuc IN ('MB', 'MT', 'MN')),
    DiaChi      NVARCHAR(255),
    SoDienThoai VARCHAR(15)
);
GO

INSERT INTO KHACHHANG (MaKH, TenKH, DiaChi, SoDienThoai, KhuVuc) VALUES
('KH01', N'Nguyễn Văn An',   N'Ba Đình, Hà Nội',      '0901000001', 'MB'),
('KH02', N'Trần Thị Bình',   N'Đống Đa, Hà Nội',      '0901000002', 'MB'),
('KH03', N'Lê Hoàng Cường',  N'Ngô Quyền, Hải Phòng', '0901000003', 'MB'),
('KH04', N'Phạm Minh Đức',   N'Thanh Xuân, Hà Nội',    '0901000004', 'MB'),
('KH05', N'Hoàng Thị Giang', N'Cầu Giấy, Hà Nội',     '0901000005', 'MB'),
('KH06', N'Vũ Đình Hải',     N'Lê Chân, Hải Phòng',    '0901000006', 'MB');
GO

CREATE TABLE TONKHO (
    MaKho       VARCHAR(10),
    MaSP        VARCHAR(10),
    SoLuongTon  INT          CHECK (SoLuongTon >= 0),
    PRIMARY KEY (MaKho, MaSP),
    FOREIGN KEY (MaKho) REFERENCES KHO(MaKho),
    FOREIGN KEY (MaSP)  REFERENCES SP_PUBLIC(MaSP)
);
GO

INSERT INTO TONKHO (MaKho, MaSP, SoLuongTon) VALUES
('K001', 'SP001', 50), ('K001', 'SP002', 80), ('K001', 'SP003', 120),
('K001', 'SP004', 25), ('K001', 'SP005', 90), ('K001', 'SP006', 60),
('K001', 'SP011', 200),('K001', 'SP016', 300),('K001', 'SP021', 500),
('K001', 'SP026', 40),
('K002', 'SP001', 30), ('K002', 'SP002', 45), ('K002', 'SP007', 35),
('K002', 'SP008', 55), ('K002', 'SP012', 100),('K002', 'SP017', 180),
('K002', 'SP022', 400),('K002', 'SP027', 25),
('K003', 'SP003', 70), ('K003', 'SP009', 80), ('K003', 'SP013', 60),
('K003', 'SP018', 250),('K003', 'SP023', 350),('K003', 'SP028', 45);
GO

CREATE TABLE DONHANG (
    MaDH       VARCHAR(20)   PRIMARY KEY,
    MaKH       VARCHAR(10),
    NgayLap    DATETIME      DEFAULT CURRENT_TIMESTAMP,
    TrangThai  NVARCHAR(50)  DEFAULT N'ChoXuLy',
    FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH)
);
GO

INSERT INTO DONHANG (MaDH, MaKH, NgayLap, TrangThai) VALUES
('DH001', 'KH01', '2026-03-01 09:15:00', N'Đã giao'),
('DH002', 'KH02', '2026-03-02 14:30:00', N'Đã giao'),
('DH003', 'KH03', '2026-03-05 10:00:00', N'Đã giao'),
('DH004', 'KH01', '2026-03-08 16:45:00', N'Đã giao'),
('DH005', 'KH04', '2026-03-10 08:20:00', N'Đã giao'),
('DH006', 'KH05', '2026-03-12 11:00:00', N'Đã giao'),
('DH007', 'KH06', '2026-03-15 13:30:00', N'Đã giao'),
('DH008', 'KH02', '2026-03-18 09:45:00', N'Đã xác nhận'),
('DH009', 'KH03', '2026-03-20 15:10:00', N'Đã xác nhận'),
('DH010', 'KH01', '2026-04-01 10:30:00', N'Đã xác nhận'),
('DH011', 'KH04', '2026-04-05 08:00:00', N'Đã xác nhận'),
('DH012', 'KH05', '2026-04-08 14:20:00', N'Đang xử lý'),
('DH013', 'KH06', '2026-04-10 16:00:00', N'Đang xử lý'),
('DH014', 'KH01', '2026-04-15 09:30:00', N'Đang xử lý'),
('DH015', 'KH02', '2026-04-17 11:45:00', N'Đang xử lý');
GO

CREATE TABLE CHITIETDONHANG (
    MaDH       VARCHAR(20),
    MaSP       VARCHAR(10),
    MaKhoXuat  VARCHAR(10),
    SoLuong    INT           CHECK (SoLuong > 0),
    DonGia     DECIMAL(18, 2) CHECK (DonGia >= 0),
    PRIMARY KEY (MaDH, MaSP, MaKhoXuat),
    FOREIGN KEY (MaDH) REFERENCES DONHANG(MaDH),
    FOREIGN KEY (MaSP) REFERENCES SP_PUBLIC(MaSP)
);
GO

INSERT INTO CHITIETDONHANG (MaDH, MaSP, MaKhoXuat, SoLuong, DonGia) VALUES
('DH001', 'SP001', 'K001', 2, 18500000),
('DH001', 'SP003', 'K001', 3, 1250000),
('DH002', 'SP002', 'K001', 1, 8990000),
('DH002', 'SP016', 'K001', 5, 165000),
('DH003', 'SP013', 'K003', 2, 2850000),
('DH003', 'SP011', 'K001', 4, 450000),
('DH004', 'SP005', 'K001', 3, 1350000),
('DH004', 'SP021', 'K001', 10, 5000),
('DH005', 'SP006', 'K001', 1, 890000),
('DH005', 'SP008', 'K002', 2, 680000),
('DH006', 'SP004', 'K001', 1, 16900000),
('DH006', 'SP022', 'K002', 5, 18000),
('DH007', 'SP007', 'K002', 1, 3200000),
('DH007', 'SP009', 'K003', 2, 450000),
('DH008', 'SP001', 'K002', 1, 18500000),
('DH008', 'SP026', 'K001', 3, 350000),
('DH009', 'SP012', 'K002', 2, 1290000),
('DH009', 'SP018', 'K003', 6, 32000),
('DH010', 'SP002', 'K001', 2, 8990000),
('DH010', 'SP017', 'K002', 3, 145000),
('DH011', 'SP003', 'K001', 5, 1250000),
('DH011', 'SP027', 'K002', 1, 890000),
('DH012', 'SP001', 'K001', 1, 18500000),
('DH012', 'SP011', 'K001', 3, 450000),
('DH013', 'SP016', 'K001', 10, 165000),
('DH013', 'SP023', 'K003', 20, 12000),
('DH014', 'SP002', 'K001', 1, 8990000),
('DH014', 'SP028', 'K003', 2, 280000),
('DH015', 'SP005', 'K001', 2, 1350000),
('DH015', 'SP006', 'K001', 1, 890000);
GO

PRINT N'=== KIỂM TRA DỮ LIỆU MÁY 1 (MIỀN BẮC) ===';
SELECT 'DANHMUC' AS Bang, COUNT(*) AS SoBanGhi FROM DANHMUC
UNION ALL SELECT 'SP_PUBLIC', COUNT(*) FROM SP_PUBLIC
UNION ALL SELECT 'SP_DETAIL', COUNT(*) FROM SP_DETAIL
UNION ALL SELECT 'KHO', COUNT(*) FROM KHO
UNION ALL SELECT 'KHACHHANG', COUNT(*) FROM KHACHHANG
UNION ALL SELECT 'TONKHO', COUNT(*) FROM TONKHO
UNION ALL SELECT 'DONHANG', COUNT(*) FROM DONHANG
UNION ALL SELECT 'CHITIETDONHANG', COUNT(*) FROM CHITIETDONHANG;
GO
