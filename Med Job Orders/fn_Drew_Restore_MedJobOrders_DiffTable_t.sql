if object_id('fn_Drew_Restore_MedJobOrders_DiffTable_t') is not null
	drop function fn_Drew_Restore_MedJobOrders_DiffTable_t
go

create function fn_Drew_Restore_MedJobOrders_DiffTable_t()
returns @DeleteCheck table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
as begin
	insert into @DeleteCheck(TableName, WhereClause)
	values('JobOrders', N'WHERE JobOrdersID = @MainRecordID'),
	('CandidateCredentials', N'WHERE JobOrdersID = @MainRecordID'),
	('JobRequirements', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrdersSources', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrderConsideredPeople', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrderPresentedPeople', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrderInterviewPeople', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrderClientTeams', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrderInternalInterviewPeople', N'WHERE JobOrdersID = @MainRecordID'),
	('PeopleAppliedTo', N'WHERE JobOrdersID = @MainRecordID'),
	('LinkJobOrdersToRates', N'WHERE JobOrdersID = @MainRecordID'),
	('LinkOpportunitiesToBusinessObjects', N'WHERE JobOrdersID = @MainRecordID'),
	('ProjectsCallStatus', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrderTeams', N'WHERE JobOrdersID = @MainRecordID'),
	('LinkEventsToBusinessObjects', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrdersConditions', N'WHERE JobOrdersID = @MainRecordID'),
	('TimeSheets', N'WHERE JobOrdersID = @MainRecordID'),
	('LinkJobOrderToWorksteps', N'WHERE JobOrdersID = @MainRecordID'),
	('Interview', N'WHERE JobOrdersID = @MainRecordID'),
	('WebJobPostings', N'WHERE JobOrdersID = @MainRecordID'),
	('Assignments', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrderSchedule', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrdersCompaniesLists', N'WHERE JobOrdersID = @MainRecordID'),
	('JobOrdersTargetCompaniesCandidates', N'WHERE JobOrdersID = @MainRecordID'),
	('Positions', N'WHERE JobOrdersID = @MainRecordID'),
	('LinkObjectToDocument', N'WHERE ObjectTableName = ''JobOrders'' AND LeftID = @MainRecordID'),
	('LinkObjectToTask', N'WHERE ObjectTableName = ''JobOrders'' AND LeftID = @MainRecordID'),
	('LinkObjectToActivityHistory', N'WHERE ObjectTableName = ''JobOrders'' AND LeftID = @MainRecordID'),
	('ListsDetails', N'WHERE ListID IN(SELECT ListsID FROM <DB>..Lists WHERE SourceTable IN(''Contracts'', ''MRContracts'', ''PermOrders'', ''Temp'')) AND RecordID = @MainRecordID'),
	('Task', N'WHERE TaskID IN(SELECT TaskID FROM <DB>..Interview WHERE JobOrdersID = @MainRecordID)'),
	('TaskData', N'WHERE TaskID IN(SELECT TaskID FROM <DB>..Interview WHERE JobOrdersID = @MainRecordID)'),
	('LinkContactsToTask', N'WHERE TaskID IN(SELECT TaskID FROM <DB>..Interview WHERE JobOrdersID = @MainRecordID)'),
	('LinkObjectToTask', N'WHERE RightID IN(SELECT TaskID FROM <DB>..Interview WHERE JobOrdersID = @MainRecordID)'),
	('LinkInterviewersToClientInterview', N'WHERE RightID IN(SELECT InterviewID FROM <DB>..Interview WHERE JobOrdersID = @MainRecordID)'),
	('LinkClnInterviewsToResults', N'WHERE InterviewsID IN(SELECT InterviewID FROM <DB>..Interview WHERE JobOrdersID = @MainRecordID)'),
	('Questions', N'WHERE WebJobPostingsID IN(SELECT WebJobPostingsID FROM <DB>..WebJobPostings WHERE JobOrdersID = @MainRecordID)'),
	('SkillsQuestions', N'WHERE WebJobPostingsID IN(SELECT WebJobPostingsID FROM <DB>..WebJobPostings WHERE JobOrdersID = @MainRecordID)'),
	('LinkWebPostingToWebsite', N'WHERE WebJobPostingsID IN(SELECT WebJobPostingsID FROM <DB>..WebJobPostings WHERE JobOrdersID = @MainRecordID)'),
	('MultipleAnswerItems', N'WHERE QuestionsID IN(SELECT QuestionsID FROM <DB>..WebJobPostings JOIN <DB>..Questions ON Questions.WebJobPostingsID = WebJobPostings.WebJobPostingsID WHERE WebJobPostings.JobOrdersID = @MainRecordID)'),
	('LinkJobOrderScheduleToPosition', N'WHERE JobOrderScheduleID IN(SELECT JobOrderScheduleID FROM <DB>..JobOrderSchedule WHERE JobOrdersID = @MainRecordID)'),
	('PositionDetails', N'WHERE PositionsID IN(SELECT PositionsID FROM <DB>..Positions WHERE JobOrdersID = @MainRecordID)'),
	('LinkPositionsToRates', N'WHERE PositionsID IN(SELECT PositionsID FROM <DB>..Positions WHERE JobOrdersID = @MainRecordID)'),
	('PositionExpenses', N'WHERE PositionsID IN(SELECT PositionsID FROM <DB>..Positions WHERE JobOrdersID = @MainRecordID)'),
	('UsersCommissionsSplit', N'WHERE JobOrdersID = @MainRecordID'),
	('WebPostingsIndustries', N'WHERE WebJobPostingsID IN(SELECT WebJobPostingsID FROM <DB>..WebJobPostings WHERE JobOrdersID = @MainRecordID)')

	return
end