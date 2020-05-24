/*
	require:
	fn_Drew_RestoreSQL_ColList
*/

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