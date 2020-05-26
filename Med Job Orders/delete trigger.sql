  
  
CREATE                   TRIGGER JobOrdersDelete ON dbo.JobOrders  
FOR DELETE  
AS  
-----------------------------------------------------------------------------------------------------------  
declare @JobOrdersID         int  
  
declare Row cursor local  for  
     select   JobOrdersID  
     from   
         deleted  
-----------------------------------------------------------------------------------------------------------  
  
open Row  
  
fetch next from Row into @JobOrdersID  
  
while @@fetch_status = 0  
    begin  
  
         delete from Interview                                where JobOrdersID =  @JobOrdersID  
         delete from JobOrderConsideredPeople        where JobOrdersID =  @JobOrdersID  
         delete from JobOrderPresentedPeople          where JobOrdersID =  @JobOrdersID  
         delete from JobOrderInterviewPeople            where JobOrdersID =  @JobOrdersID  
         delete from JobOrderInternalInterviewPeople  where JobOrdersID =  @JobOrdersID  
         delete from PeopleAppliedTo                    where JobOrdersID =  @JobOrdersID  
         delete from LinkObjectToActivityHistory        where LeftID = @JobOrdersID and ObjectTableName = 'JobOrders'  
         delete from LinkObjectToDocument              where LeftID = @JobOrdersID and ObjectTableName = 'JobOrders'  
         delete from CandidateReferrals             where JobOrdersID = @JobOrdersID   
         delete from JobRequirements             where JobOrdersID = @JobOrdersID  
         delete from WebJobPostings                     where JobOrdersID = @JobOrdersID  
         delete from TimeSheets                         where JobOrdersID = @JobOrdersID  
         delete from Assignments                        where JobOrdersID = @JobOrdersID  
         delete from LinkAddressToMCRContract           where JobOrdersID = @JobOrdersID   
         delete from LinkJobOrdersToRates       where JobOrdersID = @JobOrdersID  
         delete from JobOrderSchedule              where JobOrdersID = @JobOrdersID  
         delete from JobOrderClientTeams          where JobOrdersID = @JobOrdersID  
         delete from JobOrderTeams                   where JobOrdersID = @JobOrdersID  
         delete from LinkJobOrderToWorksteps       where JobOrdersID = @JobOrdersID  
         delete from LinkObjectToTask          where LeftID = @JobOrdersID and ObjectTableName = 'JobOrders'  
         delete from Positions                          where JobOrdersID = @JobOrdersID  
         delete from ListsDetails    where RecordID = @JobOrdersID AND ListID IN   
        ( SELECT ListsID FROM Lists WHERE SourceTable = 'MRContracts' OR SourceTable = 'Temp' OR SourceTable = 'PermOrders' OR  
 SourceTable='Contracts')  
         delete from LinkOpportunitiesToBusinessObjects where JobOrdersID = @JobOrdersID  
         delete from LinkEventsToBusinessObjects where JobOrdersID = @JobOrdersID  
         update Task SET JobOrdersID = NULL   where JobOrdersID = @JobOrdersID  
         update WebRequests SET JobOrdersID = NULL  where JobOrdersID = @JobOrdersID  
         fetch next from Row into @JobOrdersID  
  
    end  
            
close       Row  
deallocate  Row  
  