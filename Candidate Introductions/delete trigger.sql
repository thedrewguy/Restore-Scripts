
CREATE TRIGGER [dbo].[MProjectsDelete] ON [dbo].[MProjects]   
FOR DELETE   
AS
-----------------------------------------------------------------------------------------------------------  
DELETE FROM LinkCandidatesToMProjects WHERE MProjectsID IN(SELECT MProjectsID FROM deleted)
DELETE FROM LinkCandidatesToMPContacts WHERE MProjectsID IN(SELECT MProjectsID FROM deleted)
DELETE FROM LinkEventsToBusinessObjects WHERE MProjectsID IN(SELECT MProjectsID FROM deleted)
DELETE FROM LinkContactsToMProjects WHERE MProjectsID IN(SELECT MProjectsID FROM deleted)
DELETE FROM MProjectCompaniesLists WHERE MProjectsID IN(SELECT MProjectsID FROM deleted)

UPDATE LinkPeopleToCompanies SET MProjectsID = NULL WHERE MProjectsID IN(SELECT MProjectsID FROM deleted)
update Task set MProjectsID = NULL where MProjectsID IN(SELECT MProjectsID FROM deleted)

delete from LinkObjectToActivityHistory where LeftID IN(SELECT MProjectsID FROM deleted) and ObjectTableName = 'MProjects'
delete from LinkObjectToDocument where LeftID IN(SELECT MProjectsID FROM deleted) and ObjectTableName = 'MProjects'
delete LinkObjectToTask where LeftID IN(SELECT MProjectsID FROM deleted) AND ObjectTableName = 'MProjects'



GO
