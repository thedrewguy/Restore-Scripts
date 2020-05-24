
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