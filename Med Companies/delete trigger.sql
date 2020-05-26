  
/*--------------------------------------------------------------------------------------------------------  
    When a Companies record is deleted, this deletes all records  
    linked to the deleted record.  
   --------------------------------------------------------------------------------------------------------*/  
CREATE                    TRIGGER [dbo].[CompaniesDelete] ON [dbo].[Companies]  
FOR DELETE  
AS  
-----------------------------------------------------------------------------------------------------------  
declare @CompaniesID         int  
  
declare Row cursor local  for  
     select   CompaniesID  
     from   
         deleted  
-----------------------------------------------------------------------------------------------------------  
  
open Row  
  
fetch next from Row into @CompaniesID  
  
while @@fetch_status = 0  
    begin  
  
         delete from Addresses    where CompaniesID =  @CompaniesID  
         delete from CompaniesIndustry   where CompaniesID =  @CompaniesID  
         delete from CompaniesAliases            where CompaniesID =  @CompaniesID  
         delete from LinkCompaniesToRates           where CompaniesID =  @CompaniesID  
         delete from EMailAddress    where CompaniesID = @CompaniesID  
         delete from LinkObjectToActivityHistory where LeftID = @CompaniesID and ObjectTableName = 'Companies'  
         delete from LinkObjectToDocument   where LeftID = @CompaniesID and ObjectTableName = 'Companies'  
         delete from LinkCompaniesToAttributes  where CompaniesID= @CompaniesID   
         delete from ClientContactTeams   where CompaniesID= @CompaniesID  
         delete from LinkPeopleToCompanies  where CompaniesID= @CompaniesID  
         delete from LinkCompaniesToOpportunities where CompaniesID= @CompaniesID  
  delete from ProjectsCompaniesLists             where CompaniesID= @CompaniesID  
         delete from LinkObjectToTask          where LeftID = @CompaniesID and ObjectTableName = 'Companies'  
         delete from LinkCompanyToCompanies  where CompaniesID = @CompaniesID or LinkedCompaniesID = @CompaniesID  
  delete from ListsDetails  where RecordID IN( SELECT CompaniesID FROM Deleted)  
        AND ListID IN ( SELECT ListsID FROM Lists WHERE SourceTable = 'Companies')  
      
   
         fetch next from Row into @CompaniesID  
  
    end  
            
close            Row  
deallocate  Row  
  
  