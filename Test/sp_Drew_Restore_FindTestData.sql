if object_id('sp_Drew_Restore_FindTestData') is not null
	drop proc sp_Drew_Restore_FindTestData
go

create proc sp_Drew_Restore_FindTestData(@Tardb nvarchar(255), @MainTable nvarchar(255), @IDField nvarchar(255), @DiffTableFn nvarchar(255))
as
	--settings
	set nocount on

	--diff table
	declare @DtSQL nvarchar(max) = N'
	select TableName, WhereClause
	from dbo.' + @DiffTableFn + '()'

	declare @Diff table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
	insert into @Diff(TableName, WhereClause)
	exec sp_executesql @dtSQL

	--sql init
	declare @sql nvarchar(max) = N''
	declare @nl nvarchar(2) = char(13) + char(10)

	set @sql = @sql + 'declare @links table(id int identity, ' + @IDField + ' int, TableName varchar(255), unique(' + @IDField + ', id))
	insert into @links(' + @IDField + ', TableName)
	select ' + @MainTable + '.' + @IDField + ', tablename
	from ' + @MainTable + '
	cross apply('

	--loop

	declare @dc_i int = 1
	declare @dc_num int = (select count(1) from @Diff)

	while @dc_i <= @dc_num begin
		--fetch row
		declare @dc_Table varchar(255), @dc_WhereClause nvarchar(max), @dc_output nvarchar(max)
		
		select @dc_Table = TableName, @dc_WhereClause = WhereClause
		from @Diff
		where id = @dc_i

		--add to sql
		set @sql = @sql + @nl + char(9)
		if @dc_i > 1
			set @sql = @sql + 'union all '
		set @sql = @sql + 'select top 1 ' + @MainTable + '.' + @IDField + ', ''' + right('00' + cast(@dc_i as nvarchar(max)), 2) + ' ' + @dc_Table + ''' from ' + @dc_Table + ' ' + replace(replace(@dc_WhereClause, '<DB>', @TarDB), '@MainRecordID', @MainTable + '.' + @IDField)
	
		--increment
		set @dc_i = @dc_i + 1
	end

	set @sql = @sql + '
	) records(' + @IDField + ', tablename)
	where records.' + @IDField + ' is not null

	declare @recordScores table(' + @IDField + ' int primary key, Tabs int)
	insert into @recordScores(' + @IDField + ', Tabs)
	select ' + @IDField + ', count(1)
	from @links
	group by ' + @IDField + '

	select tab.TableName, topRecord.' + @IDField + '
	from (
		select distinct tablename from @links
	) tab
	outer apply(
		select top 1 ' + @IDField + '
		from @recordScores recordScores
		where ' + @IDField + ' in(
			select ' + @IDField + '
			from @links
			where tablename = tab.TableName
		)
		order by recordScores.tabs desc
	) topRecord
	order by tab.TableName'
	
	exec sp_executesql @sql
go

--testing
/*

--PARAM
declare @Tardb nvarchar(255) = 'DFETarget'
declare @MainTable nvarchar(255) = 'MProjects'
declare @IDField nvarchar(255) = 'MProjectsID'
declare @DiffTableFn nvarchar(255) = 'fn_Drew_Restore_CandidateIntroductions_DiffTable_t'

exec sp_Drew_Restore_FindTestData @Tardb, @MainTable, @IDField, @DiffTableFn
*/