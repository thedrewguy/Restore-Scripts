/* require:
	fn_Drew_RestoreSQL_ChildInsert
	fn_Drew_RestoreSQL_GrandchildInsert
	fn_Drew_RestoreSQL_GreatGrandInsert
	fn_Drew_RestoreSQL_ListItemInsert
	fn_Drew_RestoreSQL_ChildSetID
	fn_Drew_RestoreSQL_GrandChildSetID
*/


if object_id('fn_Drew_Restore_WebJobPostings_RestoreTree_t') is not null
	drop function fn_Drew_Restore_WebJobPostings_RestoreTree_t
go

create function fn_Drew_Restore_WebJobPostings_RestoreTree_t(@SourDB varchar(255), @TarDB varchar(255))
returns @RestoreTree table(id int identity primary key, TableName varchar(255) not null, Operation varchar(255) not null, RestoreSQL nvarchar(max) not null, Fatal bit not null default(0))
as begin
	--children to restore
		--regular child records

		declare @Children table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, MainLinkField varchar(255) not null, ObjectTableName varchar(255),
			Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @Children(InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName, Fatal)
		values('WebJobPostings', 'Tar.WebJobPostingsID = Sour.WebJobPostingsID', 'WebJobPostingsID', 'WebJobPostingsID', null, 1),
		('Questions', 'Tar.QuestionsID = Sour.QuestionsID', 'QuestionsID', 'WebJobPostingsID', null, 0),
		('SkillsQuestions', 'Tar.SkillsQuestionsID = Sour.SkillsQuestionsID', 'SkillsQuestionsID', 'WebJobPostingsID', null, 0),
		('WebPostingsIndustries', 'Tar.WebPostingsIndustriesID = Sour.WebPostingsIndustriesID', 'WebPostingsIndustriesID', 'WebJobPostingsID', null, 0),
		('LinkWebPostingToWebsite', 'Tar.WebJobPostingsID = Sour.WebJobPostingsID and Tar.WebSitesID = Sour.WebSitesID', 'WebJobPostingsID', 'WebJobPostingsID', null, 0)

		--grandchildren

		declare @GrandChildren table(id int identity, InsTable varchar(255) not null, InsTarSourJoinOn varchar(255) not null, InsNNField varchar(255) not null, ParentTable varchar(255), SourParentJoinOn varchar(255), 
			MainLinkField varchar(255) not null, ObjectTableName varchar(255), Fatal bit not null, InsertSQL nvarchar(max) null, RestoreSQL nvarchar(max) null)

		insert into @GrandChildren(InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName, Fatal)
		values('MultipleAnswerItems', 'Tar.MultipleAnswerItemsID = Sour.MultipleAnswerItemsID', 'MultipleAnswerItemsID', 'Questions', 'SourParent.QuestionsID = Sour.QuestionsID', 'WebJobPostingsID', null, 0)
		
	--generate insert sql

	update @Children
	set InsertSQL = dbo.fn_Drew_RestoreSQL_ChildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, MainLinkField, ObjectTableName)

	update @GrandChildren
	set insertSQL = dbo.fn_Drew_RestoreSQL_GrandchildInsert(@Sourdb, @Tardb, InsTable, InsTarSourJoinOn, InsNNField, ParentTable, SourParentJoinOn, MainLinkField, ObjectTableName)

	--populate full restore tree with bulk-generated items
	
	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @Children

	insert into @RestoreTree(TableName, RestoreSQL, Operation, Fatal)
	select InsTable, InsertSQL, 'insert', Fatal
	from @GrandChildren

	return
end

go