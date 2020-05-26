set ansi_nulls on
go
set quoted_identifier on
go


/**************************************************************************************************************************/


begin try drop proc sp_Drew_RestoreItem end try begin catch end catch
go

begin try drop type Drew_RestoreTree end try begin catch end catch
go

create type Drew_RestoreTree as table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
go


/**************************************************************************************************************************/


if objecT_id('fn_Drew_RestoreSQL_ColList') is not null
	drop function fn_Drew_RestoreSQL_ColList
go

create function fn_Drew_RestoreSQL_ColList(@InsTable varchar(255), @SourPrefix bit)
returns nvarchar(max)
as begin

	--column lists for SQL

	declare @ColList nvarchar(max)
	if @SourPrefix = 1
		set @ColList = STUFF(
			(	select ', Sour.' + COLUMN_NAME
				from INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = @InsTable	
				AND DATA_TYPE NOT LIKE 'timestamp'
				FOR XML PATH(''), ROOT('a'), TYPE
			).value('a[1]', 'varchar(max)')
			, 1, 2, ''
		)
	else
		set @ColList = STUFF(
			(	select ', ' + COLUMN_NAME
				from INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = @InsTable
				AND DATA_TYPE NOT LIKE 'timestamp'
				FOR XML PATH(''), ROOT('a'), TYPE
			).value('a[1]', 'varchar(max)')
			, 1, 2, ''
		)
	

	return isnull(@ColList, '')

end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_RestoreSQL_ChildInsert') is not null
	drop function fn_Drew_RestoreSQL_ChildInsert

go

create function fn_Drew_RestoreSQL_ChildInsert(@Sourdb varchar(255), @Tardb varchar(255), @InsTable varchar(255), @InsTarSourJoinOn varchar(4000), @InsNNField varchar(255), @MainLinkField varchar(255), @ObjectTableName varchar(255))
returns varchar(max)
as begin

	--restore
	
	declare @nl varchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = N''

	set @sql = @Sql
	+ @nl + '	INSERT INTO ' + @Tardb + '..' + @InsTable + '(' + dbo.fn_Drew_RestoreSQL_ColList(@InsTable, 0) + ')'
	+ @nl + '	SELECT ' + dbo.fn_Drew_RestoreSQL_ColList(@InsTable, 1)
	+ @nl + '	FROM ' + @Sourdb + '..' + @InsTable + ' Sour'
	+ @nl + '	LEFT JOIN ' + @Tardb + '..' + @InsTable + ' Tar'
	+ @nl + '	ON ' + @InsTarSourJoinOn
	+ @nl + '	WHERE Sour.' + @MainLinkField + ' = @MainRecordID'
	+ @nl + '	AND Tar.' + @InsNNField + ' IS NULL'

	if @ObjectTableName is not null
		set @sql = @sql
		+ @nl + '	and Sour.ObjectTableName = ''' + @ObjectTableName + ''''
	
	return @sql

end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_RestoreSQL_ChildSetID') is not null
	drop function fn_Drew_RestoreSQL_ChildSetID

go

create function fn_Drew_RestoreSQL_ChildSetID(@Sourdb varchar(255), @Tardb varchar(255), @UpTable varchar(255), @TarSourJoinOn varchar(4000), @SetIDField varchar(255))
returns varchar(max)
as begin

	--restore
	
	declare @nl varchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = N''

	set @sql = @Sql
	+ @nl + '	update ' + @Tardb + '..' + @UpTable
	+ @nl + '	set ' + @SetIDField + ' = @MainRecordID'
	+ @nl + '	FROM ' + @Sourdb + '..' + @UpTable + ' Sour'
	+ @nl + '	JOIN ' + @Tardb + '..' + @UpTable + ' Tar'
	+ @nl + '	ON ' + @TarSourJoinOn
	+ @nl + '	WHERE Sour.' + @SetIDField + ' = @MainRecordID'
	+ @nl + '	AND Tar.' + @SetIDField + ' IS NULL'

	return @sql

end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_RestoreSQL_GrandChildInsert') is not null
	drop function fn_Drew_RestoreSQL_GrandChildInsert

go

create function fn_Drew_RestoreSQL_GrandChildInsert(@Sourdb varchar(255), @Tardb varchar(255), @InsTable varchar(255), @InsTarSourJoinOn varchar(4000), @InsNNField varchar(255), @ParentTable varchar(255), @SourParentJoinOn varchar(255),
	@MainLinkField varchar(255), @ObjectTableName varchar(255))
returns varchar(max)
as begin

	--restore
	
	declare @nl varchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = N''

	set @sql = @Sql
	+ @nl + '	INSERT INTO ' + @Tardb + '..' + @InsTable + '(' + dbo.fn_Drew_RestoreSQL_ColList(@InsTable, 0) + ')'
	+ @nl + '	SELECT ' + dbo.fn_Drew_RestoreSQL_ColList(@InsTable, 1)
	+ @nl + '	FROM ' + @Sourdb + '..' + @InsTable + ' Sour'
	+ @nl + '	JOIN ' + @Sourdb + '..' + @ParentTable + ' SourParent'
	+ @nl + '		on ' + @SourParentJoinOn
	+ @nl + '	LEFT JOIN ' + @Tardb + '..' + @InsTable + ' Tar'
	+ @nl + '		on '+ @InsTarSourJoinOn
	+ @nl + '	WHERE SourParent.' + @MainLinkField + ' = @MainRecordID'
	+ @nl + '	AND Tar.' + @InsNNField + ' IS NULL'

	if @ObjectTableName is not null
		set @sql = @sql
		+ @nl + '	and Sour.ObjectTableName = ''' + @ObjectTableName + ''''
	
	return @sql

end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_RestoreSQL_GrandChildSetID') is not null
	drop function fn_Drew_RestoreSQL_GrandChildSetID

go

create function fn_Drew_RestoreSQL_GrandChildSetID(@Sourdb varchar(255), @Tardb varchar(255), @UpTable varchar(255), @TarSourJoinOn varchar(4000), @SetIDField varchar(255),
	@ParentTable varchar(255), @SourParentJoinOn varchar(255), @MainLinkField varchar(255))
returns varchar(max)
as begin

	--restore
	
	declare @nl varchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = N''

	set @sql = @Sql
	+ @nl + '	update ' + @Tardb + '..' + @UpTable
	+ @nl + '	set ' + @SetIDField + ' = @MainRecordID'
	+ @nl + '	FROM ' + @Sourdb + '..' + @UpTable + ' Sour'
	+ @nl + '	JOIN ' + @Tardb + '..' + @UpTable + ' Tar'
	+ @nl + '	ON ' + @TarSourJoinOn
	+ @nl + '	join ' + @ParentTable + ' SourParent'
	+ @nl + '		on ' + @SourParentJoinOn
	+ @nl + '	WHERE SourParent.' + @MainLinkField + ' = @MainRecordID'
	+ @nl + '	and Sour.' + @SetIDField + ' is not null'
	+ @nl + '	AND Tar.' + @SetIDField + ' IS NULL'

	return @sql

end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_RestoreSQL_GreatGrandInsert') is not null
	drop function fn_Drew_RestoreSQL_GreatGrandInsert

go

create function fn_Drew_RestoreSQL_GreatGrandInsert(@Sourdb varchar(255), @Tardb varchar(255), @InsTable varchar(255), @InsTarSourJoinOn varchar(4000), @InsNNField varchar(255),
	@ParentTable varchar(255), @SourParentJoinOn varchar(255),
	@GrandTable varchar(255), @ParentGrandJoinOn varchar(255),
	@MainLinkField varchar(255), @ObjectTableName varchar(255))
returns varchar(max)
as begin

	--restore
	
	declare @nl varchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = N''

	set @sql = @Sql
	+ @nl + '	INSERT INTO ' + @Tardb + '..' + @InsTable + '(' + dbo.fn_Drew_RestoreSQL_ColList(@InsTable, 0) + ')'
	+ @nl + '	SELECT ' + dbo.fn_Drew_RestoreSQL_ColList(@InsTable, 1)
	+ @nl + '	FROM ' + @Sourdb + '..' + @InsTable + ' Sour'
	+ @nl + '	JOIN ' + @Sourdb + '..' + @ParentTable + ' SourParent'
	+ @nl + '		on ' + @SourParentJoinOn
	+ @nl + '	JOIN ' + @Sourdb + '..' + @GrandTable + ' SourGrand'
	+ @nl + '		on ' + @ParentGrandJoinOn
	+ @nl + '	LEFT JOIN ' + @Tardb + '..' + @InsTable + ' Tar'
	+ @nl + '		on '+ @InsTarSourJoinOn
	+ @nl + '	WHERE SourGrand.' + @MainLinkField + ' = @MainRecordID'
	+ @nl + '	AND Tar.' + @InsNNField + ' IS NULL'

	if @ObjectTableName is not null
		set @sql = @sql
		+ @nl + '	and Sour.ObjectTableName = ''' + @ObjectTableName + ''''
	
	return @sql

end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_RestoreSQL_ListItemInsert') is not null
	drop function fn_Drew_RestoreSQL_ListItemInsert

go

create function fn_Drew_RestoreSQL_ListItemInsert(@Sourdb varchar(255), @Tardb varchar(255), @SrcTableIn varchar(255))
returns varchar(max)
as begin

	--restore
	
	declare @nl varchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = N''

	set @sql = @Sql
	+ @nl + '	INSERT INTO ' + @Tardb + '..ListsDetails'
	+ @nl + '	SELECT Sour.*'
	+ @nl + '	FROM ' + @Sourdb + '..ListsDetails Sour'
	+ @nl + '	join ' + @Sourdb + '..Lists SourList'
	+ @nl + '		on SourList.ListsID = Sour.ListID'
	+ @nl + '	LEFT JOIN ' + @Tardb + '..ListsDetails Tar'
	+ @nl + '		ON Tar.ListID = Sour.ListID'
	+ @nl + '		and Tar.RecordID = Sour.RecordID'
	+ @nl + '	WHERE Sour.RecordID = @MainRecordID'
	+ @nl + '	and SourList.SourceTable in(' + @SrcTableIn + ')'
	+ @nl + '	AND Tar.ListID IS NULL'
	
	return @sql

end
go


/**************************************************************************************************************************/


if object_id('fn_Drew_RestoreSQL_trigDisEn_t') is not null
	drop function fn_Drew_RestoreSQL_trigDisEn_t
go

create function fn_Drew_RestoreSQL_trigDisEn_t(@tablename nvarchar(255))
returns @SQL table(DisableTrigs nvarchar(max), EnableTrigs nvarchar(max))
as begin
	declare @nl nvarchar(2) = char(13) + char(10)
	declare @distrigs nvarchar(max) = stuff(
		(
			select @nl + ';disable trigger ' + tr.name + ' on ' + ta.name
			from sys.tables ta
			join sys.triggers tr
				on tr.parent_id = ta.object_id
			where ta.name = @tablename
			and tr.is_disabled = 0
			for xml path(''), root('a'), type
		).value('a[1]', 'nvarchar(max)'), 1, len(@nl), ''
	)
	declare @entrigs nvarchar(max) = replace(@distrigs, ';disable trigger', ';enable trigger')
	
	insert into @SQL(DisableTrigs, EnableTrigs)
	values(@distrigs, @entrigs)
	
	return
end
go


/**************************************************************************************************************************/


if objecT_id('fn_Drew_RestoreSQL_Wrap') is not null
	drop function fn_Drew_RestoreSQL_Wrap
go

create function fn_Drew_RestoreSQL_Wrap(@Table varchar(255), @OpSQL nvarchar(max), @Operation varchar(255), @Fatal bit, @NestLevel int)
returns nvarchar(max)
as begin

	--check if identity

	DECLARE @HasIdentity bit = 0
	if exists(
		SELECT 1
		FROM sys.tables t
		join sys.columns c
			on c.object_id = t.object_id
		where t.name = @Table
		AND c.is_identity = 1
	)
		set @HasIdentity = 1

	--generate sql

	declare @nl varchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = N''

	--identity insert on

	if @HasIdentity = 1 and @Operation = 'insert'
		set @sql = @sql
		+ @nl + 'set identity_insert ' + @Table + ' ON'

	--try catch (handles non-fatal runtime)

	set @sql = @sql
	+ @nl + 'begin try'

	--disable trigs

	declare @distrigs nvarchar(max) = (select DisableTrigs from dbo.fn_Drew_RestoreSQL_trigDisEn_t(@Table))

	if @distrigs is not null
		set @sql = @sql
		+ @nl + @distrigs

	--rowcount variable

	set @sql = @sql
	+ @nl + '	declare @rc int'

	--SQL for operation
	
	set @sql = @sql
	+ @nl + @OpSQL
	
	--count rows
	
	set @sql = @sql
	+ @nl + '	set @rc = @@ROWCOUNT'

	--enable trigs
	
	declare @entrigs nvarchar(max) = (select EnableTrigs from dbo.fn_Drew_RestoreSQL_trigDisEn_t(@Table))

	if @entrigs is not null
		set @sql = @sql
		+ @nl + @entrigs

	--identity insert off

	if @HasIdentity = 1 and @Operation = 'insert'
		set @sql = @sql
		+ @nl + '	set identity_insert ' + @Table + ' off'

	--success message, start catch block

	set @sql = @sql
	+ @nl + '	print ''Success - ' + @Table + ' ' + @Operation + ' - '' + cast(@rc as varchar(255)) + '' row(s) affected'''
	+ @nl + 'end try'
	+ @nl + 'begin catch'
	+ @nl + '	print ''Fail - ' + @Table + ' ' + @Operation + ''''
	
	--identity insert off

	if @HasIdentity = 1 and @Operation = 'insert'
		set @sql = @sql
		+ @nl + '	set identity_insert ' + @Table + ' off'

	--error if fatal

	if @Fatal = 1
		set @sql = @sql
		+ @nl + '	raiserror(''Failed to ' + @Operation + ' ' + @Table + ' Record'', 11, 1)'

	--finish catch block

	set @sql = @sql
	+ @nl + 'end catch'

	--return

	return @sql

end


go


/**************************************************************************************************************************/


if object_id('fn_Drew_RestoreSQL_NestedInsert') is not null
	drop function fn_Drew_RestoreSQL_NestedInsert

go

create function fn_Drew_RestoreSQL_NestedInsert(@Sourdb varchar(255), @Tardb varchar(255), @SelectItemsSQL nvarchar(max), @RestoreTreeFn nvarchar(255))
returns nvarchar(max)
as begin

	--restore
	
	declare @nl varchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = N''
	+ @nl + '	declare @Items table(id int identity, ItemID int unique not null)'
	+ @nl + '	'
	+ @nl + '	insert into @Items(ItemID)'
	+ @nl + @SelectItemsSQL
	+ @nl + ''
	+ @nl + '	declare @id int = (select max(id) from @Items)'
	+ @nl + '	while @id > 0 begin'
	+ @nl + '		declare @RestoreTree Drew_RestoreTree'
	+ @nl + '	'
	+ @nl + '		insert into @RestoreTree(TableName, Operation, RestoreSQL, Fatal)'
	+ @nl + '		select TableName, Operation, RestoreSQL, Fatal'
	+ @nl + '		from dbo.' + @RestoreTreeFn + '(''' + @Sourdb + ''', ''' + @Tardb + ''')'
	+ @nl + ''
	+ @nl + '		--execute restore'
	+ @nl + '		declare @ItemID int = (select ItemID from @Items where id = @id)'
	+ @nl + '		exec sp_Drew_RestoreItem @SourDB = ''' + @Sourdb + ''', @TarDB = ''' + @Tardb + ''', @RestoreTree = @RestoreTree, @MainRecordID = @ItemID, @NestLevel = @NestLevel'
	+ @nl + ''
	+ @nl + '		--dec'
	+ @nl + '		set @id = @id - 1'
	+ @nl + '	end'
	
	return @sql

end

go


/**************************************************************************************************************************/


if object_id('sp_Drew_RestoreSubItem') is not null
	drop proc sp_Drew_RestoreSubItem
go

create proc sp_Drew_RestoreSubItem(@MainRecordID int, @TableName varchar(255), @Operation varchar(255), @RestoreSQL nvarchar(max), @fatal bit, @NestLevel int)
as begin
	--wrap sql
	set @RestoreSQL = dbo.fn_Drew_RestoreSQL_Wrap(@TableName, @RestoreSQL, @Operation, @fatal, @NestLevel)
	
	--param def
	declare @paramdef nvarchar(max) = N'@MainRecordID int, @NestLevel int'
	
	--new line, savepoint name for later
	declare @nl varchar(2) = char(13) + char(10)
	declare @sp nvarchar(255) = N'subitem_start_' + cast(@NestLevel as nvarchar(255))

	--try to execute
	begin try
		--tran, save
		begin tran
		declare @spsql nvarchar(max) = N'save tran ' + @sp
		exec sp_executesql @spsql
		
		--execute
		declare @NewNestLevel int = @NestLevel + 1
		exec sp_executesql @RestoreSQL, @paramdef, @MainRecordID = @MainRecordID, @NestLevel = @NewNestLevel
		
		--commit
		commit tran
	end try
	--catch fatal and syntax errors
	begin catch
		--rollback to savepoint
		declare @rbsql nvarchar(max) = 'rollback tran ' + @sp
		exec sp_executesql @rbsql
		commit tran

		--if fatal, re-throw
		if @fatal = 1 begin
			declare @ErrorMessage varchar(4000) = 'Fail - ' + @Tablename + ' ' + @Operation + ': ' + ERROR_MESSAGE()
			RAISERROR(@ErrorMessage, 11, 1)
		end
		--otherwise print message and continue
		else
			print 'Syntax Error: ' + @TableName + ' ' + @Operation
			print @RestoreSQL
			print ''
	end catch
end
go


/**************************************************************************************************************************/


if object_id('sp_Drew_RestoreItem') is not null
	drop proc sp_Drew_RestoreItem
go

create proc sp_Drew_RestoreItem(@SourDB varchar(255), @TarDB varchar(255), @RestoreTree Drew_RestoreTree readonly, @MainRecordID int, @NestLevel int)
as begin
	--error message variable
	declare @ErrorMessage varchar(4000)

	--try catch rollback, to handle fatal errors
	begin tran
	declare @sp nvarchar(max) = N'RestoreItem_' + cast(@NestLevel as nvarchar(max))
	declare @saveTranSQL nvarchar(max) = N'save tran ' + @sp
	exec sp_executesql @saveTranSQL
	begin try
	
		--check that we're in the right database
		if isnull(charindex(db_name(), @TarDB), 0) = 0
			raiserror('Please switch this session to the restore target database before running', 11, 1)

		--loop, execute restore sql

		declare @r_num int = (Select count(1) from @RestoreTree)

		--for each restore table
		declare @r_i int = 1
		while @r_i <= @r_num begin

			--get settings for table
			declare @TableName varchar(255), @Operation varchar(255), @RestoreSQL nvarchar(max), @Fatal bit

			select @TableName = TableName, @Operation = Operation, @RestoreSQL = RestoreSQL, @Fatal = Fatal from @RestoreTree where id = @r_i
			--execute
			exec sp_Drew_RestoreSubItem @MainRecordID, @TableName, @Operation, @RestoreSQL, @Fatal, @NestLevel
			--increment
			set @r_i = @r_i + 1
		end
		
		commit tran
	end try
	begin catch
		set @ErrorMessage = 'Fatal Error. Record not restored. All changes reversed: ' + error_message()
		if @NestLevel = 1
			rollback
		else begin
			declare @rollbackSQL nvarchar(max) = N'rollback tran ' + @sp
			exec sp_Executesql @rollbackSQL
		end
		raiserror(@ErrorMessage, 11, 1)
	end catch
		
end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_Restore_Task_RestoreTree_t') is not null
	drop function fn_Drew_Restore_Task_RestoreTree_t
go

create function fn_Drew_Restore_Task_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'TaskID', 'TaskID', null, 1),
		('TaskData', 'Tar.TaskDataID = Sour.TaskDataID', 'TaskDataID', 'TaskID', null, 0),
		('LinkContactsToTask', 'Tar.TaskID = Sour.TaskID and Tar.PeopleID = Sour.PeopleID', 'TaskID', 'TaskID', null, 0),
		('LinkTaskToProjectStages', 'Tar.TaskID = Sour.TaskID and Tar.ProjectsID = Sour.ProjectsID and Tar.ProjectStagesID = Sour.ProjectStagesID', 'TaskID', 'TaskID', null, 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.ObjectTableName = Sour.ObjectTableName and Tar.RightID = Sour.RightID', 'LeftID', 'RightID', 'Task', 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(255), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''Task''')

	update @GrandChildren
	set insertSQL = dbo.fn_Drew_RestoreSQL_GrandchildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName)

	update @GreatGrand
	set insertSQL = dbo.fn_Drew_RestoreSQL_GreatGrandInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName)

	update @SetChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_ChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField)

	update @SetGrandChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_GrandChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField)

	--populate full restore tree with bulk-generated items
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @ListItems

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GrandChildren

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GreatGrand

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetChildID

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetGrandChildID

	return
end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_Restore_Addresses_RestoreTree_t') is not null
	drop function fn_Drew_Restore_Addresses_RestoreTree_t
go

create function fn_Drew_Restore_Addresses_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('Addresses', 'Tar.AddressesID = Sour.AddressesID', 'AddressesID', 'AddressesID', null, 1),
		('MailingAddresses', 'Tar.MailingAddressesID = Sour.MailingAddressesID', 'MailingAddressesID', 'AddressesID', null, 0)

	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	--populate full restore tree with bulk-generated items
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	--custom

	declare @nl nvarchar(2) = char(13) + char(10)
	declare @PositionsSQL nvarchar(max) = 'update Tar'
	+ @nl + 'set AddressesID = Sour.AddressesID, Location = Sour.Location'
	+ @nl + 'from ' + @TarDB + '..Positions Tar'
	+ @nl + 'join ' + @SourDB + '..Positions Sour'
	+ @nl + '	on Sour.PositionsID = Tar.PositionsID'
	+ @nl + 'where Sour.AddressesID = @MainRecordID'
	+ @nl + 'and Tar.AddressesID is null and isnull(Tar.Location, '''') = '''''
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	values('Positions', @PositionsSQL, 'update', 0)

	return
end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_Restore_People_RestoreTree_t') is not null
	drop function fn_Drew_Restore_People_RestoreTree_t
go

create function fn_Drew_Restore_People_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('People', 'Tar.PeopleID = Sour.PeopleID', 'PeopleID', 'PeopleID', null, 1),
		('Resumes', 'Tar.ResumesID = Sour.ResumesID', 'ResumesID', 'PeopleID', null, 0),
		('Notes', 'Tar.NotesID = Sour.NotesID', 'NotesID', 'PeopleID', null, 0),
		('LinkPeopleToSkills', 'Tar.LinkPeopleToSkillsID = Sour.LinkPeopleToSkillsID', 'LinkPeopleToSkillsID', 'PeopleID', null, 0),
		('Affiliates', 'Tar.AffiliatesID = Sour.AffiliatesID', 'AffiliatesID', 'PeopleID', null, 0),
		('Education', 'Tar.EducationID = Sour.EducationID', 'EducationID', 'PeopleID', null, 0),
		('PeopleAvailability', 'Tar.PeopleAvailabilityID = Sour.PeopleAvailabilityID', 'PeopleAvailabilityID', 'PeopleID', null, 0),
		('LinkPeopleToCredentials', 'Tar.LinkPeopleToCredentialsID = Sour.LinkPeopleToCredentialsID', 'LinkPeopleToCredentialsID', 'PeopleID', null, 0),
		('LinkPeopleToCompanies', 'Tar.LinkPeopleToCompaniesID = Sour.LinkPeopleToCompaniesID', 'LinkPeopleToCompaniesID', 'PeopleID', null, 0),
		('JobOrderClientTeams', 'Tar.JobOrderClientTeamsID = Sour.JobOrderClientTeamsID', 'JobOrderClientTeamsID', 'PeopleID', null, 0),
		('LinkPeopleToKnownToUsers', 'Tar.LinkPeopleToKnownToUsersID = Sour.LinkPeopleToKnownToUsersID', 'LinkPeopleToKnownToUsersID', 'PeopleID', null, 0),
		('ProjectsCallStatus', 'Tar.ProjectsCallStatusID = Sour.ProjectsCallStatusID', 'ProjectsCallStatusID', 'PeopleID', null, 0),
		('Positions', 'Tar.PositionsID = Sour.PositionsID', 'PositionsID', 'PeopleID', null, 0),
		('EmailAddress', 'Tar.EmailAddressID = Sour.EmailAddressID', 'EmailAddressID', 'PeopleID', null, 0),
		('ProjectsClientTeams', 'Tar.ProjectsClientTeamsID = Sour.ProjectsClientTeamsID', 'ProjectsClientTeamsID', 'PeopleID', null, 0),
		('EmailArchive', 'Tar.EmailArchiveID = Sour.EmailArchiveID', 'EmailArchiveID', 'PeopleID', null, 0),
		('InternalInterviews', 'Tar.InternalInterviewsID = Sour.InternalInterviewsID', 'InternalInterviewsID', 'PeopleID', null, 0),
		('CandidateCredentials', 'Tar.CandidateCredentialsID = Sour.CandidateCredentialsID', 'CandidateCredentialsID', 'CandidatePeopleID', null, 0),
		('CandidateReferrals', 'Tar.CandidateReferralsID = Sour.CandidateReferralsID', 'CandidateReferralsID', 'PeopleID', null, 0),
		('CandidateReferrals', 'Tar.CandidateReferralsID = Sour.CandidateReferralsID', 'CandidateReferralsID', 'SourcePeopleID', null, 0),
		('CandidateReferences', 'Tar.CandidateReferencesID = Sour.CandidateReferencesID', 'CandidateReferencesID', 'PeopleID', null, 0),
		('CandidateReferences', 'Tar.CandidateReferencesID = Sour.CandidateReferencesID', 'CandidateReferencesID', 'RefereePeopleID', null, 0),
		('PeopleAdditionalNames', 'Tar.AdditionalNamesID = Sour.AdditionalNamesID', 'AdditionalNamesID', 'PeopleID', null, 0),
		('LinkCandidatesToMPContacts', 'Tar.LinkCandidatesToMPContactsID = Sour.LinkCandidatesToMPContactsID', 'LinkCandidatesToMPContactsID', 'CandPeopleID', null, 0),
		('LinkCandidatesToMPContacts', 'Tar.LinkCandidatesToMPContactsID = Sour.LinkCandidatesToMPContactsID', 'LinkCandidatesToMPContactsID', 'ContactPeopleID', null, 0),
		('LinkPeopleToNetwork', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'LeftID', null, 0),
		('LinkPeopleToNetwork', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'RightID', null, 0),
		('JobOrderConsideredPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrderInterviewPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrderInternalInterviewPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrderPresentedPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrdersSources', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrdersTargetCompaniesCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID and Tar.CompaniesID = Sour.CompaniesID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsBenchmarkCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsInternalInterviewLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsPresentedLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsSources', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsClientEmployeesLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsShortLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsTargetLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsFileSearchCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('LastProjectActivity', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectTargetCompaniesCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID and Tar.CompaniesID = Sour.CompaniesID', 'PeopleID', 'PeopleID', null, 0),
		('PeopleAppliedTo', 'Tar.PeopleID = Sour.PeopleID and isnull(Tar.ProjectsID, 0) = isnull(Sour.ProjectsID, 0) and isnull(Tar.JobOrdersID, 0) = isnull(Sour.JobOrdersID, 0)', 'PeopleID', 'PeopleID', null, 0),
		('LinkContactsToTask', 'Tar.PeopleID = Sour.PeopleID and Tar.TaskID = Sour.TaskID', 'PeopleID', 'PeopleID', null, 0),
		('LinkPeopleToPackage', 'Tar.PeopleID = Sour.PeopleID and Tar.PositionsID = Sour.PositionsID and Tar.PackageID = Sour.PackageID', 'PeopleID', 'PeopleID', null, 0),
		('LinkPeopleToRates', 'Tar.PeopleID = Sour.PeopleID and Tar.RateTypesID = Sour.RateTypesID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsCandidateBlocks', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID and Tar.WorkListsID = Sour.WorkListsID', 'PeopleID', 'PeopleID', null, 0),
		('EventSessionsInvitees', 'Tar.PeopleID = Sour.PeopleID and Tar.TaskID = Sour.TaskID and Tar.EventsID = Sour.EventsID', 'PeopleID', 'PeopleID', null, 0),
		('EventSessionVendors', 'Tar.PeopleID = Sour.PeopleID and Tar.TaskID = Sour.TaskID and Tar.EventsID = Sour.EventsID', 'PeopleID', 'PeopleID', null, 0),
		('LinkCandidatesToMProjects', 'Tar.PeopleID = Sour.PeopleID and Tar.MProjectsID = Sour.MProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('LinkContactsToMProjects', 'Tar.PeopleID = Sour.PeopleID and Tar.MProjectsID = Sour.MProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('LinkContactsToOpportunities', 'Tar.PeopleID = Sour.PeopleID and Tar.OpportunitiesID = Sour.OpportunitiesID', 'PeopleID', 'PeopleID', null, 0),
		('MProjectCompaniesContacts', 'Tar.PeopleID = Sour.PeopleID and Tar.MProjectsID = Sour.MProjectsID and Tar.CompaniesID = Sour.CompaniesID', 'PeopleID', 'PeopleID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'People', 0),
		('LinkObjectToDocument', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'People', 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'People', 0),
		('LinkInterviewersToClientInterview', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'LeftID', null, 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)
		insert into @ListItems(insTable, Fatal)
		values('ListsDetails', 0)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GrandChildren(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('PositionDetails', 'Tar.PositionDetailsID = Sour.PositionDetailsID', 'PositionDetailsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('LinkPositionsToRates', 'Tar.PositionsID = Sour.PositionsID and Tar.RateTypesID = Sour.RateTypesID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('LinkJobOrderScheduleToPosition', 'Tar.PositionsID = Sour.PositionsID and Tar.JobOrderScheduleID = Sour.JobOrderScheduleID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('LinkJobOrderToWorksteps', 'Tar.PositionsID = Sour.PositionsID and isnull(Tar.WorkStepsID, 0) = isnull(Sour.WorkStepsID, 0) and isnull(Tar.JobOrdersID, 0) = isnull(Sour.JobOrdersID, 0) and isnull(Tar.AssignmentsID, 0) = isnull(Sour.AssignmentsID, 0)', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('Timesheets', 'Tar.TimesheetsID = Sour.TimesheetsID', 'TimesheetsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('PositionExpenses', 'Tar.PositionExpensesID = Sour.PositionExpensesID', 'PositionExpensesID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('JobOrderPositionTeams', 'Tar.JobOrderPositionTeamsID = Sour.JobOrderPositionTeamsID', 'JobOrderPositionTeamsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('LinkAddressToDistList', 'Tar.LinkToDistListID = Sour.LinkToDistListID', 'LinkToDistListID', 'EmailAddress', 'SourParent.EmailAddressID = Sour.EmailAddressID', 'PeopleID', null, 0),
		('LinkAddressToDistList', 'Tar.LinkToDistListID = Sour.LinkToDistListID', 'LinkToDistListID', 'EmailAddress', 'SourParent.EmailAddressID = Sour.DistListID', 'PeopleID', null, 0),
		('EmailMsgRecipients', 'Tar.EmailMsgRecipientsID = Sour.EmailMsgRecipientsID', 'EmailMsgRecipientsID', 'EmailArchive', 'SourParent.EmailArchiveID = Sour.EmailArchiveID', 'PeopleID', null, 0),
		('EmailMsgAttachments', 'Tar.EmailMsgAttachmentsID = Sour.EmailMsgAttachmentsID', 'EmailMsgAttachmentsID', 'EmailArchive', 'SourParent.EmailArchiveID = Sour.EmailArchiveID', 'PeopleID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'EmailArchive', 'SourParent.EmailArchiveID = Sour.LeftID', 'PeopleID', 'EmailArchive', 0),
		('LinkInternalInterviewsToResults', 'Tar.LinkIntInterviewsToResultsID = Sour.LinkIntInterviewsToResultsID', 'LinkIntInterviewsToResultsID', 'InternalInterviews', 'SourParent.InternalInterviewsID = Sour.InternalInterviewsID', 'PeopleID', null, 0),
		('LinkSkillsToInternalInterview', 'Tar.LinkSkillsToInternalInterviewID = Sour.LinkSkillsToInternalInterviewID', 'LinkSkillsToInternalInterviewID', 'InternalInterviews', 'SourParent.InternalInterviewsID = Sour.InternalInterviewsID', 'PeopleID', null, 0)
		
		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		insert into @SetChildID(UpTable, TarSourJoinOn, SetIDField, Fatal)
		values('Assignments', 'Tar.AssignmentsID = Sour.AssignmentsID', 'PeopleID', 0),
		('Assignments', 'Tar.AssignmentsID = Sour.AssignmentsID', 'ContactPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'PlacedByPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'InvoiceToPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'LeadContactPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'ReportsToPeopleID', 0),
		('Projects', 'Tar.ProjectsID = Sour.ProjectsID', 'BillingToPeopleID', 0)

		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(255), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
		
		insert into @SetGrandChildID(UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', 0)

	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''People''')

	update @GrandChildren
	set insertSQL = dbo.fn_Drew_RestoreSQL_GrandchildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName)

	update @GreatGrand
	set insertSQL = dbo.fn_Drew_RestoreSQL_GreatGrandInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName)

	update @SetChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_ChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField)

	update @SetGrandChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_GrandChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField)

	--populate full restore tree with bulk-generated items
	
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @ListItems

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GrandChildren

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GreatGrand

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetChildID

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetGrandChildID

	--custom
	declare @nl nvarchar(2) = char(13) + char(10)

	declare @GDPRSQL nvarchar(max) = '	delete GDPRLog where PeopleID = @MainRecordID'

	declare @TasksSQL nvarchar(max) = ''
	+ @nl + '	select Sour.TaskID'
	+ @nl + '	from ('
	+ @nl + '		select TaskID'
	+ @nl + '		from ' + @Sourdb + '..LinkCandidatestoMPContacts'
	+ @nl + '		where CandPeopleID = @MainRecordID'
	+ @nl + '		union select TaskID'
	+ @nl + '		from ' + @Sourdb + '..LinkCandidatesToMPContacts'
	+ @nl + '		where ContactPeopleID = @MainRecordID'
	+ @nl + '		union select TaskID'
	+ @nl + '		from ' + @Sourdb + '..InternalInterviews'
	+ @nl + '		where PeopleID = @MainRecordID'
	+ @nl + '	) Sour'
	+ @nl + '	left join ' + @Tardb + '..Task Tar'
	+ @nl + '		on Tar.TaskID = Sour.TaskID'
	+ @nl + '	where Sour.TaskID is not null'
	+ @nl + '	and Tar.TaskID is null'

	declare @AddressesSQL nvarchar(max) = ''
	+ @nl + '	select Sour.AddressesID'
	+ @nl + '	from ('
	+ @nl + '		select HomeAddressesID from ' + @Sourdb + '..People where PeopleID = @MainRecordID'
	+ @nl + '		union select BusinessAddressesID from ' + @Sourdb + '..People where PeopleID = @MainRecordID'
	+ @nl + '		union select AlternativeAddressesID from ' + @Sourdb + '..People where PeopleID = @MainRecordID'
	+ @nl + '	) Sour(AddressesID)'
	+ @nl + '	left join ' + @Tardb + '..Addresses Tar'
	+ @nl + '		on Tar.AddressesID = Sour.AddressesID'
	+ @nl + '	where Sour.AddressesID is not null'
	+ @nl + '	and Tar.AddressesID is null'

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	values('GDPRLog', @GDPRSQL, 'delete', 0),
	('Task', dbo.fn_Drew_RestoreSQL_NestedInsert(@SourDB, @TarDB, @TasksSQL, 'fn_Drew_Restore_Task_RestoreTree_t'), 'nested restore', 0),
	('Addresses', dbo.fn_Drew_RestoreSQL_NestedInsert(@SourDB, @TarDB, @AddressesSQL, 'fn_Drew_Restore_Addresses_RestoreTree_t'), 'nested restore', 0)
		
	return
end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_Restore_MedPeople_RestoreTree_t') is not null
	drop function fn_Drew_Restore_MedPeople_RestoreTree_t
go

create function fn_Drew_Restore_MedPeople_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('People', 'Tar.PeopleID = Sour.PeopleID', 'PeopleID', 'PeopleID', null, 1),
		('Resumes', 'Tar.ResumesID = Sour.ResumesID', 'ResumesID', 'PeopleID', null, 0),
		('Notes', 'Tar.NotesID = Sour.NotesID', 'NotesID', 'PeopleID', null, 0),
		('LinkPeopleToSkills', 'Tar.LinkPeopleToSkillsID = Sour.LinkPeopleToSkillsID', 'LinkPeopleToSkillsID', 'PeopleID', null, 0),
		('Affiliates', 'Tar.AffiliatesID = Sour.AffiliatesID', 'AffiliatesID', 'PeopleID', null, 0),
		('Education', 'Tar.EducationID = Sour.EducationID', 'EducationID', 'PeopleID', null, 0),
		('PeopleAvailability', 'Tar.PeopleAvailabilityID = Sour.PeopleAvailabilityID', 'PeopleAvailabilityID', 'PeopleID', null, 0),
		('LinkPeopleToCredentials', 'Tar.LinkPeopleToCredentialsID = Sour.LinkPeopleToCredentialsID', 'LinkPeopleToCredentialsID', 'PeopleID', null, 0),
		('LinkPeopleToCompanies', 'Tar.LinkPeopleToCompaniesID = Sour.LinkPeopleToCompaniesID', 'LinkPeopleToCompaniesID', 'PeopleID', null, 0),
		('JobOrderClientTeams', 'Tar.JobOrderClientTeamsID = Sour.JobOrderClientTeamsID', 'JobOrderClientTeamsID', 'PeopleID', null, 0),
		('LinkPeopleToKnownToUsers', 'Tar.LinkPeopleToKnownToUsersID = Sour.LinkPeopleToKnownToUsersID', 'LinkPeopleToKnownToUsersID', 'PeopleID', null, 0),
		('ProjectsCallStatus', 'Tar.ProjectsCallStatusID = Sour.ProjectsCallStatusID', 'ProjectsCallStatusID', 'PeopleID', null, 0),
		('Positions', 'Tar.PositionsID = Sour.PositionsID', 'PositionsID', 'PeopleID', null, 0),
		('EmailAddress', 'Tar.EmailAddressID = Sour.EmailAddressID', 'EmailAddressID', 'PeopleID', null, 0),
		('ProjectsClientTeams', 'Tar.ProjectsClientTeamsID = Sour.ProjectsClientTeamsID', 'ProjectsClientTeamsID', 'PeopleID', null, 0),
		('EmailArchive', 'Tar.EmailArchiveID = Sour.EmailArchiveID', 'EmailArchiveID', 'PeopleID', null, 0),
		('InternalInterviews', 'Tar.InternalInterviewsID = Sour.InternalInterviewsID', 'InternalInterviewsID', 'PeopleID', null, 0),
		('CandidateCredentials', 'Tar.CandidateCredentialsID = Sour.CandidateCredentialsID', 'CandidateCredentialsID', 'CandidatePeopleID', null, 0),
		('CandidateReferrals', 'Tar.CandidateReferralsID = Sour.CandidateReferralsID', 'CandidateReferralsID', 'PeopleID', null, 0),
		('CandidateReferrals', 'Tar.CandidateReferralsID = Sour.CandidateReferralsID', 'CandidateReferralsID', 'SourcePeopleID', null, 0),
		('CandidateReferences', 'Tar.CandidateReferencesID = Sour.CandidateReferencesID', 'CandidateReferencesID', 'PeopleID', null, 0),
		('CandidateReferences', 'Tar.CandidateReferencesID = Sour.CandidateReferencesID', 'CandidateReferencesID', 'RefereePeopleID', null, 0),
		('PeopleAdditionalNames', 'Tar.AdditionalNamesID = Sour.AdditionalNamesID', 'AdditionalNamesID', 'PeopleID', null, 0),
		('LinkCandidatesToMPContacts', 'Tar.LinkCandidatesToMPContactsID = Sour.LinkCandidatesToMPContactsID', 'LinkCandidatesToMPContactsID', 'CandPeopleID', null, 0),
		('LinkCandidatesToMPContacts', 'Tar.LinkCandidatesToMPContactsID = Sour.LinkCandidatesToMPContactsID', 'LinkCandidatesToMPContactsID', 'ContactPeopleID', null, 0),
		('LinkPeopleToNetwork', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'LeftID', null, 0),
		('LinkPeopleToNetwork', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'RightID', null, 0),
		('JobOrderConsideredPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrderInterviewPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrderInternalInterviewPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrderPresentedPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrdersSources', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrdersTargetCompaniesCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID and Tar.CompaniesID = Sour.CompaniesID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsBenchmarkCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsInternalInterviewLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsPresentedLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsSources', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsClientEmployeesLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsShortLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsTargetLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsFileSearchCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('LastProjectActivity', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectTargetCompaniesCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID and Tar.CompaniesID = Sour.CompaniesID', 'PeopleID', 'PeopleID', null, 0),
		('PeopleAppliedTo', 'Tar.PeopleID = Sour.PeopleID and isnull(Tar.ProjectsID, 0) = isnull(Sour.ProjectsID, 0) and isnull(Tar.JobOrdersID, 0) = isnull(Sour.JobOrdersID, 0)', 'PeopleID', 'PeopleID', null, 0),
		('LinkContactsToTask', 'Tar.PeopleID = Sour.PeopleID and Tar.TaskID = Sour.TaskID', 'PeopleID', 'PeopleID', null, 0),
		('LinkPeopleToPackage', 'Tar.PeopleID = Sour.PeopleID and Tar.PositionsID = Sour.PositionsID and Tar.PackageID = Sour.PackageID', 'PeopleID', 'PeopleID', null, 0),
		('LinkPeopleToRates', 'Tar.PeopleID = Sour.PeopleID and Tar.RateTypesID = Sour.RateTypesID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsCandidateBlocks', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID and Tar.WorkListsID = Sour.WorkListsID', 'PeopleID', 'PeopleID', null, 0),
		('EventSessionsInvitees', 'Tar.PeopleID = Sour.PeopleID and Tar.TaskID = Sour.TaskID and Tar.EventsID = Sour.EventsID', 'PeopleID', 'PeopleID', null, 0),
		('EventSessionVendors', 'Tar.PeopleID = Sour.PeopleID and Tar.TaskID = Sour.TaskID and Tar.EventsID = Sour.EventsID', 'PeopleID', 'PeopleID', null, 0),
		('LinkCandidatesToMProjects', 'Tar.PeopleID = Sour.PeopleID and Tar.MProjectsID = Sour.MProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('LinkContactsToMProjects', 'Tar.PeopleID = Sour.PeopleID and Tar.MProjectsID = Sour.MProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('LinkContactsToOpportunities', 'Tar.PeopleID = Sour.PeopleID and Tar.OpportunitiesID = Sour.OpportunitiesID', 'PeopleID', 'PeopleID', null, 0),
		('MProjectCompaniesContacts', 'Tar.PeopleID = Sour.PeopleID and Tar.MProjectsID = Sour.MProjectsID and Tar.CompaniesID = Sour.CompaniesID', 'PeopleID', 'PeopleID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'People', 0),
		('LinkObjectToDocument', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'People', 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'People', 0),
		('LinkInterviewersToClientInterview', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'LeftID', null, 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)
		insert into @ListItems(insTable, Fatal)
		values('ListsDetails', 0)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GrandChildren(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('LinkCredentialsToJobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.LinkPeopleToCredentialsID = Sour.LinkPeopleToCredentialsID', 'JobOrdersID', 'LinkPeopleToCredentials', 'SourParent.LinkPeopleToCredentialsID = Sour.LinkPeopleToCredentialsID', 'PeopleID', null, 0),
		('PositionDetails', 'Tar.PositionDetailsID = Sour.PositionDetailsID', 'PositionDetailsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('LinkPositionsToRates', 'Tar.PositionsID = Sour.PositionsID and Tar.RateTypesID = Sour.RateTypesID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('LinkJobOrderToWorksteps', 'Tar.PositionsID = Sour.PositionsID and isnull(Tar.WorkStepsID, 0) = isnull(Sour.WorkStepsID, 0) and isnull(Tar.JobOrdersID, 0) = isnull(Sour.JobOrdersID, 0) and isnull(Tar.AssignmentsID, 0) = isnull(Sour.AssignmentsID, 0)', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('Timesheets', 'Tar.TimesheetsID = Sour.TimesheetsID', 'TimesheetsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('PositionExpenses', 'Tar.PositionExpensesID = Sour.PositionExpensesID', 'PositionExpensesID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('UsersCommissionsSplit', 'Tar.UsersCommissionsSplitID = Sour.UsersCommissionsSplitID', 'UsersCommissionsSplitID', 'Positions', 'SourParent.PositionsID = Sour.ObjectID and Sour.Type = ''Placement''', 'PeopleID', null, 0),
		('LinkAddressToDistList', 'Tar.LinkToDistListID = Sour.LinkToDistListID', 'LinkToDistListID', 'EmailAddress', 'SourParent.EmailAddressID = Sour.EmailAddressID', 'PeopleID', null, 0),
		('LinkAddressToDistList', 'Tar.LinkToDistListID = Sour.LinkToDistListID', 'LinkToDistListID', 'EmailAddress', 'SourParent.EmailAddressID = Sour.DistListID', 'PeopleID', null, 0),
		('Interview', 'Tar.InterviewID = Sour.InterviewID', 'InterviewID', 'ProjectsClientTeams', 'SourParent.PeopleID = Sour.Interviewer and SourParent.ProjectsID = Sour.ProjectsID and Sour.Done = 0', 'PeopleID', null, 0),
		('EmailMsgRecipients', 'Tar.EmailMsgRecipientsID = Sour.EmailMsgRecipientsID', 'EmailMsgRecipientsID', 'EmailArchive', 'SourParent.EmailArchiveID = Sour.EmailArchiveID', 'PeopleID', null, 0),
		('EmailMsgAttachments', 'Tar.EmailMsgAttachmentsID = Sour.EmailMsgAttachmentsID', 'EmailMsgAttachmentsID', 'EmailArchive', 'SourParent.EmailArchiveID = Sour.EmailArchiveID', 'PeopleID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'EmailArchive', 'SourParent.EmailArchiveID = Sour.LeftID', 'PeopleID', 'EmailArchive', 0),
		('UsersCommissionsSplit', 'Tar.UsersCommissionsSplitID = Sour.UsersCommissionsSplitID', 'UsersCommissionsSplitID', 'JobOrderInterviewPeople', 'SourParent.PeopleID = Sour.PeopleID and SourParent.JobOrdersID = Sour.JobOrdersID and Sour.Type = ''Submission'' and Sour.ObjectID = 0', 'PeopleID', null, 0)
		
		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)
			
		insert into @GreatGrand(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('UsersCommissionsSplit', 'Tar.UsersCommissionsSplitID = Sour.UsersCommissionsSplitID', 'UsersCommissionsSplitID', 'Interview', 'SourParent.InterviewID = Sour.ObjectID and Sour.Type = ''Interview''', 'ProjectsClientTeams', 'SourGrand.PeopleID = SourParent.Interviewer and SourGrand.ProjectsID = SourParent.ProjectsID and SourParent.Done = 0', 'PeopleID', null, 0)
		
		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		insert into @SetChildID(UpTable, TarSourJoinOn, SetIDField, Fatal)
		values('Assignments', 'Tar.AssignmentsID = Sour.AssignmentsID', 'PeopleID', 0),
		('Assignments', 'Tar.AssignmentsID = Sour.AssignmentsID', 'ContactPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'PlacedByPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'InvoiceToPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'LeadContactPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'ReportsToPeopleID', 0),
		('Projects', 'Tar.ProjectsID = Sour.ProjectsID', 'BillingToPeopleID', 0)

		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(255), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
		
		insert into @SetGrandChildID(UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', 0)

	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''People''')

	update @GrandChildren
	set insertSQL = dbo.fn_Drew_RestoreSQL_GrandchildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName)

	update @GreatGrand
	set insertSQL = dbo.fn_Drew_RestoreSQL_GreatGrandInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName)

	update @SetChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_ChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField)

	update @SetGrandChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_GrandChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField)

	--populate full restore tree with bulk-generated items
	
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @ListItems

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GrandChildren

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GreatGrand

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetChildID

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetGrandChildID

	--custom
	declare @nl nvarchar(2) = char(13) + char(10)

	declare @GDPRSQL nvarchar(max) = '	delete ' + @Tardb + '..GDPRLog where PeopleID = @MainRecordID'

	declare @TasksSQL nvarchar(max) = ''
	+ @nl + '	select Sour.TaskID'
	+ @nl + '	from ('
	+ @nl + '		select TaskID'
	+ @nl + '		from ' + @Sourdb + '..LinkCandidatestoMPContacts'
	+ @nl + '		where CandPeopleID = @MainRecordID'
	+ @nl + '		union select TaskID'
	+ @nl + '		from ' + @Sourdb + '..LinkCandidatesToMPContacts'
	+ @nl + '		where ContactPeopleID = @MainRecordID'
	+ @nl + '		union select TaskID'
	+ @nl + '		from ' + @Sourdb + '..InternalInterviews'
	+ @nl + '		where PeopleID = @MainRecordID'
	+ @nl + '		union select SourInterview.TaskID'
	+ @nl + '		from ' + @Sourdb + '..ProjectsClientTeams SourPCT'
	+ @nl + '		join ' + @Sourdb + '..Interview SourInterview'
	+ @nl + '			on SourInterview.Interviewer = SourPCT.PeopleID'
	+ @nl + '			and SourInterview.ProjectsID = SourPCT.ProjectsID'
	+ @nl + '			and SourInterview.Done = 0'
	+ @nl + '		where SourPCT.PeopleID = @MainRecordID'
	+ @nl + '	) Sour'
	+ @nl + '	left join ' + @Tardb + '..Task Tar'
	+ @nl + '		on Tar.TaskID = Sour.TaskID'
	+ @nl + '	where Sour.TaskID is not null'
	+ @nl + '	and Tar.TaskID is null'

	declare @AddressesSQL nvarchar(max) = ''
	+ @nl + '	select Sour.AddressesID'
	+ @nl + '	from ('
	+ @nl + '		select HomeAddressesID from ' + @Sourdb + '..People where PeopleID = @MainRecordID'
	+ @nl + '		union select BusinessAddressesID from ' + @Sourdb + '..People where PeopleID = @MainRecordID'
	+ @nl + '		union select AlternativeAddressesID from ' + @Sourdb + '..People where PeopleID = @MainRecordID'
	+ @nl + '	) Sour(AddressesID)'
	+ @nl + '	left join ' + @Tardb + '..Addresses Tar'
	+ @nl + '		on Tar.AddressesID = Sour.AddressesID'
	+ @nl + '	where Sour.AddressesID is not null'
	+ @nl + '	and Tar.AddressesID is null'

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	values('GDPRLog', @GDPRSQL, 'delete', 0),
	('Task', dbo.fn_Drew_RestoreSQL_NestedInsert(@SourDB, @TarDB, @TasksSQL, 'fn_Drew_Restore_Task_RestoreTree_t'), 'nested restore', 0),
	('Addresses', dbo.fn_Drew_RestoreSQL_NestedInsert(@SourDB, @TarDB, @AddressesSQL, 'fn_Drew_Restore_MedAddresses_RestoreTree_t'), 'nested restore', 0)
		
	return
end

go


/**************************************************************************************************************************/


if object_id('fn_Drew_Restore_MedCompanies_RestoreTree_t') is not null
	drop function fn_Drew_Restore_MedCompanies_RestoreTree_t
go

create function fn_Drew_Restore_MedCompanies_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('Companies', 'Tar.CompaniesID = Sour.CompaniesID', 'CompaniesID', 'CompaniesID', null, 1),
		('CompaniesIndustry', 'Tar.CompanyIndustriesID = Sour.CompanyIndustriesID', 'CompanyIndustriesID', 'CompaniesID', null, 0),
		('LinkCompaniesToRates', 'Tar.CompaniesID = Sour.CompaniesID and Tar.RateTypesID = Sour.RateTypesID', 'CompaniesID', 'CompaniesID', null, 0),
		('LinkCompaniesToOpportunities', 'Tar.CompaniesID = Sour.CompaniesID and Tar.OpportunitiesID = Sour.OpportunitiesID', 'CompaniesID', 'CompaniesID', null, 0),
		('LinkCompanyToCompanies', 'Tar.CompaniesID = Sour.CompaniesID and Tar.LinkedCompaniesID = Sour.LinkedCompaniesID', 'CompaniesID', 'CompaniesID', null, 0),
		('LinkCompaniesToAttributes', 'Tar.LinkCompaniesToAttributesID = Sour.LinkCompaniesToAttributesID', 'LinkCompaniesToAttributesID', 'CompaniesID', null, 0),
		('ClientContactTeams', 'Tar.ClientContactTeamsID = Sour.ClientContactTeamsID', 'ClientContactTeamsID', 'CompaniesID', null, 0),
		('CompaniesAliases', 'Tar.CompaniesID = Sour.CompaniesID and isnull(Tar.Name, '''') = isnull(Sour.Name, '''')', 'CompaniesID', 'CompaniesID', null, 0),
		('LinkPeopleToCompanies', 'Tar.LinkPeopleToCompaniesID = Sour.LinkPeopleToCompaniesID', 'LinkPeopleToCompaniesID', 'CompaniesID', null, 0),
		('ProjectsCompaniesLists', 'Tar.ProjectsID = Sour.ProjectsID and Tar.CompaniesID = Sour.CompaniesID', 'CompaniesID', 'CompaniesID', null, 0),
		('Addresses', 'Tar.AddressesID = Sour.AddressesID', 'AddressesID', 'CompaniesID', null, 0),
		('EmailAddress', 'Tar.EmailAddressID = Sour.EmailAddressID', 'EmailAddressID', 'CompaniesID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Companies', 0),
		('LinkObjectToDocument', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Companies', 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Companies', 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)
		insert into @ListItems(insTable, Fatal)
		values('ListsDetails', 0)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GrandChildren(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('ProjectTargetCompaniesCandidates', 'Tar.ProjectsID = Sour.ProjectsID and Tar.CompaniesID = Sour.CompaniesID and Tar.PeopleID = Sour.PeopleID', 'CompaniesID', 'ProjectsCompaniesLists', 'SourParent.ProjectsID = Sour.ProjectsID and SourParent.CompaniesID = Sour.CompaniesID', 'CompaniesID', null, 0),
		('MailingAddresses', 'Tar.MailingAddressesID = Sour.MailingAddressesID', 'MailingAddressesID', 'Addresses', 'SourParent.AddressesID = Sour.AddressesID', 'CompaniesID', null, 0),
		('LinkAddressToDistList', 'Tar.LinkToDistListID = Sour.LinkToDistListID', 'LinkToDistListID', 'EmailAddress', 'SourParent.EmailAddressID = Sour.EmailAddressID', 'CompaniesID', null, 0)

		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))

		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(255), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''Companies''')

	update @GrandChildren
	set insertSQL = dbo.fn_Drew_RestoreSQL_GrandchildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName)

	update @GreatGrand
	set insertSQL = dbo.fn_Drew_RestoreSQL_GreatGrandInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName)

	update @SetChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_ChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField)

	update @SetGrandChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_GrandChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField)

	--populate full restore tree with bulk-generated items
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @ListItems

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GrandChildren

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GreatGrand

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetChildID

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetGrandChildID

	--custom items
	declare @nl nvarchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = 'update Tar'
	+ @nl + 'set AddressesID = Sour.AddressesID, Location = Sour.Location'
	+ @nl + 'from ' + @TarDB + '..Positions Tar'
	+ @nl + 'join ' + @SourDB + '..Positions Sour'
	+ @nl + '	on Sour.PositionsID = Tar.PositionsID'
	+ @nl + 'join ' + @SourDB + '..Addresses SourParent'
	+ @nl + '	on SourParent.AddressesID = Sour.AddressesID'
	+ @nl + 'where SourParent.CompaniesID = @MainRecordID'
	+ @nl + 'and Tar.AddressesID is null and isnull(Tar.Location, '''') = '''''
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	values('Positions', @sql, 'update', 0)

	return
end

go

/**************************************************************************************************************************/


if object_id('fn_Drew_Restore_MedJobOrders_RestoreTree_t') is not null
	drop function fn_Drew_Restore_MedJobOrders_RestoreTree_t
go

create function fn_Drew_Restore_MedJobOrders_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'JobOrdersID', 'JobOrdersID', null, 1),
		('CandidateCredentials', 'Tar.CandidateCredentialsID = Sour.CandidateCredentialsID', 'CandidateCredentialsID', 'JobOrdersID', null, 0),
		('JobRequirements', 'Tar.JobRequirementsID = Sour.JobRequirementsID', 'JobRequirementsID', 'JobOrdersID', null, 0),
		('JobOrdersSources', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('JobOrderConsideredPeople', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('JobOrderPresentedPeople', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('JobOrderInterviewPeople', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('JobOrderClientTeams', 'Tar.JobOrderClientTeamsID = Sour.JobOrderClientTeamsID', 'JobOrderClientTeamsID', 'JobOrdersID', null, 0),
		('JobOrderInternalInterviewPeople', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('PeopleAppliedTo', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('LinkJobOrdersToRates', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.RateTypesID = Sour.RateTypesID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('LinkOpportunitiesToBusinessObjects', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.OpportunitiesID = Sour.OpportunitiesID', 'OpportunitiesID', 'JobOrdersID', null, 0),
		('ProjectsCallStatus', 'Tar.ProjectsCallStatusID = Sour.ProjectsCallStatusID', 'ProjectsCallStatusID', 'JobOrdersID', null, 0),
		('Interview', 'Tar.InterviewID = Sour.InterviewID', 'InterviewID', 'JobOrdersID', null, 0),
		('WebJobPostings', 'Tar.WebJobPostingsID = Sour.WebJobPostingsID', 'WebJobPostingsID', 'JobOrdersID', null, 0),
		('Assignments', 'Tar.AssignmentsID = Sour.AssignmentsID', 'AssignmentsID', 'JobOrdersID', null, 0),
		('JobOrderSchedule', 'Tar.JobOrderScheduleID = Sour.JobOrderScheduleID', 'JobOrderScheduleID', 'JobOrdersID', null, 0),
		('JobOrdersCompaniesLists', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.CompaniesID = Sour.CompaniesID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('Positions', 'Tar.PositionsID = Sour.PositionsID', 'PositionsID', 'JobOrdersID', null, 0),
		('CandidateReferrals', 'Tar.CandidateReferralsID = Sour.CandidateReferralsID', 'CandidateReferralsID', 'JobOrdersID', null, 0),
		('JobOrderTeams', 'Tar.JobOrderTeamsID = Sour.JobOrderTeamsID', 'JobOrderTeamsID', 'JobOrdersID', null, 0),
		('LinkEventsToBusinessObjects', 'Tar.LinkEventToObjectsID = Sour.LinkEventToObjectsID', 'LinkEventToObjectsID', 'JobOrdersID', null, 0),
		('JobOrdersConditions', 'Tar.JobOrdersConditionsID = Sour.JobOrdersConditionsID', 'JobOrdersConditionsID', 'JobOrdersID', null, 0),
		('Timesheets', 'Tar.TimesheetsID = Sour.TimesheetsID', 'TimesheetsID', 'JobOrdersID', null, 0),
		('LinkJobOrderToWorkSteps', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.WorkStepsID = Sour.WorkstepsID and isnull(Tar.PositionsID, 0) = isnull(Sour.PositionsID, 0) and isnull(Tar.AssignmentsID, 0) = isnull(Sour.AssignmentsID, 0)', 'JobOrdersID', 'JobOrdersID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'JobOrders', 0),
		('LinkObjectToDocument', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'JobOrders', 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'JobOrders', 0),
		('JobOrdersTargetCompaniesCandidates', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.CompaniesID = Sour.CompaniesID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('UsersCommissionsSplit', 'Tar.JobOrdersID = Sour.JobOrdersID', 'JobOrdersID', 'JobOrdersID', null, 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)
		insert into @ListItems(insTable, Fatal)
		values('ListsDetails', 0)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GrandChildren(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'TaskID', 'Interview', 'SourParent.TaskID = Sour.TaskID', 'JobOrdersID', null, 0),
		('LinkInterviewersToClientInterview', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'Interview', 'SourParent.InterviewID = Sour.RightID', 'JobOrdersID', null, 0),
		('LinkClnInterviewsToResults', 'Tar.LinkClnInterviewsToResultsID = Sour.LinkClnInterviewsToResultsID', 'LinkClnInterviewsToResultsID', 'Interview', 'SourParent.InterviewID = Sour.InterviewsID', 'JobOrdersID', null, 0),
		('Questions', 'Tar.QuestionsID = Sour.QuestionsID', 'QuestionsID', 'WebJobPostings', 'SourParent.WebJobPostingsID = Sour.WebJobPostingsID', 'JobOrdersID', null, 0),
		('SkillsQuestions', 'Tar.SkillsQuestionsID = Sour.SkillsQuestionsID', 'SkillsQuestionsID', 'WebJobPostings', 'SourParent.WebJobPostingsID = Sour.WebJobPostingsID', 'JobOrdersID', null, 0),
		('LinkWebPostingToWebsite', 'Tar.WebJobPostingsID = Sour.WebJobPostingsID and Tar.WebsitesID = Sour.WebsitesID', 'WebJobPostingsID', 'WebJobPostings', 'SourParent.WebJobPostingsID = Sour.WebJobPostingsID', 'JobOrdersID', null, 0),
		('WebPostingsIndustries', 'Tar.WebPostingsIndustriesID = Sour.WebPostingsIndustriesID', 'WebPostingsIndustriesID', 'WebJobPostings', 'SourParent.WebJobPostingsID = Sour.WebJobPostingsID', 'JobOrdersID', null, 0),
		('LinkJobOrderScheduleToPosition', 'Tar.JobOrderScheduleID = Sour.JobOrderScheduleID and Tar.PositionsID = Sour.PositionsID', 'JobOrderScheduleID', 'JobOrderSchedule', 'SourParent.JobOrderScheduleID = Sour.JobOrderScheduleID', 'JobOrdersID', null, 0),
		('PositionDetails', 'Tar.PositionsID = Sour.PositionsID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', null, 0),
		('LinkPositionsToRates', 'Tar.PositionsID = Sour.PositionsID and Tar.RateTypesID = Sour.RateTypesID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', null, 0),
		('LinkJobOrderScheduleToPosition', 'Tar.PositionsID = Sour.PositionsID and Tar.JobOrderScheduleID = Sour.JobOrderScheduleID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', null, 0),
		('PositionExpenses', 'Tar.PositionExpensesID = Sour.PositionExpensesID', 'PositionExpensesID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', null, 0)
	
		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GreatGrand(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('TaskData', 'Tar.TaskDataID = Sour.TaskDataID', 'TaskDataID', 'Task', 'SourParent.TaskID = Sour.TaskID', 'Interview', 'SourGrand.TaskID = SourParent.TaskID', 'JobOrdersID', null, 0),
		('LinkContactsToTask', 'Tar.TaskID = Sour.TaskID and Tar.PeopleID = Sour.PeopleID', 'TaskID', 'Task', 'SourParent.TaskID = Sour.TaskID', 'Interview', 'SourGrand.TaskID = SourParent.TaskID', 'JobOrdersID', null, 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'Task', 'SourParent.TaskID = Sour.RightID', 'Interview', 'SourGrand.TaskID = SourParent.TaskID', 'JobOrdersID', null, 0),
		('MultipleAnswerItems', 'Tar.MultipleAnswerItemsID = Sour.MultipleAnswerItemsID', 'MultipleAnswerItemsID', 'Questions', 'SourParent.QuestionsID = Sour.QuestionsID', 'WebJobPostings', 'SourGrand.WebJobPostingsID = SourParent.WebJobPostingsID', 'JobOrdersID', null, 0)
	
		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		insert into @SetChildID(UpTable, TarSourJoinOn, SetIDField, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'JobOrdersID', 0),
		('WebRequests', 'Tar.WebRequestsID = Sour.WebRequestsID', 'JobOrdersID', 0)

		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(255), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		insert into @SetGrandChildID(UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', 0)

	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''MRContracts'', ''PermOrders'', ''Temp'', ''Contracts''')

	update @GrandChildren
	set insertSQL = dbo.fn_Drew_RestoreSQL_GrandchildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName)

	update @GreatGrand
	set insertSQL = dbo.fn_Drew_RestoreSQL_GreatGrandInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName)

	update @SetChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_ChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField)

	update @SetGrandChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_GrandChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField)

	--populate full restore tree with bulk-generated items
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @ListItems

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GrandChildren

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GreatGrand

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetChildID

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetGrandChildID

	return
end

go