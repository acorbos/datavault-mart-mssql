-- This script will do a validation for views and stored procedures of the current deployment.
-- Any syntax errors or broken column references should result in an error.
-- However, references in procedures to missing objects will only be caught at runtime due to SQL Server's deferred name resolution.
-- Therefore, also check for errors in the execution log after the first execution.

DECLARE @ErrorCount BIGINT = 0;

USE [{productlaunchevent#stage#database_name}];

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_EMPLOYEE_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_LOYALTYCARD_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEMUNITOFMEASURE_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_CUSTOMER_DUPLICATES_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_SALESTRANSACTION_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_POS_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_PHONENUMBER_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_ITEM_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#stage#database_name}].[{productlaunchevent#stage#schema_name}].[STG_ST_BRANCH_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

USE [{productlaunchevent#rawvault#database_name}];

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_LOYALTYCARD_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEMUNITOFMEASURE_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Address_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE1_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEM_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_SALESTRANSACTION_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_CUSTOMER_Info_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_SALESTRANSACTION_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_ITEM_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_Loyaltycard_Customer_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_EMPLOYEE_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_MAS_PHONENUMBER_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_EMPLOYEE_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_SAT_BRANCH_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_Branch_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_CUSTOMER_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_POS_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_LNK_POS_SALES_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#rawvault#database_name}].[{productlaunchevent#rawvault#schema_name}].[RDV_HUB_ITEMUNITOFMEASURE_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

USE [{productlaunchevent#businessvault#database_name}];

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_LNK_Sales_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_Current_Customer_Current]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_Current_Customer_Current]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_PIT_CUSTOMER_PIT_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_History_Customer_History]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#businessvault#database_name}].[{productlaunchevent#businessvault#schema_name}].[BDV_History_Customer_History]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

USE [{productlaunchevent#mart#database_name}];

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Scd]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Scd]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_RowCondensing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_RowCondensing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Versioning]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Versioning]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEMUNITOFMEASURE_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_Current_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_Lkp]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_Lkp]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_TruncateInsertLoader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_TruncateInsertLoader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_IncrementSource]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_IncrementSource]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MF_Sales_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Scd]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Scd]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_RowCondensing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_RowCondensing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Versioning]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Versioning]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_BRANCH_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Scd]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Scd]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_RowCondensing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_RowCondensing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Versioning]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Versioning]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_ITEM_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Source]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Source]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Scd]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Scd]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Hashing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Hashing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_RowCondensing]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_RowCondensing]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Delta]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Delta]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Loader]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Loader]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Versioning]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Versioning]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

BEGIN TRY
    EXEC [sys].[sp_refreshsqlmodule] N'[{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Result]';
END TRY
BEGIN CATCH
    PRINT N'Error in [{productlaunchevent#mart#database_name}].[{productlaunchevent#mart#schema_name}].[DM_MD_Customer_History_Result]: ' + ERROR_MESSAGE();
    SET @ErrorCount += 1;
END CATCH;

IF @ErrorCount = 0
BEGIN
    PRINT N'Deployment validation succeeded.';
END
ELSE
BEGIN
    PRINT N'Deployment validation found ' + CAST(@ErrorCount AS NVARCHAR(4000)) + N' errors.';
    THROW 50001, 'Deployment validation failed.', 0;
END;
