declare @BackupFilepath nvarchar(4000) = N'C:\Backups\DFEDrew_20190821_2087.bak'

BACKUP DATABASE DFEDREW 
TO  DISK = @BackupFilepath
WITH NOFORMAT, NOINIT,  NAME = N'Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
declare @BackupFilepath nvarchar(4000) = N'C:\Backups\DFEDrew_20190821_2087.bak'

restore database DFESource
from disk = @BackupFilepath
with
	file = 1,
	move 'DFES_Data' to 'C:\Databases\DFESource.mdf',
	move 'DFES_Log' to 'C:\Databases\DFESource_log.ldf',
	nounload, replace, stats = 5
go

declare @BackupFilepath nvarchar(4000) = N'C:\Backups\DFEDrew_20190821_2087.bak'

restore database DFETarget
from disk = @BackupFilepath
with
	file = 1,
	move 'DFES_Data' to 'C:\Databases\DFETarget.mdf',
	move 'DFES_Log' to 'C:\Databases\DFETarget_log.ldf',
	nounload, replace, stats = 5
go

