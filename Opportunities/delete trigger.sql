SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[OpportunitiesDelete] ON [dbo].[Opportunities]   
FOR DELETE   
AS  
-----------------------------------------------------------------------------------------------------------
delete from OpportunityTeams where OpportunitiesID IN(SELECT OpportunitiesID FROM deleted)
delete from LinkContactsToOpportunities where OpportunitiesID IN(SELECT OpportunitiesID FROM deleted)
delete from LinkCompaniesToOpportunities where OpportunitiesID IN(SELECT OpportunitiesID FROM deleted)
delete from LinkEventsToBusinessObjects where OpportunitiesID IN(SELECT OpportunitiesID FROM deleted)
delete from LinkOpportunitiesToBusinessObjects where OpportunitiesID IN(SELECT OpportunitiesID FROM deleted)
delete from JobRequirements where OpportunitiesID IN(SELECT OpportunitiesID FROM deleted)

delete from LinkObjectToActivityHistory where LeftID IN(SELECT OpportunitiesID FROM deleted) and ObjectTableName = 'Opportunities'
delete from LinkObjectToDocument where LeftID IN(SELECT OpportunitiesID FROM deleted) and ObjectTableName = 'Opportunities'
delete from LinkObjectToTask where LeftID IN(SELECT OpportunitiesID FROM deleted) and ObjectTableName = 'Opportunities'

update Task set OpportunitiesID = NULL  where OpportunitiesID IN(SELECT OpportunitiesID FROM deleted)


