/*
	INSTRUCTIONS:

	1. Make sure the source database is upgraded to the same Deskflow version as the target database
	2. Open the script "01 People Pre-Restore.sql" under the Target database (which you are restoring to) and run it
	3. Open the script "02 Restore Person from Backup" in the target database
	4. Set the three variables PeopleID, SourceDBPath and TargetDBPath
	5. Run
	
	ABOUT:
	
	Script updated for standard Deskflow build 2209 (by Drew)
	This script should be updated:
		- when a DELETE trigger is added or changed
*/

set ansi_nulls on
go
set quoted_identifier on
go

/*=================================================
	SET THESE THREE PARAMETER VALUES THEN RUN
=================================================*/

DECLARE @PeopleID int = 9404017

--use [dbname] or servername.[dbname] for linked servers
DECLARE @SourceDBPath nvarchar(255) = '[MedSource]'
DECLARE @TargetDBPath nvarchar(255) = '[MedTarget]'




set nocount on

--generate restore tree

declare @RestoreTree Drew_RestoreTree
insert into @RestoreTree(TableName, Operation, RestoreSQL, Fatal)
select TableName, Operation, RestoreSQL, Fatal
from dbo.fn_Drew_Restore_MedPeople_RestoreTree_t(@SourceDBPath, @TargetDBPath)

--execute restore

exec sp_Drew_RestoreItem @SourDB = @SourceDBPath, @TarDB = @TargetDBPath, @RestoreTree = @RestoreTree, @MainRecordID = @PeopleID, @NestLevel = 1
