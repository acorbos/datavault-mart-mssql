--.........................................................................
--SQL script for post deployment configuration of load control
--Project: Product Launch Event
--Layer: Business Vault
--.........................................................................
USE [{loadcontrol#loadcontrol#database_name}];
GO


--.........................................................................
--Prepare registration of load objects
--.........................................................................

EXEC [{loadcontrol#loadcontrol#schema_name}].[Build_LoadConfig] @LoadConfig = N'Product Launch Event', @ModelObjectLayer = N'Business Vault';

--.........................................................................
--Register load objects
--.........................................................................

EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'Product Launch Event',                 @ModelObject = N'CUSTOMER_PIT',                         @ModelObjectPart = N'Business PIT Loader',                  @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Business Vault',                       @ModelObjectType = N'Business PIT',                         @LoadObject = N'BDV_PIT_CUSTOMER_PIT_Loader',          @SchemaName = N'{productlaunchevent#businessvault#schema_name}', @DatabaseName = N'{productlaunchevent#businessvault#database_name}', @ServerName = N'{productlaunchevent#businessvault#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 3030, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'Product Launch Event',                 @ModelObject = N'Sales',                                @ModelObjectPart = N'Business Link Loader',                 @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Business Vault',                       @ModelObjectType = N'Business Link',                        @LoadObject = N'BDV_LNK_Sales_Loader',                 @SchemaName = N'{productlaunchevent#businessvault#schema_name}', @DatabaseName = N'{productlaunchevent#businessvault#database_name}', @ServerName = N'{productlaunchevent#businessvault#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 3040, @ExecutionPriority = 0, @IsActive = 1;

--.........................................................................
--Register load object dependencies
--.........................................................................

EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject_Dependency] @LoadConfig = N'Product Launch Event',                 @ModelObject = N'CUSTOMER_PIT',                         @ModelObjectPart = N'Business PIT Loader',                  @ModelObjectDataflow = N'Dataflow1',                            @DependentOnLoadConfig = N'Product Launch Event',                 @DependentOnModelObject = N'CUSTOMER_Address',                     @DependentOnModelObjectPart = N'Satellite Loader',                     @DependentOnModelObjectDataflow = N'Dataflow1',                            @AllowDisable = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject_Dependency] @LoadConfig = N'Product Launch Event',                 @ModelObject = N'CUSTOMER_PIT',                         @ModelObjectPart = N'Business PIT Loader',                  @ModelObjectDataflow = N'Dataflow1',                            @DependentOnLoadConfig = N'Product Launch Event',                 @DependentOnModelObject = N'CUSTOMER_Info',                        @DependentOnModelObjectPart = N'Satellite Loader',                     @DependentOnModelObjectDataflow = N'Dataflow1',                            @AllowDisable = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject_Dependency] @LoadConfig = N'Product Launch Event',                 @ModelObject = N'Sales',                                @ModelObjectPart = N'Business Link Loader',                 @ModelObjectDataflow = N'Dataflow1',                            @DependentOnLoadConfig = N'Product Launch Event',                 @DependentOnModelObject = N'Loyaltycard_Customer',                 @DependentOnModelObjectPart = N'Link Loader',                          @DependentOnModelObjectDataflow = N'Dataflow1',                            @AllowDisable = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject_Dependency] @LoadConfig = N'Product Launch Event',                 @ModelObject = N'Sales',                                @ModelObjectPart = N'Business Link Loader',                 @ModelObjectDataflow = N'Dataflow1',                            @DependentOnLoadConfig = N'Product Launch Event',                 @DependentOnModelObject = N'POS_Branch',                           @DependentOnModelObjectPart = N'Link Loader',                          @DependentOnModelObjectDataflow = N'Dataflow1',                            @AllowDisable = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject_Dependency] @LoadConfig = N'Product Launch Event',                 @ModelObject = N'Sales',                                @ModelObjectPart = N'Business Link Loader',                 @ModelObjectDataflow = N'Dataflow1',                            @DependentOnLoadConfig = N'Product Launch Event',                 @DependentOnModelObject = N'POS_SALES',                            @DependentOnModelObjectPart = N'Link Loader',                          @DependentOnModelObjectDataflow = N'Dataflow1',                            @AllowDisable = 1;

GO
