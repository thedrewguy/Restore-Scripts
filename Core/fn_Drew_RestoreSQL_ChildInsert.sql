/*
	require:
	fn_Drew_RestoreSQL_ColList
*/

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