if object_id('fn_Drew_Restore_Addresses_DiffTable_t') is not null
	drop function fn_Drew_Restore_Addresses_DiffTable_t
go

create function fn_Drew_Restore_Addresses_DiffTable_t()
returns @DeleteCheck table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
as begin
	insert into @DeleteCheck(TableName, WhereClause)
	values('Addresses', N'WHERE AddressesID = @MainRecordID'),
	('MailingAddresses', N'WHERE AddressesID = @MainRecordID'),
	('Positions', N'WHERE AddressesID = @MainRecordID')

	return
end