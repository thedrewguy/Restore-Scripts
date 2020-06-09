
set ansi_nulls on
go
set quoted_identifier on
go

/*=================================================
	SET THESE THREE PARAMETER VALUES THEN RUN
=================================================*/


--use [dbname] or servername.[dbname] for linked servers
DECLARE @SourceDBPath nvarchar(255) = '[DFESource]'
DECLARE @TargetDBPath nvarchar(255) = '[DFETarget]'

set nocount on

declare @RestoreTree Drew_RestoreTree
insert into @RestoreTree(TableName, Operation, RestoreSQL, Fatal)
select TableName, Operation, RestoreSQL, Fatal
from dbo.fn_Drew_Restore_Companies_RestoreTree_t(@SourceDBPath, @TargetDBPath)

--select * from @RestoreTree
declare @RestoreSQL nvarchar(max) = (
	select  RestoreSQL from @RestoreTree where TableName = 'projectscallstatus' for xml path(''), root('a'), type
).value('a[1]', 'varchar(max)')
print @RestoreSQL
