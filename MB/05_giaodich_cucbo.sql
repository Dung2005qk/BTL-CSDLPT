
USE CSDLPT;
GO

IF OBJECT_ID('sp_DatHang_CucBo_Demo', 'P') IS NOT NULL
    DROP PROCEDURE sp_DatHang_CucBo_Demo;
GO

CREATE PROCEDURE sp_DatHang_CucBo_Demo
    @MaKH    VARCHAR(10),
    @MaSP    VARCHAR(10),
    @SoLuong INT,
    @MaKho   VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TonHienTai INT;
    DECLARE @MaDH VARCHAR(20);
    DECLARE @DonGia DECIMAL(18, 2);

    BEGIN TRANSACTION;
    BEGIN TRY

        SELECT @TonHienTai = SoLuongTon
        FROM TONKHO WITH (UPDLOCK, HOLDLOCK)
        WHERE MaSP = @MaSP AND MaKho = @MaKho;


        WAITFOR DELAY '00:00:10';

        IF @TonHienTai IS NULL OR @TonHienTai < @SoLuong
        BEGIN
            ROLLBACK;
            RAISERROR(N'Không đủ tồn kho tại kho %s. Hiện có: %d, Cần: %d',
                       16, 1, @MaKho, @TonHienTai, @SoLuong);
            RETURN;
        END

        UPDATE TONKHO
        SET SoLuongTon = SoLuongTon - @SoLuong
        WHERE MaSP = @MaSP AND MaKho = @MaKho;

        SET @MaDH = 'DH' + FORMAT(GETDATE(), 'yyMMddHHmmssfff');
        SELECT @DonGia = GiaBan FROM SP_PUBLIC WHERE MaSP = @MaSP;

        INSERT INTO DONHANG (MaDH, MaKH, NgayLap, TrangThai)
        VALUES (@MaDH, @MaKH, GETDATE(), N'Đã xác nhận');

        INSERT INTO CHITIETDONHANG (MaDH, MaSP, MaKhoXuat, SoLuong, DonGia)
        VALUES (@MaDH, @MaSP, @MaKho, @SoLuong, @DonGia);

        COMMIT;

        PRINT N'';
        PRINT N' ĐẶT HÀNG CỤC BỘ THÀNH CÔNG!';
        PRINT N'   Mã đơn: ' + @MaDH;
        PRINT N'   Tồn kho mới: ' + CAST(@TonHienTai - @SoLuong AS VARCHAR);
        PRINT N'   Khóa wl đã được giải phóng.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT N' LỖI: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
