if object_id('fn_Drew_Restore_Opportunities_DiffTable_t') is not null
	drop function fn_Drew_Restore_Opportunities_DiffTable_t
go

create function fn_Drew_Restore_Opportunities_DiffTable_t()
returns @DiffTable table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
as begin
	insert into @DiffTable(TableName, WhereClause)
	values('Opportunities', N'WHERE OpportunitiesID = @MainRecordID'),
	
	('OpportunityTeams', N'WHERE OpportunitiesID = @MainRecordID'),
	('LinkContactsToOpportunities', N'WHERE OpportunitiesID = @MainRecordID'),
	('LinkCompaniesToOpportunities', N'WHERE OpportunitiesID = @MainRecordID'),
	('LinkEventsToBusinessObjects', N'WHERE OpportunitiesID = @MainRecordID'),
	('LinkOpportunitiesToBusinessObjects', N'WHERE OpportunitiesID = @MainRecordID'),
	('JobRequirements', N'WHERE OpportunitiesID = @MainRecordID'),

	('LinkObjectToDocument', N'WHERE ObjectTableName = ''Opportunities'' AND LeftID = @MainRecordID'),
	('LinkObjectToTask', N'WHERE ObjectTableName = ''Opportunities'' AND LeftID = @MainRecordID'),
	('LinkObjectToActivityHistory', N'WHERE ObjectTableName = ''Opportunities'' AND LeftID = @MainRecordID')

	return
end