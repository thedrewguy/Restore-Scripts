	begin try drop type Drew_RestoreTree end try begin catch end catch
	go

	create type Drew_RestoreTree as table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
	go