/*
	require:
	fn_Drew_Restore_CandidateBlock_t
*/

if object_id('fn_Drew_RestoreSQL_MakeBlockLog') is not null
	drop function fn_Drew_RestoreSQL_MakeBlockLog
go

create function fn_Drew_RestoreSQL_MakeBlockLog(@Sourdb varchar(255), @Tardb varchar(255))
returns nvarchar(max)
as begin
	return N'
	if object_id(''ProjRestoreBlockLog'') is not null
		drop table ProjRestoreBlockLog
	
	--Create block restore log
	declare @Est_BackupTime datetime = (select max(UpdatedOn) from ' + @Sourdb + '..ProjectsCallStatus)
	select Est_BackupTime = @Est_BackupTime, RestoreDate = GETDATE(), ProjectsID = @MainRecordID, SourPeople.PeopleID,
	BackupTime_BlockLevel = SourPeople.CandidateBlockStatus, BackupTime_BlockProjID = SourPeople.CandidateBlockProjectsID, BackupTime_BlockDescription = SourPeople.BlockDescription,
	PreRestore_BlockLevel = TarPeople.CandidateBlockStatus, PreRestore_BlockProjID = TarPeople.CandidateBlockProjectsID, PreRestore_BlockDescription = TarPeople.BlockDescription,
	PostRestore_BlockLevel = TarProperBlock.CandidateBlockStatus, PostRestore_BlockProjID = TarProperBlock.CandidateBlockProjectsID, PostRestore_BlockDescription = TarProperBlock.BlockDescription,
	OtherProjectsUsedInSinceBackup = OtherProjectsUsedInSinceBackup.OtherProjs
	into ProjRestoreBlockLog
	from
	(	
		select peopleid
		from ProjectsFileSearchCandidates
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from ProjectsBenchmarkCandidates
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from ProjectTargetCompaniesCandidates
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from PeopleAppliedTo
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from ProjectsClientEmployeesLists
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from ProjectsSources
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from CandidateReferrals
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from ProjectsTargetLists
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from ProjectsInternalInterviewLists
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from ProjectsPresentedLists
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from ProjectsShortLists
		where ProjectsID = @MainRecordID
		union
		select peopleid
		from Positions
		where ProjectsID = @MainRecordID
		and PeopleID is not null
	) SourCandidates
	left join ' + @Sourdb + '..People SourPeople
		on SourPeople.PeopleID = SourCandidates.PeopleID
	left join ' + @Tardb + '..People TarPeople
		on TarPeople.PeopleID = SourCandidates.PeopleID
	outer apply ' + @Tardb + '.dbo.fn_Drew_Restore_CandidateBlock_t(SourCandidates.PeopleID) TarProperBlock
	outer apply(
		select stuff(
			(
				select distinct '', '' + ProjectsOther.JobCode
				FROM ProjectsCandidateBlocks PCBOther
				join Projects ProjectsOther
					on ProjectsOther.ProjectsID = PCBOther.ProjectsID
				where PCBOther.CreatedOn > @Est_BackupTime
				AND PCBOther.ProjectsID <> @MainRecordID
				AND PCBOther.PeopleID = SourCandidates.PeopleID
				for xml path(''''), root(''a''), type
			).value(''a[1]'', ''varchar(max)'')
			, 1, 2, ''''
		)
	) OtherProjectsUsedInSinceBackup(OtherProjs)'
end

go