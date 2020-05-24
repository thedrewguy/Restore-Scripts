/*
	require:
	sp_drew_tr
*/

if object_id('sp_Drew_TableInfo') is not null
	drop proc sp_Drew_TableInfo
go

create proc sp_Drew_TableInfo(@TableName varchar(255))
as

--triggers
	exec sp_Drew_tr @TableName

--preview
	DECLARE @PreviewSQL nvarchar(max) = 'SELECT TOP 1 * FROM ' + @TableName
	EXEC sp_executesql @PreviewSQL

--UNIQUE/PK columns
	SELECT Col.Constraint_Name, UniqueColumnName = Col.Column_Name
	from INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, 
	INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col 
	WHERE Col.Constraint_Name = Tab.Constraint_Name
	AND Col.Table_Name = Tab.Table_Name
	AND Constraint_Type IN('PRIMARY KEY', 'UNIQUE')
	AND Col.Table_Name = @TableName
go

--test
DECLARE @TableName varchar(255) = 'LinkOpportunitiesToBusinessObjects'
exec sp_Drew_TableInfo @TableName = @TableName
