BEGIN TRY DROP PROC sp_Drew_Restore_CheckIdentical END TRY BEGIN CATCH END CATCH
GO

CREATE PROC sp_Drew_Restore_CheckIdentical(@SourceDBName nvarchar(255), @TargetDBName nvarchar(255), @TableName nvarchar(255), @WhereClause nvarchar(max), @MainRecordID int, @Message nvarchar(max) output)
AS
	exec sp_Drew_Restore_Diff @SourceDBName = @SourceDBName, @TargetDBName = @TargetDBName, @TableName = @TableName, @WhereClause = @WhereClause, @MainRecordID = @MainRecordID

	declare @SQL nvarchar(max) = '
	DECLARE @NumDiff int
	SET @NumDiff = (SELECT COUNT(1) FROM Drew_Diff)

	if @NumDiff = 0
		set @Message = ''PASS - Records Identical - '' + ''' + @TableName + '''
	else
		set @Message = ''FAIL - Difference in '' + cast(@NumDiff as nvarchar(max)) + '' records - '' + ''' + @TableName + '''

	DROP TABLE Drew_Diff
	'

	declare @parmdef nvarchar(max) = '@Message nvarchar(max) output'

	exec sp_executesql @SQL, @parmdef, @Message = @Message output

	print @Message
GO

DECLARE @DiffMessage nvarchar(max)
exec sp_Drew_Restore_CheckIdentical @SourceDBName = 'DFESource', @TargetDBName = 'DFETarget', @TableName = 'Companies', @WhereClause = 'WHERE CompaniesID = @MainRecordID', @MainRecordID = 26325, @Message = @DiffMessage output



--DROP TABLE Drew_Diff