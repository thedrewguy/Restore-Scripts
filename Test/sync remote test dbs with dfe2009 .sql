declare @filepath nvarchar(4000) = N'E:\Databases\DFERestoreSource\DFE2009Copy_'+cast(cast(getdate() as date) as varchar(31)) + '.bak'

BACKUP DATABASE DFE2009 
TO  DISK = @filepath
WITH NOFORMAT, NOINIT,  NAME = N'Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

declare @filepath nvarchar(4000) = N'E:\Databases\DFERestoreSource\DFE2009Copy_'+cast(cast(getdate() as date) as varchar(31)) + '.bak'

restore database DFERestoreSource
from disk = @filepath
with
	file = 1,
	move 'DFES_Data' to 'E:\Databases\DFERestoreSource\DFERestoreSource.mdf',
	move 'DFES_Log' to 'E:\Databases\DFERestoreSource\DFERestoreSource_log.ldf',
	nounload, replace, stats = 5
go


declare @filepath nvarchar(4000) = N'E:\Databases\DFERestoreSource\DFE2009Copy_'+cast(cast(getdate() as date) as varchar(31)) + '.bak'

restore database DFERestoreTarget
from disk = @filepath
with
	file = 1,
	move 'DFES_Data' to 'E:\Databases\DFERestoreTarget\DFERestoreTarget.mdf',
	move 'DFES_Log' to 'E:\Databases\DFERestoreTarget\DFERestoreTarget_log.ldf',
	nounload, replace, stats = 5
go

