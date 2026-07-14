--Used for load control execution during development
USE [{loadcontrol#loadcontrol#database_name}];
GO

--Project specific execution plan with all load objects
EXEC [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan]                @ExecutionPlan = N'DEV_Product Launch Event';
EXEC [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_AddLoadObjects] @ExecutionPlan = N'DEV_Product Launch Event', @LoadConfig = N'Product Launch Event';
EXEC [{loadcontrol#loadcontrol#schema_name}].[Start_Execution]                    @ExecutionPlan = N'DEV_Product Launch Event';

/*
    --Show results of last execution of execution plan
    EXEC [{loadcontrol#loadcontrol#schema_name}].[Show_Execution]                        @ExecutionPlan = N'DEV_Product Launch Event';

    --Example for adding specific load objects to execution plan (here: all load objects in stage layer)
    EXEC [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_AddLoadObjects]    @ExecutionPlan = N'DEV_Product Launch Event', @LoadConfig = N'Product Launch Event', @ModelObjectLayer = N'Stage';

    --Example for removing specific load objects to execution plan (here: all load objects for rawvault composite objects)
    EXEC [{loadcontrol#loadcontrol#schema_name}].[Build_ExecutionPlan_RemoveLoadObjects] @ExecutionPlan = N'DEV_Product Launch Event', @LoadConfig = N'Product Launch Event', @ModelObjectType = N'RawVault Composite';

    --Remove execution plan and all associated log entries
    EXEC [{loadcontrol#loadcontrol#schema_name}].[Remove_ExecutionPlan]                  @ExecutionPlan = N'DEV_Product Launch Event', @CleanLog = 1;

    --Stop running execution (call from another terminal)
    EXEC [{loadcontrol#loadcontrol#schema_name}].[Stop_Execution]                        @ExecutionPlan = N'DEV_Product Launch Event';

    --Resume stopped or failed execution (after fixing the problems)
    EXEC [{loadcontrol#loadcontrol#schema_name}].[Resume_Execution]                      @ExecutionPlan = N'DEV_Product Launch Event';
*/
