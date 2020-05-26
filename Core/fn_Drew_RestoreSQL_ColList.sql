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