if object_id('fn_Drew_Restore_Projects_DiffTable_t') is not null
	drop function fn_Drew_Restore_Projects_DiffTable_t
go

create function fn_Drew_Restore_Projects_DiffTable_t()
returns @DeleteCheck table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
as begin
	insert into @DeleteCheck(TableName, WhereClause)
	values('Projects', N'WHERE ProjectsID = @MainRecordID'),
	('CandidateCredentials', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsCallStatus', N'WHERE ProjectsID = @MainRecordID'),
	('JobRequirements', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectBillingDetails', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsAccounting', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsClientTeams', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsTeam', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectStages', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectInvoices', N'WHERE ProjectsID = @MainRecordID'),
	('InternalInterviews', N'WHERE ProjectsID = @MainRecordID'),
	('Interview', N'WHERE ProjectsID = @MainRecordID'),
	('LinkMediaToProject', N'WHERE ProjectsID = @MainRecordID'),
	('Affiliates', N'WHERE ProjectsID = @MainRecordID'),
	('CandidateReferrals', N'WHERE ProjectsID = @MainRecordID'),
	('LinkOpportunitiesToBusinessObjects', N'WHERE ProjectsID = @MainRecordID'),
	('LinkEventsToBusinessObjects', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsCompaniesLists', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectTargetCompaniesCandidates', N'WHERE ProjectsID = @MainRecordID'),
	('LastProjectActivity', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsTargetLists', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsSources', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsFileSearchCandidates', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsPresentedLists', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsBenchmarkCandidates', N'WHERE ProjectsID = @MainRecordID'),
	('PeopleAppliedTo', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsClientEmployeesLists', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsInternalInterviewLists', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsShortLists', N'WHERE ProjectsID = @MainRecordID'),
	('ProjectsCandidateBlocks', N'WHERE ProjectsID = @MainRecordID'),
	('CandidateReferences', N'WHERE ProjectsID = @MainRecordID'),
	('ListsDetails','WHERE ListID IN(SELECT ListsID FROM <DB>..Lists WHERE SourceTable IN(''Projects'')) AND RecordID = @MainRecordID'),
	('LinkObjectToActivityHistory', N'WHERE LeftID = @MainRecordID and ObjectTableName = ''Projects'''),
	('LinkObjectToDocument', N'WHERE LeftID = @MainRecordID and ObjectTableName = ''Projects'''),
	('LinkObjectToTask', N'WHERE LeftID = @MainRecordID and ObjectTableName = ''Projects'''),
	('WebJobPostings', N'WHERE ProjectsID = @MainRecordID'),
	('Task', N'WHERE TaskID in(select TaskID from <db>..InternalInterviews where ProjectsID = @MainRecordID)'),
	('Task', N'WHERE TaskID in(select TaskID from <db>..Interview where ProjectsID = @MainRecordID)'),
	('Task', N'WHERE ProjectsID = @MainRecordID'),
	('WebRequests', N'WHERE ProjectsID = @MainRecordID'),
	('People', N'WHERE CandidateBlockProjectsID = @MainRecordID'),
	('LinkTaskToProjectStages', N'WHERE ProjectsID = @MainRecordID'),
	('InvoiceItems', N'WHERE ProjectInvoicesID in(select ProjectInvoicesID from <DB>..ProjectInvoices where ProjectsID = @MainRecordID)'),
	('LinkInternalInterviewsToResults', N'WHERE InternalInterviewsID in(select InternalInterviewsID from <DB>..InternalInterviews where ProjectsID = @MainRecordID)'),
	('LinkSkillsToInternalInterview', N'WHERE InternalInterviewsID in(select InternalInterviewsID from <DB>..InternalInterviews where ProjectsID = @MainRecordID)'),
	('LinkInterviewersToClientInterview', N'WHERE LeftID in(select InterviewID from <DB>..Interview where ProjectsID = @MainRecordID)')

	return
end