if object_id('fn_Drew_RestoreSQL_trigDisEn_t') is not null
	drop function fn_Drew_RestoreSQL_trigDisEn_t
go

create function fn_Drew_RestoreSQL_trigDisEn_t(@tablename nvarchar(255))
returns @SQL table(DisableTrigs nvarchar(max), EnableTrigs nvarchar(max))
as begin
	declare @nl nvarchar(2) = char(13) + char(10)
	declare @distrigs nvarchar(max) = stuff(
		(
			select @nl + char(9) + ';disable trigger ' + tr.name + ' on ' + ta.name
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

/*
--test
declare @tablename nvarchar(255) = 'people'
select * from dbo.fn_Drew_RestoreSQL_trigDisEn_t(@Tablename)
*/