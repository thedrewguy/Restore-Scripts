if object_id('fn_Drew_Restore_Task_DiffTable_t') is not null
	drop function fn_Drew_Restore_Task_DiffTable_t
go

create function fn_Drew_Restore_Task_DiffTable_t()
returns @DeleteCheck table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
as begin
	insert into @DeleteCheck(TableName, WhereClause)
	values('Task', N'WHERE TaskID = @MainRecordID'),
	('TaskData', N'WHERE TaskID = @MainRecordID'),
	('LinkContactsToTask', N'WHERE TaskID = @MainRecordID'),
	('LinkTaskToProjectStages', N'WHERE TaskID = @MainRecordID'),
	('LinkObjectToTask', N'WHERE RightID = @MainRecordID and ObjectTableName = ''Task''')

	return
end