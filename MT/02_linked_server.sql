
USE master;
GO

IF EXISTS (SELECT * FROM sys.servers WHERE name = 'S1_MB')
    EXEC sp_dropserver @server = 'S1_MB', @droplogins = 'droplogins';
IF EXISTS (SELECT * FROM sys.servers WHERE name = 'S3_MN')
    EXEC sp_dropserver @server = 'S3_MN', @droplogins = 'droplogins';
GO

EXEC master.dbo.sp_addlinkedserver
    @server = N'S1_MB', @srvproduct = N'SQLServer',
    @provider = N'MSOLEDBSQL', @datasrc = N'LAPTOP-M3FKU757',
    @provstr = N'Encrypt=yes;TrustServerCertificate=yes;';
GO
EXEC master.dbo.sp_addlinkedsrvlogin
    @rmtsrvname = N'S1_MB', @useself = N'False',
    @locallogin = NULL, @rmtuser = N'sa', @rmtpassword = N'Dung2005@';
GO
EXEC sp_serveroption @server = N'S1_MB', @optname = N'rpc', @optvalue = N'true';
EXEC sp_serveroption @server = N'S1_MB', @optname = N'rpc out', @optvalue = N'true';
GO

EXEC master.dbo.sp_addlinkedserver
    @server = N'S3_MN', @srvproduct = N'SQLServer',
    @provider = N'MSOLEDBSQL', @datasrc = N'LAPTOP-UD52TRL3',
    @provstr = N'Encrypt=yes;TrustServerCertificate=yes;';
GO
EXEC master.dbo.sp_addlinkedsrvlogin
    @rmtsrvname = N'S3_MN', @useself = N'False',
    @locallogin = NULL, @rmtuser = N'sa', @rmtpassword = N'1234';
GO
EXEC sp_serveroption @server = N'S3_MN', @optname = N'rpc', @optvalue = N'true';
EXEC sp_serveroption @server = N'S3_MN', @optname = N'rpc out', @optvalue = N'true';
GO

PRINT N'=== TEST LINKED SERVER TỪ MÁY 2 ===';
SELECT * FROM [S1_MB].[CSDLPT].[dbo].[KHO];
SELECT * FROM [S3_MN].[CSDLPT].[dbo].[KHO];
PRINT N'=== OK ===';
GO
