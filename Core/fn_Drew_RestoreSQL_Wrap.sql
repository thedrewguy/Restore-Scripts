/*
	require:
	fn_Drew_RestoreSQL_trigDisEn_t
*/

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

--test
/*
declare @Table varchar(255), @OpSQL nvarchar(max), @Operation varchar(255), @Fatal bit
set @Table = 'Resumes'
set @OpSQL = '	insert into resumes(resumesID, peopleid) select ResumesID, PeopleID from Resumes where peopleid = 12345'
set @Operation = 'insert'
set @Fatal = 1

declare @wrapped nvarchar(max) = dbo.fn_Drew_RestoreSQL_Wrap(@Table, @OpSQL, @Operation, @Fatal)

print @Wrapped
*/