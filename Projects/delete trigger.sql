
CREATE TRIGGER [dbo].[ProjectOnDelete] ON [dbo].[Projects]    
FOR DELETE    
AS    
-----------------------------------------------------------------------------------------------------------
delete ProjectsCallStatus where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectBillingDetails where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectInvoices where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsBenchmarkCandidates where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsClientEmployeesLists where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsClientTeams where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsCompaniesLists where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsFileSearchCandidates where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsInternalInterviewLists where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsPresentedLists where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsShortLists where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete CandidateReferrals where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsSources where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsTargetLists where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsTeam where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete PeopleAppliedTo where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete LinkMediaToProject where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectStages where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete JobRequirements where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete InternalInterviews where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete WebJobPostings where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete LinkOpportunitiesToBusinessObjects where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete LinkEventsToBusinessObjects where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsAccounting where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete LastProjectActivity where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectsCandidateBlocks where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete Affiliates where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete CandidateCredentials where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete InternalInterviews where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete Interview where ProjectsID IN(SELECT ProjectsID FROM deleted)
delete ProjectStages where ProjectsID IN(SELECT ProjectsID FROM deleted)

delete LinkObjectToActivityHistory where LeftID IN(SELECT ProjectsID FROM deleted) AND ObjectTableName = 'Projects'
delete LinkObjectToDocument where LeftID IN(SELECT ProjectsID FROM deleted) AND ObjectTableName = 'Projects'
delete LinkObjectToTask where LeftID IN(SELECT ProjectsID FROM deleted) AND ObjectTableName = 'Projects'

delete ListsDetails where RecordID IN(SELECT ProjectsID FROM deleted) AND ListID IN ( SELECT ListsID FROM Lists WHERE SourceTable = 'Projects')

update People SET CandidateBlockStatus = NULL, CandidateBlockProjectsID = NULL  
      WHERE CandidateBlockProjectsID IN(SELECT ProjectsID FROM deleted)
update Task SET ProjectsID = NULL where ProjectsID IN(SELECT ProjectsID FROM deleted)
update WebRequests SET ProjectsID = NULL where ProjectsID IN(SELECT ProjectsID FROM deleted)



GO

ALTER TABLE [dbo].[Projects] ENABLE TRIGGER [ProjectOnDelete]
GO


