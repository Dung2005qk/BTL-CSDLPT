
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

CREATE TABLE KHO (
    MaKho   VARCHAR(10)    PRIMARY KEY,
    TenKho  NVARCHAR(100)  NOT NULL,
    KhuVuc  VARCHAR(2)     CHECK (KhuVuc IN ('MB', 'MT', 'MN')),
    DiaChi  NVARCHAR(255)
);
GO

INSERT INTO KHO (MaKho, TenKho, DiaChi, KhuVuc) VALUES
('K007', N'Kho TP.HCM 1', N'Quận 7, TP.HCM',     'MN'),
('K008', N'Kho TP.HCM 2', N'Thủ Đức, TP.HCM',    'MN'),
('K009', N'Kho Cần Thơ',  N'Ninh Kiều, Cần Thơ',  'MN');
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
('KH13', N'Mai Anh Tuấn',   N'Quận 1, TP.HCM',      '0903000001', 'MN'),
('KH14', N'Đỗ Thị Uyên',   N'Quận 3, TP.HCM',      '0903000002', 'MN'),
('KH15', N'Phan Văn Vinh',  N'Bình Thạnh, TP.HCM',  '0903000003', 'MN'),
('KH16', N'Hồ Ngọc Xuân',  N'Thủ Đức, TP.HCM',     '0903000004', 'MN'),
('KH17', N'Tô Minh Yến',   N'Quận 7, TP.HCM',      '0903000005', 'MN'),
('KH18', N'Châu Quốc Bảo', N'Ninh Kiều, Cần Thơ',  '0903000006', 'MN');
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
('K007', 'SP001', 45), ('K007', 'SP002', 95), ('K007', 'SP003', 110),
('K007', 'SP004', 30), ('K007', 'SP006', 50), ('K007', 'SP010', 90),
('K007', 'SP013', 70), ('K007', 'SP016', 350),('K007', 'SP021', 600),
('K007', 'SP027', 30),
('K008', 'SP005', 85), ('K008', 'SP007', 25), ('K008', 'SP008', 40),
('K008', 'SP011', 180),('K008', 'SP014', 55), ('K008', 'SP019', 130),
('K008', 'SP024', 40), ('K008', 'SP028', 60),
('K009', 'SP009', 50), ('K009', 'SP012', 90), ('K009', 'SP015', 15),
('K009', 'SP017', 200),('K009', 'SP020', 310),('K009', 'SP025', 170);
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
('DH031', 'KH13', '2026-03-02 08:30:00', N'Đã giao'),
('DH032', 'KH14', '2026-03-04 11:15:00', N'Đã giao'),
('DH033', 'KH15', '2026-03-07 09:40:00', N'Đã giao'),
('DH034', 'KH16', '2026-03-10 15:00:00', N'Đã giao'),
('DH035', 'KH17', '2026-03-13 10:25:00', N'Đã giao'),
('DH036', 'KH18', '2026-03-16 14:50:00', N'Đã giao'),
('DH037', 'KH13', '2026-03-19 08:10:00', N'Đã xác nhận'),
('DH038', 'KH14', '2026-03-21 16:35:00', N'Đã xác nhận'),
('DH039', 'KH15', '2026-04-03 09:15:00', N'Đã xác nhận'),
('DH040', 'KH16', '2026-04-06 13:00:00', N'Đã xác nhận'),
('DH041', 'KH17', '2026-04-09 08:40:00', N'Đang xử lý'),
('DH042', 'KH18', '2026-04-11 11:20:00', N'Đang xử lý'),
('DH043', 'KH13', '2026-04-13 15:55:00', N'Đang xử lý'),
('DH044', 'KH14', '2026-04-15 10:05:00', N'Đang xử lý'),
('DH045', 'KH15', '2026-04-17 14:30:00', N'Đang xử lý');
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
('DH031', 'SP001', 'K007', 1, 18500000),
('DH031', 'SP003', 'K007', 5, 1250000),
('DH032', 'SP002', 'K007', 2, 8990000),
('DH032', 'SP010', 'K007', 1, 320000),
('DH033', 'SP013', 'K007', 1, 2850000),
('DH033', 'SP016', 'K007', 10, 165000),
('DH034', 'SP006', 'K007', 2, 890000),
('DH034', 'SP011', 'K008', 5, 450000),
('DH035', 'SP004', 'K007', 1, 16900000),
('DH035', 'SP021', 'K007', 15, 5000),

('DH036', 'SP001', 'K001', 2, 18500000),
('DH036', 'SP027', 'K007', 1, 890000),
('DH037', 'SP007', 'K008', 1, 3200000),
('DH037', 'SP019', 'K008', 4, 95000),
('DH038', 'SP014', 'K008', 2, 1650000),
('DH038', 'SP024', 'K008', 1, 650000),

('DH039', 'SP005', 'K001', 3, 1350000),
('DH039', 'SP012', 'K009', 2, 1290000),
('DH040', 'SP008', 'K008', 1, 680000),
('DH040', 'SP020', 'K009', 5, 115000),
('DH041', 'SP015', 'K009', 1, 3200000),
('DH041', 'SP025', 'K009', 8, 25000),
('DH042', 'SP017', 'K009', 3, 145000),
('DH042', 'SP028', 'K008', 1, 280000),
('DH043', 'SP002', 'K007', 1, 8990000),
('DH043', 'SP009', 'K009', 3, 450000),
('DH044', 'SP003', 'K007', 4, 1250000),
('DH044', 'SP022', 'K009', 10, 18000),
('DH045', 'SP001', 'K001', 1, 18500000),
('DH045', 'SP016', 'K007', 8, 165000);
GO

PRINT N'=== KIỂM TRA DỮ LIỆU MÁY 3 (MIỀN NAM) ===';
SELECT 'DANHMUC' AS Bang, COUNT(*) AS SoBanGhi FROM DANHMUC
UNION ALL SELECT 'SP_PUBLIC', COUNT(*) FROM SP_PUBLIC
UNION ALL SELECT 'KHO', COUNT(*) FROM KHO
UNION ALL SELECT 'KHACHHANG', COUNT(*) FROM KHACHHANG
UNION ALL SELECT 'TONKHO', COUNT(*) FROM TONKHO
UNION ALL SELECT 'DONHANG', COUNT(*) FROM DONHANG
UNION ALL SELECT 'CHITIETDONHANG', COUNT(*) FROM CHITIETDONHANG;
GO
