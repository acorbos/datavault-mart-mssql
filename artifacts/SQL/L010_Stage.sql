-- StageHeader
USE [master];
GO
IF DB_ID(N'{productlaunchevent#stage#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{productlaunchevent#stage#database_name}];
    ALTER DATABASE [{productlaunchevent#stage#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{productlaunchevent#stage#database_name}];
GO
IF SCHEMA_ID(N'{productlaunchevent#stage#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{productlaunchevent#stage#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- StageTable: BRANCH_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BRANCH_ID] INT NULL
    ,[BRANCH_NAME] VARCHAR(50) NULL
    ,[MARKET_SIZE] VARCHAR(10) NULL
    ,[LOCATION_SINCE] INT NULL
    ,[RETAIL_SPACE_M2] INT NULL
    ,[ARTICLE_NUMBER_APPROX] INT NULL
    ,[ADDRESS_LINE1] VARCHAR(100) NULL
    ,[ADDRESS_LINE2] VARCHAR(100) NULL
    ,[ADDRESS_LINE3] VARCHAR(100) NULL
    ,[ZIP_CODE] VARCHAR(20) NULL
    ,[COUNTRY] VARCHAR(50) NULL
    ,[COUNTRY_ISO_CODE] VARCHAR(2) NULL
)
;
GO

-- StageSourceView: BRANCH_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[BRANCH_ID] AS [BRANCH_ID]
    ,[s1].[BRANCH_NAME] COLLATE DATABASE_DEFAULT AS [BRANCH_NAME]
    ,[s1].[MARKET_SIZE] COLLATE DATABASE_DEFAULT AS [MARKET_SIZE]
    ,[s1].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[s1].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[s1].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[s1].[ADDRESS_LINE1] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE3]
    ,[s1].[ZIP_CODE] COLLATE DATABASE_DEFAULT AS [ZIP_CODE]
    ,[s1].[COUNTRY] COLLATE DATABASE_DEFAULT AS [COUNTRY]
    ,[s1].[COUNTRY_ISO_CODE] COLLATE DATABASE_DEFAULT AS [COUNTRY_ISO_CODE]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[BRANCH] AS [s1]
;
GO

-- StageResultView: BRANCH_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH] AS [BG_Source]
;
GO

-- StageLoader: BRANCH_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[BRANCH_ID]
            ,[BRANCH_NAME]
            ,[MARKET_SIZE]
            ,[LOCATION_SINCE]
            ,[RETAIL_SPACE_M2]
            ,[ARTICLE_NUMBER_APPROX]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ZIP_CODE]
            ,[COUNTRY]
            ,[COUNTRY_ISO_CODE]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
            ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
            ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
            ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
            ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
            ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
            ,[BG_Source].[COUNTRY] AS [COUNTRY]
            ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Source] AS [BG_Source]
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

-- StageTable: CUSTOMER_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CUSTOMER_ID] DECIMAL(38) NULL
    ,[CUSTOMER] VARCHAR(100) NULL
    ,[CUSTOMER_TYPE] VARCHAR(100) NULL
    ,[CUSTOMER_SINCE] DATE NULL
    ,[ADDRESS_LINE1] VARCHAR(100) NULL
    ,[ADDRESS_LINE2] VARCHAR(100) NULL
    ,[ADDRESS_LINE3] VARCHAR(100) NULL
    ,[ZIP_CODE] VARCHAR(20) NULL
    ,[COUNTRY] VARCHAR(50) NULL
    ,[COUNTRY_ISO_CODE] VARCHAR(2) NULL
)
;
GO

-- StageSourceView: CUSTOMER_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[s1].[CUSTOMER] COLLATE DATABASE_DEFAULT AS [CUSTOMER]
    ,[s1].[CUSTOMER_TYPE] COLLATE DATABASE_DEFAULT AS [CUSTOMER_TYPE]
    ,[s1].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[s1].[ADDRESS_LINE1] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE3]
    ,[s1].[ZIP_CODE] COLLATE DATABASE_DEFAULT AS [ZIP_CODE]
    ,[s1].[COUNTRY] COLLATE DATABASE_DEFAULT AS [COUNTRY]
    ,[s1].[COUNTRY_ISO_CODE] COLLATE DATABASE_DEFAULT AS [COUNTRY_ISO_CODE]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[CUSTOMER] AS [s1]
;
GO

-- StageResultView: CUSTOMER_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER] AS [BG_Source]
;
GO

-- StageLoader: CUSTOMER_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[CUSTOMER_ID]
            ,[CUSTOMER]
            ,[CUSTOMER_TYPE]
            ,[CUSTOMER_SINCE]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ZIP_CODE]
            ,[COUNTRY]
            ,[COUNTRY_ISO_CODE]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
            ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
            ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
            ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
            ,[BG_Source].[COUNTRY] AS [COUNTRY]
            ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Source] AS [BG_Source]
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

-- StageTable: CUSTOMER_DUPLICATES_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CUSTOMER_ID] DECIMAL(38) NULL
    ,[DUPLICATE_CUSTOMER_ID] DECIMAL(38) NULL
)
;
GO

-- StageSourceView: CUSTOMER_DUPLICATES_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[s1].[DUPLICATE_CUSTOMER_ID] AS [DUPLICATE_CUSTOMER_ID]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[CUSTOMER_DUPLICATES] AS [s1]
;
GO

-- StageResultView: CUSTOMER_DUPLICATES_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[DUPLICATE_CUSTOMER_ID] AS [DUPLICATE_CUSTOMER_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES] AS [BG_Source]
;
GO

-- StageLoader: CUSTOMER_DUPLICATES_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[CUSTOMER_ID]
            ,[DUPLICATE_CUSTOMER_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
            ,[BG_Source].[DUPLICATE_CUSTOMER_ID] AS [DUPLICATE_CUSTOMER_ID]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Source] AS [BG_Source]
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

-- StageTable: EMPLOYEE_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[EMPLOYEE_ID] INT NULL
    ,[JOBFUNCTION_ID] INT NULL
    ,[BRANCH_ID] INT NULL
    ,[DEPARTMENT_ID] INT NULL
    ,[IS_ACTIVE_RECORD] INT NULL
    ,[LAST_NAME] VARCHAR(100) NULL
    ,[FIRST_NAME] VARCHAR(100) NULL
    ,[BIRTH_DATE] DATE NULL
    ,[FIRST_HIRE_DATE] DATE NULL
    ,[HIRE_START_DATE] DATE NULL
    ,[HIRE_END_DATE] DATE NULL
    ,[INSERT_DATE] DATETIME2 NULL
    ,[UPDATE_DATE] DATETIME2 NULL
    ,[ADDRESS_LINE1] VARCHAR(100) NULL
    ,[ADDRESS_LINE2] VARCHAR(100) NULL
    ,[ADDRESS_LINE3] VARCHAR(100) NULL
    ,[ZIP_CODE] VARCHAR(20) NULL
    ,[COUNTRY] VARCHAR(50) NULL
    ,[COUNTRY_ISO_CODE] VARCHAR(2) NULL
    ,[MANAGER_ID] INT NULL
)
;
GO

-- StageSourceView: EMPLOYEE_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[EMPLOYEE_ID] AS [EMPLOYEE_ID]
    ,[s1].[JOBFUNCTION_ID] AS [JOBFUNCTION_ID]
    ,[s1].[BRANCH_ID] AS [BRANCH_ID]
    ,[s1].[DEPARTMENT_ID] AS [DEPARTMENT_ID]
    ,[s1].[IS_ACTIVE_RECORD] AS [IS_ACTIVE_RECORD]
    ,[s1].[LAST_NAME] COLLATE DATABASE_DEFAULT AS [LAST_NAME]
    ,[s1].[FIRST_NAME] COLLATE DATABASE_DEFAULT AS [FIRST_NAME]
    ,[s1].[BIRTH_DATE] AS [BIRTH_DATE]
    ,[s1].[FIRST_HIRE_DATE] AS [FIRST_HIRE_DATE]
    ,[s1].[HIRE_START_DATE] AS [HIRE_START_DATE]
    ,[s1].[HIRE_END_DATE] AS [HIRE_END_DATE]
    ,[s1].[INSERT_DATE] AS [INSERT_DATE]
    ,[s1].[UPDATE_DATE] AS [UPDATE_DATE]
    ,[s1].[ADDRESS_LINE1] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE3]
    ,[s1].[ZIP_CODE] COLLATE DATABASE_DEFAULT AS [ZIP_CODE]
    ,[s1].[COUNTRY] COLLATE DATABASE_DEFAULT AS [COUNTRY]
    ,[s1].[COUNTRY_ISO_CODE] COLLATE DATABASE_DEFAULT AS [COUNTRY_ISO_CODE]
    ,[s1].[MANAGER_ID] AS [MANAGER_ID]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[EMPLOYEE] AS [s1]
;
GO

-- StageResultView: EMPLOYEE_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[EMPLOYEE_ID] AS [EMPLOYEE_ID]
    ,[BG_Source].[JOBFUNCTION_ID] AS [JOBFUNCTION_ID]
    ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
    ,[BG_Source].[DEPARTMENT_ID] AS [DEPARTMENT_ID]
    ,[BG_Source].[IS_ACTIVE_RECORD] AS [IS_ACTIVE_RECORD]
    ,[BG_Source].[LAST_NAME] AS [LAST_NAME]
    ,[BG_Source].[FIRST_NAME] AS [FIRST_NAME]
    ,[BG_Source].[BIRTH_DATE] AS [BIRTH_DATE]
    ,[BG_Source].[FIRST_HIRE_DATE] AS [FIRST_HIRE_DATE]
    ,[BG_Source].[HIRE_START_DATE] AS [HIRE_START_DATE]
    ,[BG_Source].[HIRE_END_DATE] AS [HIRE_END_DATE]
    ,[BG_Source].[INSERT_DATE] AS [INSERT_DATE]
    ,[BG_Source].[UPDATE_DATE] AS [UPDATE_DATE]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
    ,[BG_Source].[MANAGER_ID] AS [MANAGER_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE] AS [BG_Source]
;
GO

-- StageLoader: EMPLOYEE_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[EMPLOYEE_ID]
            ,[JOBFUNCTION_ID]
            ,[BRANCH_ID]
            ,[DEPARTMENT_ID]
            ,[IS_ACTIVE_RECORD]
            ,[LAST_NAME]
            ,[FIRST_NAME]
            ,[BIRTH_DATE]
            ,[FIRST_HIRE_DATE]
            ,[HIRE_START_DATE]
            ,[HIRE_END_DATE]
            ,[INSERT_DATE]
            ,[UPDATE_DATE]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ZIP_CODE]
            ,[COUNTRY]
            ,[COUNTRY_ISO_CODE]
            ,[MANAGER_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[EMPLOYEE_ID] AS [EMPLOYEE_ID]
            ,[BG_Source].[JOBFUNCTION_ID] AS [JOBFUNCTION_ID]
            ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
            ,[BG_Source].[DEPARTMENT_ID] AS [DEPARTMENT_ID]
            ,[BG_Source].[IS_ACTIVE_RECORD] AS [IS_ACTIVE_RECORD]
            ,[BG_Source].[LAST_NAME] AS [LAST_NAME]
            ,[BG_Source].[FIRST_NAME] AS [FIRST_NAME]
            ,[BG_Source].[BIRTH_DATE] AS [BIRTH_DATE]
            ,[BG_Source].[FIRST_HIRE_DATE] AS [FIRST_HIRE_DATE]
            ,[BG_Source].[HIRE_START_DATE] AS [HIRE_START_DATE]
            ,[BG_Source].[HIRE_END_DATE] AS [HIRE_END_DATE]
            ,[BG_Source].[INSERT_DATE] AS [INSERT_DATE]
            ,[BG_Source].[UPDATE_DATE] AS [UPDATE_DATE]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
            ,[BG_Source].[COUNTRY] AS [COUNTRY]
            ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
            ,[BG_Source].[MANAGER_ID] AS [MANAGER_ID]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Source] AS [BG_Source]
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

-- StageTable: ITEM_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_ITEM]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_ITEM] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[ITEM_ID] DECIMAL(38) NULL
    ,[DESCRIPTION] VARCHAR(1000) NULL
    ,[BASE_UOM] VARCHAR(10) NULL
    ,[SALES_UOM] VARCHAR(10) NULL
    ,[SUPPLIER_ID] DECIMAL(38) NULL
)
;
GO

-- StageSourceView: ITEM_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
    ,[s1].[DESCRIPTION] COLLATE DATABASE_DEFAULT AS [DESCRIPTION]
    ,[s1].[BASE_UOM] COLLATE DATABASE_DEFAULT AS [BASE_UOM]
    ,[s1].[SALES_UOM] COLLATE DATABASE_DEFAULT AS [SALES_UOM]
    ,[s1].[SUPPLIER_ID] AS [SUPPLIER_ID]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[ITEM] AS [s1]
;
GO

-- StageResultView: ITEM_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
    ,[BG_Source].[SUPPLIER_ID] AS [SUPPLIER_ID]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM] AS [BG_Source]
;
GO

-- StageLoader: ITEM_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_ITEM];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_ITEM] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[ITEM_ID]
            ,[DESCRIPTION]
            ,[BASE_UOM]
            ,[SALES_UOM]
            ,[SUPPLIER_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
            ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
            ,[BG_Source].[SUPPLIER_ID] AS [SUPPLIER_ID]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Source] AS [BG_Source]
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

-- StageTable: ITEMUNITOFMEASURE_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[ITEM_ID] DECIMAL(38) NULL
    ,[UOM] VARCHAR(10) NULL
    ,[DESCRIPTION] VARCHAR(100) NULL
    ,[BASE_UOM] VARCHAR(10) NULL
    ,[QTY_PER_BASE_UOM] INT NULL
)
;
GO

-- StageSourceView: ITEMUNITOFMEASURE_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
    ,[s1].[UOM] COLLATE DATABASE_DEFAULT AS [UOM]
    ,[s1].[DESCRIPTION] COLLATE DATABASE_DEFAULT AS [DESCRIPTION]
    ,[s1].[BASE_UOM] COLLATE DATABASE_DEFAULT AS [BASE_UOM]
    ,[s1].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[ITEMUNITOFMEASURE] AS [s1]
;
GO

-- StageResultView: ITEMUNITOFMEASURE_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[UOM] AS [UOM]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE] AS [BG_Source]
;
GO

-- StageLoader: ITEMUNITOFMEASURE_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[ITEM_ID]
            ,[UOM]
            ,[DESCRIPTION]
            ,[BASE_UOM]
            ,[QTY_PER_BASE_UOM]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[UOM] AS [UOM]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Source] AS [BG_Source]
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

-- StageTable: LOYALTYCARD_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[LOYALTYCARD_ID] INT NULL
    ,[CUSTOMER_ID] INT NULL
    ,[VALID_FROM] DATE NULL
    ,[VALID_TO] DATE NULL
)
;
GO

-- StageSourceView: LOYALTYCARD_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[s1].[VALID_FROM] AS [VALID_FROM]
    ,[s1].[VALID_TO] AS [VALID_TO]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[LOYALTYCARD] AS [s1]
;
GO

-- StageResultView: LOYALTYCARD_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
    ,[BG_Source].[VALID_TO] AS [VALID_TO]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD] AS [BG_Source]
;
GO

-- StageLoader: LOYALTYCARD_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[LOYALTYCARD_ID]
            ,[CUSTOMER_ID]
            ,[VALID_FROM]
            ,[VALID_TO]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
            ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
            ,[BG_Source].[VALID_TO] AS [VALID_TO]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Source] AS [BG_Source]
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

-- StageTable: PHONENUMBER_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[PHONENUMBER_ID] INT NULL
    ,[FOREIGN_KEY_ID] INT NULL
    ,[PHONE_NUMBER_TYPE_CODE] VARCHAR(10) NULL
    ,[PHONE_NUMBER] VARCHAR(50) NULL
)
;
GO

-- StageSourceView: PHONENUMBER_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[PHONENUMBER_ID] AS [PHONENUMBER_ID]
    ,[s1].[FOREIGN_KEY_ID] AS [FOREIGN_KEY_ID]
    ,[s1].[PHONE_NUMBER_TYPE_CODE] COLLATE DATABASE_DEFAULT AS [PHONE_NUMBER_TYPE_CODE]
    ,[s1].[PHONE_NUMBER] COLLATE DATABASE_DEFAULT AS [PHONE_NUMBER]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[PHONENUMBER] AS [s1]
;
GO

-- StageResultView: PHONENUMBER_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[PHONENUMBER_ID] AS [PHONENUMBER_ID]
    ,[BG_Source].[FOREIGN_KEY_ID] AS [FOREIGN_KEY_ID]
    ,[BG_Source].[PHONE_NUMBER_TYPE_CODE] AS [PHONE_NUMBER_TYPE_CODE]
    ,[BG_Source].[PHONE_NUMBER] AS [PHONE_NUMBER]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER] AS [BG_Source]
;
GO

-- StageLoader: PHONENUMBER_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[PHONENUMBER_ID]
            ,[FOREIGN_KEY_ID]
            ,[PHONE_NUMBER_TYPE_CODE]
            ,[PHONE_NUMBER]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[PHONENUMBER_ID] AS [PHONENUMBER_ID]
            ,[BG_Source].[FOREIGN_KEY_ID] AS [FOREIGN_KEY_ID]
            ,[BG_Source].[PHONE_NUMBER_TYPE_CODE] AS [PHONE_NUMBER_TYPE_CODE]
            ,[BG_Source].[PHONE_NUMBER] AS [PHONE_NUMBER]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Source] AS [BG_Source]
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

-- StageTable: POS_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_POS]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_POS]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_POS] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[POS_ID] INT NULL
    ,[BRANCH_ID] INT NULL
    ,[CASHBOX_NO] INT NULL
)
;
GO

-- StageSourceView: POS_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_POS_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_POS_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[POS_ID] AS [POS_ID]
    ,[s1].[BRANCH_ID] AS [BRANCH_ID]
    ,[s1].[CASHBOX_NO] AS [CASHBOX_NO]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[POS] AS [s1]
;
GO

-- StageResultView: POS_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_POS_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_POS_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[POS_ID] AS [POS_ID]
    ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
    ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS] AS [BG_Source]
;
GO

-- StageLoader: POS_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_POS_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_POS];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_POS] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[POS_ID]
            ,[BRANCH_ID]
            ,[CASHBOX_NO]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[POS_ID] AS [POS_ID]
            ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
            ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Source] AS [BG_Source]
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

-- StageTable: SALESTRANSACTION_Stage Table_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION]', N'U') IS NOT NULL
    DROP TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION]
;
GO

CREATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[POS_ID] INT NULL
    ,[ITEM_ID] INT NULL
    ,[DESCRIPTION] VARCHAR(1000) NULL
    ,[UOM] VARCHAR(10) NULL
    ,[TRANSACTION_ID] INT NULL
    ,[TRANSACTION_LINE_NO] INT NULL
    ,[TRANSACTION_TIME] DATETIME2 NULL
    ,[CASHIER_ID] INT NULL
    ,[LOYALTYCARD_ID] INT NULL
    ,[SALES_PRICE] DECIMAL(18,2) NULL
    ,[REDUCTION] DECIMAL(18,2) NULL
    ,[QUANTITY] DECIMAL(18,3) NULL
    ,[SALES_AMOUNT] DECIMAL(18,2) NULL
)
;
GO

-- StageSourceView: SALESTRANSACTION_Stage Source View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Source]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Source]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[POS_ID] AS [POS_ID]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
    ,[s1].[DESCRIPTION] COLLATE DATABASE_DEFAULT AS [DESCRIPTION]
    ,[s1].[UOM] COLLATE DATABASE_DEFAULT AS [UOM]
    ,[s1].[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[s1].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[s1].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[s1].[CASHIER_ID] AS [CASHIER_ID]
    ,[s1].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
    ,[s1].[SALES_PRICE] AS [SALES_PRICE]
    ,[s1].[REDUCTION] AS [REDUCTION]
    ,[s1].[QUANTITY] AS [QUANTITY]
    ,[s1].[SALES_AMOUNT] AS [SALES_AMOUNT]
FROM [{productlaunchevent#blackforestmarkets#server_name}].[{productlaunchevent#blackforestmarkets#database_name}].[{productlaunchevent#blackforestmarkets#schema_name}].[SALESTRANSACTION] AS [s1]
;
GO

-- StageResultView: SALESTRANSACTION_Stage Result View_1
IF OBJECT_ID(N'[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Result]', N'V') IS NOT NULL
    DROP VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Result]
;
GO

CREATE VIEW [{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[POS_ID] AS [POS_ID]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[UOM] AS [UOM]
    ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[BG_Source].[CASHIER_ID] AS [CASHIER_ID]
    ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
    ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
    ,[BG_Source].[REDUCTION] AS [REDUCTION]
    ,[BG_Source].[QUANTITY] AS [QUANTITY]
    ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION] AS [BG_Source]
;
GO

-- StageLoader: SALESTRANSACTION_Stage Loader_1
CREATE OR ALTER PROCEDURE [{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Loader]
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

        TRUNCATE TABLE [{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION];
        INSERT
        INTO [{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION] WITH(TABLOCK) (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[POS_ID]
            ,[ITEM_ID]
            ,[DESCRIPTION]
            ,[UOM]
            ,[TRANSACTION_ID]
            ,[TRANSACTION_LINE_NO]
            ,[TRANSACTION_TIME]
            ,[CASHIER_ID]
            ,[LOYALTYCARD_ID]
            ,[SALES_PRICE]
            ,[REDUCTION]
            ,[QUANTITY]
            ,[SALES_AMOUNT]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[POS_ID] AS [POS_ID]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[UOM] AS [UOM]
            ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
            ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
            ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
            ,[BG_Source].[CASHIER_ID] AS [CASHIER_ID]
            ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
            ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
            ,[BG_Source].[REDUCTION] AS [REDUCTION]
            ,[BG_Source].[QUANTITY] AS [QUANTITY]
            ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
        FROM [{productlaunchevent#stage#server_name}].[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Source] AS [BG_Source]
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

-- StageFooter

