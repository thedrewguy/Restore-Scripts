/*
	require:
	sp_Drew_RestoreSubItem

	type: Drew_RestoreTree
*/

set ansi_nulls on
go
set quoted_identifier on
go

if object_id('sp_Drew_RestoreItem') is not null
	drop proc sp_Drew_RestoreItem
go

create proc sp_Drew_RestoreItem(@SourDB varchar(255), @TarDB varchar(255), @RestoreTree Drew_RestoreTree readonly, @MainRecordID int, @NestLevel int)
as begin
	--error message variable
	declare @ErrorMessage varchar(4000)

	--try catch rollback, to handle fatal errors
	begin tran
	declare @sp nvarchar(max) = N'RestoreItem_' + cast(@NestLevel as nvarchar(max))
	declare @saveTranSQL nvarchar(max) = N'save tran ' + @sp
	exec sp_executesql @saveTranSQL
	begin try
	
		--check that we're in the right database
		if isnull(charindex(db_name(), @TarDB), 0) = 0
			raiserror('Please switch this session to the restore target database before running', 11, 1)

		--loop, execute restore sql

		declare @r_num int = (Select count(1) from @RestoreTree)

		--for each restore table
		declare @r_i int = 1
		while @r_i <= @r_num begin

			--get settings for table
			declare @TableName varchar(255), @Operation varchar(255), @RestoreSQL nvarchar(max), @Fatal bit

			select @TableName = TableName, @Operation = Operation, @RestoreSQL = RestoreSQL, @Fatal = Fatal from @RestoreTree where id = @r_i

			--execute
			exec sp_Drew_RestoreSubItem @MainRecordID, @TableName, @Operation, @RestoreSQL, @Fatal, @NestLevel
	
			--increment
			set @r_i = @r_i + 1
		end
		
		commit tran
	end try
	begin catch
		set @ErrorMessage = 'Fatal Error. Record not restored. All changes reversed: ' + error_message()
		if @NestLevel = 1
			rollback
		else begin
			declare @rollbackSQL nvarchar(max) = N'rollback tran ' + @sp
			exec sp_Executesql @rollbackSQL
		end
		raiserror(@ErrorMessage, 11, 1)
	end catch
		
end

go