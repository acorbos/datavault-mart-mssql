-- BusinessVaultHeader
USE [master];
GO
IF DB_ID(N'{productlaunchevent#businessvault#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{productlaunchevent#businessvault#database_name}];
    ALTER DATABASE [{productlaunchevent#businessvault#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{productlaunchevent#businessvault#database_name}];
GO
IF SCHEMA_ID(N'{productlaunchevent#businessvault#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{productlaunchevent#businessvault#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- BusinessPitTable: CUSTOMER_PIT_Business PIT Table_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT]
;
GO

CREATE TABLE [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[PIT_HK] BINARY(20) NOT NULL
    ,[CUSTOMER_Info_CUSTOMER_Info_HK] BINARY(20) NOT NULL
    ,[CUSTOMER_Info_BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[CUSTOMER_Address_CUSTOMER_Address_HK] BINARY(20) NOT NULL
    ,[CUSTOMER_Address_BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,CONSTRAINT [PK_BDV_PIT_CUSTOMER_PIT] PRIMARY KEY CLUSTERED ([BG_ValidFromTimestamp], [PIT_HK])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_BDV_PIT_CUSTOMER_PIT_CUSTOMER_Info] ON [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT] ([CUSTOMER_Info_CUSTOMER_Info_HK],[CUSTOMER_Info_BG_ValidFromTimestamp]);
CREATE NONCLUSTERED INDEX [IX_BDV_PIT_CUSTOMER_PIT_CUSTOMER_Address] ON [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT] ([CUSTOMER_Address_CUSTOMER_Address_HK],[CUSTOMER_Address_BG_ValidFromTimestamp]);
GO

-- BusinessPitSourceView: CUSTOMER_PIT_Business PIT Source View_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Source]
;
GO

CREATE VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Source]
AS
SELECT
     [loadSet].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[loadSet].[PIT_HK] AS [PIT_HK]
    ,ISNULL(MAX([s1].[Hub_HK]), 0) AS [CUSTOMER_Info_CUSTOMER_Info_HK]
    ,ISNULL(MAX([s1].[BG_ValidFromTimestamp]), N'19000101') AS [CUSTOMER_Info_BG_ValidFromTimestamp]
    ,ISNULL(MAX([s2].[Hub_HK]), 0) AS [CUSTOMER_Address_CUSTOMER_Address_HK]
    ,ISNULL(MAX([s2].[BG_ValidFromTimestamp]), N'19000101') AS [CUSTOMER_Address_BG_ValidFromTimestamp]
FROM (
    SELECT
         [Hub_HK] AS [PIT_HK]
        ,[BG_ValidFromTimestamp]
    FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info]
    UNION
    SELECT
         [Hub_HK] AS [PIT_HK]
        ,[BG_ValidFromTimestamp]
    FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address]
) AS [loadSet]
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Result] AS [s1]
   ON ([s1].[Hub_HK] = [loadSet].[PIT_HK])
  AND ([s1].[BG_ValidFromTimestamp] <= [loadSet].[BG_ValidFromTimestamp])
LEFT OUTER JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Result] AS [s2]
   ON ([s2].[Hub_HK] = [loadSet].[PIT_HK])
  AND ([s2].[BG_ValidFromTimestamp] <= [loadSet].[BG_ValidFromTimestamp])
GROUP BY
     [loadSet].[BG_ValidFromTimestamp]
    ,[loadSet].[PIT_HK]
;
GO

-- BusinessPitResultView: CUSTOMER_PIT_Business PIT Result View_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Result]
;
GO

CREATE VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [PIT_HK] ORDER BY [BG_ValidFromTimestamp]), N'99991231') AS [BG_ValidToTimestamp]
    ,[PIT_HK] AS [PIT_HK]
    ,[CUSTOMER_Info_CUSTOMER_Info_HK] AS [CUSTOMER_Info_CUSTOMER_Info_HK]
    ,[CUSTOMER_Info_BG_ValidFromTimestamp] AS [CUSTOMER_Info_BG_ValidFromTimestamp]
    ,[CUSTOMER_Address_CUSTOMER_Address_HK] AS [CUSTOMER_Address_CUSTOMER_Address_HK]
    ,[CUSTOMER_Address_BG_ValidFromTimestamp] AS [CUSTOMER_Address_BG_ValidFromTimestamp]
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT]
WHERE [PIT_HK] <> 0
;
GO

-- BusinessPitDeltaView: CUSTOMER_PIT_Business PIT Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Delta]
;
GO

CREATE VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Delta]
AS
SELECT
     [BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[PIT_HK] AS [PIT_HK]
    ,[BG_Source].[CUSTOMER_Info_CUSTOMER_Info_HK] AS [CUSTOMER_Info_CUSTOMER_Info_HK]
    ,[BG_Source].[CUSTOMER_Info_BG_ValidFromTimestamp] AS [CUSTOMER_Info_BG_ValidFromTimestamp]
    ,[BG_Source].[CUSTOMER_Address_CUSTOMER_Address_HK] AS [CUSTOMER_Address_CUSTOMER_Address_HK]
    ,[BG_Source].[CUSTOMER_Address_BG_ValidFromTimestamp] AS [CUSTOMER_Address_BG_ValidFromTimestamp]
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Source] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT] AS [BG_Target]
   ON ([BG_Source].[PIT_HK] = [BG_Target].[PIT_HK])
  AND ([BG_Source].[BG_ValidFromTimestamp] = [BG_Target].[BG_ValidFromTimestamp])
WHERE [BG_Target].[PIT_HK] IS NULL
;
GO

-- BusinessPitLoader: CUSTOMER_PIT_Business PIT Loader_1
-- ImplementationType: Permanent
CREATE OR ALTER PROCEDURE [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Loader]
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
        INTO [{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[PIT_HK]
            ,[CUSTOMER_Info_CUSTOMER_Info_HK]
            ,[CUSTOMER_Info_BG_ValidFromTimestamp]
            ,[CUSTOMER_Address_CUSTOMER_Address_HK]
            ,[CUSTOMER_Address_BG_ValidFromTimestamp]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[PIT_HK] AS [PIT_HK]
            ,[BG_Source].[CUSTOMER_Info_CUSTOMER_Info_HK] AS [CUSTOMER_Info_CUSTOMER_Info_HK]
            ,[BG_Source].[CUSTOMER_Info_BG_ValidFromTimestamp] AS [CUSTOMER_Info_BG_ValidFromTimestamp]
            ,[BG_Source].[CUSTOMER_Address_CUSTOMER_Address_HK] AS [CUSTOMER_Address_CUSTOMER_Address_HK]
            ,[BG_Source].[CUSTOMER_Address_BG_ValidFromTimestamp] AS [CUSTOMER_Address_BG_ValidFromTimestamp]
        FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Delta] AS [BG_Source]
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

-- BusinessCurrentViewResultView: Customer_Current_Business Current View Result View_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_Current_Customer_Current]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_Current_Customer_Current]
;
GO

CREATE VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_Current_Customer_Current]
AS
SELECT
     [s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[s1].[Hub_HK] AS [Hub_HK]
    ,[s3].[CUSTOMER] AS [CUSTOMER]
    ,[s3].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[s3].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[s4].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[s4].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[s4].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[s4].[ZIP_CODE] AS [ZIP_CODE]
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Result] AS [s2]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Result] AS [s1]
   ON [s1].[Hub_HK] = [s2].[PIT_HK]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info] AS [s3]
   ON ([s3].[Hub_HK] = [s2].[CUSTOMER_Info_CUSTOMER_Info_HK])
  AND ([s3].[BG_ValidFromTimestamp] = [s2].[CUSTOMER_Info_BG_ValidFromTimestamp])
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address] AS [s4]
   ON ([s4].[Hub_HK] = [s2].[CUSTOMER_Address_CUSTOMER_Address_HK])
  AND ([s4].[BG_ValidFromTimestamp] = [s2].[CUSTOMER_Address_BG_ValidFromTimestamp])
WHERE [s2].[BG_ValidToTimestamp] = N'99991231'
;
GO

-- BusinessHistoryViewResultView: Customer_History_Business History View Result View_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_History_Customer_History]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_History_Customer_History]
;
GO

CREATE VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_History_Customer_History]
AS
SELECT
     [s2].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[s2].[BG_ValidToTimestamp] AS [BG_ValidToTimestamp]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[s1].[Hub_HK] AS [Hub_HK]
    ,[s3].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[s3].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[s3].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[s3].[ZIP_CODE] AS [ZIP_CODE]
    ,[s4].[CUSTOMER] AS [CUSTOMER]
    ,[s4].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[s4].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Result] AS [s2]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Result] AS [s1]
   ON [s1].[Hub_HK] = [s2].[PIT_HK]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address] AS [s3]
   ON ([s3].[Hub_HK] = [s2].[CUSTOMER_Address_CUSTOMER_Address_HK])
  AND ([s3].[BG_ValidFromTimestamp] = [s2].[CUSTOMER_Address_BG_ValidFromTimestamp])
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info] AS [s4]
   ON ([s4].[Hub_HK] = [s2].[CUSTOMER_Info_CUSTOMER_Info_HK])
  AND ([s4].[BG_ValidFromTimestamp] = [s2].[CUSTOMER_Info_BG_ValidFromTimestamp])
;
GO

-- BusinessLinkSourceView: Sales_Business Link Source View_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Source]
;
GO

CREATE VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s2].[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,[s3].[FK_CUSTOMER_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_ID]
    ,[s1].[FK_LOYALTYCARD_LOYALTYCARD_ID] AS [FK_LOYALTYCARD_LOYALTYCARD_ID]
    ,[s1].[FK_ITEMUNITOFMEASURE_ITEM_ID] AS [FK_ITEMUNITOFMEASURE_ITEM_ID]
    ,[s1].[FK_ITEMUNITOFMEASURE_UOM] AS [FK_ITEMUNITOFMEASURE_UOM]
    ,[s1].[FK_POS_POS_ID] AS [FK_POS_POS_ID]
    ,[s1].[FK_ITEM_ITEM_ID] AS [FK_ITEM_ITEM_ID]
    ,[s1].[FK_SALESTRANSACTION_TRANSACTION_ID] AS [FK_SALESTRANSACTION_TRANSACTION_ID]
    ,[s1].[FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS [FK_SALESTRANSACTION_TRANSACTION_LINE_NO]
    ,[s1].[FK_SALESTRANSACTION_TRANSACTION_TIME] AS [FK_SALESTRANSACTION_TRANSACTION_TIME]
    ,[s1].[FK_SALESTRANSACTION_POS_ID] AS [FK_SALESTRANSACTION_POS_ID]
FROM [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Result] AS [s1]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Result] AS [s2]
   ON [s2].[POS_POS_HK] = [s1].[POS_POS_HK]
JOIN [{productlaunchevent#rawvault#server_name}].[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Result] AS [s3]
   ON [s3].[LOYALTYCARD_LOYALTYCARD_HK] = [s1].[LOYALTYCARD_LOYALTYCARD_HK]
;
GO

-- BusinessLinkTable: Sales_Business Link Table_1
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
WHERE ([s].[name] = N'{productlaunchevent#businessvault#schema_name}')
  AND ([o].[name] = N'BDV_LNK_Sales')
;
EXEC [sys].[sp_executesql] @sql;
GO
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales]
;
GO

CREATE TABLE [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[Link_HK] BINARY(20) NOT NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[FK_BRANCH_BRANCH_ID] INT NULL
    ,[BRANCH_BRANCH_HK] BINARY(20) NOT NULL
    ,[FK_CUSTOMER_CUSTOMER_ID] DECIMAL(38) NULL
    ,[CUSTOMER_CUSTOMER_HK] BINARY(20) NOT NULL
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
    ,CONSTRAINT [PK_BDV_LNK_Sales] PRIMARY KEY CLUSTERED ([Link_HK])
    ,CONSTRAINT [UC_BDV_LNK_Sales] UNIQUE NONCLUSTERED ([FK_BRANCH_BRANCH_ID], [FK_CUSTOMER_CUSTOMER_ID], [FK_LOYALTYCARD_LOYALTYCARD_ID], [FK_ITEMUNITOFMEASURE_ITEM_ID], [FK_ITEMUNITOFMEASURE_UOM], [FK_POS_POS_ID], [FK_ITEM_ITEM_ID], [FK_SALESTRANSACTION_TRANSACTION_ID], [FK_SALESTRANSACTION_TRANSACTION_LINE_NO], [FK_SALESTRANSACTION_TRANSACTION_TIME], [FK_SALESTRANSACTION_POS_ID])
)
;
GO
CREATE NONCLUSTERED INDEX [IX_BDV_LNK_Sales_BRANCH] ON [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] ([BRANCH_BRANCH_HK]);
CREATE NONCLUSTERED INDEX [IX_BDV_LNK_Sales_CUSTOMER] ON [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] ([CUSTOMER_CUSTOMER_HK]);
CREATE NONCLUSTERED INDEX [IX_BDV_LNK_Sales_LOYALTYCARD] ON [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] ([LOYALTYCARD_LOYALTYCARD_HK]);
CREATE NONCLUSTERED INDEX [IX_BDV_LNK_Sales_ITEMUNITOFMEASURE] ON [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] ([ITEMUNITOFMEASURE_ITEMUNITOFMEASURE_HK]);
CREATE NONCLUSTERED INDEX [IX_BDV_LNK_Sales_POS] ON [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] ([POS_POS_HK]);
CREATE NONCLUSTERED INDEX [IX_BDV_LNK_Sales_ITEM] ON [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] ([ITEM_ITEM_HK]);
CREATE NONCLUSTERED INDEX [IX_BDV_LNK_Sales_SALESTRANSACTION] ON [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] ([SALESTRANSACTION_SALESTRANSACTION_HK]);
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT
    INTO [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] WITH(TABLOCK) (
         [BG_SourceSystem]
        ,[Link_HK]
        ,[BG_LoadTimestamp]
        ,[FK_BRANCH_BRANCH_ID]
        ,[BRANCH_BRANCH_HK]
        ,[FK_CUSTOMER_CUSTOMER_ID]
        ,[CUSTOMER_CUSTOMER_HK]
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
         N'Unknown' AS [BG_SourceSystem]
        ,0 AS [Link_HK]
        ,N'19000101' AS [BG_LoadTimestamp]
        ,0 AS [FK_BRANCH_BRANCH_ID]
        ,0 AS [BRANCH_BRANCH_HK]
        ,0 AS [FK_CUSTOMER_CUSTOMER_ID]
        ,0 AS [CUSTOMER_CUSTOMER_HK]
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

-- BusinessLinkHashingView: Sales_Business Link Hashing View_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Hashing]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Hashing]
;
GO

CREATE VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Hashing]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_BRANCH_BRANCH_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_CUSTOMER_CUSTOMER_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_LOYALTYCARD_LOYALTYCARD_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_ITEMUNITOFMEASURE_ITEM_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL([FK_ITEMUNITOFMEASURE_UOM], N'_NULL_') + N'_' + ISNULL(CAST([FK_POS_POS_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_ITEM_ITEM_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_ID] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_LINE_NO] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_TRANSACTION_TIME] AS NVARCHAR(4000)), N'_NULL_') + N'_' + ISNULL(CAST([FK_SALESTRANSACTION_POS_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [Link_HK]
    ,[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,HASHBYTES('SHA1', ) AS [BRANCH_BRANCH_HK]
    ,[FK_CUSTOMER_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_ID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_CUSTOMER_CUSTOMER_ID] AS NVARCHAR(4000)), N'_NULL_')) AS [CUSTOMER_CUSTOMER_HK]
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
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Source]
;
GO

-- BusinessLinkresultView: Sales_Business Link Result View_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Result]
;
GO

CREATE VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Result]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[Link_HK] AS [Link_HK]
    ,[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,[BRANCH_BRANCH_HK] AS [BRANCH_BRANCH_HK]
    ,[FK_CUSTOMER_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_ID]
    ,[CUSTOMER_CUSTOMER_HK] AS [CUSTOMER_CUSTOMER_HK]
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
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales]
WHERE [Link_HK] <> 0
;
GO

-- BusinessLinkDeltaView: Sales_Business Link Delta View_1
IF OBJECT_ID(N'[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Delta]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Delta]
;
GO

CREATE VIEW [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
    ,[BG_Source].[BRANCH_BRANCH_HK] AS [BRANCH_BRANCH_HK]
    ,[BG_Source].[FK_CUSTOMER_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_ID]
    ,[BG_Source].[CUSTOMER_CUSTOMER_HK] AS [CUSTOMER_CUSTOMER_HK]
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
FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- BusinessLinkLoader: Sales_Business Link Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Loader]
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
        INTO [{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales] WITH(TABLOCK) (
             [BG_SourceSystem]
            ,[Link_HK]
            ,[BG_LoadTimestamp]
            ,[FK_BRANCH_BRANCH_ID]
            ,[BRANCH_BRANCH_HK]
            ,[FK_CUSTOMER_CUSTOMER_ID]
            ,[CUSTOMER_CUSTOMER_HK]
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
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[Link_HK] AS [Link_HK]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[FK_BRANCH_BRANCH_ID] AS [FK_BRANCH_BRANCH_ID]
            ,[BG_Source].[BRANCH_BRANCH_HK] AS [BRANCH_BRANCH_HK]
            ,[BG_Source].[FK_CUSTOMER_CUSTOMER_ID] AS [FK_CUSTOMER_CUSTOMER_ID]
            ,[BG_Source].[CUSTOMER_CUSTOMER_HK] AS [CUSTOMER_CUSTOMER_HK]
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
        FROM [{productlaunchevent#businessvault#server_name}].[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Delta] AS [BG_Source]
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

-- BusinessVaultFooter

