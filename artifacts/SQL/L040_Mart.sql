-- MartHeader
USE [master];
GO
IF DB_ID(N'{productlaunchevent#mart#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{productlaunchevent#mart#database_name}];
    ALTER DATABASE [{productlaunchevent#mart#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{productlaunchevent#mart#database_name}];
GO
IF SCHEMA_ID(N'{productlaunchevent#mart#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{productlaunchevent#mart#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- MartDimensionTable: BRANCH_Mart Dimension Table_1
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
WHERE ([s].[name] = N'{productlaunchevent#mart#schema_name}')
  AND ([o].[name] = N'DM_MD_BRANCH')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH]
;
GO

CREATE TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[BRANCH_SK] INT IDENTITY NOT NULL
    ,[BRANCH_BK] INT NOT NULL
    ,[BRANCH_NAME] VARCHAR(50) NULL
    ,[MARKET_SIZE] VARCHAR(10) NULL
    ,[LOCATION_SINCE] INT NULL
    ,[RETAIL_SPACE_M2] INT NULL
    ,[ARTICLE_NUMBER_APPROX] INT NULL
    ,[ZIP_CODE] VARCHAR(20) NULL
    ,CONSTRAINT [PK_DM_MD_BRANCH] PRIMARY KEY CLUSTERED ([BRANCH_SK])
    ,CONSTRAINT [UC_DM_MD_BRANCH] UNIQUE NONCLUSTERED ([BG_ValidFromTimestamp], [BRANCH_BK])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH] ON;

    INSERT
    INTO [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH] WITH(TABLOCK) (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[BRANCH_SK]
        ,[BRANCH_BK]
        ,[BRANCH_NAME]
        ,[MARKET_SIZE]
        ,[LOCATION_SINCE]
        ,[RETAIL_SPACE_M2]
        ,[ARTICLE_NUMBER_APPROX]
        ,[ZIP_CODE]
    )
    SELECT
         N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_LoadTimestamp]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,-1 AS [BRANCH_SK]
        ,0 AS [BRANCH_BK]
        ,N'Unknown' AS [BRANCH_NAME]
        ,N'Unknown' AS [MARKET_SIZE]
        ,0 AS [LOCATION_SINCE]
        ,0 AS [RETAIL_SPACE_M2]
        ,0 AS [ARTICLE_NUMBER_APPROX]
        ,N'Unknown' AS [ZIP_CODE]
    ;
    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH] OFF;

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

-- MartDimensionSourceView: BRANCH_Mart Dimension Source View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Source]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[BRANCH_ID] AS [BRANCH_BK]
    ,[s2].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[s2].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[s2].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[s2].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[s2].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[s2].[ZIP_CODE] AS [ZIP_CODE]
    ,CAST(ISNULL([s2].[BG_ValidFromTimestamp], N'19000101') AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp_s2]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_BRANCH_Result] AS [s1]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Result] AS [s2]
   ON [s2].[Hub_HK] = [s1].[Hub_HK]
;
GO

-- MartDimensionMultiVersionView: BRANCH_Mart Dimension Multi Version View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Versioning]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Versioning]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Versioning]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BRANCH_BK] AS [BRANCH_BK]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[BG_ValidFromTimestamp_s2] AS [BG_ValidFromTimestamp]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Source] AS [BG_Source]
;
GO

-- MartDimensionScdView: BRANCH_Mart Dimension Scd View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Scd]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Scd]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Scd]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BRANCH_BK] AS [BRANCH_BK]
    ,[BRANCH_NAME] AS [BRANCH_NAME]
    ,[MARKET_SIZE] AS [MARKET_SIZE]
    ,[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Versioning] AS [BG_Source]
;
GO

-- MartDimensionHashingView: BRANCH_Mart Dimension Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Hashing]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([BRANCH_NAME], N'_NULL_') + N'_' + ISNULL([MARKET_SIZE], N'_NULL_') + N'_' + ISNULL(CAST([LOCATION_SINCE] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([RETAIL_SPACE_M2] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([ARTICLE_NUMBER_APPROX] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([ZIP_CODE], N'_NULL_')) AS [BG_RowHash]
    ,[BG_Source].[BRANCH_BK] AS [BRANCH_BK]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Scd] AS [BG_Source]
;
GO

-- MartDimensionResultView: BRANCH_Mart Dimension Result View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Result]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [BRANCH_BK] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[BRANCH_SK] AS [BRANCH_SK]
    ,[BG_Source].[BRANCH_BK] AS [BRANCH_BK]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH] AS [BG_Source]
;
GO

-- MartDimensionRowCondensingView: BRANCH_Mart Dimension RowCondensing View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_RowCondensing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_RowCondensing]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_RowCondensing]
AS
SELECT
     [compare].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[compare].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[compare].[BG_RowHash] AS [BG_RowHash]
    ,[compare].[BRANCH_BK] AS [BRANCH_BK]
    ,[compare].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[compare].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[compare].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[compare].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[compare].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[compare].[ZIP_CODE] AS [ZIP_CODE]
FROM (
    SELECT
         [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[BRANCH_BK] AS [BRANCH_BK]
        ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
        ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
        ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
        ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
        ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
        ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
        ,CASE WHEN [BG_RowHash] = LAG([BG_RowHash]) OVER (PARTITION BY [BRANCH_BK] ORDER BY [BG_ValidFromTimestamp]) THEN 1 ELSE 0 END AS [SameHash]
    FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Hashing] AS [BG_Source]
) AS [compare]
WHERE [compare].[SameHash] = 0
;
GO

-- MartDimensionDeltaView: BRANCH_Mart Dimension Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Delta]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[BRANCH_BK] AS [BRANCH_BK]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_RowCondensing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Result] AS [BG_Target]
   ON ([BG_Source].[BRANCH_BK] = [BG_Target].[BRANCH_BK])
  AND ([BG_Source].[BG_ValidFromTimestamp] = [BG_Target].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
WHERE [BG_Target].[BRANCH_SK] IS NULL
;
GO

-- MartDimensionLoader: BRANCH_Mart Dimension Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Loader]
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

        UPDATE [BG_Target] WITH(TABLOCK)
        SET
             [BG_SourceSystem] = [BG_Source].[BG_SourceSystem]
            ,[BG_LoadTimestamp] = [BG_Source].[BG_LoadTimestamp]
            ,[BG_RowHash] = [BG_Source].[BG_RowHash]
        FROM [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
                ,@LoadTimestamp AS [BG_LoadTimestamp]
                ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
                ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
                ,CAST(NULL AS INT) AS [BRANCH_SK]
                ,[BG_Source].[BRANCH_BK] AS [BRANCH_BK]
                ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
                ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
                ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
                ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
                ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
                ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
            FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Delta] AS [BG_Source]
        ) AS [BG_Source]
           ON ([BG_Source].[BRANCH_BK] = [BG_Target].[BRANCH_BK])
          AND ([BG_Source].[BG_ValidFromTimestamp] = [BG_Target].[BG_ValidFromTimestamp])
        ;
        INSERT
        INTO [{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH] WITH(TABLOCK) (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[BRANCH_BK]
            ,[BRANCH_NAME]
            ,[MARKET_SIZE]
            ,[LOCATION_SINCE]
            ,[RETAIL_SPACE_M2]
            ,[ARTICLE_NUMBER_APPROX]
            ,[ZIP_CODE]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[BRANCH_BK] AS [BRANCH_BK]
            ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
            ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
            ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
            ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
            ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
        FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Delta] AS [BG_Source]
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

-- MartDimensionTable: Customer_Current_Mart Dimension Table_1
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
WHERE ([s].[name] = N'{productlaunchevent#mart#schema_name}')
  AND ([o].[name] = N'DM_MD_Customer_Current')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current]
;
GO

CREATE TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[Customer_Current_SK] INT IDENTITY NOT NULL
    ,[CUSTOMER_ID] DECIMAL(38) NOT NULL
    ,[CUSTOMER] VARCHAR(100) NULL
    ,[CUSTOMER_TYPE] VARCHAR(100) NULL
    ,[CUSTOMER_SINCE] DATE NULL
    ,[ADDRESS_LINE1] VARCHAR(100) NULL
    ,[ADDRESS_LINE2] VARCHAR(100) NULL
    ,[ADDRESS_LINE3] VARCHAR(100) NULL
    ,[ZIP_CODE] VARCHAR(20) NULL
    ,CONSTRAINT [PK_DM_MD_Customer_Current] PRIMARY KEY CLUSTERED ([Customer_Current_SK])
    ,CONSTRAINT [UC_DM_MD_Customer_Current] UNIQUE NONCLUSTERED ([CUSTOMER_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current] ON;

    INSERT
    INTO [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current] WITH(TABLOCK) (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_RowHash]
        ,[Customer_Current_SK]
        ,[CUSTOMER_ID]
        ,[CUSTOMER]
        ,[CUSTOMER_TYPE]
        ,[CUSTOMER_SINCE]
        ,[ADDRESS_LINE1]
        ,[ADDRESS_LINE2]
        ,[ADDRESS_LINE3]
        ,[ZIP_CODE]
    )
    SELECT
         N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_LoadTimestamp]
        ,N'0' AS [BG_RowHash]
        ,-1 AS [Customer_Current_SK]
        ,0 AS [CUSTOMER_ID]
        ,N'Unknown' AS [CUSTOMER]
        ,N'Unknown' AS [CUSTOMER_TYPE]
        ,N'19000101' AS [CUSTOMER_SINCE]
        ,N'Unknown' AS [ADDRESS_LINE1]
        ,N'Unknown' AS [ADDRESS_LINE2]
        ,N'Unknown' AS [ADDRESS_LINE3]
        ,N'Unknown' AS [ZIP_CODE]
    ;
    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current] OFF;

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

-- MartDimensionSourceView: Customer_Current_Mart Dimension Source View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Source]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[s1].[CUSTOMER] AS [CUSTOMER]
    ,[s1].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[s1].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[s1].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[s1].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_Current_Customer_Current] AS [s1]
;
GO

-- MartDimensionHashingView: Customer_Current_Mart Dimension Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Hashing]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,HASHBYTES('SHA1', ISNULL([CUSTOMER], N'_NULL_') + N'_' + ISNULL([CUSTOMER_TYPE], N'_NULL_') + N'_' + ISNULL(CAST([CUSTOMER_SINCE] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE1], N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE2], N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE3], N'_NULL_') + N'_' + ISNULL([ZIP_CODE], N'_NULL_')) AS [BG_RowHash]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Source] AS [BG_Source]
;
GO

-- MartDimensionResultView: Customer_Current_Mart Dimension Result View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Result]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[Customer_Current_SK] AS [Customer_Current_SK]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current] AS [BG_Source]
;
GO

-- MartDimensionDeltaView: Customer_Current_Mart Dimension Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Delta]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Result] AS [BG_Target]
   ON ([BG_Source].[CUSTOMER_ID] = [BG_Target].[CUSTOMER_ID])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
WHERE [BG_Target].[Customer_Current_SK] IS NULL
;
GO

-- MartDimensionLoader: Customer_Current_Mart Dimension Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Loader]
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

        UPDATE [BG_Target] WITH(TABLOCK)
        SET
             [BG_SourceSystem] = [BG_Source].[BG_SourceSystem]
            ,[BG_LoadTimestamp] = [BG_Source].[BG_LoadTimestamp]
            ,[BG_RowHash] = [BG_Source].[BG_RowHash]
            ,[CUSTOMER] = [BG_Source].[CUSTOMER]
            ,[CUSTOMER_TYPE] = [BG_Source].[CUSTOMER_TYPE]
            ,[CUSTOMER_SINCE] = [BG_Source].[CUSTOMER_SINCE]
            ,[ADDRESS_LINE1] = [BG_Source].[ADDRESS_LINE1]
            ,[ADDRESS_LINE2] = [BG_Source].[ADDRESS_LINE2]
            ,[ADDRESS_LINE3] = [BG_Source].[ADDRESS_LINE3]
            ,[ZIP_CODE] = [BG_Source].[ZIP_CODE]
        FROM [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
                ,@LoadTimestamp AS [BG_LoadTimestamp]
                ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
                ,CAST(NULL AS INT) AS [Customer_Current_SK]
                ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
                ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
                ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
                ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
                ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
                ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
                ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
                ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
            FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Delta] AS [BG_Source]
        ) AS [BG_Source]
           ON [BG_Source].[CUSTOMER_ID] = [BG_Target].[CUSTOMER_ID]
        ;
        INSERT
        INTO [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current] WITH(TABLOCK) (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_RowHash]
            ,[CUSTOMER_ID]
            ,[CUSTOMER]
            ,[CUSTOMER_TYPE]
            ,[CUSTOMER_SINCE]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ZIP_CODE]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
            ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
            ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
            ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
        FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Delta] AS [BG_Source]
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

-- MartDimensionTable: Customer_History_Mart Dimension Table_1
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
WHERE ([s].[name] = N'{productlaunchevent#mart#schema_name}')
  AND ([o].[name] = N'DM_MD_Customer_History')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History]
;
GO

CREATE TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[Customer_History_SK] INT IDENTITY NOT NULL
    ,[CUSTOMER_ID] DECIMAL(38) NOT NULL
    ,[ADDRESS_LINE1] VARCHAR(100) NULL
    ,[ADDRESS_LINE2] VARCHAR(100) NULL
    ,[ADDRESS_LINE3] VARCHAR(100) NULL
    ,[ZIP_CODE] VARCHAR(20) NULL
    ,[CUSTOMER] VARCHAR(100) NULL
    ,[CUSTOMER_TYPE] VARCHAR(100) NULL
    ,[CUSTOMER_SINCE] DATE NULL
    ,CONSTRAINT [PK_DM_MD_Customer_History] PRIMARY KEY CLUSTERED ([Customer_History_SK])
    ,CONSTRAINT [UC_DM_MD_Customer_History] UNIQUE NONCLUSTERED ([BG_ValidFromTimestamp], [CUSTOMER_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History] ON;

    INSERT
    INTO [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History] WITH(TABLOCK) (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[Customer_History_SK]
        ,[CUSTOMER_ID]
        ,[ADDRESS_LINE1]
        ,[ADDRESS_LINE2]
        ,[ADDRESS_LINE3]
        ,[ZIP_CODE]
        ,[CUSTOMER]
        ,[CUSTOMER_TYPE]
        ,[CUSTOMER_SINCE]
    )
    SELECT
         N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_LoadTimestamp]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,-1 AS [Customer_History_SK]
        ,0 AS [CUSTOMER_ID]
        ,N'Unknown' AS [ADDRESS_LINE1]
        ,N'Unknown' AS [ADDRESS_LINE2]
        ,N'Unknown' AS [ADDRESS_LINE3]
        ,N'Unknown' AS [ZIP_CODE]
        ,N'Unknown' AS [CUSTOMER]
        ,N'Unknown' AS [CUSTOMER_TYPE]
        ,N'19000101' AS [CUSTOMER_SINCE]
    ;
    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History] OFF;

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

-- MartDimensionSourceView: Customer_History_Mart Dimension Source View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Source]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[s1].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[s1].[ZIP_CODE] AS [ZIP_CODE]
    ,[s1].[CUSTOMER] AS [CUSTOMER]
    ,[s1].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[s1].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,CAST(ISNULL([s1].[BG_ValidFromTimestamp], N'19000101') AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp_s1]
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_History_Customer_History] AS [s1]
;
GO

-- MartDimensionMultiVersionView: Customer_History_Mart Dimension Multi Version View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Versioning]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Versioning]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Versioning]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[BG_Source].[BG_ValidFromTimestamp_s1] AS [BG_ValidFromTimestamp]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Source] AS [BG_Source]
;
GO

-- MartDimensionScdView: Customer_History_Mart Dimension Scd View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Scd]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Scd]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Scd]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[ZIP_CODE] AS [ZIP_CODE]
    ,[CUSTOMER] AS [CUSTOMER]
    ,[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Versioning] AS [BG_Source]
;
GO

-- MartDimensionHashingView: Customer_History_Mart Dimension Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Hashing]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([ADDRESS_LINE1], N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE2], N'_NULL_') + N'_' + ISNULL([ADDRESS_LINE3], N'_NULL_') + N'_' + ISNULL([ZIP_CODE], N'_NULL_') + N'_' + ISNULL([CUSTOMER], N'_NULL_') + N'_' + ISNULL([CUSTOMER_TYPE], N'_NULL_') + N'_' + ISNULL(CAST([CUSTOMER_SINCE] AS NVARCHAR(4000)), N'_NULL_')) AS [BG_RowHash]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Scd] AS [BG_Source]
;
GO

-- MartDimensionResultView: Customer_History_Mart Dimension Result View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Result]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[Customer_History_SK] AS [Customer_History_SK]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History] AS [BG_Source]
;
GO

-- MartDimensionRowCondensingView: Customer_History_Mart Dimension RowCondensing View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_RowCondensing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_RowCondensing]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_RowCondensing]
AS
SELECT
     [compare].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[compare].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[compare].[BG_RowHash] AS [BG_RowHash]
    ,[compare].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[compare].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[compare].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[compare].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[compare].[ZIP_CODE] AS [ZIP_CODE]
    ,[compare].[CUSTOMER] AS [CUSTOMER]
    ,[compare].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[compare].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM (
    SELECT
         [AllSourceRows].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[AllSourceRows].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
        ,[AllSourceRows].[BG_RowHash] AS [BG_RowHash]
        ,[AllSourceRows].[CUSTOMER_ID] AS [CUSTOMER_ID]
        ,[AllSourceRows].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
        ,[AllSourceRows].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
        ,[AllSourceRows].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
        ,[AllSourceRows].[ZIP_CODE] AS [ZIP_CODE]
        ,[AllSourceRows].[CUSTOMER] AS [CUSTOMER]
        ,[AllSourceRows].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
        ,[AllSourceRows].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
        ,CASE WHEN [BG_RowHash] = LAG([BG_RowHash]) OVER (PARTITION BY [CUSTOMER_ID] ORDER BY [BG_ValidFromTimestamp]) THEN 1 ELSE 0 END AS [SameHash]
    FROM (
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
            ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
            ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
            ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
        FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Hashing] AS [BG_Source]
        UNION ALL
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
            ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
            ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
            ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
        FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Result] AS [BG_Source]
        WHERE [BG_Source].[BG_ValidToTimestamp] = N'99991231'
    ) AS [AllSourceRows]
) AS [compare]
WHERE [compare].[SameHash] = 0
;
GO

-- MartDimensionDeltaView: Customer_History_Mart Dimension Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Delta]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_RowCondensing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Result] AS [BG_Target]
   ON ([BG_Source].[CUSTOMER_ID] = [BG_Target].[CUSTOMER_ID])
  AND ([BG_Source].[BG_ValidFromTimestamp] = [BG_Target].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
WHERE [BG_Target].[Customer_History_SK] IS NULL
;
GO

-- MartDimensionLoader: Customer_History_Mart Dimension Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Loader]
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

        UPDATE [BG_Target] WITH(TABLOCK)
        SET
             [BG_SourceSystem] = [BG_Source].[BG_SourceSystem]
            ,[BG_LoadTimestamp] = [BG_Source].[BG_LoadTimestamp]
            ,[BG_RowHash] = [BG_Source].[BG_RowHash]
        FROM [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
                ,@LoadTimestamp AS [BG_LoadTimestamp]
                ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
                ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
                ,CAST(NULL AS INT) AS [Customer_History_SK]
                ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
                ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
                ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
                ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
                ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
                ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
                ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
                ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
            FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Delta] AS [BG_Source]
        ) AS [BG_Source]
           ON ([BG_Source].[CUSTOMER_ID] = [BG_Target].[CUSTOMER_ID])
          AND ([BG_Source].[BG_ValidFromTimestamp] = [BG_Target].[BG_ValidFromTimestamp])
        ;
        INSERT
        INTO [{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History] WITH(TABLOCK) (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[CUSTOMER_ID]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ZIP_CODE]
            ,[CUSTOMER]
            ,[CUSTOMER_TYPE]
            ,[CUSTOMER_SINCE]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
            ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
            ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
            ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
        FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Delta] AS [BG_Source]
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

-- MartDimensionTable: ITEM_Mart Dimension Table_1
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
WHERE ([s].[name] = N'{productlaunchevent#mart#schema_name}')
  AND ([o].[name] = N'DM_MD_ITEM')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM]
;
GO

CREATE TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[ITEM_SK] INT IDENTITY NOT NULL
    ,[ITEM_ID1] DECIMAL(38) NOT NULL
    ,[DESCRIPTION] VARCHAR(1000) NULL
    ,[BASE_UOM] VARCHAR(10) NULL
    ,[SALES_UOM] VARCHAR(10) NULL
    ,CONSTRAINT [PK_DM_MD_ITEM] PRIMARY KEY CLUSTERED ([ITEM_SK])
    ,CONSTRAINT [UC_DM_MD_ITEM] UNIQUE NONCLUSTERED ([BG_ValidFromTimestamp], [ITEM_ID1])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM] ON;

    INSERT
    INTO [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM] WITH(TABLOCK) (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[ITEM_SK]
        ,[ITEM_ID1]
        ,[DESCRIPTION]
        ,[BASE_UOM]
        ,[SALES_UOM]
    )
    SELECT
         N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_LoadTimestamp]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,-1 AS [ITEM_SK]
        ,0 AS [ITEM_ID1]
        ,N'Unknown' AS [DESCRIPTION]
        ,N'Unknown' AS [BASE_UOM]
        ,N'Unknown' AS [SALES_UOM]
    ;
    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM] OFF;

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

-- MartDimensionSourceView: ITEM_Mart Dimension Source View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Source]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[ITEM_ID] AS [ITEM_ID1]
    ,[s2].[DESCRIPTION] AS [DESCRIPTION]
    ,[s2].[BASE_UOM] AS [BASE_UOM]
    ,[s2].[SALES_UOM] AS [SALES_UOM]
    ,CAST(ISNULL([s2].[BG_ValidFromTimestamp], N'19000101') AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp_s2]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Result] AS [s1]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Result] AS [s2]
   ON [s2].[Hub_HK] = [s1].[Hub_HK]
;
GO

-- MartDimensionMultiVersionView: ITEM_Mart Dimension Multi Version View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Versioning]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Versioning]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Versioning]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
    ,[BG_Source].[BG_ValidFromTimestamp_s2] AS [BG_ValidFromTimestamp]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Source] AS [BG_Source]
;
GO

-- MartDimensionScdView: ITEM_Mart Dimension Scd View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Scd]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Scd]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Scd]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[ITEM_ID1] AS [ITEM_ID1]
    ,[DESCRIPTION] AS [DESCRIPTION]
    ,[BASE_UOM] AS [BASE_UOM]
    ,[SALES_UOM] AS [SALES_UOM]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Versioning] AS [BG_Source]
;
GO

-- MartDimensionHashingView: ITEM_Mart Dimension Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Hashing]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([DESCRIPTION], N'_NULL_') + N'_' + ISNULL([BASE_UOM], N'_NULL_') + N'_' + ISNULL([SALES_UOM], N'_NULL_')) AS [BG_RowHash]
    ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Scd] AS [BG_Source]
;
GO

-- MartDimensionResultView: ITEM_Mart Dimension Result View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Result]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [ITEM_ID1] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[ITEM_SK] AS [ITEM_SK]
    ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM] AS [BG_Source]
;
GO

-- MartDimensionRowCondensingView: ITEM_Mart Dimension RowCondensing View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_RowCondensing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_RowCondensing]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_RowCondensing]
AS
SELECT
     [compare].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[compare].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[compare].[BG_RowHash] AS [BG_RowHash]
    ,[compare].[ITEM_ID1] AS [ITEM_ID1]
    ,[compare].[DESCRIPTION] AS [DESCRIPTION]
    ,[compare].[BASE_UOM] AS [BASE_UOM]
    ,[compare].[SALES_UOM] AS [SALES_UOM]
FROM (
    SELECT
         [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
        ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
        ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
        ,CASE WHEN [BG_RowHash] = LAG([BG_RowHash]) OVER (PARTITION BY [ITEM_ID1] ORDER BY [BG_ValidFromTimestamp]) THEN 1 ELSE 0 END AS [SameHash]
    FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Hashing] AS [BG_Source]
) AS [compare]
WHERE [compare].[SameHash] = 0
;
GO

-- MartDimensionDeltaView: ITEM_Mart Dimension Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Delta]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_RowCondensing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Result] AS [BG_Target]
   ON ([BG_Source].[ITEM_ID1] = [BG_Target].[ITEM_ID1])
  AND ([BG_Source].[BG_ValidFromTimestamp] = [BG_Target].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
WHERE [BG_Target].[ITEM_SK] IS NULL
;
GO

-- MartDimensionLoader: ITEM_Mart Dimension Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Loader]
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

        UPDATE [BG_Target] WITH(TABLOCK)
        SET
             [BG_SourceSystem] = [BG_Source].[BG_SourceSystem]
            ,[BG_LoadTimestamp] = [BG_Source].[BG_LoadTimestamp]
            ,[BG_RowHash] = [BG_Source].[BG_RowHash]
        FROM [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
                ,@LoadTimestamp AS [BG_LoadTimestamp]
                ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
                ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
                ,CAST(NULL AS INT) AS [ITEM_SK]
                ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
                ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
                ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
                ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
            FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Delta] AS [BG_Source]
        ) AS [BG_Source]
           ON ([BG_Source].[ITEM_ID1] = [BG_Target].[ITEM_ID1])
          AND ([BG_Source].[BG_ValidFromTimestamp] = [BG_Target].[BG_ValidFromTimestamp])
        ;
        INSERT
        INTO [{productlaunchevent#mart#schema_name}].[DM_MD_ITEM] WITH(TABLOCK) (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[ITEM_ID1]
            ,[DESCRIPTION]
            ,[BASE_UOM]
            ,[SALES_UOM]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
            ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
        FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Delta] AS [BG_Source]
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

-- MartDimensionTable: ITEMUNITOFMEASURE_Mart Dimension Table_1
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
WHERE ([s].[name] = N'{productlaunchevent#mart#schema_name}')
  AND ([o].[name] = N'DM_MD_ITEMUNITOFMEASURE')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE]
;
GO

CREATE TABLE [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] NVARCHAR(20) NOT NULL
    ,[ITEMUNITOFMEASURE_SK] INT IDENTITY NOT NULL
    ,[ITEM_ID] DECIMAL(38) NOT NULL
    ,[UOM] VARCHAR(10) NOT NULL
    ,[DESCRIPTION] VARCHAR(100) NULL
    ,[QTY_PER_BASE_UOM] INT NULL
    ,[BASE_UOM] VARCHAR(10) NULL
    ,CONSTRAINT [PK_DM_MD_ITEMUNITOFMEASURE] PRIMARY KEY CLUSTERED ([ITEMUNITOFMEASURE_SK])
    ,CONSTRAINT [UC_DM_MD_ITEMUNITOFMEASURE] UNIQUE NONCLUSTERED ([BG_ValidFromTimestamp], [ITEM_ID], [UOM])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE] ON;

    INSERT
    INTO [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE] WITH(TABLOCK) (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[ITEMUNITOFMEASURE_SK]
        ,[ITEM_ID]
        ,[UOM]
        ,[DESCRIPTION]
        ,[QTY_PER_BASE_UOM]
        ,[BASE_UOM]
    )
    SELECT
         N'Unknown' AS [BG_SourceSystem]
        ,N'19000101' AS [BG_LoadTimestamp]
        ,N'19000101' AS [BG_ValidFromTimestamp]
        ,N'0' AS [BG_RowHash]
        ,-1 AS [ITEMUNITOFMEASURE_SK]
        ,0 AS [ITEM_ID]
        ,N'Unknown' AS [UOM]
        ,N'Unknown' AS [DESCRIPTION]
        ,0 AS [QTY_PER_BASE_UOM]
        ,N'Unknown' AS [BASE_UOM]
    ;
    SET IDENTITY_INSERT [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE] OFF;

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

-- MartDimensionSourceView: ITEMUNITOFMEASURE_Mart Dimension Source View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Source]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
    ,[s1].[UOM] AS [UOM]
    ,[s2].[DESCRIPTION] AS [DESCRIPTION]
    ,[s2].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[s2].[BASE_UOM] AS [BASE_UOM]
    ,CAST(ISNULL([s2].[BG_ValidFromTimestamp], N'19000101') AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp_s2]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Result] AS [s1]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Result] AS [s2]
   ON [s2].[Hub_HK] = [s1].[Hub_HK]
;
GO

-- MartDimensionMultiVersionView: ITEMUNITOFMEASURE_Mart Dimension Multi Version View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Versioning]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Versioning]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Versioning]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[UOM] AS [UOM]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[BG_ValidFromTimestamp_s2] AS [BG_ValidFromTimestamp]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Source] AS [BG_Source]
;
GO

-- MartDimensionScdView: ITEMUNITOFMEASURE_Mart Dimension Scd View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Scd]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Scd]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Scd]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[ITEM_ID] AS [ITEM_ID]
    ,[UOM] AS [UOM]
    ,[DESCRIPTION] AS [DESCRIPTION]
    ,[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BASE_UOM] AS [BASE_UOM]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Versioning] AS [BG_Source]
;
GO

-- MartDimensionHashingView: ITEMUNITOFMEASURE_Mart Dimension Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Hashing]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([DESCRIPTION], N'_NULL_') + N'_' + ISNULL(CAST([QTY_PER_BASE_UOM] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([BASE_UOM], N'_NULL_')) AS [BG_RowHash]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[UOM] AS [UOM]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Scd] AS [BG_Source]
;
GO

-- MartDimensionResultView: ITEMUNITOFMEASURE_Mart Dimension Result View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Result]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [ITEM_ID], [UOM] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[ITEMUNITOFMEASURE_SK] AS [ITEMUNITOFMEASURE_SK]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[UOM] AS [UOM]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE] AS [BG_Source]
;
GO

-- MartDimensionRowCondensingView: ITEMUNITOFMEASURE_Mart Dimension RowCondensing View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_RowCondensing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_RowCondensing]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_RowCondensing]
AS
SELECT
     [compare].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[compare].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[compare].[BG_RowHash] AS [BG_RowHash]
    ,[compare].[ITEM_ID] AS [ITEM_ID]
    ,[compare].[UOM] AS [UOM]
    ,[compare].[DESCRIPTION] AS [DESCRIPTION]
    ,[compare].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[compare].[BASE_UOM] AS [BASE_UOM]
FROM (
    SELECT
         [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
        ,[BG_Source].[UOM] AS [UOM]
        ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
        ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
        ,CASE WHEN [BG_RowHash] = LAG([BG_RowHash]) OVER (PARTITION BY [ITEM_ID], [UOM] ORDER BY [BG_ValidFromTimestamp]) THEN 1 ELSE 0 END AS [SameHash]
    FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Hashing] AS [BG_Source]
) AS [compare]
WHERE [compare].[SameHash] = 0
;
GO

-- MartDimensionDeltaView: ITEMUNITOFMEASURE_Mart Dimension Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Delta]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[UOM] AS [UOM]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_RowCondensing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Result] AS [BG_Target]
   ON ([BG_Source].[ITEM_ID] = [BG_Target].[ITEM_ID])
  AND ([BG_Source].[UOM] = [BG_Target].[UOM])
  AND ([BG_Source].[BG_ValidFromTimestamp] = [BG_Target].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
WHERE [BG_Target].[ITEMUNITOFMEASURE_SK] IS NULL
;
GO

-- MartDimensionLoader: ITEMUNITOFMEASURE_Mart Dimension Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Loader]
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

        UPDATE [BG_Target] WITH(TABLOCK)
        SET
             [BG_SourceSystem] = [BG_Source].[BG_SourceSystem]
            ,[BG_LoadTimestamp] = [BG_Source].[BG_LoadTimestamp]
            ,[BG_RowHash] = [BG_Source].[BG_RowHash]
        FROM [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
                ,@LoadTimestamp AS [BG_LoadTimestamp]
                ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
                ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
                ,CAST(NULL AS INT) AS [ITEMUNITOFMEASURE_SK]
                ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
                ,[BG_Source].[UOM] AS [UOM]
                ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
                ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
                ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
            FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Delta] AS [BG_Source]
        ) AS [BG_Source]
           ON ([BG_Source].[ITEM_ID] = [BG_Target].[ITEM_ID])
          AND ([BG_Source].[UOM] = [BG_Target].[UOM])
          AND ([BG_Source].[BG_ValidFromTimestamp] = [BG_Target].[BG_ValidFromTimestamp])
        ;
        INSERT
        INTO [{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE] WITH(TABLOCK) (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_RowHash]
            ,[ITEM_ID]
            ,[UOM]
            ,[DESCRIPTION]
            ,[QTY_PER_BASE_UOM]
            ,[BASE_UOM]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[UOM] AS [UOM]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
        FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Delta] AS [BG_Source]
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

-- MartFactTable: Sales_upd_Mart Fact Table_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd]
;
GO

CREATE TABLE [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BRANCH_BRANCH_SK] INT NOT NULL
    ,[Customer_History_Customer_History_SK] INT NOT NULL
    ,[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_SK] INT NOT NULL
    ,[ITEM_ITEM_SK] INT NOT NULL
    ,[SALES_PRICE] DECIMAL(18,2) NULL
    ,[REDUCTION] DECIMAL(18,2) NULL
    ,[QUANTITY] DECIMAL(18,3) NULL
    ,[SALES_AMOUNT] DECIMAL(18,2) NULL
)
;
GO
CREATE NONCLUSTERED INDEX [IX_DM_MF_Sales_upd_BRANCH] ON [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd] ([BRANCH_BRANCH_SK]);
CREATE NONCLUSTERED INDEX [IX_DM_MF_Sales_upd_Customer_History] ON [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd] ([Customer_History_Customer_History_SK]);
CREATE NONCLUSTERED INDEX [IX_DM_MF_Sales_upd_ITEMUNITOFMEASURE] ON [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd] ([ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_SK]);
CREATE NONCLUSTERED INDEX [IX_DM_MF_Sales_upd_ITEM] ON [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd] ([ITEM_ITEM_SK]);
GO

-- MartFactIncrementTable: Sales_upd_Mart Fact Increment Table_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Increment]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Increment]
;
GO

CREATE TABLE [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Increment] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_DataflowName] NVARCHAR(255) NULL
    ,[BG_ID] INT IDENTITY NOT NULL
    ,[BG_IncrementalFilter] DATETIMEOFFSET NULL
    ,[BG_DataflowSetName] NVARCHAR(255) NULL
    ,CONSTRAINT [PK_DM_MF_Sales_upd_Increment] PRIMARY KEY CLUSTERED ([BG_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Increment] WITH(TABLOCK) (
         [BG_LoadTimestamp]
        ,[BG_DataflowName]
        ,[BG_IncrementalFilter]
        ,[BG_DataflowSetName]
    )
    SELECT
         N'19000101'
        ,N'Dataflow1'
        ,NULL
        ,N'Set1'
    WHERE NOT EXISTS (
              SELECT
                   1
              FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Increment]
              WHERE ([BG_DataflowName] = N'Dataflow1')
                AND ([BG_DataflowSetName] = N'Set1')
          )
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

-- MartFactIncrementSourceView: Sales_upd_Mart Fact Increment Source View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_IncrementSource]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_IncrementSource]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_IncrementSource]
AS
SELECT
     [sourcequery].[BG_DataflowName]
    ,MAX([sourcequery].[BG_IncrementalFilter]) AS [BG_IncrementalFilter]
    ,[sourcequery].[BG_DataflowSetName]
FROM (
    SELECT
         N'Dataflow1' AS [BG_DataflowName]
        ,[s2].[BG_LoadTimestamp] AS [BG_IncrementalFilter]
        ,N'Set1' AS [BG_DataflowSetName]
    FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Result] AS [s1]
    JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Result] AS [s2]
       ON [s2].[Hub_HK] = [s1].[SALESTRANSACTION_SALESTRANSACTION_HK]
    JOIN (
        SELECT
             [BG_IncrementalFilter] AS [BG_IncrementalFilter]
        FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Increment]
        WHERE [BG_ID] = (
                  SELECT
                       MAX([BG_ID])
                  FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Increment]
                  WHERE ([BG_DataflowName] = N'Dataflow1')
                    AND ([BG_DataflowSetName] = N'Set1')
              )
    ) AS [BG_max_inc]
       ON 1 = 1
    WHERE ([s2].[BG_LoadTimestamp] > [BG_IncrementalFilter])
       OR ([BG_IncrementalFilter] IS NULL)
) AS [sourcequery]
GROUP BY
     [sourcequery].[BG_DataflowName]
    ,[sourcequery].[BG_DataflowSetName]
;
GO

-- MartFactSourceView: Sales_upd_Mart Fact Source View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Source]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s2].[BG_LoadTimestamp] AS [BG_EffectiveTimestamp]
    ,N'Dataflow1' AS [BG_DataflowName]
    ,[s2].[BG_LoadTimestamp] AS [BG_IncrementalFilter]
    ,[s1].[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_BK]
    ,[s1].[FK_CUSTOMER_CUSTOMER_ID] AS [FK_Customer_History_CUSTOMER_ID]
    ,[s1].[FK_ITEMUNITOFMEASURE_ITEM_ID] AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
    ,[s1].[FK_ITEMUNITOFMEASURE_UOM] AS [FK_ITEMUNITOFMEASURE_UOM]
    ,[s1].[FK_ITEM_ITEM_ID] AS [FK_ITEM_ITEM_ID1]
    ,[s2].[SALES_PRICE] AS [SALES_PRICE]
    ,[s2].[REDUCTION] AS [REDUCTION]
    ,[s2].[QUANTITY] AS [QUANTITY]
    ,[s2].[SALES_AMOUNT] AS [SALES_AMOUNT]
    ,N'Set1' AS [BG_DataflowSetName]
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Result] AS [s1]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Result] AS [s2]
   ON [s2].[Hub_HK] = [s1].[SALESTRANSACTION_SALESTRANSACTION_HK]
JOIN (
    SELECT
         [BG_max_inc].[BG_IncrementLow] AS [BG_IncrementLow]
        ,[BG_max_inc].[BG_IncrementHigh] AS [BG_IncrementHigh]
    FROM (
        SELECT
             MAX(CASE WHEN [BG_all_inc].[BG_id_rank] = 2 THEN [BG_IncrementalFilter] END) AS [BG_IncrementLow]
            ,MAX(CASE WHEN [BG_all_inc].[BG_id_rank] = 1 THEN [BG_IncrementalFilter] END) AS [BG_IncrementHigh]
        FROM (
            SELECT
                 [BG_IncrementalFilter]
                ,ROW_NUMBER() OVER ( ORDER BY [BG_ID] DESC) AS [BG_id_rank]
            FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Increment]
            WHERE ([BG_DataflowName] = N'Dataflow1')
              AND ([BG_DataflowSetName] = N'Set1')
        ) AS [BG_all_inc]
        WHERE [BG_id_rank] IN (1,2)
    ) AS [BG_max_inc]
) AS [BG_inc]
   ON 1 = 1
WHERE (([s2].[BG_LoadTimestamp] > [BG_inc].[BG_IncrementLow])
  AND ([s2].[BG_LoadTimestamp] <= [BG_inc].[BG_IncrementHigh]))
   OR (([BG_inc].[BG_IncrementLow] IS NULL)
  AND ([s2].[BG_LoadTimestamp] <= [BG_inc].[BG_IncrementHigh]))
;
GO

-- MartFactResultView: Sales_upd_Mart Fact Result View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Result]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BRANCH_BRANCH_SK] AS [BRANCH_BRANCH_SK]
    ,[BG_Source].[Customer_History_Customer_History_SK] AS [Customer_History_Customer_History_SK]
    ,[BG_Source].[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_SK] AS [ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_SK]
    ,[BG_Source].[ITEM_ITEM_SK] AS [ITEM_ITEM_SK]
    ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
    ,[BG_Source].[REDUCTION] AS [REDUCTION]
    ,[BG_Source].[QUANTITY] AS [QUANTITY]
    ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd] AS [BG_Source]
;
GO

-- MartFactLookupView: Sales_upd_Mart Fact Lookup View_1
IF OBJECT_ID(N'[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Lkp]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Lkp]
;
GO

CREATE VIEW [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Lkp]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
    ,[BG_Source].[REDUCTION] AS [REDUCTION]
    ,[BG_Source].[QUANTITY] AS [QUANTITY]
    ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
    ,ISNULL([r1].[BRANCH_SK], -1) AS [BRANCH_BRANCH_SK]
    ,ISNULL([r2].[Customer_History_SK], -1) AS [Customer_History_Customer_History_SK]
    ,ISNULL([r3].[ITEMUNITOFMEASURE_SK], -1) AS [ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_SK]
    ,ISNULL([r4].[ITEM_SK], -1) AS [ITEM_ITEM_SK]
FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Source] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Result] AS [r1]
   ON ([r1].[BRANCH_BK] = [BG_Source].[FK_BRANCH_BRANCH_BK])
  AND ([BG_Source].[BG_EffectiveTimestamp] >= [r1].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_EffectiveTimestamp] < [r1].[BG_ValidToTimestamp])
LEFT OUTER JOIN [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Result] AS [r2]
   ON ([r2].[CUSTOMER_ID] = [BG_Source].[FK_Customer_History_CUSTOMER_ID])
  AND ([BG_Source].[BG_EffectiveTimestamp] >= [r2].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_EffectiveTimestamp] < [r2].[BG_ValidToTimestamp])
LEFT OUTER JOIN [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Result] AS [r3]
   ON ([r3].[ITEM_ID] = [BG_Source].[FK_ITEMUNITOFMEASURE_ITEM_ID])
  AND ([r3].[UOM] = [BG_Source].[FK_ITEMUNITOFMEASURE_UOM])
  AND ([BG_Source].[BG_EffectiveTimestamp] >= [r3].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_EffectiveTimestamp] < [r3].[BG_ValidToTimestamp])
LEFT OUTER JOIN [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Result] AS [r4]
   ON ([r4].[ITEM_ID1] = [BG_Source].[FK_ITEM_ITEM_ID1])
  AND ([BG_Source].[BG_EffectiveTimestamp] >= [r4].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_EffectiveTimestamp] < [r4].[BG_ValidToTimestamp])
;
GO

-- MartFactTruncateInsertLoader: Sales_upd_Mart Fact TruncateInsertLoader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_TruncateInsertLoader]
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

    DECLARE @IncrementRowsInserted BIGINT = 0;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT
        INTO [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Increment] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_DataflowName]
            ,[BG_IncrementalFilter]
            ,[BG_DataflowSetName]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_DataflowName]
            ,MAX([BG_IncrementalFilter])
            ,[BG_DataflowSetName]
        FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_IncrementSource] AS [BG_IncrementSource]
        WHERE [BG_DataflowName] = N'Dataflow1'
        GROUP BY
             [BG_DataflowName]
            ,[BG_DataflowSetName]
        ;

        SET @IncrementRowsInserted = (@IncrementRowsInserted + ROWCOUNT_BIG());

        IF @IncrementRowsInserted > 0
        BEGIN
            TRUNCATE TABLE [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd];

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;
            THROW;
        END CATCH;

        BEGIN TRY
            BEGIN TRANSACTION;

            INSERT
            INTO [{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd] WITH(TABLOCK) (
                 [BG_LoadTimestamp]
                ,[BG_SourceSystem]
                ,[BRANCH_BRANCH_SK]
                ,[Customer_History_Customer_History_SK]
                ,[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_SK]
                ,[ITEM_ITEM_SK]
                ,[SALES_PRICE]
                ,[REDUCTION]
                ,[QUANTITY]
                ,[SALES_AMOUNT]
            )
            SELECT
                 @LoadTimestamp AS [BG_LoadTimestamp]
                ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
                ,[BG_Source].[BRANCH_BRANCH_SK] AS [BRANCH_BRANCH_SK]
                ,[BG_Source].[Customer_History_Customer_History_SK] AS [Customer_History_Customer_History_SK]
                ,[BG_Source].[ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_SK] AS [ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_SK]
                ,[BG_Source].[ITEM_ITEM_SK] AS [ITEM_ITEM_SK]
                ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
                ,[BG_Source].[REDUCTION] AS [REDUCTION]
                ,[BG_Source].[QUANTITY] AS [QUANTITY]
                ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
            FROM [{productlaunchevent#mart#server_name}].[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_upd_Lkp] AS [BG_Source]
            ;

            SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());
        END;

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

-- MartFooter

