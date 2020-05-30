/*
	require:
	sp_Drew_Restore_FindTestData
	sp_DRew_Restore_Test
*/

declare @Tardb varchar(255) = 'DFETarget'
declare @Sourdb varchar(255) = 'DFESource'
declare @MainTable nvarchar(255) = 'JobOrders'
declare @IDField nvarchar(255) = 'JobOrdersID'
declare @DiffTableFn nvarchar(255) = 'fn_Drew_Restore_JobOrders_DiffTable_t'
declare @RestoreTreeFn nvarchar(255) = 'fn_Drew_Restore_JobOrders_RestoreTree_t'
declare @FindTestData bit = 0
declare @TestRestore bit = 0

--param
declare @MainRecordID int = 424



--set @FindTestData = 1
set @TestRestore = 1

--find test data
if @FindTestData = 1
	exec sp_Drew_Restore_FindTestData @Tardb, @MainTable, @IDField, @DiffTableFn

--test restore
if @TestRestore = 1
	exec sp_Drew_Restore_Test @Sourdb, @Tardb, @MainTable, @IDField, @DiffTableFn, @RestoreTreeFn, @MainRecordID


--spot checks

--sp_Drew_Restore_Diff @SourceDBName = 'DFESource', @TargetDBName = 'DFETarget', @TableName = 'Webjobpostings', @WhereClause = N'WHERE JobOrdersID = @MainRecordID', @MainRecordID = 6407
--SELECT * FROM Drew_Diff
--DROP TABLE Drew_Diff

