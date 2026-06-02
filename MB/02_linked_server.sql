
USE master;
GO

IF EXISTS (SELECT * FROM sys.servers WHERE name = 'S2_MT')
    EXEC sp_dropserver @server = 'S2_MT', @droplogins = 'droplogins';
IF EXISTS (SELECT * FROM sys.servers WHERE name = 'S3_MN')
    EXEC sp_dropserver @server = 'S3_MN', @droplogins = 'droplogins';
GO

EXEC master.dbo.sp_addlinkedserver
    @server = N'S2_MT',
    @srvproduct = N'SQLServer',
    @provider = N'MSOLEDBSQL',
    @datasrc = N'DESKTOP-Q5G45CD',
    @provstr = N'Encrypt=yes;TrustServerCertificate=yes;';
GO

EXEC master.dbo.sp_addlinkedsrvlogin
    @rmtsrvname = N'S2_MT',
    @useself = N'False',
    @locallogin = NULL,
    @rmtuser = N'sa',
    @rmtpassword = N'123456789';
GO

EXEC sp_serveroption @server = N'S2_MT', @optname = N'rpc', @optvalue = N'true';
EXEC sp_serveroption @server = N'S2_MT', @optname = N'rpc out', @optvalue = N'true';
GO

EXEC master.dbo.sp_addlinkedserver
    @server = N'S3_MN',
    @srvproduct = N'SQLServer',
    @provider = N'MSOLEDBSQL',
    @datasrc = N'LAPTOP-UD52TRL3',
    @provstr = N'Encrypt=yes;TrustServerCertificate=yes;';
GO

EXEC master.dbo.sp_addlinkedsrvlogin
    @rmtsrvname = N'S3_MN',
    @useself = N'False',
    @locallogin = NULL,
    @rmtuser = N'sa',
    @rmtpassword = N'1234';
GO

EXEC sp_serveroption @server = N'S3_MN', @optname = N'rpc', @optvalue = N'true';
EXEC sp_serveroption @server = N'S3_MN', @optname = N'rpc out', @optvalue = N'true';
GO

PRINT N'=== TEST KẾT NỐI LINKED SERVER ===';
PRINT N'--- S2_MT (Miền Trung) ---';
SELECT * FROM [S2_MT].[CSDLPT].[dbo].[KHO];
PRINT N'--- S3_MN (Miền Nam) ---';
SELECT * FROM [S3_MN].[CSDLPT].[dbo].[KHO];
PRINT N'=== KẾT NỐI THÀNH CÔNG! ===';
GO
