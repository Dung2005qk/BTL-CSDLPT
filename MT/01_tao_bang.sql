
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
('K004', N'Kho Đà Nẵng 1',  N'Hải Châu, Đà Nẵng',  'MT'),
('K005', N'Kho Đà Nẵng 2',  N'Thanh Khê, Đà Nẵng', 'MT'),
('K006', N'Kho Huế',         N'Phú Hội, Tp. Huế',   'MT');
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
('KH07', N'Đặng Văn Khoa',    N'Hải Châu, Đà Nẵng',      '0902000001', 'MT'),
('KH08', N'Bùi Thị Linh',     N'Sơn Trà, Đà Nẵng',       '0902000002', 'MT'),
('KH09', N'Ngô Quốc Minh',    N'Thanh Khê, Đà Nẵng',     '0902000003', 'MT'),
('KH10', N'Trịnh Hồng Nhung', N'Phú Hội, Tp. Huế',       '0902000004', 'MT'),
('KH11', N'Cao Văn Phú',      N'Liên Chiểu, Đà Nẵng',    '0902000005', 'MT'),
('KH12', N'Lý Thanh Quang',   N'Ngũ Hành Sơn, Đà Nẵng',  '0902000006', 'MT');
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
('K004', 'SP001', 35), ('K004', 'SP002', 55), ('K004', 'SP003', 90),
('K004', 'SP006', 70), ('K004', 'SP010', 110),('K004', 'SP014', 45),
('K004', 'SP016', 220),('K004', 'SP019', 160),('K004', 'SP024', 30),
('K004', 'SP029', 85),
('K005', 'SP004', 20), ('K005', 'SP007', 40), ('K005', 'SP008', 65),
('K005', 'SP011', 150),('K005', 'SP015', 20), ('K005', 'SP020', 280),
('K005', 'SP025', 200),('K005', 'SP030', 50),
('K006', 'SP005', 75), ('K006', 'SP009', 60), ('K006', 'SP012', 80),
('K006', 'SP017', 140),('K006', 'SP022', 320),('K006', 'SP026', 35);
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
('DH016', 'KH07', '2026-03-01 10:00:00', N'Đã giao'),
('DH017', 'KH08', '2026-03-03 09:20:00', N'Đã giao'),
('DH018', 'KH09', '2026-03-06 14:15:00', N'Đã giao'),
('DH019', 'KH10', '2026-03-09 11:30:00', N'Đã giao'),
('DH020', 'KH11', '2026-03-11 08:45:00', N'Đã giao'),
('DH021', 'KH12', '2026-03-14 16:20:00', N'Đã giao'),
('DH022', 'KH07', '2026-03-17 10:10:00', N'Đã xác nhận'),
('DH023', 'KH08', '2026-03-19 13:40:00', N'Đã xác nhận'),
('DH024', 'KH09', '2026-04-02 09:00:00', N'Đã xác nhận'),
('DH025', 'KH10', '2026-04-04 15:30:00', N'Đã xác nhận'),
('DH026', 'KH11', '2026-04-07 08:15:00', N'Đang xử lý'),
('DH027', 'KH12', '2026-04-09 12:00:00', N'Đang xử lý'),
('DH028', 'KH07', '2026-04-12 14:45:00', N'Đang xử lý'),
('DH029', 'KH08', '2026-04-14 10:20:00', N'Đang xử lý'),
('DH030', 'KH09', '2026-04-16 16:30:00', N'Đang xử lý');
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
('DH016', 'SP001', 'K004', 1, 18500000),
('DH016', 'SP003', 'K004', 4, 1250000),
('DH017', 'SP010', 'K004', 2, 320000),
('DH017', 'SP019', 'K004', 3, 95000),
('DH018', 'SP014', 'K004', 1, 1650000),
('DH018', 'SP011', 'K005', 3, 450000),
('DH019', 'SP006', 'K004', 2, 890000),
('DH019', 'SP016', 'K004', 8, 165000),
('DH020', 'SP007', 'K005', 1, 3200000),
('DH020', 'SP025', 'K005', 5, 25000),
('DH021', 'SP012', 'K006', 2, 1290000),
('DH021', 'SP029', 'K004', 3, 95000),
('DH022', 'SP002', 'K004', 2, 8990000),
('DH022', 'SP020', 'K005', 4, 115000),
('DH023', 'SP004', 'K005', 1, 16900000),
('DH023', 'SP024', 'K004', 2, 650000),
('DH024', 'SP008', 'K005', 1, 680000),
('DH024', 'SP017', 'K006', 4, 145000),
('DH025', 'SP015', 'K005', 1, 3200000),
('DH025', 'SP022', 'K006', 8, 18000),
('DH026', 'SP003', 'K004', 3, 1250000),
('DH026', 'SP030', 'K005', 2, 180000),
('DH027', 'SP009', 'K006', 2, 450000),
('DH027', 'SP026', 'K006', 1, 350000),
('DH028', 'SP001', 'K004', 1, 18500000),
('DH028', 'SP005', 'K006', 2, 1350000),
('DH029', 'SP010', 'K004', 3, 320000),
('DH029', 'SP011', 'K005', 2, 450000),
('DH030', 'SP016', 'K004', 6, 165000),
('DH030', 'SP019', 'K004', 5, 95000);
GO

PRINT N'=== KIỂM TRA DỮ LIỆU MÁY 2 (MIỀN TRUNG) ===';
SELECT 'DANHMUC' AS Bang, COUNT(*) AS SoBanGhi FROM DANHMUC
UNION ALL SELECT 'SP_PUBLIC', COUNT(*) FROM SP_PUBLIC
UNION ALL SELECT 'KHO', COUNT(*) FROM KHO
UNION ALL SELECT 'KHACHHANG', COUNT(*) FROM KHACHHANG
UNION ALL SELECT 'TONKHO', COUNT(*) FROM TONKHO
UNION ALL SELECT 'DONHANG', COUNT(*) FROM DONHANG
UNION ALL SELECT 'CHITIETDONHANG', COUNT(*) FROM CHITIETDONHANG;
GO
