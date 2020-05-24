if object_id('sp_Drew_RestoreSubItem') is not null
	drop proc sp_Drew_RestoreSubItem
go

create proc sp_Drew_RestoreSubItem(@MainRecordID int, @TableName varchar(255), @Operation varchar(255), @RestoreSQL nvarchar(max), @fatal bit, @NestLevel int)
as begin
	--wrap sql
	set @RestoreSQL = dbo.fn_Drew_RestoreSQL_Wrap(@TableName, @RestoreSQL, @Operation, @fatal, @NestLevel)
	
	--param def
	declare @paramdef nvarchar(max) = N'@MainRecordID int, @NestLevel int'

	--try to execute
	begin try
		declare @NewNestLevel int = @NestLevel + 1
		exec sp_executesql @RestoreSQL, @paramdef, @MainRecordID = @MainRecordID, @NestLevel = @NewNestLevel
	end try
	begin catch
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