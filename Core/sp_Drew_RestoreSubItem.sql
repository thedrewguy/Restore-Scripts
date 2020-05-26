/*
	require:
	fn_Drew_RestoreSQL_Wrap
*/

if object_id('sp_Drew_RestoreSubItem') is not null
	drop proc sp_Drew_RestoreSubItem
go

create proc sp_Drew_RestoreSubItem(@MainRecordID int, @TableName varchar(255), @Operation varchar(255), @RestoreSQL nvarchar(max), @fatal bit, @NestLevel int)
as begin
	--wrap sql
	set @RestoreSQL = dbo.fn_Drew_RestoreSQL_Wrap(@TableName, @RestoreSQL, @Operation, @fatal, @NestLevel)
	
	--param def
	declare @paramdef nvarchar(max) = N'@MainRecordID int, @NestLevel int'
	
	--new line, savepoint name for later
	declare @nl varchar(2) = char(13) + char(10)
	declare @sp nvarchar(255) = N'subitem_start_' + cast(@NestLevel as nvarchar(255))

	--try to execute
	begin try
		--tran, save
		begin tran
		declare @spsql nvarchar(max) = N'save tran ' + @sp
		exec sp_executesql @spsql
		
		--execute
		declare @NewNestLevel int = @NestLevel + 1
		exec sp_executesql @RestoreSQL, @paramdef, @MainRecordID = @MainRecordID, @NestLevel = @NewNestLevel
		
		--commit
		commit tran
	end try
	--catch fatal and syntax errors
	begin catch
		--rollback to savepoint
		declare @rbsql nvarchar(max) = 'rollback tran ' + @sp
		exec sp_executesql @rbsql
		commit tran

		--if fatal, re-throw
		if @fatal = 1 begin
			declare @ErrorMessage varchar(4000) = 'Fail - ' + @Tablename + ' ' + @Operation + ': ' + ERROR_MESSAGE()
			RAISERROR(@ErrorMessage, 11, 1)
		end
		--otherwise print message and continue
		else
			print 'Syntax Error: ' + @TableName + ' ' + @Operation
			print @RestoreSQL
			print ''
	end catch
end
go