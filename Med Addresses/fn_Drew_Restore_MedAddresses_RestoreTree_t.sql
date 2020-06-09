/* require:
	fn_Drew_RestoreSQL_ChildInsert
	fn_Drew_RestoreSQL_GrandchildInsert
	fn_Drew_RestoreSQL_GreatGrandInsert
	fn_Drew_RestoreSQL_ListItemInsert
	fn_Drew_RestoreSQL_ChildSetID
	fn_Drew_RestoreSQL_GrandChildSetID
	fn_Drew_RestoreSQL_Wrap
*/


if object_id('fn_Drew_Restore_MedAddresses_RestoreTree_t') is not null
	drop function fn_Drew_Restore_MedAddresses_RestoreTree_t
go

create function fn_Drew_Restore_MedAddresses_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('Addresses', 'Tar.AddressesID = Sour.AddressesID', 'AddressesID', 'AddressesID', null, 1),
		('MailingAddresses', 'Tar.MailingAddressesID = Sour.MailingAddressesID', 'MailingAddressesID', 'AddressesID', null, 0),
		('LinkAddressToMCRContract', 'Tar.JobOrdersID = Sour.JobOrdersID and Tar.AddressesID = Sour.AddressesID', 'AddressesID', 'AddressesID', null, 0)

	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	--populate full restore tree with bulk-generated items
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	--custom

	declare @nl nvarchar(2) = char(13) + char(10)
	declare @PositionsSQL nvarchar(max) = 'update Tar'
	+ @nl + 'set AddressesID = Sour.AddressesID, Location = Sour.Location'
	+ @nl + 'from ' + @TarDB + '..Positions Tar'
	+ @nl + 'join ' + @SourDB + '..Positions Sour'
	+ @nl + '	on Sour.PositionsID = Tar.PositionsID'
	+ @nl + 'where Sour.AddressesID = @MainRecordID'
	+ @nl + 'and Tar.AddressesID is null and isnull(Tar.Location, '''') = '''''
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	values('Positions', @PositionsSQL, 'update', 0)

	return
end

go

