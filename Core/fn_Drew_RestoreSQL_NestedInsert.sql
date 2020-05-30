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
	+ @nl + '	--restore tree'
	+ @nl + '	declare @RestoreTree Drew_RestoreTree'
	+ @nl + '	'
	+ @nl + '	insert into @RestoreTree(TableName, Operation, RestoreSQL, Fatal)'
	+ @nl + '	select TableName, Operation, RestoreSQL, Fatal'
	+ @nl + '	from dbo.' + @RestoreTreeFn + '(''' + @Sourdb + ''', ''' + @Tardb + ''')'
	+ @nl + ''
	+ @nl + '	declare @id int = (select max(id) from @Items)'
	+ @nl + '	while @id > 0 begin'
	+ @nl + '		--execute restore'
	+ @nl + '		declare @ItemID int = (select ItemID from @Items where id = @id)'
	+ @nl + '		exec sp_Drew_RestoreItem @SourDB = ''' + @Sourdb + ''', @TarDB = ''' + @Tardb + ''', @RestoreTree = @RestoreTree, @MainRecordID = @ItemID, @NestLevel = @NestLevel'
	+ @nl + ''
	+ @nl + '		--dec'
	+ @nl + '		set @id = @id - 1'
	+ @nl + '	end'
	+ @nl + '	update @Items set ItemID = ItemID --just for row count'
	
	return @sql

end

go