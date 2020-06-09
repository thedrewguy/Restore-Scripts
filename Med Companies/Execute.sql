
set ansi_nulls on
go
set quoted_identifier on
go

/*=================================================
	SET THESE THREE PARAMETER VALUES THEN RUN
=================================================*/

DECLARE @CompaniesID int = 5641

--use [dbname] or servername.[dbname] for linked servers
DECLARE @SourceDBPath nvarchar(255) = '[MedSource]'
DECLARE @TargetDBPath nvarchar(255) = '[MedTarget]'




set nocount on

--generate restore tree

declare @RestoreTree Drew_RestoreTree
insert into @RestoreTree(TableName, Operation, RestoreSQL, Fatal)
select TableName, Operation, RestoreSQL, Fatal
from dbo.fn_Drew_Restore_MedCompanies_RestoreTree_t(@SourceDBPath, @TargetDBPath)

--execute restore

exec sp_Drew_RestoreItem @SourDB = @SourceDBPath, @TarDB = @TargetDBPath, @RestoreTree = @RestoreTree, @MainRecordID = @CompaniesID, @NestLevel = 1
