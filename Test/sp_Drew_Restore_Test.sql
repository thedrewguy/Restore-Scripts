/*
	require:
	Restore Tree Fn
	Diff Table Fn
	sp_Drew_RestoreItem
	sp_Drew_Restore_CheckDeleted
	sp_Drew_Restore_CheckIdentical
*/

set ansi_nulls on
go
set quoted_identifier on
go

if object_id('sp_Drew_Restore_Test') is not null
	drop proc sp_Drew_Restore_Test
go

create proc sp_Drew_Restore_Test(@Sourdb nvarchar(255), @Tardb nvarchar(255), @MainTable nvarchar(255), @IDField nvarchar(255), @DiffTableFn nvarchar(255), @RestoreTreeFn nvarchar(255), @MainRecordID int)
as

declare @sql nvarchar(max) = '
set nocount on

--delete main record

delete ' + @MainTable + ' where ' + @IDField + ' = ' + cast(@MainRecordID as nvarchar(255)) + '

--check children deleted
	
	print ''DELETE CHECK''
	print ''''

	--deletes to check

	declare @Diff table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
	insert into @Diff(TableName, WhereClause)
	select TableName, WhereClause
	from dbo.' + @DiffTableFn + '()

	--loop

	declare @dc_i int = 0
	declare @dc_num int = (select count(1) from @Diff)

	while @dc_i <= @dc_num begin
		--fetch row
		declare @dc_Table varchar(255), @dc_WhereClause nvarchar(max), @dc_output nvarchar(max)
		
		select @dc_Table = TableName, @dc_WhereClause = WhereClause
		from @Diff
		where id = @dc_i

		--check deleted
		exec sp_Drew_Restore_CheckDeleted @SourceDBName = ''' + @Sourdb + ''', @TargetDBName = ''' + @Tardb + ''', @TableName = @dc_Table, @WhereClause = @dc_WhereClause, @MainRecordID = ' + cast(@MainRecordID as nvarchar(255)) + ', @Message = @dc_output output

		--increment
		set @dc_i = @dc_i + 1
	end

--Restore items
	
	print ''''
	print ''RESTORE''
	print ''''

	--generate restore tree

	declare @RestoreTree Drew_RestoreTree
	insert into @RestoreTree(TableName, Operation, RestoreSQL, Fatal)
	select TableName, Operation, RestoreSQL, Fatal
	from dbo.' + @RestoreTreeFn + '(''' + @Sourdb + ''', ''' + @Tardb + ''')

	--execute restore

	exec sp_Drew_RestoreItem @SourDB = ''' + @Sourdb + ''', @TarDB = ''' + @Tardb + ''', @RestoreTree = @RestoreTree, @MainRecordID = ' + cast(@MainRecordID as nvarchar(255)) + ', @NestLevel = 1

--Diff
	
	print ''''
	print ''CHECK RESTORED''
	print ''''

	declare @diff_i int = 0
	declare @diff_num int = (select count(1) from @Diff)

	while @diff_i <= @diff_num begin
		--fetch row
		declare @diff_Table varchar(255), @diff_WhereClause nvarchar(max), @diff_output nvarchar(max)
		
		select @diff_Table = TableName, @diff_WhereClause = WhereClause
		from @Diff
		where id = @diff_i

		--check deleted
		exec sp_Drew_Restore_CheckIdentical @SourceDBName = ''' + @Sourdb + ''', @TargetDBName = ''' + @Tardb + ''', @TableName = @diff_Table, @WhereClause = @diff_WhereClause, @MainRecordID = ' + cast(@MainRecordID as nvarchar(255)) + ', @Message = @diff_output output

		--increment
		set @diff_i = @diff_i + 1
	end

'

exec sp_executesql @sql
go

--testing
/*
declare @Tardb varchar(255) = 'DFETarget'
declare @Sourdb varchar(255) = 'DFESource'
declare @MainTable nvarchar(255) = 'MProjects'
declare @IDField nvarchar(255) = 'MProjectsID'
declare @DiffTableFn nvarchar(255) = 'fn_Drew_Restore_CandidateIntroductions_DiffTable_t'
declare @RestoreTreeFn nvarchar(255) = 'fn_Drew_Restore_CandidateIntroductions_RestoreTree_t'
declare @MainRecordID int = 22

exec sp_Drew_Restore_Test @Sourdb, @Tardb, @MainTable, @IDField, @DiffTableFn, @RestoreTreeFn, @MainRecordID


--spot checks

--sp_Drew_Restore_Diff @SourceDBName = 'DFESource', @TargetDBName = 'DFETarget', @TableName = 'Assignments', @WhereClause = 'WHERE MProjectsID = @MainRecordID', @MainRecordID = 579
--SELECT * FROM Drew_Diff
--DROP TABLE Drew_Diff
*/