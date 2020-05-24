
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
	+ @nl + '	update Tar'
	+ @nl + '	set ' + @SetIDField + ' = @MainRecordID'
	+ @nl + '	FROM ' + @Sourdb + '..' + @UpTable + ' Sour'
	+ @nl + '	JOIN ' + @Tardb + '..' + @UpTable + ' Tar'
	+ @nl + '	ON ' + @TarSourJoinOn
	+ @nl + '	WHERE Sour.' + @SetIDField + ' = @MainRecordID'
	+ @nl + '	AND Tar.' + @SetIDField + ' IS NULL'

	return @sql

end

go