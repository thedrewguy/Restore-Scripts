/* require:
	fn_Drew_RestoreSQL_ChildInsert
	fn_Drew_RestoreSQL_GrandchildInsert
	fn_Drew_RestoreSQL_GreatGrandInsert
	fn_Drew_RestoreSQL_ListItemInsert
	fn_Drew_RestoreSQL_ChildSetID
	fn_Drew_RestoreSQL_GrandChildSetID
	fn_Drew_RestoreSQL_Wrap
*/


if object_id('fn_Drew_Restore_MedJobOrders_RestoreTree_t') is not null
	drop function fn_Drew_Restore_MedJobOrders_RestoreTree_t
go

create function fn_Drew_Restore_MedJobOrders_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'JobOrdersID', 'JobOrdersID', null, 1),
		('CandidateCredentials', 'Tar.CandidateCredentialsID = Sour.CandidateCredentialsID', 'CandidateCredentialsID', 'JobOrdersID', null, 0),
		('JobRequirements', 'Tar.JobRequirementsID = Sour.JobRequirementsID', 'JobRequirementsID', 'JobOrdersID', null, 0),
		('JobOrdersSources', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('JobOrderConsideredPeople', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('JobOrderPresentedPeople', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('JobOrderInterviewPeople', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('JobOrderClientTeams', 'Tar.JobOrderClientTeamsID = Sour.JobOrderClientTeamsID', 'JobOrderClientTeamsID', 'JobOrdersID', null, 0),
		('JobOrderInternalInterviewPeople', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('PeopleAppliedTo', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('LinkJobOrdersToRates', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.RateTypesID = Sour.RateTypesID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('LinkOpportunitiesToBusinessObjects', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.OpportunitiesID = Sour.OpportunitiesID', 'OpportunitiesID', 'JobOrdersID', null, 0),
		('ProjectsCallStatus', 'Tar.ProjectsCallStatusID = Sour.ProjectsCallStatusID', 'ProjectsCallStatusID', 'JobOrdersID', null, 0),
		('Interview', 'Tar.InterviewID = Sour.InterviewID', 'InterviewID', 'JobOrdersID', null, 0),
		('WebJobPostings', 'Tar.WebJobPostingsID = Sour.WebJobPostingsID', 'WebJobPostingsID', 'JobOrdersID', null, 0),
		('Assignments', 'Tar.AssignmentsID = Sour.AssignmentsID', 'AssignmentsID', 'JobOrdersID', null, 0),
		('JobOrderSchedule', 'Tar.JobOrderScheduleID = Sour.JobOrderScheduleID', 'JobOrderScheduleID', 'JobOrdersID', null, 0),
		('JobOrdersCompaniesLists', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.CompaniesID = Sour.CompaniesID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('Positions', 'Tar.PositionsID = Sour.PositionsID', 'PositionsID', 'JobOrdersID', null, 0),
		('CandidateReferrals', 'Tar.CandidateReferralsID = Sour.CandidateReferralsID', 'CandidateReferralsID', 'JobOrdersID', null, 0),
		('JobOrderTeams', 'Tar.JobOrderTeamsID = Sour.JobOrderTeamsID', 'JobOrderTeamsID', 'JobOrdersID', null, 0),
		('LinkEventsToBusinessObjects', 'Tar.LinkEventToObjectsID = Sour.LinkEventToObjectsID', 'LinkEventToObjectsID', 'JobOrdersID', null, 0),
		('JobOrdersConditions', 'Tar.JobOrdersConditionsID = Sour.JobOrdersConditionsID', 'JobOrdersConditionsID', 'JobOrdersID', null, 0),
		('Timesheets', 'Tar.TimesheetsID = Sour.TimesheetsID', 'TimesheetsID', 'JobOrdersID', null, 0),
		('LinkJobOrderToWorkSteps', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.WorkStepsID = Sour.WorkstepsID and isnull(Tar.PositionsID, 0) = isnull(Sour.PositionsID, 0) and isnull(Tar.AssignmentsID, 0) = isnull(Sour.AssignmentsID, 0)', 'JobOrdersID', 'JobOrdersID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'JobOrders', 0),
		('LinkObjectToDocument', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'JobOrders', 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'JobOrders', 0),
		('JobOrdersTargetCompaniesCandidates', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.CompaniesID = Sour.CompaniesID and Tar.PeopleID = Sour.PeopleID', 'JobOrdersID', 'JobOrdersID', null, 0),
		('UsersCommissionsSplit', 'Tar.JobOrdersID = Sour.JobOrdersID', 'JobOrdersID', 'JobOrdersID', null, 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)
		insert into @ListItems(insTable, Fatal)
		values('ListsDetails', 0)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GrandChildren(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'TaskID', 'Interview', 'SourParent.TaskID = Sour.TaskID', 'JobOrdersID', null, 0),
		('LinkInterviewersToClientInterview', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'Interview', 'SourParent.InterviewID = Sour.RightID', 'JobOrdersID', null, 0),
		('LinkClnInterviewsToResults', 'Tar.LinkClnInterviewsToResultsID = Sour.LinkClnInterviewsToResultsID', 'LinkClnInterviewsToResultsID', 'Interview', 'SourParent.InterviewID = Sour.InterviewsID', 'JobOrdersID', null, 0),
		('Questions', 'Tar.QuestionsID = Sour.QuestionsID', 'QuestionsID', 'WebJobPostings', 'SourParent.WebJobPostingsID = Sour.WebJobPostingsID', 'JobOrdersID', null, 0),
		('SkillsQuestions', 'Tar.SkillsQuestionsID = Sour.SkillsQuestionsID', 'SkillsQuestionsID', 'WebJobPostings', 'SourParent.WebJobPostingsID = Sour.WebJobPostingsID', 'JobOrdersID', null, 0),
		('LinkWebPostingToWebsite', 'Tar.WebJobPostingsID = Sour.WebJobPostingsID and Tar.WebsitesID = Sour.WebsitesID', 'WebJobPostingsID', 'WebJobPostings', 'SourParent.WebJobPostingsID = Sour.WebJobPostingsID', 'JobOrdersID', null, 0),
		('WebPostingsIndustries', 'Tar.WebPostingsIndustriesID = Sour.WebPostingsIndustriesID', 'WebPostingsIndustriesID', 'WebJobPostings', 'SourParent.WebJobPostingsID = Sour.WebJobPostingsID', 'JobOrdersID', null, 0),
		('LinkJobOrderScheduleToPosition', 'Tar.JobOrderScheduleID = Sour.JobOrderScheduleID and Tar.PositionsID = Sour.PositionsID', 'JobOrderScheduleID', 'JobOrderSchedule', 'SourParent.JobOrderScheduleID = Sour.JobOrderScheduleID', 'JobOrdersID', null, 0),
		('PositionDetails', 'Tar.PositionsID = Sour.PositionsID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', null, 0),
		('LinkPositionsToRates', 'Tar.PositionsID = Sour.PositionsID and Tar.RateTypesID = Sour.RateTypesID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', null, 0),
		('LinkJobOrderScheduleToPosition', 'Tar.PositionsID = Sour.PositionsID and Tar.JobOrderScheduleID = Sour.JobOrderScheduleID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', null, 0),
		('PositionExpenses', 'Tar.PositionExpensesID = Sour.PositionExpensesID', 'PositionExpensesID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', null, 0)
	
		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GreatGrand(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('TaskData', 'Tar.TaskDataID = Sour.TaskDataID', 'TaskDataID', 'Task', 'SourParent.TaskID = Sour.TaskID', 'Interview', 'SourGrand.TaskID = SourParent.TaskID', 'JobOrdersID', null, 0),
		('LinkContactsToTask', 'Tar.TaskID = Sour.TaskID and Tar.PeopleID = Sour.PeopleID', 'TaskID', 'Task', 'SourParent.TaskID = Sour.TaskID', 'Interview', 'SourGrand.TaskID = SourParent.TaskID', 'JobOrdersID', null, 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'Task', 'SourParent.TaskID = Sour.RightID', 'Interview', 'SourGrand.TaskID = SourParent.TaskID', 'JobOrdersID', null, 0),
		('MultipleAnswerItems', 'Tar.MultipleAnswerItemsID = Sour.MultipleAnswerItemsID', 'MultipleAnswerItemsID', 'Questions', 'SourParent.QuestionsID = Sour.QuestionsID', 'WebJobPostings', 'SourGrand.WebJobPostingsID = SourParent.WebJobPostingsID', 'JobOrdersID', null, 0)
	
		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		insert into @SetChildID(UpTable, TarSourJoinOn, SetIDField, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'JobOrdersID', 0),
		('WebRequests', 'Tar.WebRequestsID = Sour.WebRequestsID', 'JobOrdersID', 0)

		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(255), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		insert into @SetGrandChildID(UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'JobOrdersID', 0)

	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''MRContracts'', ''PermOrders'', ''Temp'', ''Contracts''')

	update @GrandChildren
	set insertSQL = dbo.fn_Drew_RestoreSQL_GrandchildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName)

	update @GreatGrand
	set insertSQL = dbo.fn_Drew_RestoreSQL_GreatGrandInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName)

	update @SetChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_ChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField)

	update @SetGrandChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_GrandChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField)

	--populate full restore tree with bulk-generated items
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @ListItems

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GrandChildren

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GreatGrand

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetChildID

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetGrandChildID

	return
end