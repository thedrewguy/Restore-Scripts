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
		+ @nl + 'SET IDENTITY_INSERT ' + @Table + ' ON'

	--tran, sp, try (handles non-fatal runtime)

	declare @sp nvarchar(255) = N'subitem_start_' + cast(@NestLevel as nvarchar(255))

	set @sql = @sql
	+ @nl + 'begin tran'
	+ @nl + 'save tran ' + @sp
	+ @nl + 'BEGIN TRY'

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

	--commit

	set @sql = @sql
	+ @nl + '	commit tran'

	--identity insert off

	if @HasIdentity = 1 and @Operation = 'insert'
		set @sql = @sql
		+ @nl + '	SET IDENTITY_INSERT ' + @Table + ' OFF'

	--success message, start catch block

	set @sql = @sql
	+ @nl + '	print ''Success - ' + @Table + ' ' + @Operation + ' - '' + cast(@rc as varchar(255)) + '' row(s) affected'''
	+ @nl + 'END TRY'
	+ @nl + 'BEGIN CATCH'
	+ @nl + '	print ''Fail - ' + @Table + ' ' + @Operation + ''''
	+ @nl + '	rollback tran ' + @sp
	+ @nl + '	commit tran'
	
	--identity insert off

	if @HasIdentity = 1 and @Operation = 'insert'
		set @sql = @sql
		+ @nl + '	SET IDENTITY_INSERT ' + @Table + ' OFF'

	--error if fatal

	if @Fatal = 1
		set @sql = @sql
		+ @nl + '	RAISERROR(''Failed to ' + @Operation + ' ' + @Table + ' Record'', 11, 1)'

	--finish catch block

	set @sql = @sql
	+ @nl + 'END CATCH'

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