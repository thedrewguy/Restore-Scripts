/* require:
	fn_Drew_RestoreSQL_ChildInsert
	fn_Drew_RestoreSQL_GrandchildInsert
	fn_Drew_RestoreSQL_GreatGrandInsert
	fn_Drew_RestoreSQL_ListItemInsert
	fn_Drew_RestoreSQL_ChildSetID
	fn_Drew_RestoreSQL_GrandChildSetID
	fn_Drew_RestoreSQL_NestedInsert
	fn_Drew_Restore_Task_RestoreTree_t
	fn_Drew_Restore_WebJobPostings_RestoreTree_t
	fn_Drew_Restore_CandidateBlock_t
	fn_Drew_RestoreSQL_MakeBlockLog
*/


if object_id('fn_Drew_Restore_Projects_RestoreTree_t') is not null
	drop function fn_Drew_Restore_Projects_RestoreTree_t
go

create function fn_Drew_Restore_Projects_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('Projects', 'Tar.ProjectsID = Sour.ProjectsID', 'ProjectsID', 'ProjectsID', null, 1),
		('CandidateCredentials', 'Tar.CandidateCredentialsID = Sour.CandidateCredentialsID', 'CandidateCredentialsID', 'ProjectsID', null, 0),
		('ProjectsCallStatus', 'Tar.ProjectsCallStatusID = Sour.ProjectsCallStatusID', 'ProjectsCallStatusID', 'ProjectsID', null, 0),
		('JobRequirements', 'Tar.JobRequirementsID = Sour.JobRequirementsID', 'JobRequirementsID', 'ProjectsID', null, 0),
		('ProjectBillingDetails', 'Tar.ProjectBillingDetailsID = Sour.ProjectBillingDetailsID', 'ProjectBillingDetailsID', 'ProjectsID', null, 0),
		('ProjectsAccounting', 'Tar.ProjectsAccountingID = Sour.ProjectsAccountingID', 'ProjectsAccountingID', 'ProjectsID', null, 0),
		('ProjectsClientTeams', 'Tar.ProjectsClientTeamsID = Sour.ProjectsClientTeamsID', 'ProjectsClientTeamsID', 'ProjectsID', null, 0),
		('ProjectsTeam', 'Tar.ProjectsTeamID = Sour.ProjectsTeamID', 'ProjectsTeamID', 'ProjectsID', null, 0),
		('ProjectStages', 'Tar.ProjectStagesID = Sour.ProjectStagesID', 'ProjectStagesID', 'ProjectsID', null, 0),
		('ProjectInvoices', 'Tar.ProjectInvoicesID = Sour.ProjectInvoicesID', 'ProjectInvoicesID', 'ProjectsID', null, 0),
		('InternalInterviews', 'Tar.InternalInterviewsID = Sour.InternalInterviewsID', 'InternalInterviewsID', 'ProjectsID', null, 0),
		('Interview', 'Tar.InterviewID = Sour.InterviewID', 'InterviewID', 'ProjectsID', null, 0),
		('LinkMediaToProject', 'Tar.LinkMediaToProjectID = Sour.LinkMediaToProjectID', 'LinkMediaToProjectID', 'ProjectsID', null, 0),
		('Affiliates', 'Tar.AffiliatesID = Sour.AffiliatesID', 'AffiliatesID', 'ProjectsID', null, 0),
		('CandidateReferrals', 'Tar.CandidateReferralsID = Sour.CandidateReferralsID', 'CandidateReferralsID', 'ProjectsID', null, 0),
		('LinkOpportunitiesToBusinessObjects', 'Tar.OpportunitiesID = Sour.OpportunitiesID and Tar.ProjectsID = Sour.ProjectsID', 'OpportunitiesID', 'ProjectsID', null, 0),
		('LinkEventsToBusinessObjects', 'Tar.LinkEventToObjectsID = Sour.LinkEventToObjectsID', 'LinkEventToObjectsID', 'ProjectsID', null, 0),
		('ProjectsCompaniesLists', 'Tar.ProjectsID = Sour.ProjectsID and Tar.CompaniesID = Sour.CompaniesID', 'ProjectsID', 'ProjectsID', null, 0),
		('ProjectTargetCompaniesCandidates', 'Tar.ProjectsID = Sour.ProjectsID and Tar.CompaniesID = Sour.CompaniesID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('LastProjectActivity', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('ProjectsTargetLists', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('ProjectsSources', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('ProjectsFileSearchCandidates', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('ProjectsPresentedLists', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('ProjectsBenchmarkCandidates', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('PeopleAppliedTo', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('ProjectsClientEmployeesLists', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('ProjectsInternalInterviewLists', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('ProjectsShortLists', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID', 'ProjectsID', 'ProjectsID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Projects', 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Projects', 0),
		('LinkObjectToDocument', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Projects', 0),
		('CandidateReferences', 'Tar.CandidateReferencesID = Sour.CandidateReferencesID', 'CandidateReferencesID', 'ProjectsID', null, 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)
		insert into @ListItems(insTable, Fatal)
		values('ListsDetails', 0)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GrandChildren(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('LinkTaskToProjectStages', 'Tar.ProjectsID = Sour.ProjectsID and Tar.ProjectStagesID = Sour.ProjectStagesID and Tar.TaskID = Sour.TaskID', 'ProjectsID', 'ProjectStages', 'SourParent.ProjectStagesID = Sour.ProjectStagesID', 'ProjectsID', null, 0),
		('InvoiceItems', 'Tar.InvoiceItemsID = Sour.InvoiceItemsID', 'InvoiceItemsID', 'ProjectInvoices', 'SourParent.ProjectInvoicesID = Sour.ProjectInvoicesID', 'ProjectsID', null, 0),
		('LinkInternalInterviewsToResults', 'Tar.LinkIntInterviewsToResultsID = Sour.LinkIntInterviewsToResultsID', 'LinkIntInterviewsToResultsID', 'InternalInterviews', 'SourParent.InternalInterviewsID = Sour.InternalInterviewsID', 'ProjectsID', null, 0),
		('LinkSkillsToInternalInterview', 'Tar.LinkSkillsToInternalInterviewID = Sour.LinkSkillsToInternalInterviewID', 'LinkSkillsToInternalInterviewID', 'InternalInterviews', 'SourParent.InternalInterviewsID = Sour.InternalInterviewsID', 'ProjectsID', null, 0),
		('LinkInterviewersToClientInterview', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'Interview', 'SourParent.InterviewID = Sour.LeftID', 'ProjectsID', null, 0)
		
		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		insert into @SetChildID(UpTable, TarSourJoinOn, SetIDField, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'ProjectsID', 0),
		('WebRequests', 'Tar.WebRequestsID = Sour.WebRequestsID', 'ProjectsID', 0)

		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(255), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
		
	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''Projects''')

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

	--custom
	declare @nl nvarchar(2) = char(13) + char(10)

	declare @TasksSQL nvarchar(max) = N''
	+ @nl + '	select Sour.TaskID'
	+ @nl + '	from ('
	+ @nl + '		select TaskID'
	+ @nl + '		from ' + @Sourdb + '..InternalInterviews'
	+ @nl + '		where ProjectsID = @MainRecordID'
	+ @nl + '		union select TaskID'
	+ @nl + '		from ' + @Sourdb + '..Interview'
	+ @nl + '		where ProjectsID = @MainRecordID'
	+ @nl + '	) Sour'
	+ @nl + '	left join ' + @Tardb + '..Task Tar'
	+ @nl + '		on Tar.TaskID = Sour.TaskID'
	+ @nl + '	where Sour.TaskID is not null'
	+ @nl + '	and Tar.TaskID is null'

	declare @WebJobPostingsSQL nvarchar(max) = N''
	+ @nl + '	select Sour.WebJobPostingsID'
	+ @nl + '	from ' + @Sourdb + '..WebJobPostings Sour'
	+ @nl + '	left join ' + @Tardb + '..WebJobPostings Tar'
	+ @nl + '		on Tar.WebJobPostingsID = Sour.WebJobPostingsID'
	+ @nl + '	where Sour.ProjectsID = @MainRecordID'
	+ @nl + '	and Sour.WebJobPostingsID is not null'
	+ @nl + '	and Tar.WebJobPostingsID is null'

	declare @PCBSQL nvarchar(max) = N''
	+ @nl + '	delete ProjectsCandidateBlocks from ' + @Tardb + '..ProjectsCandidateBlocks where ProjectsID = @MainRecordID'
	+ @nl + dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, 'ProjectsCandidateBlocks', 'Tar.ProjectsID = Sour.ProjectsID and Tar.PeopleID = Sour.PeopleID and Tar.WorkListsID = Sour.WorkListsID', 'ProjectsID', 'ProjectsID', null)

	declare @BlockSQL nvarchar(max) = N''
	+ @nl + '	update Tar'
	+ @nl + '	set CandidateBlockStatus = activePCB.CandidateBlockStatus,'
	+ @nl + '	BlockDescription = activePCB.BlockDescription,'
	+ @nl + '	CandidateBlockProjectsID = activePCB.CandidateBlockProjectsID'
	+ @nl + '	from ' + @Tardb + '..People Tar'
	+ @nl + '	join ' + @Tardb + '..ProjectsCallStatus TarPCS'
	+ @nl + '		on TarPCS.PeopleID = Tar.PeopleID'
	+ @nl + '	outer apply ' + @Tardb + '..fn_Drew_Restore_CandidateBlock_t(Tar.PeopleID) activePCB'
	+ @nl + '	where TarPCS.ProjectsID = @MainRecordID'
	+ @nl + '	and ('
	+ @nl + '		isnull(activePCB.CandidateBlockStatus, 0) <> isnull(Tar.CandidateBlockStatus, 0)'
	+ @nl + '		or isnull(activePCB.BlockDescription, 0) <> isnull(Tar.BlockDescription, 0)'
	+ @nl + '		or isnull(activePCB.CandidateBlockProjectsID, 0) <> isnull(Tar.CandidateBlockProjectsID, 0)'
	+ @nl + '	)'

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	values('Task', dbo.fn_Drew_RestoreSQL_NestedInsert(@SourDB, @TarDB, @TasksSQL, 'fn_Drew_Restore_Task_RestoreTree_t'), 'nested restore', 0),
	('WebJobPostings', dbo.fn_Drew_RestoreSQL_NestedInsert(@SourDB, @TarDB, @WebJobPostingsSQL, 'fn_Drew_Restore_WebJobPostings_RestoreTree_t'), 'nested restore', 0),
	('ProjectsCandidateBlocks', @PCBSQL, 'replace', 0),
	('ProjRestoreBlockLog', dbo.fn_Drew_RestoreSQL_MakeBlockLog(@SourDB, @TarDB), 'create', 0),
	('People', @BlockSQL, 'block update', 0)
		
	return
end