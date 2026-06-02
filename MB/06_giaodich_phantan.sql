
USE CSDLPT;
GO

IF OBJECT_ID('sp_DatHang_LienKho', 'P') IS NOT NULL
    DROP PROCEDURE sp_DatHang_LienKho;
GO

CREATE PROCEDURE sp_DatHang_LienKho
    @MaKH        VARCHAR(10),
    @MaSP        VARCHAR(10),
    @TongSoLuong INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @TonS1 INT, @TonS2 INT;
    DECLARE @LayS1 INT, @LayS2 INT;
    DECLARE @MaKhoS1 VARCHAR(10), @MaKhoS2 VARCHAR(10);
    DECLARE @MaDH VARCHAR(20), @DonGia DECIMAL(18, 2);

    BEGIN DISTRIBUTED TRANSACTION;
    BEGIN TRY

        SELECT TOP 1 @MaKhoS1 = MaKho FROM KHO;

        SELECT @TonS1 = ISNULL(SoLuongTon, 0)
        FROM TONKHO WITH (UPDLOCK, HOLDLOCK)
        WHERE MaSP = @MaSP AND MaKho = @MaKhoS1;

        SET @LayS1 = CASE
            WHEN @TonS1 >= @TongSoLuong THEN @TongSoLuong
            ELSE @TonS1
        END;
        SET @LayS2 = @TongSoLuong - @LayS1;

        PRINT N'📦 Kho S1 (' + @MaKhoS1 + N'): Tồn='
              + CAST(@TonS1 AS VARCHAR) + N', Lấy=' + CAST(@LayS1 AS VARCHAR);

        IF @LayS1 > 0
            UPDATE TONKHO
            SET SoLuongTon = SoLuongTon - @LayS1
            WHERE MaSP = @MaSP AND MaKho = @MaKhoS1;

        IF @LayS2 > 0
        BEGIN
            SELECT TOP 1 @MaKhoS2 = MaKho
            FROM [S2_MT].[CSDLPT].[dbo].[KHO];

            SELECT @TonS2 = ISNULL(SoLuongTon, 0)
            FROM [S2_MT].[CSDLPT].[dbo].[TONKHO]
            WHERE MaSP = @MaSP AND MaKho = @MaKhoS2;

            PRINT N'📦 Kho S2 (' + @MaKhoS2 + N'): Tồn='
                  + CAST(@TonS2 AS VARCHAR) + N', Cần=' + CAST(@LayS2 AS VARCHAR);

            IF @TonS2 < @LayS2
            BEGIN
                ROLLBACK TRAN;
                RAISERROR(N'S2 không đủ tồn kho. Tồn=%d, Cần=%d',
                           16, 1, @TonS2, @LayS2);
                RETURN;
            END

            UPDATE [S2_MT].[CSDLPT].[dbo].[TONKHO]
            SET SoLuongTon = SoLuongTon - @LayS2
            WHERE MaSP = @MaSP AND MaKho = @MaKhoS2;
        END

        SET @MaDH = 'DH' + FORMAT(GETDATE(), 'yyMMddHHmmssfff');
        SELECT @DonGia = GiaBan FROM SP_PUBLIC WHERE MaSP = @MaSP;

        INSERT INTO DONHANG (MaDH, MaKH, NgayLap, TrangThai)
        VALUES (@MaDH, @MaKH, GETDATE(), N'Đã xác nhận');

        IF @LayS1 > 0
            INSERT INTO CHITIETDONHANG (MaDH, MaSP, MaKhoXuat, SoLuong, DonGia)
            VALUES (@MaDH, @MaSP, @MaKhoS1, @LayS1, @DonGia);
        IF @LayS2 > 0
            INSERT INTO CHITIETDONHANG (MaDH, MaSP, MaKhoXuat, SoLuong, DonGia)
            VALUES (@MaDH, @MaSP, @MaKhoS2, @LayS2, @DonGia);



        WAITFOR DELAY '00:00:08';

        COMMIT TRAN;

        PRINT N'';
        PRINT N' ĐẶT HÀNG LIÊN KHO THÀNH CÔNG!';
        PRINT N'   Mã đơn: ' + @MaDH;
        PRINT N'   Lấy từ S1 (' + @MaKhoS1 + N'): ' + CAST(@LayS1 AS VARCHAR);
        IF @LayS2 > 0
            PRINT N'   Lấy từ S2 (' + @MaKhoS2 + N'): ' + CAST(@LayS2 AS VARCHAR);
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK TRAN;


        THROW;
    END CATCH
END;
GO
