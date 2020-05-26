if object_id('fn_Drew_Restore_CandidateIntroductions_DiffTable_t') is not null
	drop function fn_Drew_Restore_CandidateIntroductions_DiffTable_t
go

create function fn_Drew_Restore_CandidateIntroductions_DiffTable_t()
returns @DeleteCheck table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
as begin
	insert into @DeleteCheck(TableName, WhereClause)
	values('MProjects', N'WHERE MProjectsID = @MainRecordID'),
	('LinkCandidatesToMProjects', N'WHERE MProjectsID = @MainRecordID'),
	('LinkEventsToBusinessObjects', N'WHERE MProjectsID = @MainRecordID'),
	('LinkContactsToMProjects', N'WHERE MProjectsID = @MainRecordID'),
	('LinkObjectToTask', N'WHERE ObjectTableName = ''MProjects'' AND LeftID = @MainRecordID'),
	('LinkObjectToDocument', N'WHERE ObjectTableName = ''MProjects'' AND LeftID = @MainRecordID'),
	('LinkObjectToActivityHistory', N'WHERE ObjectTableName = ''MProjects'' AND LeftID = @MainRecordID'),
	('LinkCandidatesToMPContacts', N'WHERE MProjectsID = @MainRecordID'),
	('MProjectCompaniesLists', N'WHERE MProjectsID = @MainRecordID'),
	('Task', N'WHERE TaskID in(select TaskID from <DB>..LinkCandidatesToMPContacts where MProjectsID = @MainRecordID)'),
	('MProjectCompaniesContacts', N'WHERE MProjectsID = @MainRecordID'),
	('TaskData', N'WHERE TaskID IN(SELECT TaskID FROM <DB>..LinkCandidatesToMPContacts WHERE MProjectsID = @MainRecordID)'),
	('LinkContactsToTask', N'WHERE TaskID IN(SELECT TaskID FROM <DB>..LinkCandidatesToMPContacts WHERE MProjectsID = @MainRecordID)'),
	('LinkObjectToTask', N'WHERE RightID IN(SELECT TaskID FROM <DB>..LinkCandidatesToMPContacts WHERE MProjectsID = @MainRecordID)')
		
	return
end