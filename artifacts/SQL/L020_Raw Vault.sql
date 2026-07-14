-- RawVaultHeader
USE [master];
GO
IF DB_ID(N'{productlaunchevent#rawvault#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{productlaunchevent#rawvault#database_name}];
    ALTER DATABASE [{productlaunchevent#rawvault#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{productlaunchevent#rawvault#database_name}];
GO
IF SCHEMA_ID(N'{productlaunchevent#rawvault#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{productlaunchevent#rawvault#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- SatelliteSourceView: BRANCH_Satellite Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,[s1].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[s1].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[s1].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[s1].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[s1].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[s1].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Result] AS [s1]
;
GO

-- SatelliteTable: BRANCH_Satellite Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_SAT_BRANCH')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[BRANCH_NAME] VARCHAR(50) NULL
    ,[MARKET_SIZE] VARCHAR(10) NULL
    ,[LOCATION_SINCE] INT NULL
    ,[RETAIL_SPACE_M2] INT NULL
    ,[ARTICLE_NUMBER_APPROX] INT NULL
    ,[ZIP_CODE] VARCHAR(20) NULL
    ,CONSTRAINT [PK_RDV_SAT_BRANCH] PRIMARY KEY CLUSTERED ([Hub_HK], [BG_ValidFromTimestamp])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_SAT_BRANCH_BRANCH] ON [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH] ([Hub_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[BRANCH_NAME]
        ,[MARKET_SIZE]
        ,[LOCATION_SINCE]
        ,[RETAIL_SPACE_M2]
        ,[ARTICLE_NUMBER_APPROX]
        ,[ZIP_CODE]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,N'Unknown' AS [BRANCH_NAME]
        ,N'Unknown' AS [MARKET_SIZE]
        ,0 AS [LOCATION_SINCE]
        ,0 AS [RETAIL_SPACE_M2]
        ,0 AS [ARTICLE_NUMBER_APPROX]
        ,N'Unknown' AS [ZIP_CODE]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- SatelliteHashingView: BRANCH_Satellite Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([BRANCH_NAME], N'_NULL_') + N'_' + ISNULL([MARKET_SIZE], N'_NULL_') + N'_' + ISNULL(CAST([LOCATION_SINCE] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([RETAIL_SPACE_M2] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([ARTICLE_NUMBER_APPROX] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([ZIP_CODE], N'_NULL_')) AS [BG_RowHash]
    ,[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,[BRANCH_NAME] AS [BRANCH_NAME]
    ,[MARKET_SIZE] AS [MARKET_SIZE]
    ,[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Source]
;
GO

-- SatelliteResultView: BRANCH_Satellite Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[BRANCH_NAME] AS [BRANCH_NAME]
    ,[MARKET_SIZE] AS [MARKET_SIZE]
    ,[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH]
WHERE [Hub_HK] <> 0
;
GO

-- SatelliteDeltaView: BRANCH_Satellite Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = N'99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteLoader: BRANCH_Satellite Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[BRANCH_NAME]
            ,[MARKET_SIZE]
            ,[LOCATION_SINCE]
            ,[RETAIL_SPACE_M2]
            ,[ARTICLE_NUMBER_APPROX]
            ,[ZIP_CODE]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
            ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
            ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
            ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
            ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- HubSourceView: CUSTOMER_Hub Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Result] AS [s1]
;
GO

-- HubTable: CUSTOMER_Hub Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_HUB_CUSTOMER')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CUSTOMER_ID] DECIMAL(38) NULL
    ,CONSTRAINT [PK_RDV_HUB_CUSTOMER] PRIMARY KEY CLUSTERED ([Hub_HK])
    ,CONSTRAINT [UC_RDV_HUB_CUSTOMER] UNIQUE NONCLUSTERED ([CUSTOMER_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[CUSTOMER_ID]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [CUSTOMER_ID]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- HubHashingView: CUSTOMER_Hub Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([CUSTOMER_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[CUSTOMER_ID] AS [CUSTOMER_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Source]
;
GO

-- HubResultView: CUSTOMER_Hub Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[CUSTOMER_ID] AS [CUSTOMER_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: CUSTOMER_Hub Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: CUSTOMER_Hub Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[CUSTOMER_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- SatelliteSourceView: CUSTOMER_Address_Satellite Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID]
    ,[s1].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[s1].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Result] AS [s1]
;
GO

-- SatelliteTable: CUSTOMER_Address_Satellite Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_SAT_CUSTOMER_Address')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] BINARY(20) NOT NULL
    ,[ADDRESS_LINE1] VARCHAR(100) NULL
    ,[ADDRESS_LINE2] VARCHAR(100) NULL
    ,[ADDRESS_LINE3] VARCHAR(100) NULL
    ,[ZIP_CODE] VARCHAR(20) NULL
    ,CONSTRAINT [PK_RDV_SAT_CUSTOMER_Address] PRIMARY KEY CLUSTERED ([Hub_HK], [BG_ValidFromTimestamp])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_SAT_CUSTOMER_Address_CUSTOMER_Hub] ON [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address] ([Hub_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[ADDRESS_LINE1]
        ,[ADDRESS_LINE2]
        ,[ADDRESS_LINE3]
        ,[ZIP_CODE]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,0 AS [BG_RowHash]
        ,N'Unknown' AS [ADDRESS_LINE1]
        ,N'Unknown' AS [ADDRESS_LINE2]
        ,N'Unknown' AS [ADDRESS_LINE3]
        ,N'Unknown' AS [ZIP_CODE]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- SatelliteHashingView: CUSTOMER_Address_Satellite Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([ADDRESS_LINE1], N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE2], N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE3], N'_NULL_') + N'_' + ISNULL([ZIP_CODE], N'_NULL_')) AS [BG_RowHash]
    ,[FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID]
    ,[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Source]
;
GO

-- SatelliteResultView: CUSTOMER_Address_Satellite Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address]
WHERE [Hub_HK] <> 0
;
GO

-- SatelliteDeltaView: CUSTOMER_Address_Satellite Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = N'99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteLoader: CUSTOMER_Address_Satellite Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ZIP_CODE]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- SatelliteSourceView: CUSTOMER_Info_Satellite Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID]
    ,[s1].[CUSTOMER] AS [CUSTOMER]
    ,[s1].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[s1].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Result] AS [s1]
;
GO

-- SatelliteTable: CUSTOMER_Info_Satellite Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_SAT_CUSTOMER_Info')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] BINARY(20) NOT NULL
    ,[CUSTOMER] VARCHAR(100) NULL
    ,[CUSTOMER_TYPE] VARCHAR(100) NULL
    ,[CUSTOMER_SINCE] DATE NULL
    ,CONSTRAINT [PK_RDV_SAT_CUSTOMER_Info] PRIMARY KEY CLUSTERED ([Hub_HK], [BG_ValidFromTimestamp])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_SAT_CUSTOMER_Info_CUSTOMER_Hub] ON [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info] ([Hub_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[CUSTOMER]
        ,[CUSTOMER_TYPE]
        ,[CUSTOMER_SINCE]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,0 AS [BG_RowHash]
        ,N'Unknown' AS [CUSTOMER]
        ,N'Unknown' AS [CUSTOMER_TYPE]
        ,N'19000101' AS [CUSTOMER_SINCE]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- SatelliteHashingView: CUSTOMER_Info_Satellite Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([CUSTOMER], N'_NULL_') + N'_' + ISNULL([CUSTOMER_TYPE], N'_NULL_') + N'_' + ISNULL(CAST([CUSTOMER_SINCE] AS NVARCHAR(4000)), N'_NULL_')) AS [BG_RowHash]
    ,[FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID]
    ,[CUSTOMER] AS [CUSTOMER]
    ,[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Source]
;
GO

-- SatelliteResultView: CUSTOMER_Info_Satellite Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[CUSTOMER] AS [CUSTOMER]
    ,[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info]
WHERE [Hub_HK] <> 0
;
GO

-- SatelliteDeltaView: CUSTOMER_Info_Satellite Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = N'99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteLoader: CUSTOMER_Info_Satellite Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[CUSTOMER]
            ,[CUSTOMER_TYPE]
            ,[CUSTOMER_SINCE]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
            ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
            ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- HubSourceView: EMPLOYEE_Hub Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[EMPLOYEE_ID] AS [EMPLOYEE_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Result] AS [s1]
;
GO

-- HubTable: EMPLOYEE_Hub Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_HUB_EMPLOYEE')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[EMPLOYEE_ID] INT NULL
    ,CONSTRAINT [PK_RDV_HUB_EMPLOYEE] PRIMARY KEY CLUSTERED ([Hub_HK])
    ,CONSTRAINT [UC_RDV_HUB_EMPLOYEE] UNIQUE NONCLUSTERED ([EMPLOYEE_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[EMPLOYEE_ID]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [EMPLOYEE_ID]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- HubHashingView: EMPLOYEE_Hub Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([EMPLOYEE_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[EMPLOYEE_ID] AS [EMPLOYEE_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Source]
;
GO

-- HubResultView: EMPLOYEE_Hub Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[EMPLOYEE_ID] AS [EMPLOYEE_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: EMPLOYEE_Hub Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[EMPLOYEE_ID] AS [EMPLOYEE_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: EMPLOYEE_Hub Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[EMPLOYEE_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[EMPLOYEE_ID] AS [EMPLOYEE_ID]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- SatelliteSourceView: EMPLOYEE_Satellite Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[EMPLOYEE_ID] AS [FK_EMPLOYEE_EMPLOYEE_Hub_EMPLOYEE_ID]
    ,[s1].[LAST_NAME] AS [LAST_NAME]
    ,[s1].[FIRST_NAME] AS [FIRST_NAME]
    ,[s1].[BIRTH_DATE] AS [BIRTH_DATE]
    ,[s1].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[s1].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Result] AS [s1]
;
GO

-- SatelliteTable: EMPLOYEE_Satellite Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_SAT_EMPLOYEE')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[LAST_NAME] VARCHAR(100) NULL
    ,[FIRST_NAME] VARCHAR(100) NULL
    ,[BIRTH_DATE] DATE NULL
    ,[ADDRESS_LINE1] VARCHAR(100) NULL
    ,[ADDRESS_LINE2] VARCHAR(100) NULL
    ,[ADDRESS_LINE3] VARCHAR(100) NULL
    ,[ZIP_CODE] VARCHAR(20) NULL
    ,CONSTRAINT [PK_RDV_SAT_EMPLOYEE] PRIMARY KEY CLUSTERED ([Hub_HK], [BG_ValidFromTimestamp])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_SAT_EMPLOYEE_EMPLOYEE_Hub] ON [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE] ([Hub_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[LAST_NAME]
        ,[FIRST_NAME]
        ,[BIRTH_DATE]
        ,[ADDRESS_LINE1]
        ,[ADDRESS_LINE2]
        ,[ADDRESS_LINE3]
        ,[ZIP_CODE]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,N'Unknown' AS [LAST_NAME]
        ,N'Unknown' AS [FIRST_NAME]
        ,N'19000101' AS [BIRTH_DATE]
        ,N'Unknown' AS [ADDRESS_LINE1]
        ,N'Unknown' AS [ADDRESS_LINE2]
        ,N'Unknown' AS [ADDRESS_LINE3]
        ,N'Unknown' AS [ZIP_CODE]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- SatelliteHashingView: EMPLOYEE_Satellite Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_EMPLOYEE_EMPLOYEE_Hub_EMPLOYEE_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([LAST_NAME], N'_NULL_') + N'_' + ISNULL([FIRST_NAME], N'_NULL_') + N'_' + ISNULL(CAST([BIRTH_DATE] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE1], N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE2], N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE3], N'_NULL_') + N'_' + ISNULL([ZIP_CODE], N'_NULL_')) AS [BG_RowHash]
    ,[FK_EMPLOYEE_EMPLOYEE_Hub_EMPLOYEE_ID] AS [FK_EMPLOYEE_EMPLOYEE_Hub_EMPLOYEE_ID]
    ,[LAST_NAME] AS [LAST_NAME]
    ,[FIRST_NAME] AS [FIRST_NAME]
    ,[BIRTH_DATE] AS [BIRTH_DATE]
    ,[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Source]
;
GO

-- SatelliteResultView: EMPLOYEE_Satellite Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[LAST_NAME] AS [LAST_NAME]
    ,[FIRST_NAME] AS [FIRST_NAME]
    ,[BIRTH_DATE] AS [BIRTH_DATE]
    ,[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE]
WHERE [Hub_HK] <> 0
;
GO

-- SatelliteDeltaView: EMPLOYEE_Satellite Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[LAST_NAME] AS [LAST_NAME]
    ,[BG_Source].[FIRST_NAME] AS [FIRST_NAME]
    ,[BG_Source].[BIRTH_DATE] AS [BIRTH_DATE]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = N'99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteLoader: EMPLOYEE_Satellite Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[LAST_NAME]
            ,[FIRST_NAME]
            ,[BIRTH_DATE]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ZIP_CODE]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[LAST_NAME] AS [LAST_NAME]
            ,[BG_Source].[FIRST_NAME] AS [FIRST_NAME]
            ,[BG_Source].[BIRTH_DATE] AS [BIRTH_DATE]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- HubSourceView: EMPLOYEE1_Hub Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,BG_CONCATENATE(s1.FirstName, s1.LastName) AS [Name]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Result] AS [s1]
;
GO

-- HubTable: EMPLOYEE1_Hub Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_HUB_EMPLOYEE1')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[Name] NVARCHAR(200) NULL
    ,CONSTRAINT [PK_RDV_HUB_EMPLOYEE1] PRIMARY KEY CLUSTERED ([Hub_HK])
    ,CONSTRAINT [UC_RDV_HUB_EMPLOYEE1] UNIQUE NONCLUSTERED ([Name])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[Name]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,N'Unknown' AS [Name]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- HubHashingView: EMPLOYEE1_Hub Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL([Name], N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[Name] AS [Name]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Source]
;
GO

-- HubResultView: EMPLOYEE1_Hub Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[Name] AS [Name]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: EMPLOYEE1_Hub Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[Name] AS [Name]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: EMPLOYEE1_Hub Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[Name]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[Name] AS [Name]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- HubSourceView: ITEM_Hub Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Result] AS [s1]
;
GO

-- HubTable: ITEM_Hub Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_HUB_ITEM')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[ITEM_ID] DECIMAL(38) NULL
    ,CONSTRAINT [PK_RDV_HUB_ITEM] PRIMARY KEY CLUSTERED ([Hub_HK])
    ,CONSTRAINT [UC_RDV_HUB_ITEM] UNIQUE NONCLUSTERED ([ITEM_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[ITEM_ID]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [ITEM_ID]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- HubHashingView: ITEM_Hub Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([ITEM_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[ITEM_ID] AS [ITEM_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Source]
;
GO

-- HubResultView: ITEM_Hub Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[ITEM_ID] AS [ITEM_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: ITEM_Hub Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: ITEM_Hub Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[ITEM_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- SatelliteSourceView: ITEM_Satellite Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[ITEM_ID] AS [FK_ITEM_ITEM_Hub_ITEM_ID]
    ,[s1].[DESCRIPTION] AS [DESCRIPTION]
    ,[s1].[BASE_UOM] AS [BASE_UOM]
    ,[s1].[SALES_UOM] AS [SALES_UOM]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Result] AS [s1]
;
GO

-- SatelliteTable: ITEM_Satellite Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_SAT_ITEM')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[DESCRIPTION] VARCHAR(1000) NULL
    ,[BASE_UOM] VARCHAR(10) NULL
    ,[SALES_UOM] VARCHAR(10) NULL
    ,CONSTRAINT [PK_RDV_SAT_ITEM] PRIMARY KEY CLUSTERED ([Hub_HK], [BG_ValidFromTimestamp])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_SAT_ITEM_ITEM_Hub] ON [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM] ([Hub_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[DESCRIPTION]
        ,[BASE_UOM]
        ,[SALES_UOM]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,N'Unknown' AS [DESCRIPTION]
        ,N'Unknown' AS [BASE_UOM]
        ,N'Unknown' AS [SALES_UOM]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- SatelliteHashingView: ITEM_Satellite Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_ITEM_ITEM_Hub_ITEM_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([DESCRIPTION], N'_NULL_') + N'_' + ISNULL([BASE_UOM], N'_NULL_') + N'_' + ISNULL([SALES_UOM], N'_NULL_')) AS [BG_RowHash]
    ,[FK_ITEM_ITEM_Hub_ITEM_ID] AS [FK_ITEM_ITEM_Hub_ITEM_ID]
    ,[DESCRIPTION] AS [DESCRIPTION]
    ,[BASE_UOM] AS [BASE_UOM]
    ,[SALES_UOM] AS [SALES_UOM]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Source]
;
GO

-- SatelliteResultView: ITEM_Satellite Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[DESCRIPTION] AS [DESCRIPTION]
    ,[BASE_UOM] AS [BASE_UOM]
    ,[SALES_UOM] AS [SALES_UOM]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM]
WHERE [Hub_HK] <> 0
;
GO

-- SatelliteDeltaView: ITEM_Satellite Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = N'99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteLoader: ITEM_Satellite Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[DESCRIPTION]
            ,[BASE_UOM]
            ,[SALES_UOM]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
            ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- HubSourceView: ITEMUNITOFMEASURE_Hub Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
    ,[s1].[UOM] AS [UOM]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Result] AS [s1]
;
GO

-- HubTable: ITEMUNITOFMEASURE_Hub Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_HUB_ITEMUNITOFMEASURE')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[ITEM_ID] DECIMAL(38) NULL
    ,[UOM] VARCHAR(10) NULL
    ,CONSTRAINT [PK_RDV_HUB_ITEMUNITOFMEASURE] PRIMARY KEY CLUSTERED ([Hub_HK])
    ,CONSTRAINT [UC_RDV_HUB_ITEMUNITOFMEASURE] UNIQUE NONCLUSTERED ([ITEM_ID], [UOM])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[ITEM_ID]
        ,[UOM]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [ITEM_ID]
        ,N'Unknown' AS [UOM]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- HubHashingView: ITEMUNITOFMEASURE_Hub Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([ITEM_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([UOM], N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[ITEM_ID] AS [ITEM_ID]
    ,[UOM] AS [UOM]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Source]
;
GO

-- HubResultView: ITEMUNITOFMEASURE_Hub Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[ITEM_ID] AS [ITEM_ID]
    ,[UOM] AS [UOM]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: ITEMUNITOFMEASURE_Hub Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[UOM] AS [UOM]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: ITEMUNITOFMEASURE_Hub Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[ITEM_ID]
            ,[UOM]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[UOM] AS [UOM]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- SatelliteSourceView: ITEMUNITOFMEASURE_Satellite Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[ITEM_ID] AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
    ,[s1].[UOM] AS [FK_ITEMUNITOFMEASURE_UOM]
    ,[s1].[DESCRIPTION] AS [DESCRIPTION]
    ,[s1].[BASE_UOM] AS [BASE_UOM]
    ,[s1].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Result] AS [s1]
;
GO

-- SatelliteTable: ITEMUNITOFMEASURE_Satellite Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_SAT_ITEMUNITOFMEASURE')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[DESCRIPTION] VARCHAR(100) NULL
    ,[BASE_UOM] VARCHAR(10) NULL
    ,[QTY_PER_BASE_UOM] INT NULL
    ,CONSTRAINT [PK_RDV_SAT_ITEMUNITOFMEASURE] PRIMARY KEY CLUSTERED ([Hub_HK], [BG_ValidFromTimestamp])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_SAT_ITEMUNITOFMEASURE_ITEMUNITOFMEASURE] ON [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE] ([Hub_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[DESCRIPTION]
        ,[BASE_UOM]
        ,[QTY_PER_BASE_UOM]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,N'Unknown' AS [DESCRIPTION]
        ,N'Unknown' AS [BASE_UOM]
        ,0 AS [QTY_PER_BASE_UOM]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- SatelliteHashingView: ITEMUNITOFMEASURE_Satellite Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_ITEMUNITOFMEASURE_ITEM_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([FK_ITEMUNITOFMEASURE_UOM], N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([DESCRIPTION], N'_NULL_') + N'_' + ISNULL([BASE_UOM], N'_NULL_') + N'_' + ISNULL(CAST([QTY_PER_BASE_UOM] AS NVARCHAR(4000)), N'_NULL_')) AS [BG_RowHash]
    ,[FK_ITEMUNITOFMEASURE_ITEM_ID] AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
    ,[FK_ITEMUNITOFMEASURE_UOM] AS [FK_ITEMUNITOFMEASURE_UOM]
    ,[DESCRIPTION] AS [DESCRIPTION]
    ,[BASE_UOM] AS [BASE_UOM]
    ,[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Source]
;
GO

-- SatelliteResultView: ITEMUNITOFMEASURE_Satellite Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[DESCRIPTION] AS [DESCRIPTION]
    ,[BASE_UOM] AS [BASE_UOM]
    ,[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE]
WHERE [Hub_HK] <> 0
;
GO

-- SatelliteDeltaView: ITEMUNITOFMEASURE_Satellite Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = N'99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteLoader: ITEMUNITOFMEASURE_Satellite Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[DESCRIPTION]
            ,[BASE_UOM]
            ,[QTY_PER_BASE_UOM]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- HubSourceView: LOYALTYCARD_Hub Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Result] AS [s1]
;
GO

-- HubTable: LOYALTYCARD_Hub Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_HUB_LOYALTYCARD')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[LOYALTYCARD_ID] INT NULL
    ,CONSTRAINT [PK_RDV_HUB_LOYALTYCARD] PRIMARY KEY CLUSTERED ([Hub_HK])
    ,CONSTRAINT [UC_RDV_HUB_LOYALTYCARD] UNIQUE NONCLUSTERED ([LOYALTYCARD_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[LOYALTYCARD_ID]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [LOYALTYCARD_ID]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- HubHashingView: LOYALTYCARD_Hub Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([LOYALTYCARD_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Source]
;
GO

-- HubResultView: LOYALTYCARD_Hub Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: LOYALTYCARD_Hub Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: LOYALTYCARD_Hub Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[LOYALTYCARD_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- LinkSourceView: Loyaltycard_Customer_Link Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST([s1].[CUSTOMER_ID] AS DECIMAL(38)) AS [FK_CUSTOMER_CUSTOMER_ID]
    ,[s1].[LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Result] AS [s1]
;
GO

-- LinkTable: Loyaltycard_Customer_Link Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_LNK_Loyaltycard_Customer')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Link_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[FK_CUSTOMER_CUSTOMER_ID] DECIMAL(38) NULL
    ,[CUSTOMER_CUSTOMER_HK] BINARY(20) NOT NULL
    ,[FK_LOYALTYCARD_LOYALTYCARD_ID] INT NULL
    ,[LOYALTYCARD_LOYALTYCARD_HK] BINARY(20) NOT NULL
    ,CONSTRAINT [PK_RDV_LNK_Loyaltycard_Customer] PRIMARY KEY CLUSTERED ([Link_HK])
    ,CONSTRAINT [UC_RDV_LNK_Loyaltycard_Customer] UNIQUE NONCLUSTERED ([FK_CUSTOMER_CUSTOMER_ID], [FK_LOYALTYCARD_LOYALTYCARD_ID])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_LNK_Loyaltycard_Customer_CUSTOMER] ON [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer] ([CUSTOMER_CUSTOMER_HK]);
CREATE NONCLUSTERED INDEX [IX_RDV_LNK_Loyaltycard_Customer_LOYALTYCARD] ON [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer] ([LOYALTYCARD_LOYALTYCARD_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Link_HK]
        ,[BG_SourceSystem]
        ,[FK_CUSTOMER_CUSTOMER_ID]
        ,[CUSTOMER_CUSTOMER_HK]
        ,[FK_LOYALTYCARD_LOYALTYCARD_ID]
        ,[LOYALTYCARD_LOYALTYCARD_HK]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Link_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [FK_CUSTOMER_CUSTOMER_ID]
        ,0 AS [CUSTOMER_CUSTOMER_HK]
        ,0 AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
        ,0 AS [LOYALTYCARD_LOYALTYCARD_HK]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- LinkHashingView: Loyaltycard_Customer_Link Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_CUSTOMER_CUSTOMER_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_LOYALTYCARD_LOYALTYCARD_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_CUSTOMER_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_ID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_CUSTOMER_CUSTOMER_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [CUSTOMER_CUSTOMER_HK]
    ,[FK_LOYALTYCARD_LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_LOYALTYCARD_LOYALTYCARD_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [LOYALTYCARD_LOYALTYCARD_HK]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Source]
;
GO

-- LinkresultView: Loyaltycard_Customer_Link Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Link_HK] AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_CUSTOMER_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_ID]
    ,[CUSTOMER_CUSTOMER_HK] AS [CUSTOMER_CUSTOMER_HK]
    ,[FK_LOYALTYCARD_LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
    ,[LOYALTYCARD_LOYALTYCARD_HK] AS [LOYALTYCARD_LOYALTYCARD_HK]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer]
WHERE [Link_HK] <> 0
;
GO

-- LinkDeltaView: Loyaltycard_Customer_Link Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_CUSTOMER_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_ID]
    ,[BG_Source].[CUSTOMER_CUSTOMER_HK] AS [CUSTOMER_CUSTOMER_HK]
    ,[BG_Source].[FK_LOYALTYCARD_LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
    ,[BG_Source].[LOYALTYCARD_LOYALTYCARD_HK] AS [LOYALTYCARD_LOYALTYCARD_HK]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- LinkLoader: Loyaltycard_Customer_Link Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Link_HK]
            ,[BG_SourceSystem]
            ,[FK_CUSTOMER_CUSTOMER_ID]
            ,[CUSTOMER_CUSTOMER_HK]
            ,[FK_LOYALTYCARD_LOYALTYCARD_ID]
            ,[LOYALTYCARD_LOYALTYCARD_HK]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Link_HK] AS [Link_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[FK_CUSTOMER_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_ID]
            ,[BG_Source].[CUSTOMER_CUSTOMER_HK] AS [CUSTOMER_CUSTOMER_HK]
            ,[BG_Source].[FK_LOYALTYCARD_LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
            ,[BG_Source].[LOYALTYCARD_LOYALTYCARD_HK] AS [LOYALTYCARD_LOYALTYCARD_HK]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- MultiActiveSatelliteSourceView: PHONENUMBER_Multi-Active Satellite Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[PHONENUMBER_ID] AS [BG_Sequence]
    ,CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST([s1].[FOREIGN_KEY_ID] AS DECIMAL(38)) AS [FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID]
    ,[s1].[PHONE_NUMBER] AS [PHONE_NUMBER]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Result] AS [s1]
WHERE [s1].[PHONE_NUMBER_TYPE_CODE] = 'CUST'
;
GO

-- MultiActiveSatelliteTable: PHONENUMBER_Multi-Active Satellite Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_MAS_PHONENUMBER')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[BG_Sequence] INT NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[PHONE_NUMBER] VARCHAR(50) NULL
    ,CONSTRAINT [PK_RDV_MAS_PHONENUMBER] PRIMARY KEY CLUSTERED ([Hub_HK], [BG_ValidFromTimestamp], [BG_Sequence])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_MAS_PHONENUMBER_CUSTOMER_Hub] ON [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER] ([Hub_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[BG_Sequence]
        ,[BG_SourceSystem]
        ,[PHONE_NUMBER]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,0 AS [BG_Sequence]
        ,N'Unknown' AS [BG_SourceSystem]
        ,N'Unknown' AS [PHONE_NUMBER]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- MultiActiveSatelliteHashingView: PHONENUMBER_Multi-Active Satellite Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([PHONE_NUMBER], N'_NULL_')) AS [BG_RowHash]
    ,[BG_Sequence] AS [BG_Sequence]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_Hub_CUSTOMER_ID]
    ,[PHONE_NUMBER] AS [PHONE_NUMBER]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Source]
;
GO

-- MultiActiveSatelliteResultView: PHONENUMBER_Multi-Active Satellite Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK], [BG_Sequence] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,[BG_Sequence] AS [BG_Sequence]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[PHONE_NUMBER] AS [PHONE_NUMBER]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER]
WHERE [Hub_HK] <> 0
;
GO

-- MultiActiveSatelliteDeltaView: PHONENUMBER_Multi-Active Satellite Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Delta]
AS
SELECT
     [BG_Source].[Hub_HK]
    ,[BG_Source].[BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash]
    ,[BG_Source].[BG_Sequence]
    ,[BG_Source].[BG_SourceSystem]
    ,[BG_Source].[PHONE_NUMBER]
FROM (
    SELECT
         [BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[PHONE_NUMBER] AS [PHONE_NUMBER]
        ,ISNULL([BG_Source].[Hub_HK], [BG_Target].[Hub_HK]) AS [Hub_HK]
        ,ISNULL([BG_Source].[BG_Sequence], [BG_Target].[BG_Sequence]) AS [BG_Sequence]
        ,MAX(CASE WHEN ISNULL([BG_Source].[BG_RowHash], N'0') <> ISNULL([BG_Target].[BG_RowHash], N'0') THEN 1 ELSE 0 END) OVER (PARTITION BY ISNULL([BG_Source].[Hub_HK], [BG_Target].[Hub_HK])) AS [BG_MAS_HubDifferenceFound]
    FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Hashing] AS [BG_Source]
    FULL JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Result] AS [BG_Target]
       ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
      AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
      AND ([BG_Source].[BG_Sequence] = [BG_Target].[BG_Sequence])
      AND ([BG_Target].[BG_ValidToTimestamp] = N'99991231')
) AS [BG_Source]
WHERE ([BG_RowHash] IS NOT NULL)
  AND ([BG_MAS_HubDifferenceFound] = 1)
;
GO

-- Multi-Active SatelliteLoader: PHONENUMBER_Multi-Active Satellite Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[BG_Sequence]
            ,[BG_SourceSystem]
            ,[PHONE_NUMBER]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,@LoadTimestamp AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[BG_Sequence] AS [BG_Sequence]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[PHONE_NUMBER] AS [PHONE_NUMBER]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- HubSourceView: POS_Hub Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[POS_ID] AS [POS_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Result] AS [s1]
;
GO

-- HubTable: POS_Hub Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_HUB_POS')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[POS_ID] INT NULL
    ,CONSTRAINT [PK_RDV_HUB_POS] PRIMARY KEY CLUSTERED ([Hub_HK])
    ,CONSTRAINT [UC_RDV_HUB_POS] UNIQUE NONCLUSTERED ([POS_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[POS_ID]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [POS_ID]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- HubHashingView: POS_Hub Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([POS_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[POS_ID] AS [POS_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Source]
;
GO

-- HubResultView: POS_Hub Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[POS_ID] AS [POS_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: POS_Hub Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[POS_ID] AS [POS_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: POS_Hub Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[POS_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[POS_ID] AS [POS_ID]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- LinkSourceView: POS_Branch_Link Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,[s1].[POS_ID] AS [FK_POS_POS_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Result] AS [s1]
;
GO

-- LinkTable: POS_Branch_Link Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_LNK_POS_Branch')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Link_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[FK_BRANCH_BRANCH_ID] INT NULL
    ,[BRANCH_BRANCH_HK] BINARY(20) NOT NULL
    ,[FK_POS_POS_ID] INT NULL
    ,[POS_POS_HK] BINARY(20) NOT NULL
    ,CONSTRAINT [PK_RDV_LNK_POS_Branch] PRIMARY KEY CLUSTERED ([Link_HK])
    ,CONSTRAINT [UC_RDV_LNK_POS_Branch] UNIQUE NONCLUSTERED ([FK_BRANCH_BRANCH_ID], [FK_POS_POS_ID])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_LNK_POS_Branch_BRANCH] ON [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch] ([BRANCH_BRANCH_HK]);
CREATE NONCLUSTERED INDEX [IX_RDV_LNK_POS_Branch_POS] ON [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch] ([POS_POS_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Link_HK]
        ,[BG_SourceSystem]
        ,[FK_BRANCH_BRANCH_ID]
        ,[BRANCH_BRANCH_HK]
        ,[FK_POS_POS_ID]
        ,[POS_POS_HK]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Link_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [FK_BRANCH_BRANCH_ID]
        ,0 AS [BRANCH_BRANCH_HK]
        ,0 AS [FK_POS_POS_ID]
        ,0 AS [POS_POS_HK]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- LinkHashingView: POS_Branch_Link Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_BRANCH_BRANCH_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_POS_POS_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,HASHBYTES('SHA1', ) AS [BRANCH_BRANCH_HK]
    ,[FK_POS_POS_ID] AS [FK_POS_POS_ID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_POS_POS_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [POS_POS_HK]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Source]
;
GO

-- LinkresultView: POS_Branch_Link Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Link_HK] AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,[BRANCH_BRANCH_HK] AS [BRANCH_BRANCH_HK]
    ,[FK_POS_POS_ID] AS [FK_POS_POS_ID]
    ,[POS_POS_HK] AS [POS_POS_HK]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch]
WHERE [Link_HK] <> 0
;
GO

-- LinkDeltaView: POS_Branch_Link Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,[BG_Source].[BRANCH_BRANCH_HK] AS [BRANCH_BRANCH_HK]
    ,[BG_Source].[FK_POS_POS_ID] AS [FK_POS_POS_ID]
    ,[BG_Source].[POS_POS_HK] AS [POS_POS_HK]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- LinkLoader: POS_Branch_Link Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Link_HK]
            ,[BG_SourceSystem]
            ,[FK_BRANCH_BRANCH_ID]
            ,[BRANCH_BRANCH_HK]
            ,[FK_POS_POS_ID]
            ,[POS_POS_HK]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Link_HK] AS [Link_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
            ,[BG_Source].[BRANCH_BRANCH_HK] AS [BRANCH_BRANCH_HK]
            ,[BG_Source].[FK_POS_POS_ID] AS [FK_POS_POS_ID]
            ,[BG_Source].[POS_POS_HK] AS [POS_POS_HK]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- LinkSourceView: POS_SALES_Link Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
    ,CAST([s1].[ITEM_ID] AS DECIMAL(38)) AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
    ,[s1].[UOM] AS [FK_ITEMUNITOFMEASURE_UOM]
    ,[s1].[POS_ID] AS [FK_POS_POS_ID]
    ,CAST([s1].[ITEM_ID] AS DECIMAL(38)) AS [FK_ITEM_ITEM_ID]
    ,[s1].[TRANSACTION_ID] AS [FK_SALESTRANSACTION_TRANSACTION_ID]
    ,[s1].[TRANSACTION_LINE_NO] AS [FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
    ,[s1].[TRANSACTION_TIME] AS [FK_SALESTRANSACTION_TRANSACTION_TIME]
    ,[s1].[POS_ID] AS [FK_SALESTRANSACTION_POS_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Result] AS [s1]
;
GO

-- HubSourceView: SALESTRANSACTION_Hub Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[s1].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[s1].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[s1].[POS_ID] AS [POS_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Result] AS [s1]
;
GO

-- HubTable: SALESTRANSACTION_Hub Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_HUB_SALESTRANSACTION')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[TRANSACTION_ID] INT NULL
    ,[TRANSACTION_LINE_NO] INT NULL
    ,[TRANSACTION_TIME] DATETIME2 NULL
    ,[POS_ID] INT NULL
    ,CONSTRAINT [PK_RDV_HUB_SALESTRANSACTION] PRIMARY KEY CLUSTERED ([Hub_HK])
    ,CONSTRAINT [UC_RDV_HUB_SALESTRANSACTION] UNIQUE NONCLUSTERED ([TRANSACTION_ID], [TRANSACTION_LINE_NO], [TRANSACTION_TIME], [POS_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[TRANSACTION_ID]
        ,[TRANSACTION_LINE_NO]
        ,[TRANSACTION_TIME]
        ,[POS_ID]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [TRANSACTION_ID]
        ,0 AS [TRANSACTION_LINE_NO]
        ,N'19000101' AS [TRANSACTION_TIME]
        ,0 AS [POS_ID]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- HubHashingView: SALESTRANSACTION_Hub Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([TRANSACTION_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([TRANSACTION_LINE_NO] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([TRANSACTION_TIME] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([POS_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[POS_ID] AS [POS_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Source]
;
GO

-- HubResultView: SALESTRANSACTION_Hub Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[POS_ID] AS [POS_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: SALESTRANSACTION_Hub Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[BG_Source].[POS_ID] AS [POS_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: SALESTRANSACTION_Hub Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[TRANSACTION_ID]
            ,[TRANSACTION_LINE_NO]
            ,[TRANSACTION_TIME]
            ,[POS_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
            ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
            ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
            ,[BG_Source].[POS_ID] AS [POS_ID]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- LinkTable: POS_SALES_Link Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_LNK_POS_SALES')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Link_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[FK_LOYALTYCARD_LOYALTYCARD_ID] INT NULL
    ,[LOYALTYCARD_LOYALTYCARD_HK] BINARY(20) NOT NULL
    ,[FK_ITEMUNITOFMEASURE_ITEM_ID] DECIMAL(38) NULL
    ,[FK_ITEMUNITOFMEASURE_UOM] VARCHAR(10) NULL
    ,[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK] BINARY(20) NOT NULL
    ,[FK_POS_POS_ID] INT NULL
    ,[POS_POS_HK] BINARY(20) NOT NULL
    ,[FK_ITEM_ITEM_ID] DECIMAL(38) NULL
    ,[ITEM_ITEM_HK] BINARY(20) NOT NULL
    ,[FK_SALESTRANSACTION_TRANSACTION_ID] INT NULL
    ,[FK_SALESTRANSACTION_TRANSACTION_LINE_NO] INT NULL
    ,[FK_SALESTRANSACTION_TRANSACTION_TIME] DATETIME2 NULL
    ,[FK_SALESTRANSACTION_POS_ID] INT NULL
    ,[SALESTRANSACTION_SALESTRANSACTION_HK] BINARY(20) NOT NULL
    ,CONSTRAINT [PK_RDV_LNK_POS_SALES] PRIMARY KEY CLUSTERED ([Link_HK])
    ,CONSTRAINT [UC_RDV_LNK_POS_SALES] UNIQUE NONCLUSTERED ([FK_LOYALTYCARD_LOYALTYCARD_ID], [FK_ITEMUNITOFMEASURE_ITEM_ID], [FK_ITEMUNITOFMEASURE_UOM], [FK_POS_POS_ID], [FK_ITEM_ITEM_ID], [FK_SALESTRANSACTION_TRANSACTION_ID], [FK_SALESTRANSACTION_TRANSACTION_LINE_NO], [FK_SALESTRANSACTION_TRANSACTION_TIME], [FK_SALESTRANSACTION_POS_ID])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_LNK_POS_SALES_LOYALTYCARD] ON [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES] ([LOYALTYCARD_LOYALTYCARD_HK]);
CREATE NONCLUSTERED INDEX [IX_RDV_LNK_POS_SALES_ITEMUNITOFMEASURE] ON [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES] ([ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK]);
CREATE NONCLUSTERED INDEX [IX_RDV_LNK_POS_SALES_POS] ON [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES] ([POS_POS_HK]);
CREATE NONCLUSTERED INDEX [IX_RDV_LNK_POS_SALES_ITEM] ON [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES] ([ITEM_ITEM_HK]);
CREATE NONCLUSTERED INDEX [IX_RDV_LNK_POS_SALES_SALESTRANSACTION] ON [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES] ([SALESTRANSACTION_SALESTRANSACTION_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Link_HK]
        ,[BG_SourceSystem]
        ,[FK_LOYALTYCARD_LOYALTYCARD_ID]
        ,[LOYALTYCARD_LOYALTYCARD_HK]
        ,[FK_ITEMUNITOFMEASURE_ITEM_ID]
        ,[FK_ITEMUNITOFMEASURE_UOM]
        ,[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK]
        ,[FK_POS_POS_ID]
        ,[POS_POS_HK]
        ,[FK_ITEM_ITEM_ID]
        ,[ITEM_ITEM_HK]
        ,[FK_SALESTRANSACTION_TRANSACTION_ID]
        ,[FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
        ,[FK_SALESTRANSACTION_TRANSACTION_TIME]
        ,[FK_SALESTRANSACTION_POS_ID]
        ,[SALESTRANSACTION_SALESTRANSACTION_HK]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Link_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,0 AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
        ,0 AS [LOYALTYCARD_LOYALTYCARD_HK]
        ,0 AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
        ,N'Unknown' AS [FK_ITEMUNITOFMEASURE_UOM]
        ,0 AS [ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK]
        ,0 AS [FK_POS_POS_ID]
        ,0 AS [POS_POS_HK]
        ,0 AS [FK_ITEM_ITEM_ID]
        ,0 AS [ITEM_ITEM_HK]
        ,0 AS [FK_SALESTRANSACTION_TRANSACTION_ID]
        ,0 AS [FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
        ,N'19000101' AS [FK_SALESTRANSACTION_TRANSACTION_TIME]
        ,0 AS [FK_SALESTRANSACTION_POS_ID]
        ,0 AS [SALESTRANSACTION_SALESTRANSACTION_HK]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- LinkHashingView: POS_SALES_Link Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_LOYALTYCARD_LOYALTYCARD_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_ITEMUNITOFMEASURE_ITEM_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([FK_ITEMUNITOFMEASURE_UOM], N'_NULL_') + N'_' + ISNULL(CAST([FK_POS_POS_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_ITEM_ITEM_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_TIME] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_POS_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_LOYALTYCARD_LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_LOYALTYCARD_LOYALTYCARD_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [LOYALTYCARD_LOYALTYCARD_HK]
    ,[FK_ITEMUNITOFMEASURE_ITEM_ID] AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
    ,[FK_ITEMUNITOFMEASURE_UOM] AS [FK_ITEMUNITOFMEASURE_UOM]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_ITEMUNITOFMEASURE_ITEM_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([FK_ITEMUNITOFMEASURE_UOM], N'_NULL_')) AS [ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK]
    ,[FK_POS_POS_ID] AS [FK_POS_POS_ID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_POS_POS_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [POS_POS_HK]
    ,[FK_ITEM_ITEM_ID] AS [FK_ITEM_ITEM_ID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_ITEM_ITEM_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [ITEM_ITEM_HK]
    ,[FK_SALESTRANSACTION_TRANSACTION_ID] AS [FK_SALESTRANSACTION_TRANSACTION_ID]
    ,[FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS [FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
    ,[FK_SALESTRANSACTION_TRANSACTION_TIME] AS [FK_SALESTRANSACTION_TRANSACTION_TIME]
    ,[FK_SALESTRANSACTION_POS_ID] AS [FK_SALESTRANSACTION_POS_ID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_TIME] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_POS_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [SALESTRANSACTION_SALESTRANSACTION_HK]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Source]
;
GO

-- LinkresultView: POS_SALES_Link Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Link_HK] AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_LOYALTYCARD_LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
    ,[LOYALTYCARD_LOYALTYCARD_HK] AS [LOYALTYCARD_LOYALTYCARD_HK]
    ,[FK_ITEMUNITOFMEASURE_ITEM_ID] AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
    ,[FK_ITEMUNITOFMEASURE_UOM] AS [FK_ITEMUNITOFMEASURE_UOM]
    ,[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK] AS [ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK]
    ,[FK_POS_POS_ID] AS [FK_POS_POS_ID]
    ,[POS_POS_HK] AS [POS_POS_HK]
    ,[FK_ITEM_ITEM_ID] AS [FK_ITEM_ITEM_ID]
    ,[ITEM_ITEM_HK] AS [ITEM_ITEM_HK]
    ,[FK_SALESTRANSACTION_TRANSACTION_ID] AS [FK_SALESTRANSACTION_TRANSACTION_ID]
    ,[FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS [FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
    ,[FK_SALESTRANSACTION_TRANSACTION_TIME] AS [FK_SALESTRANSACTION_TRANSACTION_TIME]
    ,[FK_SALESTRANSACTION_POS_ID] AS [FK_SALESTRANSACTION_POS_ID]
    ,[SALESTRANSACTION_SALESTRANSACTION_HK] AS [SALESTRANSACTION_SALESTRANSACTION_HK]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES]
WHERE [Link_HK] <> 0
;
GO

-- LinkDeltaView: POS_SALES_Link Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_LOYALTYCARD_LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
    ,[BG_Source].[LOYALTYCARD_LOYALTYCARD_HK] AS [LOYALTYCARD_LOYALTYCARD_HK]
    ,[BG_Source].[FK_ITEMUNITOFMEASURE_ITEM_ID] AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
    ,[BG_Source].[FK_ITEMUNITOFMEASURE_UOM] AS [FK_ITEMUNITOFMEASURE_UOM]
    ,[BG_Source].[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK] AS [ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK]
    ,[BG_Source].[FK_POS_POS_ID] AS [FK_POS_POS_ID]
    ,[BG_Source].[POS_POS_HK] AS [POS_POS_HK]
    ,[BG_Source].[FK_ITEM_ITEM_ID] AS [FK_ITEM_ITEM_ID]
    ,[BG_Source].[ITEM_ITEM_HK] AS [ITEM_ITEM_HK]
    ,[BG_Source].[FK_SALESTRANSACTION_TRANSACTION_ID] AS [FK_SALESTRANSACTION_TRANSACTION_ID]
    ,[BG_Source].[FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS [FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
    ,[BG_Source].[FK_SALESTRANSACTION_TRANSACTION_TIME] AS [FK_SALESTRANSACTION_TRANSACTION_TIME]
    ,[BG_Source].[FK_SALESTRANSACTION_POS_ID] AS [FK_SALESTRANSACTION_POS_ID]
    ,[BG_Source].[SALESTRANSACTION_SALESTRANSACTION_HK] AS [SALESTRANSACTION_SALESTRANSACTION_HK]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- LinkLoader: POS_SALES_Link Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Link_HK]
            ,[BG_SourceSystem]
            ,[FK_LOYALTYCARD_LOYALTYCARD_ID]
            ,[LOYALTYCARD_LOYALTYCARD_HK]
            ,[FK_ITEMUNITOFMEASURE_ITEM_ID]
            ,[FK_ITEMUNITOFMEASURE_UOM]
            ,[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK]
            ,[FK_POS_POS_ID]
            ,[POS_POS_HK]
            ,[FK_ITEM_ITEM_ID]
            ,[ITEM_ITEM_HK]
            ,[FK_SALESTRANSACTION_TRANSACTION_ID]
            ,[FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
            ,[FK_SALESTRANSACTION_TRANSACTION_TIME]
            ,[FK_SALESTRANSACTION_POS_ID]
            ,[SALESTRANSACTION_SALESTRANSACTION_HK]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Link_HK] AS [Link_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[FK_LOYALTYCARD_LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
            ,[BG_Source].[LOYALTYCARD_LOYALTYCARD_HK] AS [LOYALTYCARD_LOYALTYCARD_HK]
            ,[BG_Source].[FK_ITEMUNITOFMEASURE_ITEM_ID] AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
            ,[BG_Source].[FK_ITEMUNITOFMEASURE_UOM] AS [FK_ITEMUNITOFMEASURE_UOM]
            ,[BG_Source].[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK] AS [ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK]
            ,[BG_Source].[FK_POS_POS_ID] AS [FK_POS_POS_ID]
            ,[BG_Source].[POS_POS_HK] AS [POS_POS_HK]
            ,[BG_Source].[FK_ITEM_ITEM_ID] AS [FK_ITEM_ITEM_ID]
            ,[BG_Source].[ITEM_ITEM_HK] AS [ITEM_ITEM_HK]
            ,[BG_Source].[FK_SALESTRANSACTION_TRANSACTION_ID] AS [FK_SALESTRANSACTION_TRANSACTION_ID]
            ,[BG_Source].[FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS [FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
            ,[BG_Source].[FK_SALESTRANSACTION_TRANSACTION_TIME] AS [FK_SALESTRANSACTION_TRANSACTION_TIME]
            ,[BG_Source].[FK_SALESTRANSACTION_POS_ID] AS [FK_SALESTRANSACTION_POS_ID]
            ,[BG_Source].[SALESTRANSACTION_SALESTRANSACTION_HK] AS [SALESTRANSACTION_SALESTRANSACTION_HK]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- SatelliteSourceView: SALESTRANSACTION_Satellite Source View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Source]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[TRANSACTION_ID] AS [FK_SALESTRANSACTION_TRANSACTION_ID]
    ,[s1].[TRANSACTION_LINE_NO] AS [FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
    ,[s1].[TRANSACTION_TIME] AS [FK_SALESTRANSACTION_TRANSACTION_TIME]
    ,[s1].[POS_ID] AS [FK_SALESTRANSACTION_POS_ID]
    ,[s1].[SALES_PRICE] AS [SALES_PRICE]
    ,[s1].[REDUCTION] AS [REDUCTION]
    ,[s1].[QUANTITY] AS [QUANTITY]
    ,[s1].[SALES_AMOUNT] AS [SALES_AMOUNT]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Result] AS [s1]
;
GO

-- SatelliteTable: SALESTRANSACTION_Satellite Table_1
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
     @sql += N'ALTER TABLE ' + QUOTENAME([ps].[name]) + N'.' + QUOTENAME([po].[name]) + N' DROP CONSTRAINT ' + QUOTENAME([c].[name]) + N';' + CHAR(13) + CHAR(10)
FROM [sys].[foreign_keys] AS [c]
JOIN [sys].[objects] AS [o]
   ON ([c].[referenced_object_id] = [o].[object_id])
JOIN [sys].[schemas] AS [s]
   ON ([s].[schema_id] = [o].[schema_id])
JOIN [sys].[objects] AS [po]
   ON ([c].[parent_object_id] = [po].[object_id])
JOIN [sys].[schemas] AS [ps]
   ON ([ps].[schema_id] = [po].[schema_id])
WHERE ([s].[name] = N'{productlaunchevent#rawvault#schema_name}')
  AND ([o].[name] = N'RDV_SAT_SALESTRANSACTION')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION]
;
GO

CREATE TABLE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[SALES_PRICE] DECIMAL(18,2) NULL
    ,[REDUCTION] DECIMAL(18,2) NULL
    ,[QUANTITY] DECIMAL(18,3) NULL
    ,[SALES_AMOUNT] DECIMAL(18,2) NULL
    ,CONSTRAINT [PK_RDV_SAT_SALESTRANSACTION] PRIMARY KEY CLUSTERED ([Hub_HK], [BG_ValidFromTimestamp])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_RDV_SAT_SALESTRANSACTION_SALESTRANSACTION] ON [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION] ([Hub_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[SALES_PRICE]
        ,[REDUCTION]
        ,[QUANTITY]
        ,[SALES_AMOUNT]
    )
    SELECT
         N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [Hub_HK]
        ,N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,0 AS [SALES_PRICE]
        ,0 AS [REDUCTION]
        ,0 AS [QUANTITY]
        ,0 AS [SALES_AMOUNT]
    ;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- SatelliteHashingView: SALESTRANSACTION_Satellite Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_TIME] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_POS_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL(CAST([SALES_PRICE] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([REDUCTION] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([QUANTITY] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([SALES_AMOUNT] AS NVARCHAR(4000)), N'_NULL_')) AS [BG_RowHash]
    ,[FK_SALESTRANSACTION_TRANSACTION_ID] AS [FK_SALESTRANSACTION_TRANSACTION_ID]
    ,[FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS [FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
    ,[FK_SALESTRANSACTION_TRANSACTION_TIME] AS [FK_SALESTRANSACTION_TRANSACTION_TIME]
    ,[FK_SALESTRANSACTION_POS_ID] AS [FK_SALESTRANSACTION_POS_ID]
    ,[SALES_PRICE] AS [SALES_PRICE]
    ,[REDUCTION] AS [REDUCTION]
    ,[QUANTITY] AS [QUANTITY]
    ,[SALES_AMOUNT] AS [SALES_AMOUNT]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Source]
;
GO

-- SatelliteResultView: SALESTRANSACTION_Satellite Result View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Result]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[SALES_PRICE] AS [SALES_PRICE]
    ,[REDUCTION] AS [REDUCTION]
    ,[QUANTITY] AS [QUANTITY]
    ,[SALES_AMOUNT] AS [SALES_AMOUNT]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION]
WHERE [Hub_HK] <> 0
;
GO

-- SatelliteDeltaView: SALESTRANSACTION_Satellite Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Delta]
;
GO

CREATE VIEW [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
    ,[BG_Source].[REDUCTION] AS [REDUCTION]
    ,[BG_Source].[QUANTITY] AS [QUANTITY]
    ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = N'99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteLoader: SALESTRANSACTION_Satellite Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[Hub_HK]
            ,[BG_SourceSystem]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[SALES_PRICE]
            ,[REDUCTION]
            ,[QUANTITY]
            ,[SALES_AMOUNT]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[Hub_HK] AS [Hub_HK]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
            ,[BG_Source].[REDUCTION] AS [REDUCTION]
            ,[BG_Source].[QUANTITY] AS [QUANTITY]
            ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
        FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Delta] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- RawVaultFooter

