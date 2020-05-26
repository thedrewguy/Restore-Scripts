
/*--------------------------------------------------------------------------------------------------------   
 When a People record is deleted, this deletes all records   
 linked to the deleted record.   
 --------------------------------------------------------------------------------------------------------*/   
CREATE TRIGGER [dbo].[PeopleDelete] ON [dbo].[People]   
FOR DELETE   
AS   
-----------------------------------------------------------------------------------------------------------   
begin   
 
 --delete internal interview?
 --profile importer tables?
 --ResumeProcessing?
 if ( (select COUNT(*) from ClientConfig where GDPRSupport =1 ) > 0 )
 begin
	IF (SELECT COUNT(*) FROM deleted where IsNull(PermissiontoRetainData,0)=0 and PermissiontoRetainDate >'01/01/2017') > 0 
		BEGIN 
		INSERT INTO GDPRLog ( PeopleID,FirstName, LastName, Phone1,Phone2,Phone3,Phone4,Phone5,EmailAddress )
		SELECT PeopleID, FirstName, LastName, Phone1,Phone2,Phone3,Phone4,Phone5,dbo.fn_GetAllEmails(deleted.PeopleID) 
		from deleted where IsNull(PermissiontoRetainData,0)=0 and PermissiontoRetainDate >'01/01/1920'
	 END 
 end
 delete from Addresses where AddressesID IN (SELECT HomeAddressesID from Deleted)   
 delete from Addresses where AddressesID IN (SELECT BusinessAddressesID from Deleted)   
 delete from Addresses where AddressesID IN (SELECT AlternativeAddressesID from Deleted)   
   
 delete from Resumes  where PeopleID IN( SELECT PeopleID FROM Deleted)  
 delete from EMailAddress where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from Notes   where PeopleID IN( SELECT PeopleID FROM Deleted)  
   
 delete from LinkObjectToActivityHistory where LeftID IN( SELECT PeopleID FROM Deleted) and ObjectTableName = 'People'   
 delete from LinkObjectToDocument   where LeftID IN( SELECT PeopleID FROM Deleted) and ObjectTableName = 'People'    
 delete from LinkObjectToTask   where LeftID IN( SELECT PeopleID FROM Deleted) and ObjectTableName = 'People'   
 delete from LinkPeopleToNetWork   where LeftID IN( SELECT PeopleID FROM Deleted)   
 delete from LinkPeopleToNetWork   where RightID IN( SELECT PeopleID FROM Deleted)  
   
 delete from LinkPeopleToSkills  where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ListsDetails   where RecordID IN( SELECT PeopleID FROM Deleted)   
         AND ListID IN ( SELECT ListsID FROM Lists WHERE SourceTable = 'People')   
   
 delete from JobOrderConsideredPeople   where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from JobOrderInterviewPeople   where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from JobOrderInternalInterviewPeople where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from JobOrderPresentedPeople   where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ProjectsClientTeams    where PeopleID IN( SELECT PeopleID FROM Deleted)   
   
 delete from ProjectsBenchmarkCandidates  where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ProjectsInternalInterviewLists  where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ProjectsPresentedLists    where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ProjectsSources     where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ProjectsClientEmployeesLists  where PeopleID IN( SELECT PeopleID FROM Deleted)   
   
 delete from ProjectsShortLists     where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ProjectsTargetLists    where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ProjectTargetCompaniesCandidates where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ProjectsFileSearchCandidates  where PeopleID IN( SELECT PeopleID FROM Deleted)   
 
 delete from Affiliates where PeopleID IN( SELECT PeopleID FROM Deleted)
 delete from CandidateCredentials where CandidatePeopleID IN( SELECT PeopleID FROM Deleted)
 
 delete from JobOrdersTargetCompaniesCandidates where PeopleID IN (SELECT PeopleID FROM Deleted)   
 delete from JobOrdersSources     where PeopleID IN (SELECT PeopleID FROM Deleted)   
   
 delete from CandidateReferrals  where PeopleID IN( SELECT PeopleID FROM Deleted) or SourcePeopleID IN( SELECT PeopleID FROM Deleted)
 delete from CandidateReferences where PeopleID IN( SELECT PeopleID FROM Deleted) or RefereePeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from PeopleAppliedTo  where PeopleID IN( SELECT PeopleID FROM Deleted)   
   
 delete from LinkContactsToTask  where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from CandidateCredentials where CandidatePeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from Education    where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from EMailArchive   where PeopleID IN( SELECT PeopleID FROM Deleted) AND CompaniesID IS NULL   
 delete from LinkPeopleToPackage where PeopleID IN( SELECT PeopleID FROM Deleted)   
   
 delete from PeopleAvailability   where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from LinkPeopleToRates   where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from LinkPeopleToCredentials where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from LinkPeopleToCompanies  where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from LastProjectActivity  where PeopleID IN( SELECT PeopleID FROM Deleted)   
 delete from ProjectsCandidateBlocks where PeopleID IN( SELECT PeopleID FROM Deleted)  
 
 delete from EventSessionsInvitees where PeopleID IN( SELECT PeopleID FROM Deleted)  
 delete from EventSessionVendors where PeopleID IN( SELECT PeopleID FROM Deleted)  
 delete from JobOrderClientTeams where PeopleID IN( SELECT PeopleID FROM Deleted)  
 delete from LinkCandidatesToMPContacts where CandPeopleID IN( SELECT PeopleID FROM Deleted)   or ContactPeopleID IN( SELECT PeopleID FROM Deleted)  
 delete from LinkCandidatesToMProjects where PeopleID IN( SELECT PeopleID FROM Deleted)  
 delete from LinkContactsToMProjects where PeopleID IN( SELECT PeopleID FROM Deleted)    
 
 delete from LinkContactsToOpportunities where PeopleID IN( SELECT PeopleID FROM Deleted)    
 delete from LinkPeopleToKnownToUsers where PeopleID IN( SELECT PeopleID FROM Deleted)    
 delete from MProjectCompaniesContacts where PeopleID IN( SELECT PeopleID FROM Deleted)    
 delete from PeopleAdditionalNames where PeopleID IN( SELECT PeopleID FROM Deleted)    
 delete from ProjectsCallStatus where PeopleID IN( SELECT PeopleID FROM Deleted)     
  
 update Assignments set PeopleID = NULL    where PeopleID IN( SELECT PeopleID FROM Deleted)   
 update Assignments set ContactPeopleID = NULL  where ContactPeopleID IN( SELECT PeopleID FROM Deleted)   
 update JobOrders set PlacedByPeopleID = NULL  where PlacedByPeopleID IN( SELECT PeopleID FROM Deleted)   
 update JobOrders set InvoiceToPeopleID = NULL  where InvoiceToPeopleID IN( SELECT PeopleID FROM Deleted)   
 update JobOrders set LeadContactPeopleID = NULL where LeadContactPeopleID IN( SELECT PeopleID FROM Deleted)   
   
 update JobOrders set ReportsToPeopleID = NULL  where ReportsToPeopleID IN( SELECT PeopleID FROM Deleted)   
 update Projects set BillingToPeopleID = NULL  where BillingToPeopleID IN( SELECT PeopleID FROM Deleted)   
 
 
 delete Positions 
 FROM Positions
 LEFT JOIN Projects
	ON Projects.ProjectsID = Positions.ProjectsID
 LEFT JOIN Joborders
	ON JobOrders.JobOrdersID = Positions.JobOrdersID
 where Positions.PeopleID IN( SELECT PeopleID FROM Deleted)  
 AND Projects.ProjectsID IS NULL
 AND JobOrders.JobOrdersID IS NULL
 
end   

