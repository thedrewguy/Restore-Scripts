if object_id('sp_Drew_Restore_TableInfo') is not null
	drop proc sp_Drew_Restore_TableInfo
go

create proc sp_Drew_Restore_TableInfo(@TableName varchar(255))
as

--delete triggers

select TableName = ta.name, TriggerName = tr.name, TriggerOn = trigOn.things, TriggerDef = trigDef.value
from sys.tables ta
left join (
	sys.triggers tr
	join sys.trigger_events ev
		on ev.object_id = tr.object_id
		and ev.type_desc = 'DELETE'
)
	on tr.parent_id = ta.object_id
outer apply(
	SELECT STUFF(
		(
			SELECT ', ' + type_desc
			FROM sys.trigger_events ev
			WHERE ev.object_id = tr.object_id
			FOR XML PATH('')
		), 1, 2, ''
	)
) trigOn(things)
outer apply(
	select m.definition
	from sys.sql_modules m
	where m.object_id = tr.object_id
	for xml path(''), type
) trigDef(value)
where ta.name = @TableName

--UNIQUE/PK columns

SELECT Col.Constraint_Name, UniqueColumnName = Col.Column_Name
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, 
INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col 
WHERE Col.Constraint_Name = Tab.Constraint_Name
AND Col.Table_Name = Tab.Table_Name
AND Constraint_Type IN('PRIMARY KEY', 'UNIQUE')
AND Col.Table_Name = @TableName

--preview

DECLARE @PreviewSQL nvarchar(max) = 'SELECT TOP 1 * FROM ' + @TableName
EXEC sp_executesql @PreviewSQL

go




--test

sp_drew_Restore_TableInfo 'Projects'