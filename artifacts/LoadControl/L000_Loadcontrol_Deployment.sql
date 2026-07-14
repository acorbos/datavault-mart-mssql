--.........................................................................
--SQL script for deployment of load control
--.........................................................................
USE [master];
GO
IF DB_ID(N'{loadcontrol#loadcontrol#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{loadcontrol#loadcontrol#database_name}];
    ALTER DATABASE [{loadcontrol#loadcontrol#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{loadcontrol#loadcontrol#database_name}];
GO
IF SCHEMA_ID(N'{loadcontrol#loadcontrol#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{loadcontrol#loadcontrol#schema_name}]'
;
GO
SET NOCOUNT ON;
GO
-- drop procedures
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_ExecutionPlan]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_ExecutionPlan]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_ExecutionPlan_LoadObject]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_ExecutionPlan_LoadObject]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject_Dependency]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject_Dependency]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_AddLoadObjects]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_AddLoadObjects]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_RemoveLoadObjects]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_RemoveLoadObjects]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Build_LoadConfig]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Build_LoadConfig]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_External]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_External]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_LoadObject_Dependencies]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_LoadObject_Dependencies]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_Step]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_Step]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_LoadObject_ID]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_LoadObject_ID]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_Dependency_ID]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_Dependency_ID]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_External]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_External]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Resume]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Resume]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Start]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Start]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Step]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Step]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Process_Execution]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Process_Execution]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Process_Execution_Step]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Process_Execution_Step]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Remove_ExecutionPlan]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_ExecutionPlan]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Remove_ExecutionPlan_LoadObject]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_ExecutionPlan_LoadObject]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig_LoadObject]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig_LoadObject]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig_LoadObject_Dependency]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig_LoadObject_Dependency]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Resume_Execution]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Resume_Execution]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Show_Execution]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Show_Execution]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Show_ExecutionMonitor]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Show_ExecutionMonitor]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Show_ExecutionPlan]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Show_ExecutionPlan]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Start_Execution]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Start_Execution]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Stop_Execution]', N'P') IS NOT NULL
	DROP PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Stop_Execution]
GO

-- drop views
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Execution_All]', N'V') IS NOT NULL
    DROP VIEW [{loadcontrol#loadcontrol#schema_name}].[Execution_All]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependencies]', N'V') IS NOT NULL
    DROP VIEW [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependencies]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[ExecutionMonitor_All]', N'V') IS NOT NULL
    DROP VIEW [{loadcontrol#loadcontrol#schema_name}].[ExecutionMonitor_All]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_All]', N'V') IS NOT NULL
    DROP VIEW [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_All]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependencies]', N'V') IS NOT NULL
    DROP VIEW [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependencies]
GO

-- drop tables
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Execution_Step]', N'U') IS NOT NULL
    DROP TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]', N'U') IS NOT NULL
	DROP TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[Execution]', N'U') IS NOT NULL
	DROP TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]', N'U') IS NOT NULL
	DROP TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]', N'U') IS NOT NULL
	DROP TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]', N'U') IS NOT NULL
	DROP TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]', N'U') IS NOT NULL
	DROP TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
GO
IF OBJECT_ID (N'[{loadcontrol#loadcontrol#schema_name}].[LoadConfig]', N'U') IS NOT NULL
	DROP TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]
GO



GO
PRINT N'Creating Table [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] (
    [ID]                  INT                IDENTITY (1, 1) NOT NULL,
    [FK_LoadConfig_ID]    INT                NOT NULL,
    [ModelObject]         NVARCHAR (255)     NOT NULL,
    [ModelObjectPart]     NVARCHAR (255)     NOT NULL,
    [ModelObjectDataflow] NVARCHAR (255)     NOT NULL,
    [ModelObjectLayer]    NVARCHAR (255)     NULL,
    [ModelObjectType]     NVARCHAR (255)     NULL,
    [LoadObject]          NVARCHAR (255)     NOT NULL,
    [SchemaName]          NVARCHAR (255)     NULL,
    [DatabaseName]        NVARCHAR (255)     NULL,
    [ServerName]          NVARCHAR (255)     NULL,
    [ErrorBehavior]       NVARCHAR (255)     NULL,
    [ExecutionTechnology] NVARCHAR (255)     NULL,
    [ExecutionSortOrder]  INT                NOT NULL,
    [ExecutionPriority]   INT                NULL,
    [IsActive]            BIT                NOT NULL,
    [InsertedAt]          DATETIMEOFFSET (7) NULL,
    [InsertedBy]          NVARCHAR (255)     NULL,
    [UpdatedAt]           DATETIMEOFFSET (7) NULL,
    [UpdatedBy]           NVARCHAR (255)     NULL,
    CONSTRAINT [PK_LoadConfig_LoadObject] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ_LoadConfig_LoadObject] UNIQUE NONCLUSTERED ([FK_LoadConfig_ID] ASC, [ModelObjectPart] ASC, [ModelObject] ASC, [ModelObjectDataflow] ASC)
);


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Table [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig] (
    [ID]          INT                IDENTITY (1, 1) NOT NULL,
    [LoadConfig]  NVARCHAR (255)     NOT NULL,
    [Description] NVARCHAR (4000)    NULL,
    [Project]     NVARCHAR (255)     NULL,
    [Version]     NVARCHAR (255)     NULL,
    [Status]      NVARCHAR (255)     NULL,
    [InsertedAt]  DATETIMEOFFSET (7) NULL,
    [InsertedBy]  NVARCHAR (255)     NULL,
    [UpdatedAt]   DATETIMEOFFSET (7) NULL,
    [UpdatedBy]   NVARCHAR (255)     NULL,
    CONSTRAINT [PK_LoadConfig] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ_LoadConfig] UNIQUE NONCLUSTERED ([LoadConfig] ASC)
);


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Table [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency] (
    [ID]                          INT                IDENTITY (1, 1) NOT NULL,
    [FK_Execution_ID]             INT                NOT NULL,
    [FK_LoadObject_ID]            INT                NOT NULL,
    [FK_DependentOnLoadObject_ID] INT                NOT NULL,
    [IsDependentObjectFinished]   BIT                NOT NULL,
    [AllowDisable]                BIT                NOT NULL,
    [InsertedAt]                  DATETIMEOFFSET (7) NULL,
    [InsertedBy]                  NVARCHAR (255)     NULL,
    [UpdatedAt]                   DATETIMEOFFSET (7) NULL,
    [UpdatedBy]                   NVARCHAR (255)     NULL,
    CONSTRAINT [PK_Execution_LoadObject_Dependency] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ_Execution_LoadObject_Dependency] UNIQUE NONCLUSTERED ([FK_Execution_ID] ASC, [FK_LoadObject_ID] ASC, [FK_DependentOnLoadObject_ID] ASC)
);


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Table [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] (
    [ID]                          INT                IDENTITY (1, 1) NOT NULL,
    [FK_Execution_ID]             INT                NOT NULL,
    [FK_LoadObject_ID]            INT                NULL,
    [ServerName]                  NVARCHAR (255)     NULL,
    [DatabaseName]                NVARCHAR (255)     NULL,
    [SchemaName]                  NVARCHAR (255)     NOT NULL,
    [LoadObject]                  NVARCHAR (255)     NOT NULL,
    [ExecutionTechnology]         NVARCHAR (255)     NOT NULL,
    [ExecutionPriority]           INT                NOT NULL,
    [ExecutionOrder]              INT                NOT NULL,
    [IsAvailableForExecution]     BIT                NOT NULL,
    [ExecutionStartedAt]          DATETIMEOFFSET (7) NULL,
    [ExecutionFinishedAt]         DATETIMEOFFSET (7) NULL,
    [ExecutionDuration]           BIGINT             NULL,
    [ExecutionResult]             NVARCHAR (4000)    NULL,
    [LoaderMessage]               NVARCHAR (4000)    NULL,
    [ErrorBehavior]               NVARCHAR (255)     NOT NULL,
    [ErrorDescription]            NVARCHAR (4000)    NULL,
    [RowCountInserted]            BIGINT             NULL,
    [RowCountUpdated]             BIGINT             NULL,
    [RowCountDeleted]             BIGINT             NULL,
    [RowCountWarning]             BIGINT             NULL,
    [RowCountError]               BIGINT             NULL,
    [ExecutionProcessSPID]        BIGINT             NULL,
    [ExecutionProcessExternalKey] BIGINT             NULL,
    [InsertedAt]                  DATETIMEOFFSET (7) NULL,
    [InsertedBy]                  NVARCHAR (255)     NULL,
    [UpdatedAt]                   DATETIMEOFFSET (7) NULL,
    [UpdatedBy]                   NVARCHAR (255)     NULL,
    CONSTRAINT [PK_Execution_Step] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Table [{loadcontrol#loadcontrol#schema_name}].[Execution]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution] (
    [ID]                         INT                IDENTITY (1, 1) NOT NULL,
    [FK_ExecutionPlan_ID]        INT                NOT NULL,
    [FK_ResumedExecution_ID]     INT                NULL,
    [LoadCreatedAt]              DATETIMEOFFSET (7) NOT NULL,
    [LoadEffectiveAt]            DATETIMEOFFSET (7) NOT NULL,
    [Description]                NVARCHAR (4000)    NULL,
    [ExecutionStartedAt]         DATETIMEOFFSET (7) NULL,
    [ExecutionFinishedAt]        DATETIMEOFFSET (7) NULL,
    [ExecutionDuration]          BIGINT             NULL,
    [ExecutionResult]            NVARCHAR (4000)    NULL,
    [Message]                    NVARCHAR (4000)    NULL,
    [IsActive]                   BIT                NOT NULL,
    [IsCanceled]                 BIT                NOT NULL,
    [ExecutionExternalReference] NVARCHAR (4000)    NULL,
    [InsertedAt]                 DATETIMEOFFSET (7) NULL,
    [InsertedBy]                 NVARCHAR (255)     NULL,
    [UpdatedAt]                  DATETIMEOFFSET (7) NULL,
    [UpdatedBy]                  NVARCHAR (255)     NULL,
    CONSTRAINT [PK_Execution] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ_Execution] UNIQUE NONCLUSTERED ([LoadCreatedAt] ASC)
);


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Table [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject] (
    [ID]                  INT                IDENTITY (1, 1) NOT NULL,
    [FK_ExecutionPlan_ID] INT                NOT NULL,
    [FK_LoadObject_ID]    INT                NOT NULL,
    [ErrorBehavior]       NVARCHAR (255)     NOT NULL,
    [ExecutionPriority]   INT                NULL,
    [InsertedAt]          DATETIMEOFFSET (7) NULL,
    [InsertedBy]          NVARCHAR (255)     NULL,
    [UpdatedAt]           DATETIMEOFFSET (7) NULL,
    [UpdatedBy]           NVARCHAR (255)     NULL,
    CONSTRAINT [PK_ExecutionPlan_LoadObject] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ_ExecutionPlan_LoadObject] UNIQUE NONCLUSTERED ([FK_ExecutionPlan_ID] ASC, [FK_LoadObject_ID] ASC)
);


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Table [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan] (
    [ID]            INT                IDENTITY (1, 1) NOT NULL,
    [ExecutionPlan] NVARCHAR (255)     NOT NULL,
    [Description]   NVARCHAR (4000)    NULL,
    [InsertedAt]    DATETIMEOFFSET (7) NULL,
    [InsertedBy]    NVARCHAR (255)     NULL,
    [UpdatedAt]     DATETIMEOFFSET (7) NULL,
    [UpdatedBy]     NVARCHAR (255)     NULL,
    CONSTRAINT [PK_ExecutionPlan] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ_ExecutionPlan] UNIQUE NONCLUSTERED ([ExecutionPlan] ASC)
);


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Table [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency] (
    [ID]                          INT                IDENTITY (1, 1) NOT NULL,
    [FK_LoadObject_ID]            INT                NOT NULL,
    [FK_DependentOnLoadObject_ID] INT                NOT NULL,
    [AllowDisable]                BIT                NOT NULL,
    [InsertedAt]                  DATETIMEOFFSET (7) NULL,
    [InsertedBy]                  NVARCHAR (255)     NULL,
    [UpdatedAt]                   DATETIMEOFFSET (7) NULL,
    [UpdatedBy]                   NVARCHAR (255)     NULL,
    CONSTRAINT [PK_LoadConfig_LoadObject_Dependency] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ_LoadConfig_LoadObject_Dependency] UNIQUE NONCLUSTERED ([FK_LoadObject_ID] ASC, [FK_DependentOnLoadObject_ID] ASC)
);


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
    ADD DEFAULT ((1)) FOR [IsActive];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [InsertedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
    ADD DEFAULT (USER_NAME()) FOR [InsertedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [UpdatedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
    ADD DEFAULT (USER_NAME()) FOR [UpdatedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [InsertedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]
    ADD DEFAULT (USER_NAME()) FOR [InsertedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [UpdatedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]
    ADD DEFAULT (USER_NAME()) FOR [UpdatedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [InsertedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
    ADD DEFAULT (USER_NAME()) FOR [InsertedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [UpdatedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
    ADD DEFAULT (USER_NAME()) FOR [UpdatedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [InsertedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
    ADD DEFAULT (USER_NAME()) FOR [InsertedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [UpdatedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
    ADD DEFAULT (USER_NAME()) FOR [UpdatedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [InsertedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution]
    ADD DEFAULT (USER_NAME()) FOR [InsertedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [UpdatedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[Execution]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution]
    ADD DEFAULT (USER_NAME()) FOR [UpdatedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [InsertedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
    ADD DEFAULT (USER_NAME()) FOR [InsertedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [UpdatedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
    ADD DEFAULT (USER_NAME()) FOR [UpdatedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [InsertedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]
    ADD DEFAULT (USER_NAME()) FOR [InsertedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [UpdatedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]
    ADD DEFAULT (USER_NAME()) FOR [UpdatedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [InsertedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
    ADD DEFAULT (USER_NAME()) FOR [InsertedBy];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
    ADD DEFAULT (SYSDATETIMEOFFSET()) FOR [UpdatedAt];


GO
PRINT N'Creating Default Constraint unnamed constraint on [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
    ADD DEFAULT (USER_NAME()) FOR [UpdatedBy];


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_LoadConfig_LoadObject_FK_LoadConfig_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
    ADD CONSTRAINT [FK_LoadConfig_LoadObject_FK_LoadConfig_ID] FOREIGN KEY ([FK_LoadConfig_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[LoadConfig] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_Execution_LoadObject_Dependency_FK_DependentOnLoadObject_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
    ADD CONSTRAINT [FK_Execution_LoadObject_Dependency_FK_DependentOnLoadObject_ID] FOREIGN KEY ([FK_DependentOnLoadObject_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_Execution_LoadObject_Dependency_FK_Execution_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
    ADD CONSTRAINT [FK_Execution_LoadObject_Dependency_FK_Execution_ID] FOREIGN KEY ([FK_Execution_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[Execution] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_Execution_LoadObject_Dependency_FK_LoadObject_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
    ADD CONSTRAINT [FK_Execution_LoadObject_Dependency_FK_LoadObject_ID] FOREIGN KEY ([FK_LoadObject_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_Execution_Step_FK_Execution_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
    ADD CONSTRAINT [FK_Execution_Step_FK_Execution_ID] FOREIGN KEY ([FK_Execution_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[Execution] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_Execution_Step_FK_LoadObject_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
    ADD CONSTRAINT [FK_Execution_Step_FK_LoadObject_ID] FOREIGN KEY ([FK_LoadObject_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_Execution_FK_ExecutionPlan_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[Execution]
    ADD CONSTRAINT [FK_Execution_FK_ExecutionPlan_ID] FOREIGN KEY ([FK_ExecutionPlan_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_ExecutionPlan_LoadObject_FK_ExecutionPlan_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
    ADD CONSTRAINT [FK_ExecutionPlan_LoadObject_FK_ExecutionPlan_ID] FOREIGN KEY ([FK_ExecutionPlan_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_ExecutionPlan_LoadObject_FK_LoadObject_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
    ADD CONSTRAINT [FK_ExecutionPlan_LoadObject_FK_LoadObject_ID] FOREIGN KEY ([FK_LoadObject_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_LoadConfig_LoadObject_Dependency_FK_DependentOnLoadObject_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
    ADD CONSTRAINT [FK_LoadConfig_LoadObject_Dependency_FK_DependentOnLoadObject_ID] FOREIGN KEY ([FK_DependentOnLoadObject_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] ([ID]);


GO
PRINT N'Creating Foreign Key [{loadcontrol#loadcontrol#schema_name}].[FK_LoadConfig_LoadObject_Dependency_FK_LoadObject_ID]...';


GO
ALTER TABLE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
    ADD CONSTRAINT [FK_LoadConfig_LoadObject_Dependency_FK_LoadObject_ID] FOREIGN KEY ([FK_LoadObject_ID]) REFERENCES [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] ([ID]);


GO
PRINT N'Creating View [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependencies]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE VIEW [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependencies]
AS

SELECT
	 [s].[FK_Execution_ID] AS [Execution_ID]
	,[s].[ID] AS [Execution_Step_ID]
	,[co].[ID] AS [LoadObject_ID]
	,(
		SELECT COUNT(*)
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
		WHERE [FK_LoadObject_ID] = [s].[FK_LoadObject_ID]
		  AND [FK_Execution_ID] = [s].[FK_Execution_ID]
	 ) AS [DependencyCount]
	,(
		SELECT COUNT(*)
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
		WHERE [FK_LoadObject_ID] = [s].[FK_LoadObject_ID]
		  AND [FK_Execution_ID] = [s].[FK_Execution_ID]
		  AND [IsDependentObjectFinished] = 1
	 ) AS [DependencyCountFinished]
	,STUFF(
		 (
			SELECT ' | ' + CAST([FK_DependentOnLoadObject_ID] AS NVARCHAR(10))
			FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
			WHERE [FK_LoadObject_ID] = [s].[FK_LoadObject_ID]
			  AND [FK_Execution_ID] = [s].[FK_Execution_ID]
			ORDER BY [FK_DependentOnLoadObject_ID] ASC
			FOR XML PATH('')
		 )
		,1
		,3
		,''
	 ) AS [DependentOnLoadObject_ID]
	,STUFF(
		 (
			SELECT ' | ' + [co1].[SchemaName] + '.' + [co1].[LoadObject]
			FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency] AS [d]
			JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co1] ON [co1].[ID] = [d].[FK_DependentOnLoadObject_ID]
			WHERE [d].[FK_LoadObject_ID] = [s].[FK_LoadObject_ID]
			  AND [d].[FK_Execution_ID] = [s].[FK_Execution_ID]
			ORDER BY [co1].[ExecutionSortOrder] ASC, [co1].[LoadObject] ASC
			FOR XML PATH('')
		 )
		,1
		,3
		,''
	 ) AS [DependentOnLoadObject]
FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] AS [s]
JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co] ON [co].[ID] = [s].[FK_LoadObject_ID]
;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating View [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependencies]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE VIEW [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependencies]
AS
SELECT
	 [co].[ID] AS [LoadObject_ID]
	,(
		SELECT COUNT(*)
		FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
		WHERE [FK_LoadObject_ID] = [co].[ID]
	 ) AS [DependencyCount]
	,STUFF(
		 (
			SELECT ' | ' + [co1].[SchemaName] + '.' + [co1].[LoadObject]
			FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency] AS [d]
			JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co1] ON [co1].[ID] = [d].[FK_DependentOnLoadObject_ID]
			WHERE [d].[FK_LoadObject_ID] = [co].[ID]
			ORDER BY [co1].[ExecutionSortOrder] ASC, [co1].[LoadObject] ASC
			FOR XML PATH('')
		 )
		 ,1
		 ,3
		 ,''
	 ) AS [DependentOnLoadObject]
	,STUFF(
		 (
			SELECT ' | ' + CAST([FK_DependentOnLoadObject_ID] AS NVARCHAR(10))
			FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
			WHERE [FK_LoadObject_ID] = [co].[ID]
			ORDER BY [FK_DependentOnLoadObject_ID] ASC
			FOR XML PATH('')
		 )
		,1
		,3
		,''
	 ) AS [DependentOnLoadObject_ID]
FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co]
;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating View [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_All]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE VIEW [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_All]
AS
SELECT
	 [p].[ID] AS [ExecutionPlan_ID]
	,[p].[ExecutionPlan]
	,[co].[ID] AS [LoadObject_ID]
	,[co].[SchemaName] + '.' + [co].[LoadObject] AS [LoadObject]
	,[po].[ErrorBehavior]
	,[co].[ExecutionTechnology]
	,[po].[ExecutionPriority]
	,[co].[ExecutionSortOrder]
	,[co].[IsActive]
	,[d].[DependencyCount]
	,[d].[DependentOnLoadObject]
	,[d].[DependentOnLoadObject_ID]
FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan] AS [p]
JOIN [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject] AS [po] ON [po].[FK_ExecutionPlan_ID] = [p].[ID]
JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co] ON [co].[ID] = [po].[FK_LoadObject_ID]
JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependencies] AS [d] ON [d].[LoadObject_ID] = [co].[ID]
;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating View [{loadcontrol#loadcontrol#schema_name}].[Execution_All]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE VIEW [{loadcontrol#loadcontrol#schema_name}].[Execution_All]
AS
SELECT
	 [e].[ID] AS [Execution_ID]
	,[e].[LoadCreatedAt]
	,[e].[LoadEffectiveAt]
	,[e].[IsActive]
	,[e].[IsCanceled]
	,[s].[ID] AS [Execution_Step_ID]
	,[s].[FK_LoadObject_ID] AS [LoadObject_ID]
	,[s].[SchemaName] + '.' + [s].[LoadObject] AS [LoadObject]
	,[s].[ExecutionOrder]
	,[s].[ExecutionTechnology]
	,CASE
		WHEN [s].[IsAvailableForExecution] = 1 THEN 'Waiting'
		WHEN [s].[IsAvailableForExecution] = 0 AND [s].[ExecutionFinishedAt] IS NULL THEN 'Running'
		WHEN [s].[IsAvailableForExecution] = 0 AND [s].[ExecutionFinishedAt] IS NOT NULL THEN 'Finished'
		ELSE 'Undefined'
	 END AS [ExecutionStatus]
	,[s].[ExecutionResult]
	,[s].[LoaderMessage]
	,[s].[RowCountInserted]
	,[s].[RowCountUpdated]
	,[s].[RowCountDeleted]
	,[s].[RowCountWarning]
	,[s].[RowCountError]
	,CASE
		WHEN [s].[RowCountError] > 0 THEN CAST([s].[RowCountError] AS NVARCHAR(20)) + ' errors found'
		WHEN [s].[ErrorDescription] IS NOT NULL THEN 'Error description available'
		ElSE 'ok'
	 END AS [ErrorStatus]
	,[s].[ErrorDescription]
	,[d].[DependencyCount]
	,[d].[DependencyCountFinished]
	,[d].[DependentOnLoadObject]
	,[d].[DependentOnLoadObject_ID]
	,FORMAT([s].[ExecutionStartedAt], 'yyyy-MM-dd HH:mm:ss') AS [ExecutionStartedAt]
	,FORMAT([s].[ExecutionFinishedAt], 'yyyy-MM-dd HH:mm:ss') AS [ExecutionFinishedAt]
	,FORMAT([s].[ExecutionDuration]  / 1000 / 60/ 60 % 60, '##\ ') + FORMAT([s].[ExecutionDuration] / 1000 /60 % 60, '00\:') + FORMAT([s].[ExecutionDuration] / 1000 % 60, '00\.') + FORMAT([s].[ExecutionDuration] % 1000, '000') AS [ExecutionDuration]
	,[s].[ExecutionProcessSPID]
	,[s].[ExecutionProcessExternalKey]
FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] AS [e]
JOIN [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] AS [s] ON [s].[FK_Execution_ID] = [e].[ID]
JOIN [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependencies] AS [d] ON [d].[Execution_Step_ID] = [s].[ID]
;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating View [{loadcontrol#loadcontrol#schema_name}].[ExecutionMonitor_All]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE VIEW [{loadcontrol#loadcontrol#schema_name}].[ExecutionMonitor_All]
AS
SELECT
	 [s].[FK_Execution_ID] AS [Execution_ID]
	,[co].[ExecutionSortOrder] AS [ExecutionSortOrder]
	,[co].[ModelObjectLayer] AS [ModelObjectLayer]
	,[co].[ModelObjectPart] AS [ModelObjectPart]
	,FORMAT(SUM(CASE WHEN [s].[ExecutionStartedAt] IS NULL THEN 1 ELSE 0 END), '#') AS [Waiting]
	,FORMAT(SUM(CASE WHEN [s].[ExecutionStartedAt] IS NOT NULL AND [s].[ExecutionFinishedAt] IS NULL THEN 1 ELSE 0 END), '#') AS [Running]
	,FORMAT(SUM(CASE WHEN [s].[ExecutionStartedAt] IS NOT NULL AND [s].[ExecutionFinishedAt] IS NOT NULL THEN 1 ELSE 0 END), '#') AS [Finished]
	,FORMAT(SUM(CASE WHEN LEFT([s].[ExecutionResult], 1) = 'S' THEN 1 ELSE 0 END), '#') AS [Success]
	,FORMAT(SUM(CASE WHEN LEFT([s].[ExecutionResult], 1) = 'F' THEN 1 ELSE 0 END), '#') AS [Failure]
	,FORMAT(SUM(CASE WHEN LEFT([s].[ExecutionResult], 1) = 'D' THEN 1 ELSE 0 END), '#') AS [Disabled]
	,FORMAT(SUM([s].[ExecutionDuration]) / 1000.0 / 60.0, '0.00') AS [DurationForAllSteps]
	,FORMAT(DATEDIFF(SECOND, Min([s].[ExecutionStartedAt]), Max([s].[ExecutionFinishedAt])) / 60, '0.00') AS [DurationForPart]
	,FORMAT(MIN([s].[ExecutionStartedAt]), 'yyyy-MM-dd HH:mm:ss') AS [ExecutionStartedAt]
	,FORMAT(MAX([s].[ExecutionFinishedAt]), 'yyyy-MM-dd HH:mm:ss') AS [ExecutionFinishedAt]
FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] AS [s]
JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co] ON [co].[ID] = [s].[FK_LoadObject_ID]
GROUP BY
	 [s].[FK_Execution_ID]
	,[co].[ModelObjectLayer]
	,[co].[ModelObjectPart]
	,[co].[ExecutionSortOrder]
;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID] (
	 @ExecutionPlan    NVARCHAR(255)
	,@ExecutionPlan_ID INT           = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	SET @ExecutionPlan_ID = NULL;

	--get execution plan
	SELECT @ExecutionPlan_ID = [ID]
	FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]
	WHERE [ExecutionPlan] = @ExecutionPlan
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Show_Execution]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Show_Execution] (
	 @ExecutionPlan NVARCHAR(255) = NULL
	,@Execution_ID  INT           = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE @ExecutionPlan_ID INT;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	--get last execution ID if no one was provided
	IF @Execution_ID IS NULL
	BEGIN

		SELECT TOP 1
			 @Execution_ID = [ID]
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution]
		WHERE @ExecutionPlan IS NULL
		   OR [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
		ORDER BY [IsActive] DESC, [ExecutionFinishedAt] DESC
		;

	END;

	--get execution details
	SELECT
		 [Execution_ID]
		,[LoadCreatedAt]
		,[LoadEffectiveAt]
		,[IsActive]
		,[IsCanceled]
		,[Execution_Step_ID]
		,[LoadObject_ID]
		,[LoadObject]
		,[ExecutionOrder]
		,[ExecutionTechnology]
		,[ExecutionStatus]
		,[ExecutionResult]
		,[LoaderMessage]
		,[RowCountInserted]
		,[RowCountUpdated]
		,[RowCountDeleted]
		,[RowCountWarning]
		,[RowCountError]
		,[ErrorStatus]
		,[ErrorDescription]
		,[DependencyCount]
		,[DependencyCountFinished]
		,[DependentOnLoadObject]
		,[DependentOnLoadObject_ID]
		,[ExecutionStartedAt]
		,[ExecutionFinishedAt]
		,[ExecutionDuration]
		,[ExecutionProcessSPID]
		,[ExecutionProcessExternalKey]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_All]
	WHERE [Execution_ID] = @Execution_ID
	ORDER BY [ExecutionOrder] ASC, [LoadObject] ASC
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Show_ExecutionMonitor]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Show_ExecutionMonitor] (
	 @ExecutionPlan NVARCHAR(255) = NULL
	,@Execution_ID  INT           = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE @ExecutionPlan_ID INT;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	--get last execution ID if no one was provided
	IF @Execution_ID IS NULL
	BEGIN

		SELECT TOP 1
			 @Execution_ID = [ID]
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution]
		WHERE @ExecutionPlan IS NULL
		   OR [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
		ORDER BY [IsActive] DESC, [ExecutionFinishedAt] DESC
		;

	END;
	
	--get execution details
	SELECT
		 [Execution_ID]
		,[ExecutionSortOrder]
		,[ModelObjectLayer]
		,[ModelObjectPart]
		,[Waiting]
		,[Running]
		,[Finished]
		,[Success]
		,[Failure]
		,[Disabled]
		,[DurationForAllSteps]
		,[DurationForPart]
		,[ExecutionStartedAt]
		,[ExecutionFinishedAt]
	FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionMonitor_All]
	WHERE [Execution_ID] = @Execution_ID
	ORDER BY [ExecutionSortOrder] ASC
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Show_ExecutionPlan]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Show_ExecutionPlan] (
	 @ExecutionPlan NVARCHAR(255) = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE @ExecutionPlan_ID INT;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	SELECT
		 [ExecutionPlan_ID]
		,[ExecutionPlan]
		,[LoadObject_ID]
		,[LoadObject]
		,[ErrorBehavior]
		,[ExecutionTechnology]
		,[ExecutionPriority]
		,[ExecutionSortOrder]
		,[IsActive]
		,[DependencyCount]
		,[DependentOnLoadObject]
		,[DependentOnLoadObject_ID]
	FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_All]
	WHERE @ExecutionPlan IS NULL
	   OR [ExecutionPlan_ID] = @ExecutionPlan_ID
	ORDER BY [ExecutionSortOrder], [LoadObject]
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Resume]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Resume] (
	 @ExecutionPlan              NVARCHAR(255)
	,@Message                    NVARCHAR(4000) = NULL
	,@ExecutionExternalReference NVARCHAR(4000) = NULL
	,@Execution_ID               INT            = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
		,@ResumedExecution_ID INT
		,@LoadEffectiveTimestamp DATETIMEOFFSET
		,@IsActive BIT
		,@LoadTimestamp DATETIMEOFFSET = SYSDATETIMEOFFSET()
	;
	SET @Execution_ID = NULL;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	--get last execution
	SELECT TOP 1
		 @ResumedExecution_ID = [ID]
		,@LoadEffectiveTimestamp = [LoadEffectiveAt]
		,@ExecutionExternalReference = COALESCE(@ExecutionExternalReference, [ExecutionExternalReference] + N'-resumed')
		,@IsActive = [IsActive]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution]
	WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
	ORDER BY [ExecutionFinishedAt] DESC
	;

	IF @ExecutionPlan_ID IS NULL
	BEGIN
		RAISERROR(N'%s [%d]: Execution plan [%s] not found. Execution not created.', 0, 1, @ProcedureName, @@SPID, @ExecutionPlan) WITH NOWAIT;
		RETURN 0;
	END;

	IF @ResumedExecution_ID IS NULL OR @IsActive = 1 OR NOT EXISTS (SELECT 1 FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] WHERE [FK_Execution_ID] = @ResumedExecution_ID AND ISNULL([ExecutionResult], N'') <> N'Success')
	BEGIN
		RAISERROR(N'%s [%d]: No execution with pending steps available. Execution not created.', 0, 1, @ProcedureName, @@SPID) WITH NOWAIT;
		RETURN 0;
	END;

	BEGIN TRANSACTION;

	--create execution entry to resume
	INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[Execution] (
		 [FK_ExecutionPlan_ID]
		,[FK_ResumedExecution_ID]
		,[LoadCreatedAt]
		,[LoadEffectiveAt]
		,[Description]
		,[IsCanceled]
		,[ExecutionStartedAt]
		,[IsActive]
		,[ExecutionExternalReference]
	)
	VALUES (
		 @ExecutionPlan_ID
		,@ResumedExecution_ID
		,@LoadTimestamp
		,@LoadEffectiveTimestamp
		,N'Resume execution with execution id ' + CAST(@ResumedExecution_ID AS NVARCHAR(10)) + ISNULL(N'. ' + @Message, N'')
		,0  --IsCanceled
		,SYSDATETIMEOFFSET()
		,1  --IsActive
		,@ExecutionExternalReference
	)
	;

	SET @Execution_ID = SCOPE_IDENTITY();

	--copy unfinished execution steps
	INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] (
		 [FK_Execution_ID]
		,[FK_LoadObject_ID]
		,[ServerName]
		,[DatabaseName]
		,[SchemaName]
		,[LoadObject]
		,[ExecutionTechnology]
		,[ExecutionPriority]
		,[ExecutionOrder]
		,[ErrorBehavior]
		,[IsAvailableForExecution]
	)
	SELECT
		 @Execution_ID
		,[FK_LoadObject_ID]
		,[ServerName]
		,[DatabaseName]
		,[SchemaName]
		,[LoadObject]
		,[ExecutionTechnology]
		,COALESCE([ExecutionPriority], 100000)
		,0 --ExecutionOrder
		,[ErrorBehavior]
		,1 --IsAvailableForExecution
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
	WHERE [FK_Execution_ID] = @ResumedExecution_ID
	  AND ISNULL([ExecutionResult], N'') <> N'Success'
	;

	--create execution load object dependencies for unfinished steps
	WITH [UnfinishedLoadObjects] AS (
		SELECT [FK_LoadObject_ID] AS [LoadObject_ID]
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
		WHERE [FK_Execution_ID] = @ResumedExecution_ID
		  AND ISNULL([ExecutionResult], N'') <> N'Success'
	)
	INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency] (
		 [FK_Execution_ID]
		,[FK_LoadObject_ID]
		,[FK_DependentOnLoadObject_ID]
		,[IsDependentObjectFinished]
		,[AllowDisable]
	)
	SELECT
		 @Execution_ID
		,[d].[FK_LoadObject_ID]
		,[d].[FK_DependentOnLoadObject_ID]
		,0
		,[d].[AllowDisable]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency] AS [d]
	WHERE [d].[FK_Execution_ID] = @ResumedExecution_ID
	  AND EXISTS (
			SELECT 1
			FROM [UnfinishedLoadObjects]
			WHERE [LoadObject_ID] = [FK_LoadObject_ID]
		  )
	  AND EXISTS (
			SELECT 1
			FROM [UnfinishedLoadObjects]
			WHERE [LoadObject_ID] = [FK_DependentOnLoadObject_ID]
		  )
	;

	COMMIT TRANSACTION;

	RAISERROR(N'%s [%d]: Execution [%d] created for execution plan [%s] to resume execution [%d].', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @ExecutionPlan, @ResumedExecution_ID) WITH NOWAIT;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_LoadObject_Dependencies]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_LoadObject_Dependencies] (
	 @Execution_ID  INT
	,@LoadObject_ID INT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE @Dummy_ID BIGINT;
	DECLARE @DisabledObjects AS TABLE ([LoadObject_ID] INT);

	BEGIN TRANSACTION;

	--the steps below could cause deadlocks in combination with [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_Step] because of conflicting order of access to [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] and [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
	--therefore we added an additional dummy access to [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] as first operation
	SELECT @Dummy_ID = [FK_Execution_ID]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] WITH (TABLOCKX) -- prevent deadlocks with multi threaded calls
	WHERE [FK_Execution_ID] = @Execution_ID
	;

	--get dependent load objects
	WITH [RecursiveLoadObjects]
	AS (
		--anchor member definition
		SELECT
			 [FK_LoadObject_ID]
			,[FK_DependentOnLoadObject_ID]
			,[FK_Execution_ID]
			,[AllowDisable]
			,0 AS [Level]
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency] WITH (TABLOCKX) -- prevent deadlocks with multi threaded calls
		WHERE [FK_Execution_ID] = @Execution_ID
		  AND [FK_DependentOnLoadObject_ID] = @LoadObject_ID

		UNION ALL

		--recursive member definition
		SELECT
			 [d].[FK_LoadObject_ID]
			,[d].[FK_DependentOnLoadObject_ID]
			,[d].[FK_Execution_ID]
			,[d].[AllowDisable]
			,[r].[Level] + 1 AS [Level]
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency] AS [d]
		JOIN [RecursiveLoadObjects] AS [r]
		   ON [r].[FK_LoadObject_ID] = [d].[FK_DependentOnLoadObject_ID]
		  AND [r].[FK_Execution_ID] = [d].[FK_Execution_ID]
	)
	--add to disable load objects
	INSERT INTO @DisabledObjects (
		 [LoadObject_ID]
	)
	SELECT [FK_LoadObject_ID]
	FROM [RecursiveLoadObjects]
	WHERE [AllowDisable] = 1
	GROUP BY [FK_LoadObject_ID]
	;

	--deactivate dependent objects
	UPDATE [s]
	SET  [ErrorDescription] = 'Disabled due to error of method ' + [co].[SchemaName] + '.' + [co].[LoadObject]
		,[IsAvailableForExecution] = 0
		,[ExecutionResult] = 'Disabled'
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] AS [s]
	CROSS JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co]
	WHERE [s].[FK_Execution_ID] = @Execution_ID
	  AND [s].[FK_LoadObject_ID] IN (SELECT [LoadObject_ID] from @DisabledObjects)
	  AND [co].[ID] = @LoadObject_ID
	;

	--remove dependencies on disabled and failed objects
	UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
	SET  [IsDependentObjectFinished] = 1
	WHERE [FK_Execution_ID] = @Execution_ID
	  AND (
			   [FK_DependentOnLoadObject_ID] IN (SELECT [LoadObject_ID] from @DisabledObjects)
			OR [FK_DependentOnLoadObject_ID] = @LoadObject_ID --Failed Object
	      )
	;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_Step]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_Step] (
	 @Execution_ID                INT
	,@Execution_Step_ID           INT
	,@LoadObject_ID               INT
	,@ExecutionResult             NVARCHAR(4000) = NULL
	,@ErrorDescription            NVARCHAR(4000) = NULL
	,@RowCountInserted            BIGINT         = 0
	,@RowCountUpdated             BIGINT         = 0
	,@RowCountDeleted             BIGINT         = 0
	,@RowCountWarning             BIGINT         = 0
	,@RowCountError               BIGINT         = 0
	,@ExecutionProcessExternalKey BIGINT         = NULL
	,@LoaderMessage               NVARCHAR(4000) = NULL
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	BEGIN TRANSACTION;

	--update log step
	UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] WITH (TABLOCKX) -- prevent deadlocks with multi threaded calls 
	SET  [ExecutionFinishedAt] = SYSDATETIMEOFFSET()
		,[ExecutionDuration] = DATEDIFF_BIG(ms, [ExecutionStartedAt], SYSDATETIMEOFFSET())
		,[ExecutionResult] = @ExecutionResult
		,[ErrorDescription] = @ErrorDescription
		,[RowCountInserted] = @RowCountInserted
		,[RowCountUpdated] = @RowCountUpdated
		,[RowCountDeleted] = @RowCountDeleted
		,[RowCountWarning] = @RowCountWarning
		,[RowCountError] = @RowCountError
		,[ExecutionProcessExternalKey] = @ExecutionProcessExternalKey
		,[LoaderMessage] = @LoaderMessage
		,[UpdatedAt] = SYSDATETIMEOFFSET()
		,[UpdatedBy] = CURRENT_USER
	WHERE [ID] = @Execution_Step_ID
	;

	--update dependencies
	UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency] WITH (TABLOCKX) -- prevent deadlocks with multi threaded calls
	SET  [IsDependentObjectFinished] = 1
		,[UpdatedAt] = SYSDATETIMEOFFSET()
		,[UpdatedBy] = CURRENT_USER
	WHERE [FK_DependentOnLoadObject_ID] = @LoadObject_ID
	  AND [FK_Execution_ID] = @Execution_ID
	;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Start]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Start] (
	 @ExecutionPlan              NVARCHAR(255)   
	,@LoadEffectiveTimestamp     DATETIMEOFFSET = NULL
	,@Description                NVARCHAR(4000) = NULL
	,@ExecutionExternalReference NVARCHAR(4000) = NULL
	,@Execution_ID               INT            = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
		,@LoadTimestamp DATETIMEOFFSET = SYSDATETIMEOFFSET()
	;
	SET @LoadEffectiveTimestamp = COALESCE(@LoadEffectiveTimestamp, @LoadTimestamp);
	SET @Execution_ID = NULL;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	IF @ExecutionPlan_ID IS NULL
	BEGIN
		RAISERROR(N'%s [%d]: Execution plan [%s] not found. Execution not created.', 11, 1, @ProcedureName, @@SPID, @ExecutionPlan) WITH NOWAIT;
		RETURN 0;
	END;

	IF EXISTS (
		SELECT 1
		FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject] AS [po]
		JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co]
		   ON [co].[ID] = [po].[FK_LoadObject_ID]
		  AND [co].[ModelObjectType] NOT IN (N'CH', N'CF') -- exclude headers/footers as they would block all parallel executions
		  AND [co].[IsActive] = 1
		WHERE [po].[FK_ExecutionPlan_ID] = @ExecutionPlan_ID
		  AND EXISTS (
				SELECT 1
				FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] AS [e]
				JOIN [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] AS [s] ON [s].[FK_Execution_ID] = [e].[ID]
				WHERE [e].[IsActive] = 1
				  AND [s].[FK_LoadObject_ID] = [po].[FK_LoadObject_ID]
			  )
	)
	BEGIN
		RAISERROR(N'%s [%d]: Execution plan [%s] has load objects that are worked on by another active execution. Execution not created.', 11, 1, @ProcedureName, @@SPID, @ExecutionPlan) WITH NOWAIT;
		RETURN 0;
	END;

	BEGIN TRANSACTION;

	--deactivate active log entries for the execution plan (due to abort of an earlier execution)
	--there must be only one active log entry for an execution plan.
	UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution]
	SET  [IsActive] = 0
		,[IsCanceled] = 1
		,[ExecutionResult] = 'Deactivated'
		,[Message] = COALESCE([Message] + ' ', '') + 'Deactivated before execution with load timestamp ' + CAST(@LoadTimestamp AS NVARCHAR(15)) + '.'
	WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
	  AND [IsActive] = 1
	;

	--create execution entry
	INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[Execution] (
		 [FK_ExecutionPlan_ID]
		,[LoadCreatedAt]
		,[LoadEffectiveAt]
		,[Description]
		,[ExecutionExternalReference]
		,[IsCanceled]
		,[IsActive]
	)
	VALUES (
		 @ExecutionPlan_ID
		,@LoadTimestamp
		,@LoadEffectiveTimestamp
		,@Description
		,@ExecutionExternalReference
		,0 --IsCanceled
		,1 --IsActive
	)
	;

	SET @Execution_ID = SCOPE_IDENTITY();

	--create execution steps
	INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] (
		 [FK_Execution_ID]
		,[FK_LoadObject_ID]
		,[ServerName]
		,[DatabaseName]
		,[SchemaName]
		,[LoadObject]
		,[ExecutionTechnology]
		,[ExecutionPriority]
		,[ExecutionOrder]
		,[ErrorBehavior]
		,[IsAvailableForExecution]
	)
	SELECT
		 @Execution_ID
		,[po].[FK_LoadObject_ID]
		,[co].[ServerName]
		,[co].[DatabaseName]
		,[co].[SchemaName]
		,[co].[LoadObject]
		,[co].[ExecutionTechnology]
		,COALESCE([po].[ExecutionPriority], [co].[ExecutionPriority], [co].[ExecutionSortOrder] + 100000)
		,0 --ExecutionOrder
		,[po].[ErrorBehavior]
		,1 --IsAvailableForExecution
	FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject] AS [po]
	JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co] ON [po].[FK_LoadObject_ID] = [co].[ID]
	WHERE [po].[FK_ExecutionPlan_ID] = @ExecutionPlan_ID
	  AND [co].[IsActive] = 1
	ORDER BY [co].[ExecutionSortOrder] ASC, [co].[LoadObject] ASC
	;

	--create execution load object dependencies
	INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency] (
		 [FK_Execution_ID]
		,[FK_LoadObject_ID]
		,[FK_DependentOnLoadObject_ID]
		,[IsDependentObjectFinished]
		,[AllowDisable]
	)
	SELECT
		 @Execution_ID
		,[po1].[FK_LoadObject_ID]
		,[po2].[FK_LoadObject_ID]
		,0
		,[d].[AllowDisable]
	FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency] AS [d]    
	JOIN [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject] AS [po1]
	   ON [po1].[FK_LoadObject_ID] = [d].[FK_LoadObject_ID]
	  AND [po1].[FK_ExecutionPlan_ID] = @ExecutionPlan_ID
	JOIN [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject] AS [po2]
	   ON [po2].[FK_LoadObject_ID] = [d].[FK_DependentOnLoadObject_ID]
	  AND [po2].[FK_ExecutionPlan_ID] = @ExecutionPlan_ID
	JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co1]
	   ON [co1].[ID] = [po1].[FK_LoadObject_ID]
	  AND [co1].[IsActive] = 1
	JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [lo2]
	   ON [lo2].[ID] = [po2].[FK_LoadObject_ID]
	  AND [lo2].[IsActive] = 1
	WHERE [d].[FK_LoadObject_ID] <> [d].[FK_DependentOnLoadObject_ID]
	;

	COMMIT TRANSACTION;

	RAISERROR(N'%s [%d]: Execution plan [%s] launched with execution [%d].', 0, 1, @ProcedureName, @@SPID, @ExecutionPlan, @Execution_ID) WITH NOWAIT;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution] (
	 @Execution_ID    INT
	,@Message         NVARCHAR(4000) = NULL
	,@CancelExecution INT            = 0
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @Dummy_ID BIGINT
		,@ErrorCount INT
		,@ExecutionResult NVARCHAR(4000) = N'Success'
	;

	BEGIN TRANSACTION;

	--the other code below could cause deadlocks in combination with [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Step] because of conflicting order of access to [{loadcontrol#loadcontrol#schema_name}].[Execution] and [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
	--therefore we added an additional dummy access to [{loadcontrol#loadcontrol#schema_name}].[Execution] as first operation
	SELECT @Dummy_ID = [ID]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] WITH (TABLOCKX) -- prevent deadlocks with multi threaded calls
	WHERE [ID] = @Execution_ID
	;

	--check for errors
	SELECT @ErrorCount = COUNT(*)
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] WITH (TABLOCKX) -- prevent deadlocks with multi threaded calls
	WHERE [FK_Execution_ID] = @Execution_ID
	  AND [ExecutionResult] <> N'Success'
	;

	--set execution result
	IF @CancelExecution = 1
	BEGIN
		SET @ExecutionResult = N'Aborted';
	END
	ELSE IF @ErrorCount > 0
	BEGIN
		SET @ExecutionResult = N'Finished with ' + CAST(@ErrorCount AS NVARCHAR(20)) + N' errors';
	END;

	--update log
	UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution]
	SET  [ExecutionResult] = @ExecutionResult
		,[Message] = @Message
		,[ExecutionFinishedAt] = SYSDATETIMEOFFSET()
		,[ExecutionDuration] = DATEDIFF_BIG(ms, [ExecutionStartedAt], SYSDATETIMEOFFSET())
		,[IsCanceled] = @CancelExecution
		,[IsActive] = 0
		,[UpdatedAt] = SYSDATETIMEOFFSET()
		,[UpdatedBy] = CURRENT_USER
	WHERE [ID] = @Execution_ID
	;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_RemoveLoadObjects]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_RemoveLoadObjects] (
	 @ExecutionPlan       NVARCHAR(255)  
	,@LoadConfig          NVARCHAR(255) = NULL 
	,@ModelObject         NVARCHAR(255) = NULL 
	,@ModelObjectPart     NVARCHAR(255) = NULL 
	,@ModelObjectDataflow NVARCHAR(255) = NULL 
	,@ModelObjectLayer    NVARCHAR(255) = NULL 
	,@ModelObjectType     NVARCHAR(255) = NULL 
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
	;

	BEGIN TRANSACTION;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	IF @ExecutionPlan_ID IS NULL
		RAISERROR(N'%s: Execution plan [%s] not found.', 0, 1, @ProcedureName, @ExecutionPlan) WITH NOWAIT;
	ELSE
	BEGIN

		--remove execution plan load object mappings (bulk)
		DELETE
		FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
		WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
		  AND [FK_LoadObject_ID] IN (
				SELECT [co].[ID]
				FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig] AS [c]
				JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co] ON [co].[FK_LoadConfig_ID] = [c].[ID]
				WHERE [co].[IsActive] = 1
				  AND (@LoadConfig IS NULL OR [c].[LoadConfig] = @LoadConfig)
				  AND (@ModelObject IS NULL OR [co].[ModelObject] = @ModelObject)
				  AND (@ModelObjectPart IS NULL OR [co].[ModelObjectPart] = @ModelObjectPart)
				  AND (@ModelObjectDataflow IS NULL OR [co].[ModelObjectDataflow] = @ModelObjectDataflow)
				  AND (@ModelObjectLayer IS NULL OR [co].[ModelObjectLayer] = @ModelObjectLayer)
				  AND (@ModelObjectType IS NULL OR [co].[ModelObjectType] = @ModelObjectType)
		      )
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_AddLoadObjects]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_AddLoadObjects] (
	 @ExecutionPlan       NVARCHAR(255)
	,@LoadConfig          NVARCHAR(255) = NULL
	,@ModelObject         NVARCHAR(255) = NULL
	,@ModelObjectPart     NVARCHAR(255) = NULL
	,@ModelObjectDataflow NVARCHAR(255) = NULL
	,@ModelObjectLayer    NVARCHAR(255) = NULL
	,@ModelObjectType     NVARCHAR(255) = NULL
	,@ErrorBehavior       NVARCHAR(255) = NULL
	,@ExecutionPriority   INT           = NULL
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
	;

	BEGIN TRANSACTION;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	IF @ExecutionPlan_ID IS NULL
		RAISERROR(N'%s: Execution plan [%s] not found.', 0, 1, @ProcedureName, @ExecutionPlan) WITH NOWAIT;
	ELSE
	BEGIN
	
		--add execution plan load object mappings (bulk)
		INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject] (
			 [FK_ExecutionPlan_ID]
			,[FK_LoadObject_ID]
			,[ErrorBehavior]
			,[ExecutionPriority]
			,[InsertedAt]
			,[InsertedBy]
			,[UpdatedAt]
			,[UpdatedBy]
		)
		SELECT DISTINCT
			 @ExecutionPlan_ID
			,[co].[ID]
			,CASE
				WHEN [co].[ErrorBehavior] = N'Default' THEN COALESCE(@ErrorBehavior, N'ContinueOnError')
				ELSE COALESCE(@ErrorBehavior, [co].[ErrorBehavior], N'ContinueOnError')
			 END
			,COALESCE(@ExecutionPriority, [co].[ExecutionPriority])
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
		FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig] AS [c]
		JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co] ON [co].[FK_LoadConfig_ID] = [c].[ID]
		WHERE [co].[IsActive] = 1
		  AND (@LoadConfig IS NULL OR [c].[LoadConfig] = @LoadConfig)
		  AND (@ModelObject IS NULL OR [co].[ModelObject] = @ModelObject)
		  AND (@ModelObjectPart IS NULL OR [co].[ModelObjectPart] = @ModelObjectPart)
		  AND (@ModelObjectDataflow IS NULL OR [co].[ModelObjectDataflow] = @ModelObjectDataflow)
		  AND (@ModelObjectLayer IS NULL OR [co].[ModelObjectLayer] = @ModelObjectLayer)
		  AND (@ModelObjectType IS NULL OR [co].[ModelObjectType] = @ModelObjectType)
		  AND NOT EXISTS (
				SELECT 1
				FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
				WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
				  AND [FK_LoadObject_ID] = [co].[ID]
			  )
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Remove_ExecutionPlan]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_ExecutionPlan] (
	 @ExecutionPlan NVARCHAR(255)
	,@CleanLog      BIT           =  0 
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
	;
	
	BEGIN TRANSACTION;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;
	
	IF @ExecutionPlan_ID IS NULL
		RAISERROR(N'%s: Execution plan [%s] not found.', 0, 1, @ProcedureName, @ExecutionPlan) WITH NOWAIT;
	ELSE IF @CleanLog = 0 AND EXISTS (SELECT 1 FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID)
		RAISERROR(N'%s: Associated log entries for execution plan [%s] found. Execution plan could not be removed.', 0, 1, @ProcedureName, @ExecutionPlan) WITH NOWAIT;
	ELSE
	BEGIN

		--remove dependent log
		IF @CleanLog = 1
		BEGIN

			DELETE
			FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
			WHERE [FK_Execution_ID] IN (SELECT [ID] FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID)
			;

			DELETE
			FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency]
			WHERE [FK_Execution_ID] IN (SELECT [ID] FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID)
			;

			DELETE
			FROM [{loadcontrol#loadcontrol#schema_name}].[Execution]
			WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
			;

		END;

		--remove dependent load object mapping
		DELETE
		FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
		WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
		;

		--remove execution plan
		DELETE
		FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]
		WHERE [ID] = @ExecutionPlan_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Process_Execution_Step]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Process_Execution_Step] (
	 @Execution_Step_ID INT
	,@ExecutionProcessExternalKey BIGINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@Execution_ID INT
		,@LoadObject_ID INT
		,@LoadTimestamp DATETIMEOFFSET
		,@LoadEffectiveTimestamp DATETIMEOFFSET
		,@IsActive BIT = 0
		,@IsAvailableForExecution BIT = 0
		,@ServerName NVARCHAR(255)
		,@DatabaseName NVARCHAR(255)
		,@SchemaName NVARCHAR(255)
		,@LoadObject NVARCHAR(255)
		,@LoadObjectFullName NVARCHAR(255)
		,@ExecutionTechnology NVARCHAR(255)
		,@ExecutionResult NVARCHAR(4000)
		,@ErrorBehavior NVARCHAR(255)
		,@ErrorDescription NVARCHAR(4000)
		,@RowCountInserted BIGINT
		,@RowCountUpdated BIGINT
		,@RowCountDeleted BIGINT
		,@RowCountWarning BIGINT
		,@RowCountError BIGINT
		,@LoaderMessage NVARCHAR(4000)
		,@ErrorMessage NVARCHAR(4000)
		,@SqlStatement NVARCHAR(4000)
	;

	--abort if no execution provided
	IF @Execution_Step_ID IS NULL
	BEGIN
		RAISERROR(N'%s [%d]: No execution step provided.', 11, 1, @ProcedureName, @@SPID) WITH NOWAIT;
		RETURN 0;
	END;

	--abort if execution not found
	IF NOT EXISTS (SELECT 1 FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] WHERE [ID] = @Execution_Step_ID)
	BEGIN
		RAISERROR(N'%s [%d]: Execution step [%d] not found.', 11, 1, @ProcedureName, @@SPID, @Execution_Step_ID) WITH NOWAIT;
		RETURN 0;
	END;

	--get execution and step details
	SELECT
		 @IsAvailableForExecution = [s].[IsAvailableForExecution]
		,@ExecutionTechnology = [s].[ExecutionTechnology]
		,@ExecutionResult = [s].[ExecutionResult]
		,@LoadObject_ID = [s].[FK_LoadObject_ID]
		,@ServerName = [s].[ServerName]
		,@DatabaseName = [s].[DatabaseName]
		,@SchemaName = [s].[SchemaName]
		,@LoadObject = [s].[LoadObject]
		,@ErrorBehavior = [s].[ErrorBehavior]
		,@Execution_ID = [e].[ID]
		,@IsActive = [e].[IsActive]
		,@LoadTimestamp = [e].[LoadCreatedAt]
		,@LoadEffectiveTimestamp = [e].[LoadEffectiveAt]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] AS [s]
	JOIN [{loadcontrol#loadcontrol#schema_name}].[Execution] AS [e] ON [e].[ID] = [s].[FK_Execution_ID]
	WHERE [s].[ID] = @Execution_Step_ID
	;

	IF @IsActive <> 1
	BEGIN
		RAISERROR(N'%s [%d]: Execution [%d] is not active.', 11, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;
		RETURN 0;
	END;

	IF @IsAvailableForExecution <> 0
	BEGIN
		RAISERROR(N'%s [%d]: Execution [%d] step [%d] is not selected for processing.', 11, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;
		RETURN 0;
	END;
	
	IF @ExecutionResult IS NOT NULL
	BEGIN
		RAISERROR(N'%s [%d]: Execution [%d] step [%d] was already processed.', 11, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;
		RETURN 0;
	END;

	IF @ExecutionTechnology <> 'SQL'
	BEGIN
		RAISERROR(N'%s [%d]: Execution [%d] step [%d] has unsupport execution technology [%s]. Execution aborted.', 11, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID, @ExecutionTechnology) WITH NOWAIT;
		RETURN 0;
	END;

	IF @ServerName IS NOT NULL AND @DatabaseName IS NULL
	BEGIN
		RAISERROR(N'%s [%d]: Execution [%d] step [%d] has server name but no database name. Execution aborted.', 11, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;
		RETURN 0;
	END;

	IF @ServerName IS NOT NULL
	BEGIN
		SET @LoadObjectFullName = N'[' + @ServerName + N'].[' + @DatabaseName + N'].[' + @SchemaName + N'].[' + @LoadObject + N']';
	END
	ELSE IF @DatabaseName IS NOT NULL
	BEGIN
		SET @LoadObjectFullName = N'[' + @DatabaseName + N'].[' + @SchemaName + N'].[' + @LoadObject + N']';
	END
	ELSE
	BEGIN
		SET @LoadObjectFullName = N'[' + @SchemaName + N'].[' + @LoadObject + N']';
	END;

	RAISERROR(N'%s [%d]: Execution [%d] step [%d] started: %s', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID, @LoadObjectFullName) WITH NOWAIT;

	BEGIN TRY

		----------------------------------------------------------------------------------------------------------------
		--Loader Call
		----------------------------------------------------------------------------------------------------------------

		--prepare the loader call
		SELECT @SqlStatement = N'BEGIN TRY' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'    EXEC ' + @LoadObjectFullName + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'         @LoadTimestamp = @LoadTimestamp' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'        ,@LoadEffectiveTimestamp = @LoadEffectiveTimestamp' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'        ,@RowCountInserted = @RowCountInserted OUT' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'        ,@RowCountUpdated = @RowCountUpdated OUT' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'        ,@RowCountDeleted = @RowCountDeleted OUT' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'        ,@RowCountWarning = @RowCountWarning OUT' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'        ,@RowCountError = @RowCountError OUT' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'        ,@LoaderMessage = @LoaderMessage OUT' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'    ;' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'    SET @ErrorMessage = NULL;' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'END TRY' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'BEGIN CATCH' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'    SET @ErrorMessage = ERROR_MESSAGE();' + CHAR(13) + CHAR(10);
		SELECT @SqlStatement += N'END CATCH;' + CHAR(13) + CHAR(10);

		--execute the loader call
		EXEC [sys].[sp_executesql]
			 @stmt = @SqlStatement
			,@params = N'@LoadTimestamp DATETIMEOFFSET, @LoadEffectiveTimestamp DATETIMEOFFSET, @RowCountInserted BIGINT OUT, @RowCountUpdated BIGINT OUT, @RowCountDeleted BIGINT OUT, @RowCountWarning BIGINT OUT, @RowCountError BIGINT OUT, @LoaderMessage NVARCHAR(4000) OUT, @ErrorMessage NVARCHAR(4000) OUT'
			,@LoadTimestamp = @LoadTimestamp
			,@LoadEffectiveTimestamp = @LoadEffectiveTimestamp
			,@RowCountInserted = @RowCountInserted OUT
			,@RowCountUpdated = @RowCountUpdated OUT
			,@RowCountDeleted = @RowCountDeleted OUT
			,@RowCountWarning = @RowCountWarning OUT
			,@RowCountError = @RowCountError OUT
			,@LoaderMessage = @LoaderMessage OUT
			,@ErrorMessage = @ErrorMessage OUT
		;

		--error occurred during loader call?
		IF @ErrorMessage IS NOT NULL
		BEGIN
			RAISERROR(N'%s [%d]: Execution [%d] step [%d] returned error: %s', 11, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID, @ErrorMessage) WITH NOWAIT;
		END;

		--no error
		SET @ExecutionResult = N'Success';
		RAISERROR(N'%s [%d]: Execution [%d] step [%d] finished sucessful: INS %I64d, UPD %I64d, DEL %I64d, WRN %I64d, ERR %I64d, MSG %s', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID, @RowCountInserted, @RowCountUpdated, @RowCountDeleted, @RowCountWarning, @RowCountError, @LoaderMessage) WITH NOWAIT;

	END TRY
	BEGIN CATCH

		----------------------------------------------------------------------------------------------------------------
		--Errorhandling
		----------------------------------------------------------------------------------------------------------------

		--show catched error
		SET @ErrorMessage = ERROR_MESSAGE();
		RAISERROR(@ErrorMessage, 0, 1) WITH NOWAIT;

		SET @ExecutionResult = N'Failure';
		SET @ErrorDescription = @ErrorMessage;

		--failure is critical
		IF @ErrorBehavior = N'AbortOnError'
		BEGIN

			--cancel execution
			EXEC [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution]
				 @Execution_ID = @Execution_ID
				,@Message = N'Aborted'
				,@CancelExecution = 1
			;

			--update all unfinished execution steps
			UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
			SET  [ErrorDescription] = 'Aborted due to error of method ' + @SchemaName + '.' + @LoadObject
			WHERE [FK_Execution_ID] = @Execution_ID
			  AND IsAvailableForExecution = 1
			;

			EXEC [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_Step]
				 @Execution_ID = @Execution_ID
				,@Execution_Step_ID = @Execution_Step_ID
				,@LoadObject_ID = @LoadObject_ID
				,@ExecutionResult = 'Failure with abort'
				,@ErrorDescription = @ErrorDescription
				,@ExecutionProcessExternalKey = @ExecutionProcessExternalKey
				,@LoaderMessage = @LoaderMessage
				,@RowCountInserted = NULL
				,@RowCountUpdated = NULL
				,@RowCountDeleted = NULL
				,@RowCountWarning = NULL
				,@RowCountError = NULL
			;

			RAISERROR(N'%s [%d]: Execution [%d] step [%d] finished with error. AbortOnError configured: execution aborted.', 11, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;

		END
		--failure is not critical
		ELSE IF @ErrorBehavior = 'ContinueOnError'
		BEGIN

			RAISERROR(N'%s [%d]: Execution [%d] step [%d] finished with error. ContinueOnError configured: dependent steps disabled.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;

			--deactivate dependent objects
			EXEC [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_LoadObject_Dependencies]
				 @Execution_ID = @Execution_ID
				,@LoadObject_ID = @LoadObject_ID
			;

		END
		ELSE
		BEGIN
			RAISERROR(N'%s [%d]: Execution [%d] step [%d] finished with error. Unknown error handling configured.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;
		END;

	END CATCH;

	--update execution step
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_Step]
		 @Execution_ID = @Execution_ID
		,@Execution_Step_ID = @Execution_Step_ID
		,@LoadObject_ID = @LoadObject_ID
		,@ExecutionResult = @ExecutionResult
		,@ErrorDescription = @ErrorDescription
		,@RowCountInserted = @RowCountInserted
		,@RowCountUpdated = @RowCountUpdated
		,@RowCountDeleted = @RowCountDeleted
		,@RowCountWarning = @RowCountWarning
		,@RowCountError = @RowCountError
		,@ExecutionProcessExternalKey = @ExecutionProcessExternalKey
		,@LoaderMessage = @LoaderMessage
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID] (
	 @LoadConfig    NVARCHAR(255)
	,@LoadConfig_ID INT           = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	SET @LoadConfig_ID = NULL;

	--get execution plan
	SELECT @LoadConfig_ID = [ID]
	FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]
	WHERE [LoadConfig] = @LoadConfig
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_ExecutionPlan]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_ExecutionPlan] (
	 @ExecutionPlan    NVARCHAR(255)
	,@Description      NVARCHAR(4000) = NULL
	,@ExecutionPlan_ID INT            = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	SET @ExecutionPlan_ID = NULL;

	BEGIN TRANSACTION;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	IF @ExecutionPlan_ID IS NULL
	BEGIN

		--add execution plan
		INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan] (
			 [ExecutionPlan]
			,[Description]
			,[InsertedAt]
			,[InsertedBy]
			,[UpdatedAt]
			,[UpdatedBy]
		)
		VALUES (
			 @ExecutionPlan
			,@Description
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
		)
		;

		SET @ExecutionPlan_ID = SCOPE_IDENTITY();

	END
	ELSE
	BEGIN

		--update execution plan
		UPDATE [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan]
		SET  [Description] = @Description
			,[UpdatedAt] = SYSDATETIMEOFFSET()
			,[UpdatedBy] = CURRENT_USER
		WHERE [ID] = @ExecutionPlan_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig] (
	 @LoadConfig NVARCHAR(255)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@LoadConfig_ID INT
	;

	BEGIN TRANSACTION;

	--get load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @LoadConfig
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	IF @LoadConfig_ID IS NULL
		RAISERROR(N'%s: Load config [%s] not found.', 0, 1, @ProcedureName, @LoadConfig) WITH NOWAIT;
	ELSE
	BEGIN

		--remove load config
		DELETE
		FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]
		WHERE [ID] = @LoadConfig_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig] (
	 @LoadConfig    NVARCHAR(255)
	,@Description   NVARCHAR(4000) = NULL 
	,@Project       NVARCHAR(255)  = NULL 
	,@Version       NVARCHAR(255)  = NULL 
	,@Status        NVARCHAR(255)  = NULL 
	,@LoadConfig_ID INT            = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	SET @LoadConfig_ID = NULL;
	
	BEGIN TRANSACTION;

	--get load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @LoadConfig
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	IF @LoadConfig_ID IS NULL
	BEGIN

		--add load config
		INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[LoadConfig] (
			 [LoadConfig]
			,[Description]
			,[Project]
			,[Version]
			,[Status]
			,[InsertedAt]
			,[InsertedBy]
			,[UpdatedAt]
			,[UpdatedBy]
		)
		VALUES (
			 @LoadConfig
			,@Description
			,@Project
			,@Version
			,@Status
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
		)
		;

		SET @LoadConfig_ID = SCOPE_IDENTITY();

	END
	ELSE
	BEGIN

		--update load config
		UPDATE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig]
		SET  [Description] = @Description
			,[Project] = @Project
			,[Version] = @Version
			,[Status] = @Status
			,[UpdatedAt] = SYSDATETIMEOFFSET()
			,[UpdatedBy] = CURRENT_USER
		WHERE [ID] = @LoadConfig_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_External]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_External] (
	 @Execution_Step_ID           INT
	,@RowCountInserted            BIGINT         = 0
	,@RowCountUpdated             BIGINT         = 0
	,@RowCountDeleted             BIGINT         = 0
	,@RowCountWarning             BIGINT         = 0
	,@RowCountError               BIGINT         = 0
	,@LoaderMessage               NVARCHAR(4000) = NULL
	,@ErrorDescription            NVARCHAR(4000) = NULL
	,@ExecutionProcessExternalKey BIGINT         = NULL
	,@ExecutionStatus             NVARCHAR(4000)        OUT
)
AS
BEGIN

	SET NOCOUNT ON;

	/* @ExecutionStatus values
		Ok						= "OK";
		Waiting					= "waiting";
		Canceled				= "canceled";
		Finished				= "finished";
		Failed					= "failed";
		Terminated				= "terminated";
		ExecutionPlanNotFound	= "epnotfound"; 
		Unexpected				= "unexpected";
	*/

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@Execution_ID INT
		,@LoadObject_ID INT
		,@LoadObject NVARCHAR(255)
		,@SchemaName NVARCHAR(255)
		,@ErrorBehavior NVARCHAR(255)
		,@ExecutionResult NVARCHAR(4000)
	;
	
	--get execution step details
	SELECT
		 @Execution_ID = [FK_Execution_ID]
		,@LoadObject_ID = [FK_LoadObject_ID]
		,@LoadObject = [LoadObject]
		,@SchemaName = [SchemaName]
		,@ErrorBehavior = [ErrorBehavior]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
	WHERE [ID] = @Execution_Step_ID
	;
	
	--process execution status
	IF @ExecutionStatus = N'failed'
	BEGIN

		----------------------------------------------------------------------------------------------------------------
		--Errorhandling
		----------------------------------------------------------------------------------------------------------------

		SET @ExecutionResult = N'Failure';

		--failure is critical
		IF @ErrorBehavior = N'AbortOnError'
		BEGIN

			--cancel execution
			EXEC [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution]
				 @Execution_ID = @Execution_ID
				,@Message = N'Aborted'
				,@CancelExecution = 1
			;

			--update all unfinished execution steps
			UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
			SET  [ErrorDescription] = 'Aborted due to error of method ' + @SchemaName + '.' + @LoadObject
			WHERE [FK_Execution_ID] = @Execution_ID
			  AND IsAvailableForExecution = 1
			;

			SET @ExecutionResult = N'Failure with abort';
			SET @RowCountInserted = NULL;
			SET @RowCountUpdated = NULL;
			SET @RowCountDeleted = NULL;
			SET @RowCountWarning = NULL;
			SET @RowCountError = NULL;

			RAISERROR(N'%s [%d]: Execution [%d] step [%d] finished with error (method [%s].[%s]). AbortOnError configured: execution aborted.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID, @SchemaName, @LoadObject) WITH NOWAIT;

		END
		--failure is not critical
		ELSE IF @ErrorBehavior = N'ContinueOnError'
		BEGIN

			RAISERROR(N'%s [%d]: Execution [%d] step [%d] finished with error (method [%s].[%s]). ContinueOnError configured: dependent steps disabled.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID, @SchemaName, @LoadObject) WITH NOWAIT;

			--deactivate dependent objects
			EXEC [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_LoadObject_Dependencies]
				 @Execution_ID = @Execution_ID
				,@LoadObject_ID = @LoadObject_ID
			;

		END
		ELSE
		BEGIN
			RAISERROR(N'%s [%d]: Execution [%d] step [%d] finished with error (method [%d].[%s]). Unknown error handling configured.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID, @SchemaName, @LoadObject) WITH NOWAIT;
		END;

	END
	ELSE
	BEGIN

		SET @ExecutionResult = N'Success'
		RAISERROR(N'%s [%d]: Execution [%d] step [%d] finished successful.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;

	END;

	EXEC [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution_Step]
		 @Execution_ID = @Execution_ID
		,@Execution_Step_ID = @Execution_Step_ID
		,@LoadObject_ID = @LoadObject_ID
		,@ExecutionResult = @ExecutionResult
		,@ErrorDescription = @ErrorDescription
		,@RowCountInserted = @RowCountInserted
		,@RowCountUpdated = @RowCountUpdated
		,@RowCountDeleted = @RowCountDeleted
		,@RowCountWarning = @RowCountWarning
		,@RowCountError = @RowCountError
		,@ExecutionProcessExternalKey = @ExecutionProcessExternalKey
		,@LoaderMessage = @LoaderMessage
	;

	--quit with handshake
	SET @ExecutionStatus = N'OK';

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Stop_Execution]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Stop_Execution] (
	 @ExecutionPlan NVARCHAR(255)
	,@Message       NVARCHAR(4000) = N'Execution stopped manually.'
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
		,@Execution_ID INT
	;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	--abort if execution plan not found
	IF @ExecutionPlan_ID IS NULL
	BEGIN
		RAISERROR(N'%s [%d]: Execution plan [%s] not found.', 11, 1, @ProcedureName, @@SPID, @ExecutionPlan) WITH NOWAIT;
		RETURN 0;
	END;

	--get active execution
	SELECT TOP 1
		 @Execution_ID = [ID]
		,@Message = ISNULL([Message] + ' | ', '') + ISNULL(@Message, '')
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution]
	WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
	  AND [IsActive] = 1
	ORDER BY [LoadCreatedAt] DESC
	;

	--abort if active execution not found
	IF @Execution_ID IS NULL
	BEGIN
		RAISERROR(N'%s [%d]: No active execution found for execution plan [%s].', 11, 1, @ProcedureName, @@SPID, @ExecutionPlan) WITH NOWAIT;
		RETURN 0;
	END;

	--cancel execution
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution]
		 @Execution_ID = @Execution_ID
		,@Message = @Message
		,@CancelExecution = 1
	;

	RAISERROR(N'%s [%d]: Execution [%d] for execution plan [%s] stopped.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @ExecutionPlan) WITH NOWAIT;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Step]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Step] (
	 @Execution_ID        INT             
	,@Execution_Step_ID   INT           = NULL OUT
	,@Status              INT           = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	/*
		Values for @Status
		0: OK. Execution step fetched
		1: Canceled. Execution was canceled.
		2: Finished. Execution is finished. No more steps available.
		3: Waiting. No step available at the moment. Try again later.
		4: Error.
	*/

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionOrder BIGINT
	;
	SET @Execution_Step_ID = NULL;
	SET @Status = NULL;

	BEGIN TRANSACTION;

	--Check if execution was canceled
	IF EXISTS(
		SELECT 1
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] WITH (TABLOCKX) -- prevent deadlocks with multi threaded calls
		WHERE [ID] = @Execution_ID
		  AND [IsCanceled] = 1
	)
	BEGIN

		SET @Status = 1; --execution was canceled
		RAISERROR(N'%s [%d]: Execution [%d] was canceled.', 0, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;

	END
	--Check if all steps have been complished
	ELSE IF NOT EXISTS (
		SELECT 1
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] WITH (TABLOCKX) -- prevent deadlocks with multi threaded calls
		WHERE [FK_Execution_ID] = @Execution_ID
		  AND [IsAvailableForExecution] = 1
	)
	BEGIN

		SET @Status = 2; --all steps have been complished
		RAISERROR(N'%s [%d]: Execution [%d] has no more selectable steps.', 0, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;

		EXEC [{loadcontrol#loadcontrol#schema_name}].[Finalize_Execution]
			 @Execution_ID = @Execution_ID
			,@Message = NULL
			,@CancelExecution = 0
		;

	END
	ELSE
	BEGIN

		--Fetch the next available step
		SELECT TOP 1
			 @Execution_Step_ID = [s].[ID]
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] AS [s]
		WHERE [s].[FK_Execution_ID] = @Execution_ID
		  AND [s].[IsAvailableForExecution] = 1
		  AND NOT EXISTS (
				  SELECT 1
				  FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_LoadObject_Dependency] WITH (TABLOCKX) -- prevent deadlocks with multi threaded calls
				  WHERE [FK_LoadObject_ID] = [s].[FK_LoadObject_ID]
					AND [FK_Execution_ID] = @Execution_ID
					AND [IsDependentObjectFinished] = 0
			  )
		ORDER BY [s].[ExecutionPriority] DESC
		;

		IF @Execution_Step_ID IS NULL
		BEGIN

			SET @Status = 3; -- no step available at the moment

		END
		ELSE
		BEGIN

			SET @Status = 0; -- next execution step fetched

			--increment execution order to reflect actual execution order in log
			SELECT @ExecutionOrder = MAX([ExecutionOrder]) + 1
			FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
			WHERE [FK_Execution_ID] = @Execution_ID
			;

			IF @ExecutionOrder >= 2147483647
			BEGIN
				RAISERROR(N'%s [%d]: Execution [%d] exceeded maximum ExecutionOrder. Execution process terminated.', 11, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;
				SET @Status = 4; --error
			END;

			--update execution step
			UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
			SET  [IsAvailableForExecution] = 0
				,[ExecutionStartedAt] = SYSDATETIMEOFFSET()
				,[ExecutionProcessSPID] = @@SPID
				,[ExecutionOrder] = @ExecutionOrder
			WHERE [ID] = @Execution_Step_ID
			;

			RAISERROR(N'%s [%d]: Execution [%d] step [%d] selected for processing.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;

		END;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan] (
	 @ExecutionPlan    NVARCHAR(255)
	,@Description      NVARCHAR(4000) = NULL
	,@ExecutionPlan_ID INT            = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;

	--add or update execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_ExecutionPlan]
		 @ExecutionPlan = @ExecutionPlan
		,@Description = @Description
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	--remove execution plan load object mappings
	DELETE
	FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
	WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Build_LoadConfig]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Build_LoadConfig] (
	 @ModelObjectLayer NVARCHAR(255)
	,@LoadConfig       NVARCHAR(255)
	,@Description      NVARCHAR(4000) = NULL 
	,@Project          NVARCHAR(255)  = NULL 
	,@Version          NVARCHAR(255)  = NULL 
	,@Status           NVARCHAR(255)  = NULL 
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE @LoadConfig_ID INT;

	--add or update load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig]
		 @LoadConfig = @LoadConfig
		,@Description = @Description
		,@Project = @Project
		,@Version = @Version
		,@Status = @Status
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	--deactivate all load objects for a layer
	--we do not delete them as we need stable load objects so execution plans don't have to be re-created
	--all that are still in use should be reactivated during deployment
	UPDATE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
	SET  [IsActive] = 0
	WHERE [FK_LoadConfig_ID] = @LoadConfig_ID
	  AND [ModelObjectLayer] = @ModelObjectLayer
	;

	--delete all load config load object dependencies defined for a layer
	--all that are still in use should be recreated during deployment
	DELETE
	FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
	WHERE EXISTS (
			SELECT [ID]
			FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
			WHERE [FK_LoadConfig_ID] = @LoadConfig_ID
			  AND [ModelObjectLayer] = @ModelObjectLayer
			  AND [ID] = [FK_LoadObject_ID]
	      )
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID] (
	 @LoadConfig               NVARCHAR(255)
	,@ModelObject              NVARCHAR(255)
	,@ModelObjectPart          NVARCHAR(255)
	,@ModelObjectDataflow      NVARCHAR(255)
	,@LoadConfig_LoadObject_ID INT           = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE @LoadConfig_ID INT;
	SET @LoadConfig_LoadObject_ID = NULL;

	--get load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @LoadConfig
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	--get load object
	SELECT @LoadConfig_LoadObject_ID = [ID]
	FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
	WHERE [FK_LoadConfig_ID] = @LoadConfig_ID
	  AND [ModelObject] = @ModelObject
	  AND [ModelObjectPart] = @ModelObjectPart
	  AND [ModelObjectDataflow] = @ModelObjectDataflow
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig_LoadObject]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig_LoadObject] (
	 @LoadConfig          NVARCHAR(255)
	,@ModelObject         NVARCHAR(255)
	,@ModelObjectPart     NVARCHAR(255)
	,@ModelObjectDataflow NVARCHAR(255)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@LoadConfig_ID INT
		,@LoadConfig_LoadObject_ID INT
	;

	BEGIN TRANSACTION;

	--get load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @LoadConfig
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	--get load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @LoadConfig_LoadObject_ID OUT
	;

	IF @LoadConfig_ID IS NULL
		RAISERROR(N'%s: Load config [%s] not found.', 0, 1, @ProcedureName, @LoadConfig) WITH NOWAIT;
	ELSE IF @LoadConfig_LoadObject_ID IS NULL
		RAISERROR(N'%s: Load object [%s, %s, %s] not found.', 0, 1, @ProcedureName, @ModelObject, @ModelObjectPart, @ModelObjectDataflow) WITH NOWAIT;
	ELSE
	BEGIN

		--remove load object
		DELETE
		FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
		WHERE [ID] = @LoadConfig_LoadObject_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] (
	 @LoadConfig               NVARCHAR(255)
	,@ModelObject              NVARCHAR(255)
	,@ModelObjectPart          NVARCHAR(255)
	,@ModelObjectDataflow      NVARCHAR(255)
	,@ModelObjectLayer         NVARCHAR(255) = NULL
	,@ModelObjectType          NVARCHAR(255) = NULL
	,@LoadObject               NVARCHAR(255)
	,@SchemaName               NVARCHAR(255) = NULL
	,@DatabaseName             NVARCHAR(255) = NULL
	,@ServerName               NVARCHAR(255) = NULL
	,@ErrorBehavior            NVARCHAR(255) = NULL
	,@ExecutionTechnology      NVARCHAR(255) = NULL
	,@ExecutionSortOrder       INT
	,@ExecutionPriority        INT           = NULL
	,@IsActive                 BIT           = NULL
	,@LoadConfig_LoadObject_ID INT           = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@LoadConfig_ID INT
	;
	SET @LoadConfig_LoadObject_ID = NULL;

	BEGIN TRANSACTION;

	--get load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @LoadConfig
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	--get load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @LoadConfig_LoadObject_ID OUT
	;

	IF @LoadConfig_ID IS NULL
		RAISERROR(N'%s: Load config [%s] not found.', 0, 1, @ProcedureName, @LoadConfig) WITH NOWAIT;
	ELSE IF @LoadConfig_LoadObject_ID IS NULL
	BEGIN

		--add load object
		INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] (
			 [FK_LoadConfig_ID]
			,[ModelObject]
			,[ModelObjectPart]
			,[ModelObjectDataflow]
			,[ModelObjectLayer]
			,[ModelObjectType]
			,[LoadObject]
			,[SchemaName]
			,[DatabaseName]
			,[ServerName]
			,[ErrorBehavior]
			,[ExecutionTechnology]
			,[ExecutionSortOrder]
			,[ExecutionPriority]
			,[IsActive]
			,[InsertedAt]
			,[InsertedBy]
			,[UpdatedAt]
			,[UpdatedBy]
		)
		VALUES (
			 @LoadConfig_ID
			,@ModelObject
			,@ModelObjectPart
			,@ModelObjectDataflow
			,@ModelObjectLayer
			,@ModelObjectType
			,@LoadObject
			,NULLIF(@SchemaName, N'')
			,NULLIF(@DatabaseName, N'')
			,NULLIF(@ServerName, N'')
			,COALESCE(@ErrorBehavior, N'Default')
			,@ExecutionTechnology
			,@ExecutionSortOrder
			,@ExecutionPriority
			,COALESCE(@IsActive, 1)
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
		)
		;

		SELECT @LoadConfig_LoadObject_ID = SCOPE_IDENTITY();

	END
	ELSE
	BEGIN

		--update load object
		UPDATE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
		SET  [ModelObjectLayer] = @ModelObjectLayer
			,[ModelObjectType] = @ModelObjectType
			,[LoadObject] = @LoadObject
			,[SchemaName] = NULLIF(@SchemaName, N'')
			,[DatabaseName] = NULLIF(@DatabaseName, N'')
			,[ServerName] = NULLIF(@ServerName, N'')
			,[ErrorBehavior] = COALESCE(@ErrorBehavior, N'Default')
			,[ExecutionTechnology] = @ExecutionTechnology
			,[ExecutionSortOrder] = @ExecutionSortOrder
			,[ExecutionPriority] = @ExecutionPriority
			,[IsActive] = COALESCE(@IsActive, 1)
			,[UpdatedAt] = SYSDATETIMEOFFSET()
			,[UpdatedBy] = CURRENT_USER
		WHERE [ID] = @LoadConfig_LoadObject_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_External]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_External] (
	 @ExecutionPlan              NVARCHAR(255)  = NULL     --mandatory input for new execution
	,@Description                NVARCHAR(4000) = NULL     --optional input for new execution
	,@ExecutionExternalReference NVARCHAR(4000) = NULL     --optional input for new execution
	,@Execution_ID               INT            = NULL OUT --mandatory input for existing execution
	,@Execution_Step_ID          INT            = NULL OUT
	,@LoadTimestamp              DATETIMEOFFSET = NULL OUT
	,@LoadEffectiveTimestamp     DATETIMEOFFSET = NULL OUT --optional input for new execution
	,@ServerName		         NVARCHAR(255)  = NULL OUT
	,@DatabaseName		         NVARCHAR(255)  = NULL OUT
	,@SchemaName		         NVARCHAR(255)  = NULL OUT
	,@LoadObject                 NVARCHAR(255)  = NULL OUT
	,@ModelObject                NVARCHAR(255)  = NULL OUT
	,@ModelObjectPart            NVARCHAR(255)  = NULL OUT
	,@ModelObjectDataflow        NVARCHAR(255)  = NULL OUT
	,@ModelObjectLayer           NVARCHAR(255)  = NULL OUT
	,@ModelObjectType            NVARCHAR(255)  = NULL OUT
	,@ExecutionTechnology        NVARCHAR(255)  = NULL OUT
	,@ExecutionStatus            NVARCHAR(4000) = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	/* @ExecutionStatus values
		Ok						= "OK";
		Waiting					= "waiting";
		Canceled				= "canceled";
		Finished				= "finished";
		Failed					= "failed";
		Terminated				= "terminated";
		ExecutionPlanNotFound	= "epnotfound";
		ExecutionNotFound	    = "exnotfound";
		Unexpected				= "unexpected";
	*/

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
		,@IsWaiting        BIT = 0
		,@Status           INT = 3 --Waiting
	;
	SET @Execution_Step_ID = NULL;
	SET @LoadTimestamp = NULL;
	SET @ServerName = NULL;
	SET @DatabaseName = NULL;  
	SET @SchemaName = NULL;
	SET @LoadObject = NULL; 
	SET @ModelObject = NULL;
	SET @ModelObjectPart = NULL;
	SET @ModelObjectDataflow = NULL;
	SET @ModelObjectLayer = NULL;
	SET @ModelObjectType = NULL;
	SET @ExecutionTechnology = NULL
	SET @ExecutionStatus = N'unexpected';

	BEGIN TRANSACTION;

	--no provided execution
	IF @Execution_ID IS NULL
	BEGIN

		--get execution plan
		EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
			 @ExecutionPlan = @ExecutionPlan
			,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
		;

		--abort if execution plan is not found
		IF @ExecutionPlan_ID IS NULL
		BEGIN
			SET @ExecutionStatus = N'epnotfound';
			RAISERROR(N'%s [%d]: Execution plan [%s] not found.', 0, 1, @ProcedureName, @@SPID, @ExecutionPlan) WITH NOWAIT;
			RETURN 0;
		END;

		--get active execution
		SELECT TOP 1
			 @Execution_ID = [ID]
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution]
		WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
		  AND [IsActive] = 1
		ORDER BY [LoadCreatedAt] DESC
		;

		--start new execution (if no active one was found)
		IF @Execution_ID IS NULL
		BEGIN

			EXEC [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Start]
				 @ExecutionPlan = @ExecutionPlan
				,@LoadEffectiveTimestamp = @LoadEffectiveTimestamp
				,@Description = @Description
				,@ExecutionExternalReference = @ExecutionExternalReference
				,@Execution_ID = @Execution_ID OUT
			;

		END
		ELSE
		BEGIN
			RAISERROR(N'%s [%d]: Execution [%d] found for execution plan [%s].', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @ExecutionPlan) WITH NOWAIT;
		END;

	END
	--with provided execution
	ELSE
	BEGIN

		--abort if execution is not found
		IF NOT EXISTS (SELECT 1 FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] WHERE [ID] = @Execution_ID)
		BEGIN
			SET @ExecutionStatus = N'exnotfound';
			RAISERROR(N'%s [%d]: Execution [%d] not found.', 0, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;
			RETURN 0;
		END;

		--abort if execution is not active
		IF NOT EXISTS (SELECT 1 FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] WHERE [ID] = @Execution_ID AND [IsActive] = 1)
		BEGIN
			SET @ExecutionStatus = N'terminated';
			RAISERROR(N'%s [%d]: Execution [%d] is not active.', 0, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;
			RETURN 0;
		END;

	END;

	--get execution details
	SELECT
		 @LoadTimestamp = [LoadCreatedAt]
		,@LoadEffectiveTimestamp = [LoadEffectiveAt]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution]
	WHERE [ID] = @Execution_ID
	;

	--start execution if not already running
	UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution]
	SET  [ExecutionStartedAt] = SYSDATETIMEOFFSET()
	WHERE [ID] = @Execution_ID
	  AND [ExecutionStartedAt] IS NULL
	;

	--store session context
	EXEC [sys].[sp_set_session_context] @key = N'Execution_ID', @value = @Execution_ID;
	EXEC [sys].[sp_set_session_context] @key = N'LoadTimestamp', @value = @LoadTimestamp;
	EXEC [sys].[sp_set_session_context] @key = N'LoadEffectiveTimestamp', @value = @LoadEffectiveTimestamp;

	--loop for next execution step
	WHILE @Status = 3 --3: Waiting
	BEGIN

		--get next execution step
		EXEC [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Step]
			 @Execution_ID = @Execution_ID
			,@Execution_Step_ID = @Execution_Step_ID OUT
			,@Status = @Status OUT
		;

		IF @Status = 3 --3: Waiting
		BEGIN

			--no step available at the moment, we try again after some waiting
			IF @IsWaiting = 0
			BEGIN
				RAISERROR(N'%s [%d]: Execution [%d] process waiting for work...', 0, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;
				SET @IsWaiting = 1;
			END;

			WAITFOR DELAY '00:00:01';

		END;

	END;

	COMMIT TRANSACTION;

	IF @Status = 0 --0: OK
	BEGIN
		
		--get execution step details
		SELECT
			 @ServerName = [s].[ServerName]
			,@DatabaseName = [s].[DatabaseName]
			,@SchemaName = [s].[SchemaName]
			,@LoadObject = [s].[LoadObject]
			,@ModelObject = [co].[ModelObject]
			,@ModelObjectPart = [co].[ModelObjectPart]
			,@ModelObjectDataflow = [co].[ModelObjectDataflow]
			,@ModelObjectLayer = [co].[ModelObjectLayer]
			,@ModelObjectType = [co].[ModelObjectType]
			,@ExecutionTechnology = [s].[ExecutionTechnology]
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step] AS [s]
		JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co] ON [co].[ID] = [s].[FK_LoadObject_ID]
		WHERE [s].[ID] = @Execution_Step_ID
		;

		RAISERROR(N'%s [%d]: Execution [%d] step [%d] started.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;
		SET @ExecutionStatus =  N'OK';
	END
	ELSE IF @Status = 1 --1: Canceled
	BEGIN
		SET @ExecutionStatus = N'canceled';
	END
	ELSE IF @Status = 2 --2: Finished
	BEGIN
		SET @ExecutionStatus = N'finished';
	END
	ELSE
	BEGIN
		RAISERROR(N'%s [%d]: Execution [%s] returned unexpected status [%d].', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Status) WITH NOWAIT;
		SET @ExecutionStatus = N'unexpected';
	END;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Process_Execution]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Process_Execution] (
	 @Execution_ID INT
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@LoadTimestamp DATETIMEOFFSET
		,@LoadEffectiveTimestamp DATETIMEOFFSET
		,@Execution_Step_ID INT
		,@ExecutionTechnology NVARCHAR(255)
		,@Status INT
		,@IsWaiting BIT = 0
		,@ErrorMessage NVARCHAR(4000)
	;

	--abort if no execution provided
	IF @Execution_ID IS NULL
	BEGIN
		RAISERROR(N'%s [%d]: No execution provided.', 11, 1, @ProcedureName, @@SPID) WITH NOWAIT;
		RETURN 0;
	END;

	--abort if execution not found
	IF NOT EXISTS (SELECT 1 FROM [{loadcontrol#loadcontrol#schema_name}].[Execution] WHERE [ID] = @Execution_ID)
	BEGIN
		RAISERROR(N'%s [%d]: Execution [%d] not found.', 11, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;
		RETURN 0;
	END;

	RAISERROR(N'%s [%d]: Execution [%d] started.', 0, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;

	--start execution if not already running
	UPDATE [{loadcontrol#loadcontrol#schema_name}].[Execution]
	SET  [ExecutionStartedAt] = SYSDATETIMEOFFSET()
	WHERE [ID] = @Execution_ID
	  AND [ExecutionStartedAt] IS NULL
	;

	--get execution details
	SELECT
		 @LoadTimestamp = [LoadCreatedAt]
		,@LoadEffectiveTimestamp = [LoadEffectiveAt]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution]
	WHERE [ID] = @Execution_ID
	;

	--store session context
	EXEC [sys].[sp_set_session_context] @key = N'Execution_ID', @value = @Execution_ID;
	EXEC [sys].[sp_set_session_context] @key = N'LoadTimestamp', @value = @LoadTimestamp;
	EXEC [sys].[sp_set_session_context] @key = N'LoadEffectiveTimestamp', @value = @LoadEffectiveTimestamp;

	--loop steps and process
	WHILE 1 = 1
	BEGIN

		--fetch next step
		EXEC [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Step]
			 @Execution_ID = @Execution_ID
			,@Execution_Step_ID = @Execution_Step_ID OUT
			,@Status = @Status OUT
		;

		IF @Status = 0 --0: OK
		BEGIN

			--reset
			SET @IsWaiting = 0;

			--get execution step details
			SELECT
				 @ExecutionTechnology = [ExecutionTechnology]
			FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
			WHERE [ID] = @Execution_Step_ID
			;

			IF @ExecutionTechnology = 'SQL'
			BEGIN

				BEGIN TRY

					EXEC [{loadcontrol#loadcontrol#schema_name}].[Process_Execution_Step]
						 @Execution_Step_ID = @Execution_Step_ID
						,@ExecutionProcessExternalKey = NULL --no external processing
					;

				END TRY
				BEGIN CATCH

					--show catched error
					SET @ErrorMessage = ERROR_MESSAGE();
					RAISERROR(@ErrorMessage, 0, 1) WITH NOWAIT;
					
					RAISERROR(N'%s [%d]: Execution [%d] aborted at step [%d].', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID) WITH NOWAIT;
					BREAK;

				END CATCH;

			END
			ELSE
			BEGIN
				RAISERROR(N'%s [%d]: Execution [%d] skipped step [%d] with unsupported execution technology [%s].', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Execution_Step_ID, @ExecutionTechnology) WITH NOWAIT;
			END;

		END
		ELSE IF @Status = 1 --1: Canceled
		BEGIN
			BREAK;
		END
		ELSE IF @Status = 2 --2: Finished
		BEGIN
			BREAK;
		END
		ELSE IF @Status = 3 --3: Waiting
		BEGIN

			--no step available at the moment, we try again after some waiting
			IF @IsWaiting = 0
			BEGIN
				RAISERROR(N'%s [%d]: Execution [%d] process waiting for work...', 0, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;
				SET @IsWaiting = 1;
			END;

			WAITFOR DELAY '00:00:01';

		END
		ELSE
		BEGIN
			RAISERROR(N'%s [%d]: Execution [%d] returned unexpected status [%d].', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @Status) WITH NOWAIT;
			BREAK;
		END;

	END;

	RAISERROR(N'%s [%d]: Execution [%d] finished.', 0, 1, @ProcedureName, @@SPID, @Execution_ID) WITH NOWAIT;
	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_Dependency_ID]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_Dependency_ID] (
	 @LoadConfig                          NVARCHAR(255)
	,@ModelObject                         NVARCHAR(255)
	,@ModelObjectPart                     NVARCHAR(255)
	,@ModelObjectDataflow                 NVARCHAR(255)
	,@DependentOnLoadConfig               NVARCHAR(255)
	,@DependentOnModelObject              NVARCHAR(255)
	,@DependentOnModelObjectPart          NVARCHAR(255)
	,@DependentOnModelObjectDataflow      NVARCHAR(255)
	,@LoadConfig_LoadObject_Dependency_ID INT           = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE
		 @LoadObject_ID INT
		,@DependentOnLoadObject_ID INT
	;
	SET @LoadConfig_LoadObject_Dependency_ID = NULL;

	--get load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @LoadObject_ID OUT
	;

	--get dependent on load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @DependentOnLoadConfig
		,@ModelObject = @DependentOnModelObject
		,@ModelObjectPart = @DependentOnModelObjectPart
		,@ModelObjectDataflow = @DependentOnModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @DependentOnLoadObject_ID OUT
	;

	SELECT @LoadConfig_LoadObject_Dependency_ID = [ID]
	FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
	WHERE [FK_LoadObject_ID] = @LoadObject_ID
	  AND [FK_DependentOnLoadObject_ID] = @DependentOnLoadObject_ID
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_LoadObject_ID]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_LoadObject_ID] (
	 @ExecutionPlan               NVARCHAR(255)
	,@LoadConfig                  NVARCHAR(255)
	,@ModelObject                 NVARCHAR(255)
	,@ModelObjectPart             NVARCHAR(255)
	,@ModelObjectDataflow         NVARCHAR(255)
	,@ExecutionPlan_LoadObject_ID INT           = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE
		 @ExecutionPlan_ID INT
		,@LoadObject_ID INT
	;
	SET @ExecutionPlan_LoadObject_ID = NULL;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	--get load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @LoadObject_ID OUT
	;

	-- get execution plan load object mapping
	SELECT @ExecutionPlan_LoadObject_ID = [ID]
	FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
	WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
	  AND [FK_LoadObject_ID] = @LoadObject_ID
	;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_ExecutionPlan_LoadObject]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_ExecutionPlan_LoadObject] (
	 @ExecutionPlan               NVARCHAR(255)
	,@LoadConfig                  NVARCHAR(255)
	,@ModelObject                 NVARCHAR(255)
	,@ModelObjectPart             NVARCHAR(255)
	,@ModelObjectDataflow         NVARCHAR(255)
	,@ErrorBehavior               NVARCHAR(255) = NULL
	,@ExecutionPriority           INT           = NULL
	,@ExecutionPlan_LoadObject_ID INT           = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
		,@LoadConfig_ID INT
		,@LoadObject_ID INT
	;
	SET @ExecutionPlan_LoadObject_ID = NULL;

	BEGIN TRANSACTION;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	--get load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @LoadConfig
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	--get load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @LoadObject_ID OUT
	;

	--get execution plan load object mapping
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_LoadObject_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@ExecutionPlan_LoadObject_ID = @ExecutionPlan_LoadObject_ID OUT
	;

	IF @ExecutionPlan_ID IS NULL
		RAISERROR(N'%s: Execution plan [%s] not found.', 0, 1, @ProcedureName, @ExecutionPlan) WITH NOWAIT;
	ELSE IF @LoadConfig_ID IS NULL
		RAISERROR(N'%s: Load config [%s] not found.', 0, 1, @ProcedureName, @LoadConfig) WITH NOWAIT;
	ELSE IF @LoadObject_ID IS NULL
		RAISERROR(N'%s: Load object [%s, %s, %s] not found.', 0, 1, @ProcedureName, @ModelObject, @ModelObjectPart, @ModelObjectDataflow) WITH NOWAIT;
	ELSE IF @ExecutionPlan_LoadObject_ID IS NULL
	BEGIN

		--add execution plan load object mapping
		INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject] (
			 [FK_ExecutionPlan_ID]
			,[FK_LoadObject_ID]
			,[ErrorBehavior]
			,[ExecutionPriority]
			,[InsertedAt]
			,[InsertedBy]
			,[UpdatedAt]
			,[UpdatedBy]
		)
		SELECT
			 @ExecutionPlan_ID
			,@LoadObject_ID
			,CASE
				WHEN [ErrorBehavior] = N'Default' THEN COALESCE(@ErrorBehavior, N'ContinueOnError')
				ELSE COALESCE(@ErrorBehavior, [ErrorBehavior], N'ContinueOnError')
			 END
			,COALESCE(@ExecutionPriority, [ExecutionPriority])
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
		FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject]
		WHERE [ID] = @LoadObject_ID
		;

		SET @ExecutionPlan_LoadObject_ID = SCOPE_IDENTITY();

	END
	ELSE
	BEGIN

		--update execution plan load object mapping
		UPDATE [po]
		SET  [ErrorBehavior] = CASE
								WHEN [co].[ErrorBehavior] = N'Default' THEN COALESCE(@ErrorBehavior, N'ContinueOnError')
								ELSE COALESCE(@ErrorBehavior, [co].[ErrorBehavior], N'ContinueOnError')
			                   END
			,[ExecutionPriority] = COALESCE(@ExecutionPriority, [co].[ExecutionPriority])
			,[UpdatedAt] = SYSDATETIMEOFFSET()
			,[UpdatedBy] = CURRENT_USER
		FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject] AS [po]
		JOIN [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject] AS [co] ON [co].[ID] = [po].[FK_LoadObject_ID]
		WHERE [po].[ID] = @ExecutionPlan_LoadObject_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig_LoadObject_Dependency]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_LoadConfig_LoadObject_Dependency] (
	 @LoadConfig                     NVARCHAR(255)
	,@ModelObject                    NVARCHAR(255)
	,@ModelObjectPart                NVARCHAR(255)
	,@ModelObjectDataflow            NVARCHAR(255)
	,@DependentOnLoadConfig          NVARCHAR(255)
	,@DependentOnModelObject         NVARCHAR(255)
	,@DependentOnModelObjectPart     NVARCHAR(255)
	,@DependentOnModelObjectDataflow NVARCHAR(255)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@LoadConfig_ID INT
		,@LoadObject_ID INT
		,@DependentOnLoadConfig_ID INT
		,@DependentOnLoadObject_ID INT
		,@LoadConfig_LoadObject_Dependency_ID INT
	;

	BEGIN TRANSACTION;

	--get load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @LoadConfig
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	--get load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @LoadObject_ID OUT
	;

	--get dependent on load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @DependentOnLoadConfig
		,@LoadConfig_ID = @DependentOnLoadConfig_ID OUT
	;

	--get dependent on load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @DependentOnLoadConfig
		,@ModelObject = @DependentOnModelObject
		,@ModelObjectPart = @DependentOnModelObjectPart
		,@ModelObjectDataflow = @DependentOnModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @DependentOnLoadObject_ID OUT
	;

	--get load config load object dependency
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_Dependency_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@DependentOnLoadConfig = @DependentOnLoadConfig
		,@DependentOnModelObject = @DependentOnModelObject
		,@DependentOnModelObjectPart = @DependentOnModelObjectPart
		,@DependentOnModelObjectDataflow = @DependentOnModelObjectDataflow
		,@LoadConfig_LoadObject_Dependency_ID = @LoadConfig_LoadObject_Dependency_ID OUT
	;

	IF @LoadConfig_ID IS NULL
		RAISERROR(N'%s: Load config [%s] not found.', 0, 1, @ProcedureName, @LoadConfig) WITH NOWAIT;
	ELSE IF @LoadObject_ID IS NULL
		RAISERROR(N'%s: Load object [%s, %s, %s] not found.', 0, 1, @ProcedureName, @ModelObject, @ModelObjectPart, @ModelObjectDataflow) WITH NOWAIT;
	ELSE IF @DependentOnLoadConfig IS NULL
		RAISERROR(N'%s: Dependent on load config [%s] not found.', 0, 1, @ProcedureName, @DependentOnLoadConfig) WITH NOWAIT;
	ELSE IF @DependentOnLoadObject_ID IS NULL
		RAISERROR(N'%s: Dependent on load object [%s, %s, %s] not found.', 0, 1, @ProcedureName, @DependentOnModelObject, @DependentOnModelObjectPart, @DependentOnModelObjectDataflow) WITH NOWAIT;
	ELSE IF @LoadConfig_LoadObject_Dependency_ID IS NULL
		RAISERROR(N'%s: Load config load object dependency not found found.', 0, 1, @ProcedureName) WITH NOWAIT;
	ELSE
	BEGIN

		DELETE
		FROM [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
		WHERE [ID] = @LoadConfig_LoadObject_Dependency_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject_Dependency]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject_Dependency] (
	 @LoadConfig                          NVARCHAR(255)
	,@ModelObject                         NVARCHAR(255)
	,@ModelObjectPart                     NVARCHAR(255)
	,@ModelObjectDataflow                 NVARCHAR(255)
	,@DependentOnLoadConfig               NVARCHAR(255)
	,@DependentOnModelObject              NVARCHAR(255)
	,@DependentOnModelObjectPart          NVARCHAR(255)
	,@DependentOnModelObjectDataflow      NVARCHAR(255)
	,@AllowDisable                        BIT           = NULL
	,@LoadConfig_LoadObject_Dependency_ID INT           = NULL OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@LoadConfig_ID INT
		,@LoadObject_ID INT
		,@DependentOnLoadConfig_ID INT
		,@DependentOnLoadObject_ID INT
	;
	SET @LoadConfig_LoadObject_Dependency_ID = NULL;

	BEGIN TRANSACTION;

	--get load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @LoadConfig
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	--get load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @LoadObject_ID OUT
	;

	--get dependent on load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @DependentOnLoadConfig
		,@LoadConfig_ID = @DependentOnLoadConfig_ID OUT
	;

	--get dependent on load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @DependentOnLoadConfig
		,@ModelObject = @DependentOnModelObject
		,@ModelObjectPart = @DependentOnModelObjectPart
		,@ModelObjectDataflow = @DependentOnModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @DependentOnLoadObject_ID OUT
	;

	--get load config load object dependency
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_Dependency_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@DependentOnLoadConfig = @DependentOnLoadConfig
		,@DependentOnModelObject = @DependentOnModelObject
		,@DependentOnModelObjectPart = @DependentOnModelObjectPart
		,@DependentOnModelObjectDataflow = @DependentOnModelObjectDataflow
		,@LoadConfig_LoadObject_Dependency_ID = @LoadConfig_LoadObject_Dependency_ID OUT
	;

	IF @LoadConfig_ID IS NULL
		RAISERROR(N'%s: Load config [%s] not found.', 0, 1, @ProcedureName, @LoadConfig) WITH NOWAIT;
	ELSE IF @LoadObject_ID IS NULL
		RAISERROR(N'%s: Load object [%s, %s, %s] not found.', 0, 1, @ProcedureName, @ModelObject, @ModelObjectPart, @ModelObjectDataflow) WITH NOWAIT;
	ELSE IF @DependentOnLoadConfig IS NULL
		RAISERROR(N'%s: Dependent on load config [%s] not found.', 0, 1, @ProcedureName, @DependentOnLoadConfig) WITH NOWAIT;
	ELSE IF @DependentOnLoadObject_ID IS NULL
		RAISERROR(N'%s: Dependent on load object [%s, %s, %s] not found.', 0, 1, @ProcedureName, @DependentOnModelObject, @DependentOnModelObjectPart, @DependentOnModelObjectDataflow) WITH NOWAIT;
	ELSE IF @LoadConfig_LoadObject_Dependency_ID IS NULL
	BEGIN

		--add load config load object dependency
		INSERT INTO [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency] (
			 [FK_LoadObject_ID]
			,[FK_DependentOnLoadObject_ID]
			,[AllowDisable]
			,[InsertedAt]
			,[InsertedBy]
			,[UpdatedAt]
			,[UpdatedBy]
		)
		VALUES (
			 @LoadObject_ID
			,@DependentOnLoadObject_ID
			,COALESCE(@AllowDisable, 1)
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
			,SYSDATETIMEOFFSET()
			,CURRENT_USER
		)
		;

		SELECT @LoadConfig_LoadObject_Dependency_ID = SCOPE_IDENTITY();

	END
	ELSE
	BEGIN

		--update load config load object dependency
		UPDATE [{loadcontrol#loadcontrol#schema_name}].[LoadConfig_LoadObject_Dependency]
		SET  [AllowDisable] = COALESCE(@AllowDisable, 1)
			,[UpdatedAt] = SYSDATETIMEOFFSET()
			,[UpdatedBy] = CURRENT_USER
		WHERE [ID] = @LoadConfig_LoadObject_Dependency_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Resume_Execution]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Resume_Execution] (
	 @ExecutionPlan              NVARCHAR(255)
	,@Message                    NVARCHAR(4000) = NULL
	,@ExecutionExternalReference NVARCHAR(4000) = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@Execution_ID INT
		,@ResumedExecution_ID INT
		,@ErrorCount INT = 0
	;
	
	--Prepare resume execution
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Resume]
		 @ExecutionPlan = @ExecutionPlan
		,@Message = @Message
		,@ExecutionExternalReference = @ExecutionExternalReference
		,@Execution_ID = @Execution_ID OUT
	;

	IF @Execution_ID IS NOT NULL
	BEGIN

		--process execution
		EXEC [{loadcontrol#loadcontrol#schema_name}].[Process_Execution]
			 @Execution_ID = @Execution_ID
		;

		--check for errors
		SELECT @ErrorCount = COUNT(*)
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
		WHERE [FK_Execution_ID] = @Execution_ID
		  AND [ExecutionResult] <> N'Success'
		;

		IF @ErrorCount > 0
			RAISERROR(N'%s [%d]: Execution [%d] for execution plan [%s] finished with %d FAILED or DISABLED load steps.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @ExecutionPlan, @ErrorCount) WITH NOWAIT;
		ELSE
			RAISERROR(N'%s [%d]: Execution [%d] for execution plan [%s] finished.', 0, 1, @ProcedureName, @@SPID, @Execution_ID, @ExecutionPlan) WITH NOWAIT;

	END;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Start_Execution]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Start_Execution] (
	 @ExecutionPlan              NVARCHAR(255)                
	,@LoadEffectiveTimestamp     DATETIMEOFFSET = NULL          
	,@Description                NVARCHAR(4000) = NULL
	,@ExecutionExternalReference NVARCHAR(4000) = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
		,@Execution_ID INT
		,@ErrorCount INT = 0
	;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	--get active execution of execution plan
	SELECT TOP 1
		 @Execution_ID = [ID]
	FROM [{loadcontrol#loadcontrol#schema_name}].[Execution]
	WHERE [FK_ExecutionPlan_ID] = @ExecutionPlan_ID
	  AND [IsActive] = 1
	ORDER BY [LoadCreatedAt] DESC
	;

	--prepare new execution if no active execution was found
	IF @Execution_ID IS NULL
	BEGIN

		EXEC [{loadcontrol#loadcontrol#schema_name}].[Prepare_Execution_Start]
			 @ExecutionPlan = @ExecutionPlan
			,@LoadEffectiveTimestamp = @LoadEffectiveTimestamp
			,@Description = @Description
			,@ExecutionExternalReference = @ExecutionExternalReference
			,@Execution_ID = @Execution_ID OUT
		;

	END
	ELSE
		RAISERROR(N'%s [%d]: Execution plan [%s] has active execution [%d]. Adding worker.', 0, 1, @ProcedureName, @@SPID, @ExecutionPlan, @Execution_ID) WITH NOWAIT;

	IF @Execution_ID IS NOT NULL
	BEGIN

		--process execution
		EXEC [{loadcontrol#loadcontrol#schema_name}].[Process_Execution]
			 @Execution_ID = @Execution_ID
		;

		--check for errors
		SELECT @ErrorCount = COUNT(*)
		FROM [{loadcontrol#loadcontrol#schema_name}].[Execution_Step]
		WHERE [FK_Execution_ID] = @Execution_ID
		  AND [ExecutionResult] <> N'Success'
		;

		IF @ErrorCount > 0
			RAISERROR(N'%s [%d]: Execution plan [%s] completed by execution [%d] with %d FAILED or DISABLED load steps.', 0, 1, @ProcedureName, @@SPID, @ExecutionPlan, @Execution_ID, @ErrorCount) WITH NOWAIT;
		ELSE
			RAISERROR(N'%s [%d]: Execution plan [%s] completed by execution [%d].', 0, 1, @ProcedureName, @@SPID, @ExecutionPlan, @Execution_ID) WITH NOWAIT;

	END;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Creating Procedure [{loadcontrol#loadcontrol#schema_name}].[Remove_ExecutionPlan_LoadObject]...';


GO
SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER OFF;


GO
CREATE PROCEDURE [{loadcontrol#loadcontrol#schema_name}].[Remove_ExecutionPlan_LoadObject] (
	 @ExecutionPlan       NVARCHAR(255)
	,@LoadConfig          NVARCHAR(255)
	,@ModelObject         NVARCHAR(255)
	,@ModelObjectPart     NVARCHAR(255)
	,@ModelObjectDataflow NVARCHAR(255)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- prevent deadlocks with multi threaded calls

	--init
	DECLARE
		 @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID)
		,@ExecutionPlan_ID INT
		,@LoadConfig_ID INT
		,@LoadObject_ID INT
		,@ExecutionPlan_LoadObject_ID INT
	;

	BEGIN TRANSACTION;

	--get execution plan
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@ExecutionPlan_ID = @ExecutionPlan_ID OUT
	;

	--get load config
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_ID]
		 @LoadConfig = @LoadConfig
		,@LoadConfig_ID = @LoadConfig_ID OUT
	;

	--get load object
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_LoadConfig_LoadObject_ID]
		 @LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@LoadConfig_LoadObject_ID = @LoadObject_ID OUT
	;

	--get execution plan load object mapping
	EXEC [{loadcontrol#loadcontrol#schema_name}].[Get_ExecutionPlan_LoadObject_ID]
		 @ExecutionPlan = @ExecutionPlan
		,@LoadConfig = @LoadConfig
		,@ModelObject = @ModelObject
		,@ModelObjectPart = @ModelObjectPart
		,@ModelObjectDataflow = @ModelObjectDataflow
		,@ExecutionPlan_LoadObject_ID = @ExecutionPlan_LoadObject_ID OUT
	;

	IF @ExecutionPlan_ID IS NULL
		RAISERROR(N'%s: Execution plan [%s] not found.', 0, 1, @ProcedureName, @ExecutionPlan) WITH NOWAIT;
	ELSE IF @LoadConfig_ID IS NULL
		RAISERROR(N'%s: Load config [%s] not found.', 0, 1, @ProcedureName, @LoadConfig) WITH NOWAIT;
	ELSE IF @LoadObject_ID IS NULL
		RAISERROR(N'%s: Load object [%s, %s, %s] not found.', 0, 1, @ProcedureName, @ModelObject, @ModelObjectPart, @ModelObjectDataflow) WITH NOWAIT;
	ELSE IF @ExecutionPlan_LoadObject_ID IS NULL
		RAISERROR(N'%s: Execution plan load object mapping not found.', 0, 1, @ProcedureName) WITH NOWAIT;
	ELSE
	BEGIN

		--remove execution plan load object mapping
		DELETE
		FROM [{loadcontrol#loadcontrol#schema_name}].[ExecutionPlan_LoadObject]
		WHERE [ID] = @ExecutionPlan_LoadObject_ID
		;

	END;

	COMMIT TRANSACTION;

	RETURN 0;

END;
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;
