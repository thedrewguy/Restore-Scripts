if object_id('fn_Drew_Restore_MedCompanies_DiffTable_t') is not null
	drop function fn_Drew_Restore_MedCompanies_DiffTable_t
go

create function fn_Drew_Restore_MedCompanies_DiffTable_t()
returns @DeleteCheck table(id int identity primary key, TableName varchar(255), WhereClause nvarchar(max))
as begin
	insert into @DeleteCheck(TableName, WhereClause)
	values('Companies', N'WHERE CompaniesID = @MainRecordID'),
	('CompaniesIndustry', N'WHERE CompaniesID = @MainRecordID'),
	('LinkCompaniesToRates', N'WHERE CompaniesID = @MainRecordID'),
	('LinkCompaniesToOpportunities', N'WHERE CompaniesID = @MainRecordID'),
	('LinkCompanyToCompanies', N'WHERE @MainRecordID in(CompaniesID, LinkedCompaniesID)'),
	('ListsDetails', N'WHERE ListID IN(SELECT ListsID FROM <DB>..Lists WHERE SourceTable IN(''Companies'')) AND RecordID = @MainRecordID'),
	('LinkCompaniesToAttributes', N'WHERE CompaniesID = @MainRecordID'),
	('ClientContactTeams', N'WHERE CompaniesID = @MainRecordID'),
	('CompaniesAliases', N'WHERE CompaniesID = @MainRecordID'),
	('LinkPeopleToCompanies', N'WHERE CompaniesID = @MainRecordID'),
	('LinkObjectToDocument', N'WHERE ObjectTableName = ''Companies'' AND LeftID = @MainRecordID'),
	('LinkObjectToTask', N'WHERE ObjectTableName = ''Companies'' AND LeftID = @MainRecordID'),
	('LinkObjectToActivityHistory', N'WHERE ObjectTableName = ''Companies'' AND LeftID = @MainRecordID'),
	('ProjectsCompaniesLists', N'WHERE CompaniesID = @MainRecordID'),
	('Addresses', N'WHERE CompaniesID = @MainRecordID'),
	('EmailAddress', N'WHERE CompaniesID = @MainRecordID'),
	('ProjectTargetCompaniesCandidates', N'WHERE CompaniesID = @MainRecordID'),
	('MailingAddresses', N'WHERE AddressesID in(select AddressesID from <DB>..Addresses where CompaniesID = @MainRecordID)'),
	('LinkAddressToDistList', N'WHERE EmailAddressID in(select EmailAddressID from <DB>..EmailAddress where CompaniesID = @MainRecordID)')
	
	return
end