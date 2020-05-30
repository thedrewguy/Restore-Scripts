
set ansi_nulls on
go
set quoted_identifier on
go

/*=================================================
	SET THESE THREE PARAMETER VALUES THEN RUN
=================================================*/

DECLARE @ProjectsID int = 6407

--use [dbname] or servername.[dbname] for linked servers
DECLARE @SourceDBPath nvarchar(255) = '[DFESource]'
DECLARE @TargetDBPath nvarchar(255) = '[DFETarget]'

set nocount on

declare @RestoreTree Drew_RestoreTree
insert into @RestoreTree(TableName, Operation, RestoreSQL, Fatal)
select TableName, Operation, RestoreSQL, Fatal
from dbo.fn_Drew_Restore_Projects_RestoreTree_t(@SourceDBPath, @TargetDBPath)

--select * from @RestoreTree
declare @RestoreSQL nvarchar(max) = (
	select  RestoreSQL from @RestoreTree where TableName = 'webjobpostings'for xml path(''), root('a'), type
).value('a[1]', 'varchar(max)')
print @RestoreSQL
--exec sp_Drew_RestoreItem @SourDB = @SourceDBPath, @TarDB = @TargetDBPath, @RestoreTree = @RestoreTree, @MainRecordID = @ProjectsID, @NestLevel = 1