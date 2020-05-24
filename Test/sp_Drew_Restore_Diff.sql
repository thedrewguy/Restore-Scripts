BEGIN TRY DROP PROC sp_Drew_Restore_Diff END TRY BEGIN CATCH END CATCH
GO

CREATE PROC sp_Drew_Restore_Diff(@SourceDBName nvarchar(255), @TargetDBName nvarchar(255), @TableName nvarchar(255), @WhereClause nvarchar(max), @MainRecordID int)
AS
	DECLARE @ComparableColumnList nvarchar(max)
	DECLARE @ColListSQL nvarchar(max) = 'SET @ColList = ISNULL(STUFF(
		(	select '', '' + COLUMN_NAME
			from ' + @TargetDBName + '.INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = ''' + @TableName + '''
			AND DATA_TYPE NOT IN(''timestamp'', ''text'', ''image'', ''ntext'')
			AND COLUMN_NAME NOT IN(''UpdatedOn'', ''UpdatedBy'', ''CreatedOn'', ''CreatedBy'')
			AND COLUMN_NAME NOT LIKE ''UTC%''
			AND COLUMNPROPERTY(OBJECT_ID(TABLE_NAME), COLUMN_NAME, ''IsIdentity'') = 0
			FOR XML PATH(''''), ROOT(''a''), TYPE
		).value(''a[1]'', ''nvarchar(max)'')
		, 1, 2, ''''
	), '''')'
	exec sp_executesql @ColListSQL, N'@ColList nvarchar(max) output', @ColList = @ComparableColumnList OUTPUT

	DECLARE @DiffSQL nvarchar(max) = '
	SELECT * INTO Drew_Diff
	FROM('
	+ REPLACE('
		SELECT dbname = '''+@SourceDBName+''', *
		FROM(
			SELECT '+@ComparableColumnList+'
			FROM '+@SourceDBName+'..'+@TableName+'
			'+@WhereClause+'
			EXCEPT SELECT '+@ComparableColumnList+'
			FROM '+@TargetDBName+'..'+@TableName+'
			'+@WhereClause+'
		) SourceHas', '<DB>', @SourceDBName
		)
		+ REPLACE('
		UNION ALL
		SELECT dbname = '''+@TargetDBName+''', *
		FROM(
			SELECT '+@ComparableColumnList+'
			FROM '+@TargetDBName+'..'+@TableName+'
			'+@WhereClause+'
			EXCEPT SELECT '+@ComparableColumnList+'
			FROM '+@SourceDBName+'..'+@TableName+'
			'+@WhereClause+'
		) TargetHas', '<DB>', @TargetDBName
		)
		+ '
	) Diff
	'

	declare @parmdef nvarchar(max) = '@MainRecordID int'
	exec sp_executesql @DiffSQL, @parmdef, @MainRecordID = @MainRecordID
GO




BEGIN TRY DROP TABLE Drew_Diff END TRY BEGIN CATCH END CATCH
GO


sp_Drew_Restore_Diff @SourceDBName = 'DFESource', @TargetDBName = 'DFETarget', @TableName = 'Companies', @WhereClause = 'WHERE CompaniesID = @MainRecordID', @MainRecordID = 26325
SELECT * FROM Drew_Diff
DROP TABLE Drew_Diff

exec sp_Drew_Restore_Diff @SourceDBName = 'DFESource', @TargetDBName = 'DFETarget', @TableName = 'Addresses', @WhereClause = 'WHERE CompaniesID = @MainRecordID', @MainRecordID = 26325
SELECT * FROM Drew_Diff
DROP TABLE Drew_Diff