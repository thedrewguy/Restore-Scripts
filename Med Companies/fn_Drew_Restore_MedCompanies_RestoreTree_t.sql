/* require:
	fn_Drew_RestoreSQL_ChildInsert
	fn_Drew_RestoreSQL_GrandchildInsert
	fn_Drew_RestoreSQL_GreatGrandInsert
	fn_Drew_RestoreSQL_ListItemInsert
	fn_Drew_RestoreSQL_ChildSetID
	fn_Drew_RestoreSQL_GrandChildSetID
	fn_Drew_RestoreSQL_Wrap
*/


if object_id('fn_Drew_Restore_MedCompanies_RestoreTree_t') is not null
	drop function fn_Drew_Restore_MedCompanies_RestoreTree_t
go

create function fn_Drew_Restore_MedCompanies_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('Companies', 'Tar.CompaniesID = Sour.CompaniesID', 'CompaniesID', 'CompaniesID', null, 1),
		('CompaniesIndustry', 'Tar.CompanyIndustriesID = Sour.CompanyIndustriesID', 'CompanyIndustriesID', 'CompaniesID', null, 0),
		('LinkCompaniesToRates', 'Tar.CompaniesID = Sour.CompaniesID and Tar.RateTypesID = Sour.RateTypesID', 'CompaniesID', 'CompaniesID', null, 0),
		('LinkCompaniesToOpportunities', 'Tar.CompaniesID = Sour.CompaniesID and Tar.OpportunitiesID = Sour.OpportunitiesID', 'CompaniesID', 'CompaniesID', null, 0),
		('LinkCompanyToCompanies', 'Tar.CompaniesID = Sour.CompaniesID and Tar.LinkedCompaniesID = Sour.LinkedCompaniesID', 'CompaniesID', 'CompaniesID', null, 0),
		('LinkCompaniesToAttributes', 'Tar.LinkCompaniesToAttributesID = Sour.LinkCompaniesToAttributesID', 'LinkCompaniesToAttributesID', 'CompaniesID', null, 0),
		('ClientContactTeams', 'Tar.ClientContactTeamsID = Sour.ClientContactTeamsID', 'ClientContactTeamsID', 'CompaniesID', null, 0),
		('CompaniesAliases', 'Tar.CompaniesID = Sour.CompaniesID and isnull(Tar.Name, '''') = isnull(Sour.Name, '''')', 'CompaniesID', 'CompaniesID', null, 0),
		('LinkPeopleToCompanies', 'Tar.LinkPeopleToCompaniesID = Sour.LinkPeopleToCompaniesID', 'LinkPeopleToCompaniesID', 'CompaniesID', null, 0),
		('ProjectsCompaniesLists', 'Tar.ProjectsID = Sour.ProjectsID and Tar.CompaniesID = Sour.CompaniesID', 'CompaniesID', 'CompaniesID', null, 0),
		('Addresses', 'Tar.AddressesID = Sour.AddressesID', 'AddressesID', 'CompaniesID', null, 0),
		('EmailAddress', 'Tar.EmailAddressID = Sour.EmailAddressID', 'EmailAddressID', 'CompaniesID', null, 0),
		('LinkObjectToActivityHistory', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Companies', 0),
		('LinkObjectToDocument', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Companies', 0),
		('LinkObjectToTask', 'Tar.LeftID = Sour.LeftID and Tar.RightID = Sour.RightID and Tar.ObjectTableName = Sour.ObjectTableName', 'LeftID', 'LeftID', 'Companies', 0)

		--list items

		declare @ListItems table(id int identity, insTable varchar(255) not null, insertSQL nvarchar(max), Fatal bit)
		insert into @ListItems(insTable, Fatal)
		values('ListsDetails', 0)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GrandChildren(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('ProjectTargetCompaniesCandidates', 'Tar.ProjectsID = Sour.ProjectsID and Tar.CompaniesID = Sour.CompaniesID and Tar.PeopleID = Sour.PeopleID', 'CompaniesID', 'ProjectsCompaniesLists', 'SourParent.ProjectsID = Sour.ProjectsID and SourParent.CompaniesID = Sour.CompaniesID', 'CompaniesID', null, 0),
		('MailingAddresses', 'Tar.MailingAddressesID = Sour.MailingAddressesID', 'MailingAddressesID', 'Addresses', 'SourParent.AddressesID = Sour.AddressesID', 'CompaniesID', null, 0),
		('LinkAddressToDistList', 'Tar.LinkToDistListID = Sour.LinkToDistListID', 'LinkToDistListID', 'EmailAddress', 'SourParent.EmailAddressID = Sour.EmailAddressID', 'CompaniesID', null, 0)

		--great grandchildren

		declare @GreatGrand table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			GrandTable varchar(255), ParentGrandJoinOn varchar(255), MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		--set child IDs
	
		declare @SetChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))

		--set grandchild IDs
	
		declare @SetGrandChildID table(id int identity, UpTable varchar(255), TarSourJoinOn varchar(255), SetIDField varchar(255), ParentTable varchar(255), SourParentJoinOn varchar(255), MainLinkField varchar(255), Fatal bit not null, UpdateSQL nvarchar(max), RestoreSQL nvarchar(max))
	
	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @ListItems
	set insertSQL = dbo.fn_Drew_RestoreSQL_ListItemInsert(@Sourdb, @Tardb, '''Companies''')

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

	--custom items
	declare @nl nvarchar(2) = char(13) + char(10)
	declare @sql nvarchar(max) = 'update Tar'
	+ @nl + 'set AddressesID = Sour.AddressesID, Location = Sour.Location'
	+ @nl + 'from ' + @TarDB + '..Positions Tar'
	+ @nl + 'join ' + @SourDB + '..Positions Sour'
	+ @nl + '	on Sour.PositionsID = Tar.PositionsID'
	+ @nl + 'join ' + @SourDB + '..Addresses SourParent'
	+ @nl + '	on SourParent.AddressesID = Sour.AddressesID'
	+ @nl + 'where SourParent.CompaniesID = @MainRecordID'
	+ @nl + 'and Tar.AddressesID is null and isnull(Tar.Location, '''') = '''''
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	values('Positions', @sql, 'update', 0)

	return
end