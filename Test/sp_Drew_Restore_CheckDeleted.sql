BEGIN TRY DROP PROC sp_Drew_Restore_CheckDeleted END TRY BEGIN CATCH END CATCH
GO

CREATE PROC sp_Drew_Restore_CheckDeleted(@SourceDBName nvarchar(255), @TargetDBName nvarchar(255), @TableName nvarchar(255), @MainRecordID int, @WhereClause nvarchar(max), @Message nvarchar(max) output)
AS
	DECLARE @SQL nvarchar(max), @ParamDef nvarchar(max)
	DECLARE @NumInSource int = 0, @NumInTarget int = 0

	SET @SQL = REPLACE('SET @NumInSource = (SELECT COUNT(1) FROM ' + @SourceDBName + '..' + @TableName + ' ' + @WhereClause + ')', '<DB>', @SourceDBName)
	+ REPLACE(CHAR(10) + 'SET @NumInTarget = (SELECT COUNT(1) FROM ' + @TargetDBName + '..' + @TableName + ' ' + @WhereClause + ')', '<DB>', @TargetDBName)
	
	SET @ParamDef = '@MainRecordID int, @NumInSource int output, @NumInTarget int output'
	exec sp_executesql @SQL, @ParamDef, @MainRecordID = @MainRecordID, @NumInSource = @NumInSource output, @NumInTarget = @NumInTarget output

	if @NumInSource = 0
		set @Message = 'FAIL - No records to delete - ' + @TableName
	else --@NumInSource > 0
		begin
		if @NumInTarget > 0
			set @Message = 'FAIL - record deletion not triggered - ' + @TableName
		else
			set @Message = 'PASS - records deleted - ' + @TableName
		end
	print @Message
GO

DECLARE @DiffMessage nvarchar(max)
exec sp_Drew_Restore_CheckDeleted @SourceDBName = 'DFESource', @TargetDBName = 'DFETarget', @TableName = 'CompaniesIndustry', @WhereClause = 'WHERE CompaniesID = @MainRecordID', @MainRecordID = 26325, @Message = @DiffMessage output