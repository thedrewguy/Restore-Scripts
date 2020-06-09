/*
	require:
	sp_Drew_Restore_FindTestData
	sp_DRew_Restore_Test
*/

declare @Tardb varchar(255) = 'DFETarget'
declare @Sourdb varchar(255) = 'DFESource'
declare @MainTable nvarchar(255) = 'MProjects'
declare @IDField nvarchar(255) = 'MProjectsID'
declare @DiffTableFn nvarchar(255) = 'fn_Drew_Restore_CandidateIntroductions_DiffTable_t'
declare @RestoreTreeFn nvarchar(255) = 'fn_Drew_Restore_CandidateIntroductions_RestoreTree_t'

declare @FindTestData bit = 1
declare @TestRestore bit = 0
declare @MainRecordID int = 26518


--find test data
if @FindTestData = 1
	exec sp_Drew_Restore_FindTestData @Tardb, @MainTable, @IDField, @DiffTableFn

--test restore
if @TestRestore = 1
	exec sp_Drew_Restore_Test @Sourdb, @Tardb, @MainTable, @IDField, @DiffTableFn, @RestoreTreeFn, @MainRecordID


--spot checks

declare @tablename varchar(255) = null

--set @tablename = 'ProjectsCandidateBlocks'

if @tablename is not null begin
	declare @WhereClause nvarchar(max) = (select top 1 WhereClause from dbo.fn_Drew_Restore_CandidateIntroductions_DiffTable_t() where TableName = @tablename)
	exec sp_Drew_Restore_Diff @SourceDBName = 'DFESource', @TargetDBName = 'DFETarget', @TableName = @tablename, @WhereClause = @WhereClause, @MainRecordID = 26518
	SELECT * FROM Drew_Diff
	DROP TABLE Drew_Diff
end

