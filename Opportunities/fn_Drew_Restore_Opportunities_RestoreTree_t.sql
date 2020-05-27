/* require:
	fn_Drew_RestoreSQL_ChildInsert
	fn_Drew_RestoreSQL_GrandchildInsert
	fn_Drew_RestoreSQL_GreatGrandInsert
	fn_Drew_RestoreSQL_ListItemInsert
	fn_Drew_RestoreSQL_ChildSetID
	fn_Drew_RestoreSQL_GrandChildSetID
	fn_Drew_RestoreSQL_Wrap
*/


if object_id('fn_Drew_Restore_Opportunities_RestoreTree_t') is not null
	drop function fn_Drew_Restore_Opportunities_RestoreTree_t
go

create function fn_Drew_Restore_Opportunities_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(4000) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('Opportunities', 'Tar.OpportunitiesID = Sour.OpportunitiesID', 'OpportunitiesID', 'OpportunitiesID', null, 1),

		('OpportunityTeams', 'Tar.OpportunityTeamsID = Sour.OpportunityTeamsID', 'OpportunityTeamsID', 'OpportunitiesID', null, 0),
		('LinkContactsToOpportunities', 'Tar.OpportunitiesID = Sour.OpportunitiesID and Tar.PeopleID = Sour.PeopleID', 'OpportunitiesID', 'OpportunitiesID', null, 0),
		('LinkCompaniesToOpportunities', 'Tar.OpportunitiesID = Sour.OpportunitiesID and Tar.CompaniesID = Sour.CompaniesID', 'OpportunitiesID', 'OpportunitiesID', null, 0),
		('LinkEventsToBusinessObjects', 'Tar.LinkEventToObjectsID = Sour.LinkEventToObjectsID', 'LinkEventToObjectsID', 'OpportunitiesID', null, 0),
		('LinkOpportunitiesToBusinessObjects', 'Tar.OpportunitiesID = Sour.OpportunitiesID and isnull(Tar.ProjectsID, 0) = isnull(Sour.ProjectsID, 0) and isnull(Tar.JobOrdersID, 0) = isnull(Sour.JobOrdersID, 0) and isnull(Tar.NewOpportunitiesID, 0) = isnull(Sour.NewOpportunitiesID, 0) and isnull(Tar.ObjectName, '''') = isnull(Sour.ObjectName, '''')', 'OpportunitiesID', 'OpportunitiesID', null, 0),
		('JobRequirements', 'Tar.JobRequirementsID = Sour.JobRequirementsID', 'JobRequirementsID', 'OpportunitiesID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Opportunities', 0),
		('LinkObjectToDocument', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Opportunities', 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Opportunities', 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, insTarSourJoinOn varchar(4000) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, insTarSourJoinOn varchar(4000) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(4000), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
		insert into @SetChildID(UpTable, TarSourJoinOn, SetIDField, Fatal)
		values('Task', 'Tar.TaskID = Sour.TaskID', 'OpportunitiesID', 0)

		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(4000), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(4000), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''MRContracts'', ''PermOrders'', ''Temp'', ''Contracts''')

	update @GrandChildren
	set insertSQL = dbo.fn_Drew_RestoreSQL_GrandchildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName)

	update @GreatGrand
	set insertSQL = dbo.fn_Drew_RestoreSQL_GreatGrandInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, GrandTable, ParentGrandJoinOn, MainLinkField, ObjectTableName)

	update @SetChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_ChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField)

	update @SetGrandChildID
	set UpdateSQL = dbo.fn_Drew_RestoreSQL_GrandChildSetID(@Sourdb, @Tardb, UpTable, TarSourJoinOn, SetIDField, ParentTable, SourParentJoinOn, MainLinkField)

	--populate full restore tree with bulk-generated items
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @ListItems

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GrandChildren

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GreatGrand

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetChildID

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select UpTable, UpdateSQL, 'Update', Fatal
	from @SetGrandChildID

	return
end