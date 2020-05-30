if object_id('fn_Drew_Restore_CandidateBlock_t') is not null
	drop function fn_Drew_Restore_CandidateBlock_t
go

create function fn_Drew_Restore_CandidateBlock_t(@PeopleID int)
returns table
as return
	select top 1 CandidateBlockStatus, BlockDescription, CandidateBlockProjectsID
	from (
		select BlockLevelRankForPerson = rank() over(order by WorkLists.BlockLevel desc),
		ProjRankInBlockLevel = rank() over(partition by WorkLists.BlockLevel order by pcb.CreatedOn),
		ListRankInProj = ROW_NUMBER() over(partition by pcb.ProjectsID order by WorkLists.ListLevel desc),
		CandidateBlockStatus = WorkLists.BlockLevel,
		BlockDescription = WorkLists.Caption,
		CandidateBlockProjectsID = pcb.ProjectsID
		from ProjectsCandidateBlocks pcb
		join Projects proj
			on proj.ProjectsID = pcb.ProjectsID
			and isnull(proj.NEDProject, 0) = 0
		join ProjectStatus ps
			on ps.Name = proj.ProjectStatus
			and ps.StatusActive = 1
		join WorkLists
			on WorkLists.WorkListsID = pcb.WorkListsID
		where pcb.PeopleID = @PeopleID
	) rankedBlocks
	where rankedBlocks.BlockLevelRankForPerson = 1
	and rankedBlocks.ProjRankInBlockLevel = 1
	and rankedBlocks.ListRankInProj = 1

go