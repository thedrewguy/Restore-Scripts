
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
	+ @nl + '	update Tar'
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