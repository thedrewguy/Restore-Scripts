if object_id('fn_Drew_Restore_WebJobPostings_DiffTable_t') is not null
	drop function fn_Drew_Restore_WebJobPostings_DiffTable_t
go

create function fn_Drew_Restore_WebJobPostings_DiffTable_t()
returns @DeleteCheck table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
as begin
	insert into @DeleteCheck(TableName, WhereClause)
	values('WebJobPostings', N'WHERE WebJobPostingsID = @MainRecordID'),
	('Questions', N'WHERE WebJobPostingsID = @MainRecordID'),
	('SkillsQuestions', N'WHERE WebJobPostingsID = @MainRecordID'),
	('WebPostingsIndustries', N'WHERE WebJobPostingsID = @MainRecordID'),
	('LinkWebPostingToWebsite', N'WHERE WebJobPostingsID = @MainRecordID'),
	('MultipleAnswerItems', N'WHERE QuestionsID in(select QuestionsID from <db>..Questions where WebJobPostingsID = @MainRecordID)')

	return
end