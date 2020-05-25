/* require:
	fn_Drew_RestoreSQL_ChildInsert
	fn_Drew_RestoreSQL_GrandchildInsert
	fn_Drew_RestoreSQL_GreatGrandInsert
	fn_Drew_RestoreSQL_ListItemInsert
	fn_Drew_RestoreSQL_ChildSetID
	fn_Drew_RestoreSQL_GrandChildSetID
	fn_Drew_RestoreSQL_NestedInsert
	fn_Drew_Restore_Addresses_RestoreTree_t
	fn_Drew_Restore_Task_RestoreTree_t
*/


if object_id('fn_Drew_Restore_People_RestoreTree_t') is not null
	drop function fn_Drew_Restore_People_RestoreTree_t
go

create function fn_Drew_Restore_People_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('People', 'Tar.PeopleID = Sour.PeopleID', 'PeopleID', 'PeopleID', null, 1),
		('Resumes', 'Tar.ResumesID = Sour.ResumesID', 'ResumesID', 'PeopleID', null, 0),
		('Notes', 'Tar.NotesID = Sour.NotesID', 'NotesID', 'PeopleID', null, 0),
		('LinkPeopleToSkills', 'Tar.LinkPeopleToSkillsID = Sour.LinkPeopleToSkillsID', 'LinkPeopleToSkillsID', 'PeopleID', null, 0),
		('Affiliates', 'Tar.AffiliatesID = Sour.AffiliatesID', 'AffiliatesID', 'PeopleID', null, 0),
		('Education', 'Tar.EducationID = Sour.EducationID', 'EducationID', 'PeopleID', null, 0),
		('PeopleAvailability', 'Tar.PeopleAvailabilityID = Sour.PeopleAvailabilityID', 'PeopleAvailabilityID', 'PeopleID', null, 0),
		('LinkPeopleToCredentials', 'Tar.LinkPeopleToCredentialsID = Sour.LinkPeopleToCredentialsID', 'LinkPeopleToCredentialsID', 'PeopleID', null, 0),
		('LinkPeopleToCompanies', 'Tar.LinkPeopleToCompaniesID = Sour.LinkPeopleToCompaniesID', 'LinkPeopleToCompaniesID', 'PeopleID', null, 0),
		('JobOrderClientTeams', 'Tar.JobOrderClientTeamsID = Sour.JobOrderClientTeamsID', 'JobOrderClientTeamsID', 'PeopleID', null, 0),
		('LinkPeopleToKnownToUsers', 'Tar.LinkPeopleToKnownToUsersID = Sour.LinkPeopleToKnownToUsersID', 'LinkPeopleToKnownToUsersID', 'PeopleID', null, 0),
		('ProjectsCallStatus', 'Tar.ProjectsCallStatusID = Sour.ProjectsCallStatusID', 'ProjectsCallStatusID', 'PeopleID', null, 0),
		('Positions', 'Tar.PositionsID = Sour.PositionsID', 'PositionsID', 'PeopleID', null, 0),
		('EmailAddress', 'Tar.EmailAddressID = Sour.EmailAddressID', 'EmailAddressID', 'PeopleID', null, 0),
		('ProjectsClientTeams', 'Tar.ProjectsClientTeamsID = Sour.ProjectsClientTeamsID', 'ProjectsClientTeamsID', 'PeopleID', null, 0),
		('EmailArchive', 'Tar.EmailArchiveID = Sour.EmailArchiveID', 'EmailArchiveID', 'PeopleID', null, 0),
		('InternalInterviews', 'Tar.InternalInterviewsID = Sour.InternalInterviewsID', 'InternalInterviewsID', 'PeopleID', null, 0),
		('CandidateCredentials', 'Tar.CandidateCredentialsID = Sour.CandidateCredentialsID', 'CandidateCredentialsID', 'CandidatePeopleID', null, 0),
		('CandidateReferrals', 'Tar.CandidateReferralsID = Sour.CandidateReferralsID', 'CandidateReferralsID', 'PeopleID', null, 0),
		('CandidateReferrals', 'Tar.CandidateReferralsID = Sour.CandidateReferralsID', 'CandidateReferralsID', 'SourcePeopleID', null, 0),
		('CandidateReferences', 'Tar.CandidateReferencesID = Sour.CandidateReferencesID', 'CandidateReferencesID', 'PeopleID', null, 0),
		('CandidateReferences', 'Tar.CandidateReferencesID = Sour.CandidateReferencesID', 'CandidateReferencesID', 'RefereePeopleID', null, 0),
		('PeopleAdditionalNames', 'Tar.AdditionalNamesID = Sour.AdditionalNamesID', 'AdditionalNamesID', 'PeopleID', null, 0),
		('LinkCandidatesToMPContacts', 'Tar.LinkCandidatesToMPContactsID = Sour.LinkCandidatesToMPContactsID', 'LinkCandidatesToMPContactsID', 'CandPeopleID', null, 0),
		('LinkCandidatesToMPContacts', 'Tar.LinkCandidatesToMPContactsID = Sour.LinkCandidatesToMPContactsID', 'LinkCandidatesToMPContactsID', 'ContactPeopleID', null, 0),
		('LinkPeopleToNetwork', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'LeftID', null, 0),
		('LinkPeopleToNetwork', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'RightID', null, 0),
		('JobOrderConsideredPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrderInterviewPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrderInternalInterviewPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrderPresentedPeople', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrdersSources', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID', 'PeopleID', 'PeopleID', null, 0),
		('JobOrdersTargetCompaniesCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.JobOrdersID = Sour.JobOrdersID and Tar.CompaniesID = Sour.CompaniesID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsBenchmarkCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsInternalInterviewLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsPresentedLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsSources', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsClientEmployeesLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsShortLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsTargetLists', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsFileSearchCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('LastProjectActivity', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectTargetCompaniesCandidates', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID and Tar.CompaniesID = Sour.CompaniesID', 'PeopleID', 'PeopleID', null, 0),
		('PeopleAppliedTo', 'Tar.PeopleID = Sour.PeopleID and isnull(Tar.ProjectsID, 0) = isnull(Sour.ProjectsID, 0) and isnull(Tar.JobOrdersID, 0) = isnull(Sour.JobOrdersID, 0)', 'PeopleID', 'PeopleID', null, 0),
		('LinkContactsToTask', 'Tar.PeopleID = Sour.PeopleID and Tar.TaskID = Sour.TaskID', 'PeopleID', 'PeopleID', null, 0),
		('LinkPeopleToPackage', 'Tar.PeopleID = Sour.PeopleID and Tar.PositionsID = Sour.PositionsID and Tar.PackageID = Sour.PackageID', 'PeopleID', 'PeopleID', null, 0),
		('LinkPeopleToRates', 'Tar.PeopleID = Sour.PeopleID and Tar.RateTypesID = Sour.RateTypesID', 'PeopleID', 'PeopleID', null, 0),
		('ProjectsCandidateBlocks', 'Tar.PeopleID = Sour.PeopleID and Tar.ProjectsID = Sour.ProjectsID and Tar.WorkListsID = Sour.WorkListsID', 'PeopleID', 'PeopleID', null, 0),
		('EventSessionsInvitees', 'Tar.PeopleID = Sour.PeopleID and Tar.TaskID = Sour.TaskID and Tar.EventsID = Sour.EventsID', 'PeopleID', 'PeopleID', null, 0),
		('EventSessionVendors', 'Tar.PeopleID = Sour.PeopleID and Tar.TaskID = Sour.TaskID and Tar.EventsID = Sour.EventsID', 'PeopleID', 'PeopleID', null, 0),
		('LinkCandidatesToMProjects', 'Tar.PeopleID = Sour.PeopleID and Tar.MProjectsID = Sour.MProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('LinkContactsToMProjects', 'Tar.PeopleID = Sour.PeopleID and Tar.MProjectsID = Sour.MProjectsID', 'PeopleID', 'PeopleID', null, 0),
		('LinkContactsToOpportunities', 'Tar.PeopleID = Sour.PeopleID and Tar.OpportunitiesID = Sour.OpportunitiesID', 'PeopleID', 'PeopleID', null, 0),
		('MProjectCompaniesContacts', 'Tar.PeopleID = Sour.PeopleID and Tar.MProjectsID = Sour.MProjectsID and Tar.CompaniesID = Sour.CompaniesID', 'PeopleID', 'PeopleID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'People', 0),
		('LinkObjectToDocument', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'People', 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'People', 0),
		('LinkInterviewersToClientInterview', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID', 'LeftID', 'LeftID', null, 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)
		insert into @ListItems(insTable, Fatal)
		values('ListsDetails', 0)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GrandChildren(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('LinkCredentialsToJobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.LinkPeopleToCredentialsID = Sour.LinkPeopleToCredentialsID', 'JobOrdersID', 'LinkPeopleToCredentials', 'SourParent.LinkPeopleToCredentialsID = Sour.LinkPeopleToCredentialsID', 'PeopleID', null, 0),
		('PositionDetails', 'Tar.PositionDetailsID = Sour.PositionDetailsID', 'PositionDetailsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('LinkPositionsToRates', 'Tar.PositionsID = Sour.PositionsID and Tar.RateTypesID = Sour.RateTypesID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('LinkJobOrderToWorksteps', 'Tar.PositionsID = Sour.PositionsID and isnull(Tar.WorkStepsID, 0) = isnull(Sour.WorkStepsID, 0) and isnull(Tar.JobOrdersID, 0) = isnull(Sour.JobOrdersID, 0) and isnull(Tar.AssignmentsID, 0) = isnull(Sour.AssignmentsID, 0)', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('Timesheets', 'Tar.TimesheetsID = Sour.TimesheetsID', 'TimesheetsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('PositionExpenses', 'Tar.PositionExpensesID = Sour.PositionExpensesID', 'PositionExpensesID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', null, 0),
		('UsersCommissionsSplit', 'Tar.UsersCommissionsSplitID = Sour.UsersCommissionsSplitID', 'UsersCommissionsSplitID', 'Positions', 'SourParent.PositionsID = Sour.ObjectID and Sour.Type = ''Placement''', 'PeopleID', null, 0),
		('LinkAddressToDistList', 'Tar.LinkToDistListID = Sour.LinkToDistListID', 'LinkToDistListID', 'EmailAddress', 'SourParent.EmailAddressID = Sour.EmailAddressID', 'PeopleID', null, 0),
		('LinkAddressToDistList', 'Tar.LinkToDistListID = Sour.LinkToDistListID', 'LinkToDistListID', 'EmailAddress', 'SourParent.EmailAddressID = Sour.DistListID', 'PeopleID', null, 0),
		('Interview', 'Tar.InterviewID = Sour.InterviewID', 'InterviewID', 'ProjectsClientTeams', 'SourParent.PeopleID = Sour.Interviewer and SourParent.ProjectsID = Sour.ProjectsID and Sour.Done = 0', 'PeopleID', null, 0),
		('EmailMsgRecipients', 'Tar.EmailMsgRecipientsID = Sour.EmailMsgRecipientsID', 'EmailMsgRecipientsID', 'EmailArchive', 'SourParent.EmailArchiveID = Sour.EmailArchiveID', 'PeopleID', null, 0),
		('EmailMsgAttachments', 'Tar.EmailMsgAttachmentsID = Sour.EmailMsgAttachmentsID', 'EmailMsgAttachmentsID', 'EmailArchive', 'SourParent.EmailArchiveID = Sour.EmailArchiveID', 'PeopleID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'EmailArchive', 'SourParent.EmailArchiveID = Sour.LeftID', 'PeopleID', 'EmailArchive', 0),
		('UsersCommissionsSplit', 'Tar.UsersCommissionsSplitID = Sour.UsersCommissionsSplitID', 'UsersCommissionsSplitID', 'JobOrderInterviewPeople', 'SourParent.PeopleID = Sour.PeopleID and SourParent.JobOrdersID = Sour.JobOrdersID and Sour.Type = ''Submission'' and Sour.ObjectID = 0', 'PeopleID', null, 0)
		
		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)
			
		insert into @GreatGrand(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('UsersCommissionsSplit', 'Tar.UsersCommissionsSplitID = Sour.UsersCommissionsSplitID', 'UsersCommissionsSplitID', 'Interview', 'SourParent.InterviewID = Sour.ObjectID and Sour.Type = ''Interview''', 'ProjectsClientTeams', 'SourGrand.PeopleID = SourParent.Interviewer and SourGrand.ProjectsID = SourParent.ProjectsID and SourParent.Done = 0', 'PeopleID', null, 0),
		('LinkInterviewersToClientInterview', 'Tar.LinkInterviewersToClientInterviewID = Sour.LinkInterviewersToClientInterviewID', 'LinkInterviewersToClientInterviewID', 'Interview', 'SourParent.InterviewID = Sour.RightID', 'ProjectsClientTeams', 'SourGrand.PeopleID = SourParent.Interviewer and SourGrand.ProjectsID = SourParent.ProjectsID and SourParent.Done = 0', 'PeopleID', null, 0)
		
		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		insert into @SetChildID(UpTable, TarSourJoinOn, SetIDField, Fatal)
		values('Assignments', 'Tar.AssignmentsID = Sour.AssignmentsID', 'PeopleID', 0),
		('Assignments', 'Tar.AssignmentsID = Sour.AssignmentsID', 'ContactPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'PlacedByPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'InvoiceToPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'LeadContactPeopleID', 0),
		('JobOrders', 'Tar.JobOrdersID = Sour.JobOrdersID', 'ReportsToPeopleID', 0),
		('Projects', 'Tar.ProjectsID = Sour.ProjectsID', 'BillingToPeopleID', 0)

		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(255), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
		
		insert into @SetGrandChildID(UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'PositionsID', 'Positions', 'SourParent.PositionsID = Sour.PositionsID', 'PeopleID', 0)

	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''People''')

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

	declare @GDPRSQL nvarchar(max) = '	delete GDPRLog where PeopleID = @MainRecordID'

	declare @TasksSQL nvarchar(max) = ''
	+ @nl + '	select Sour.TaskID'
	+ @nl + '	from ('
	+ @nl + '		select TaskID'
	+ @nl + '		from ' + @Sourdb + '..LinkCandidatestoMPContacts'
	+ @nl + '		where CandPeopleID = @MainRecordID'
	+ @nl + '		union select TaskID'
	+ @nl + '		from ' + @Sourdb + '..LinkCandidatesToMPContacts'
	+ @nl + '		where ContactPeopleID = @MainRecordID'
	+ @nl + '		union select TaskID'
	+ @nl + '		from ' + @Sourdb + '..InternalInterviews'
	+ @nl + '		where PeopleID = @MainRecordID'
	+ @nl + '		union select SourInterview.TaskID'
	+ @nl + '		from ' + @Sourdb + '..ProjectsClientTeams SourPCT'
	+ @nl + '		join ' + @Sourdb + '..Interview SourInterview'
	+ @nl + '			on SourInterview.Interviewer = SourPCT.PeopleID'
	+ @nl + '			and SourInterview.ProjectsID = SourPCT.ProjectsID'
	+ @nl + '			and SourInterview.Done = 0'
	+ @nl + '		where SourPCT.PeopleID = @MainRecordID'
	+ @nl + '	) Sour'
	+ @nl + '	left join ' + @Tardb + '..Task Tar'
	+ @nl + '		on Tar.TaskID = Sour.TaskID'
	+ @nl + '	where Sour.TaskID is not null'
	+ @nl + '	and Tar.TaskID is null'

	declare @AddressesSQL nvarchar(max) = ''
	+ @nl + '	select Sour.AddressesID'
	+ @nl + '	from ('
	+ @nl + '		select HomeAddressesID from ' + @Sourdb + '..People where PeopleID = @MainRecordID'
	+ @nl + '		union select BusinessAddressesID from ' + @Sourdb + '..People where PeopleID = @MainRecordID'
	+ @nl + '		union select AlternativeAddressesID from ' + @Sourdb + '..People where PeopleID = @MainRecordID'
	+ @nl + '	) Sour(AddressesID)'
	+ @nl + '	left join ' + @Tardb + '..Addresses Tar'
	+ @nl + '		on Tar.AddressesID = Sour.AddressesID'
	+ @nl + '	where Sour.AddressesID is not null'
	+ @nl + '	and Tar.AddressesID is null'

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	values('GDPRLog', @GDPRSQL, 'delete', 0),
	('Task', dbo.fn_Drew_RestoreSQL_NestedInsert(@SourDB, @TarDB, @TasksSQL, 'fn_Drew_Restore_Task_RestoreTree_t'), 'nested restore', 0),
	('Addresses', dbo.fn_Drew_RestoreSQL_NestedInsert(@SourDB, @TarDB, @AddressesSQL, 'fn_Drew_Restore_Addresses_RestoreTree_t'), 'nested restore', 0)
		
	return
end

go