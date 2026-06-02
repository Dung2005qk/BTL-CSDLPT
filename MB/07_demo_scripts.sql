
USE CSDLPT;
GO

PRINT N'';
PRINT N'════════════════════════════════════════════════════════';
PRINT N'  BƯỚC 1: TÍNH TRONG SUỐT VỊ TRÍ';
PRINT N'  Người dùng không cần biết dữ liệu nằm ở đâu';
PRINT N'════════════════════════════════════════════════════════';
PRINT N'';

PRINT N'→ SELECT * FROM V_KHO (9 kho từ 3 máy):';
SELECT * FROM V_KHO;

PRINT N'';
PRINT N'→ Tồn kho SP001 trên toàn hệ thống:';
SELECT K.TenKho, K.KhuVuc, T.SoLuongTon
FROM V_TONKHO T
    INNER JOIN V_KHO K ON T.MaKho = K.MaKho COLLATE DATABASE_DEFAULT
WHERE T.MaSP = 'SP001';

PRINT N'';
PRINT N'→ Tổng số bản ghi toàn hệ thống:';
SELECT 'Kho' AS [Bảng], COUNT(*) AS [Tổng] FROM V_KHO
UNION ALL SELECT 'Khách hàng', COUNT(*) FROM V_KHACHHANG
UNION ALL SELECT 'Tồn kho', COUNT(*) FROM V_TONKHO
UNION ALL SELECT 'Đơn hàng', COUNT(*) FROM V_DONHANG
UNION ALL SELECT 'Chi tiết ĐH', COUNT(*) FROM V_CHITIETDONHANG;
GO

PRINT N'';
PRINT N'════════════════════════════════════════════════════════';
PRINT N'  BƯỚC 2: TỐI ƯU TRUY VẤN PHÂN TÁN';
PRINT N'════════════════════════════════════════════════════════';
PRINT N'';

PRINT N'→ TV1: Truy vấn hoàn toàn cục bộ (chỉ S1):';
SELECT P.TenSP, P.GiaBan, T.SoLuongTon
FROM SP_PUBLIC P
    INNER JOIN TONKHO T ON P.MaSP = T.MaSP
    INNER JOIN KHO K ON T.MaKho = K.MaKho
WHERE K.MaKho = 'K001' AND P.MaDM = 'DM01';

PRINT N'';
PRINT N'→ TV4: Doanh thu theo khu vực (GROUP BY 2 giai đoạn):';
SELECT KhuVuc, SUM(DoanhThu) AS TongDoanhThu FROM (
    SELECT 'MB' AS KhuVuc, SUM(CT.SoLuong * CT.DonGia) AS DoanhThu
    FROM CHITIETDONHANG CT
    UNION ALL
    SELECT 'MT', SUM(CT.SoLuong * CT.DonGia)
    FROM [S2_MT].[CSDLPT].[dbo].[CHITIETDONHANG] CT
    UNION ALL
    SELECT 'MN', SUM(CT.SoLuong * CT.DonGia)
    FROM [S3_MN].[CSDLPT].[dbo].[CHITIETDONHANG] CT
) AS T GROUP BY KhuVuc ORDER BY TongDoanhThu DESC;
GO

PRINT N'';
PRINT N'════════════════════════════════════════════════════════';
PRINT N'  BƯỚC 3: KHÓA HAI PHA CỤC BỘ (S2PL)';
PRINT N'════════════════════════════════════════════════════════';
PRINT N'';

GO

PRINT N'';
PRINT N'════════════════════════════════════════════════════════';
PRINT N'  BƯỚC 4: GIAO THỨC CAM KẾT HAI PHA (2PC)';
PRINT N'════════════════════════════════════════════════════════';
PRINT N'';

PRINT N'→ 4a: Reset SP001: S1=4, S2=6';
UPDATE TONKHO SET SoLuongTon = 4 WHERE MaSP = 'SP001' AND MaKho = 'K001';
UPDATE [S2_MT].[CSDLPT].[dbo].[TONKHO] SET SoLuongTon = 6 WHERE MaSP = 'SP001' AND MaKho = 'K004';

SELECT 'S1-K001' AS Kho, SoLuongTon FROM TONKHO WHERE MaSP = 'SP001' AND MaKho = 'K001'
UNION ALL
SELECT 'S2-K004', SoLuongTon FROM [S2_MT].[CSDLPT].[dbo].[TONKHO] WHERE MaSP = 'SP001' AND MaKho = 'K004';
GO

PRINT N'→ 4b: Đặt 10 chiếc SP001 (S1 chỉ có 4 → cần lấy 6 từ S2)';
PRINT N'   KHÔNG ngắt mạng → phải thành công';

GO

GO

PRINT N'→ 4d: Đặt 10 chiếc SP001 + NGẮT MẠNG Máy 2 trong 8 giây';
PRINT N'   → COMMIT sẽ thất bại → Global Abort';
PRINT N'   → Kiểm tra: S1 vẫn = 4';

GO

PRINT N'→ 4e: Kiểm tra tồn kho sau Global Abort:';
SELECT 'S1-K001' AS Kho, SoLuongTon FROM TONKHO WHERE MaSP = 'SP001' AND MaKho = 'K001';

GO
