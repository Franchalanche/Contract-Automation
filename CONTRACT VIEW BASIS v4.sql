----select * from sys.servers
--select 'PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF' 'top 200 *'
--select top 200
--* from
--PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF
--WHERE ISNULL(EDITSTATUS,'')=''

----select top 200
----* from
----PRODWINMASTER.WinData.dbo.PatientBenefits_WPF
--select 'PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF' 'distinct contract'
--select distinct contract
-- from
--PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF
--WHERE ISNULL(EDITSTATUS,'')=''

--select 'PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF' 'distinct Title, Subtitle'
--select distinct Title, Subtitle
-- from
--PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF
--WHERE 1=1
--	and ISNULL(EDITSTATUS,'')=''
--	--and (title like 'Medical %' or title like 'Pharmacy %'
--	--or subtitle like 'Medical %' or subtitle like 'Pharmacy %')
--order by Title, Subtitle

--select 'DLDB.DBO.dl_dw_contractspecifications_sand' 'top 200 *'
--select top 200 * from 
--DLDB.DBO.dl_dw_contractspecifications_sand CS
--WHERE 1=1
--	and ISNULL(EDITSTATUS,'')=''

--	--select * from sys.servers
----select 'PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF' 'top 200 *'
----select top 200
----* from
----PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF
----WHERE ISNULL(EDITSTATUS,'')=''

--select 'DLDB.DBO.[dl_dw_luFaxContract]' 'top 200 *'
--select top 200 * from 
--DLDB.DBO.[dl_dw_luFaxContract] C

--select 'Distinct Text-CYCLE ONLY' 'Below';
--select distinct CS.[Text]
--from [DLDB].[dbo].[dl_dw_luFaxContract] C
--left join [DLDB].[dbo].dl_dw_contractspecifications_sand CS 
--on c.contractDesc = cs.[contract] 
--WHERE 1=1
--	and CS.text like '%cycle%'
--	and ISNULL(CS.EDITSTATUS,'')=''
--	and (CS.title like 'Medical Benefit' or CS.title like 'Pharmacy Benefit')
--	and cs.subtitle = 'Limit'
--	and isnull(cs.[Text],'')<>''
--	and cs.[Text] <> 'N/A'
--	and CS.timeofentry >= (
--							select max(cs2.timeofentry)
--							from DLDB.DBO.dl_dw_contractspecifications_sand Cs2
--							where cs.title = cs2.title and cs.contract = cs2.contract
--							and cs2.subtitle = 'Limit'
--							and isnull(cs2.[Text],'')<>''
--							and cs2.[Text] <> 'N/A'
--						)
--group by CS.[Text]
--order by CS.[Text]
--; 

----select 'Distinct Text & Title' 'Below';
----select distinct 
----  CS.Title
----, CS.[Text]
----from [DLDB].[dbo].[dl_dw_luFaxContract] C
----left join [DLDB].[dbo].dl_dw_contractspecifications_sand CS 
----on c.contractDesc = cs.[contract] 
----WHERE 1=1
----	and ISNULL(CS.EDITSTATUS,'')=''
----	and (CS.title like 'Medical Benefit' or CS.title like 'Pharmacy Benefit')
----	and cs.subtitle = 'Limit'
----	and isnull(cs.[Text],'')<>''
----	and cs.[Text] <> 'N/A'
----	and CS.timeofentry >= (
----							select max(cs2.timeofentry)
----							from DLDB.DBO.dl_dw_contractspecifications_sand Cs2
----							where cs.title = cs2.title and cs.contract = cs2.contract
----							and cs2.subtitle = 'Limit'
----							and isnull(cs2.[Text],'')<>''
----							and cs2.[Text] <> 'N/A'
----						)
----group by   CS.Title, CS.[Text]
----order by   CS.Title, CS.[Text]
----; 

--select 'Cycles w IUI Medical Distinct Contract, Text & Title' 'Below';
--select distinct 
--  cs.contract
--,  CS.Title
--, CS.[Text]
--from [DLDB].[dbo].[dl_dw_luFaxContract] C
--left join [DLDB].[dbo].dl_dw_contractspecifications_sand CS 
--on c.contractDesc = cs.[contract] 
--WHERE 1=1
--	and CS.[text] like '%cycle%'
--	and CS.[text] like '%IUI%'
--	and cs.title like '%medical%'
--	and ISNULL(CS.EDITSTATUS,'')=''
--	and (CS.title like 'Medical Benefit' or CS.title like 'Pharmacy Benefit')
--	and cs.subtitle = 'Limit'
--	and isnull(cs.[Text],'')<>''
--	and cs.[Text] <> 'N/A'
--	and CS.timeofentry >= (
--							select max(cs2.timeofentry)
--							from DLDB.DBO.dl_dw_contractspecifications_sand Cs2
--							where cs.title = cs2.title and cs.contract = cs2.contract
--							and cs2.subtitle = 'Limit'
--							and isnull(cs2.[Text],'')<>''
--							and cs2.[Text] <> 'N/A'
--						)
--group by  cs.contract, CS.Title, CS.[Text]
--order by  cs.contract, CS.Title, CS.[Text]
--; 

--PROBLEMS
--Unlimited TI/IUI. No ART coverage.
--Unlimited IUI. No ART coverage. 

drop table if exists #Med_Rx_Benefits;
--select 'DLDB.DBO.dl_dw_contractspecifications_sand' 'Contracts Most Recent Benefit Descriptions'
select --top 200 
C.ContractDesc
, CS.Title
, CS.[Text]
, C.Active
, C.GoLive_Date
, case  when CS.[Text] like '%combined%' or CS.[Text] like '%including Rx%' then 'Combined' 
		else '' end 
		as Combined_or_Split_Benefit
, cast(case when CS.[Text] like '%LTM%' and CS.[Text] NOT like '%Cycle%' then 'LTM' 
	   when CS.[Text] like '%Cycle%' then 'Cycle' 
		else '' end as nvarchar(max)) as Benefit_Type
, cast(case 
	when --CS.Title like '%medical%' and 
	(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
	and (CS.[Text] like '%7,000%' or CS.[Text] like '%7000%' or CS.[Text] like '%7k%' or CS.[Text] like '%7 k%')
		then '7k'
	--when --CS.Title like '%medical%' and 	(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') and 
	--	(CS.[Text] like '%7,500%' or CS.[Text] like '%7500%' or CS.[Text] like '%[7.5]_[k]%')
	--		then '7.5k'
	when --CS.Title like '%medical%' and 
	(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%17,500%' or CS.[Text] like '%17500%' or CS.[Text] like '%17.5k%' or CS.[Text] like '%17.5 k%')
			then '17.5k'
	when --CS.Title like '%medical%' and (CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 		and
		(CS.[Text] like '%7,500%' or CS.[Text] like '%7500%' or CS.[Text] like '%7.5k%' or CS.[Text] like '%7.5 k%')
		then '7.5k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%10,000%' or CS.[Text] like '%10000%' or CS.[Text] like '%10k%' or CS.[Text] like '%10 k%')
			then '10k'
	when CS.[Text] in ('$15k','$10k','$20k') then CS.[Text]
	when CS.[Text] like '$15,000%' then '15k'
	when CS.[Text] like '%basic benefit level of $12k%' then '12k'
	when (CS.[Text] like '%basic benefit%' and CS.[Text] like '%of $10k%') or CS.[Text] like  '$10k Annual Max%' then '10k'
	when CS.[Text] like '$10k%' then '10k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%15,000%' or CS.[Text] like '%15000%' or CS.[Text] like '%15k%' or CS.[Text] like '%15 k%')
			then '15k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%20,000%' or CS.[Text] like '%20000%' or CS.[Text] like '%20k%' or CS.[Text] like '%20 k%')
			then '20k'
	when --CS.Title like '%medical%' and 	(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') and 
		(CS.[Text] like '%24,000%' or CS.[Text] like '%24000%' or CS.[Text] like '%24k%' or CS.[Text] like '%24 k%')
			then '24k'	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%25,000%' or CS.[Text] like '%25000%' or CS.[Text] like '%25k%' or CS.[Text] like '%25 k%')
			then '25k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%30,000%' or CS.[Text] like '%30000%' or CS.[Text] like '%30k%' or CS.[Text] like '%30 k%')
			then '30k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%35,000%' or CS.[Text] like '%35000%' or CS.[Text] like '%35k%' or CS.[Text] like '%35 k%')
			then '35k'
	when --.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%40,000%' or CS.[Text] like '%40000%' or CS.[Text] like '%40k%' or CS.[Text] like '%40 k%')
			then '40k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%45,000%' or CS.[Text] like '%45000%' or CS.[Text] like '%45k%' or CS.[Text] like '%45 k%')
			then '45k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%50,000%' or CS.[Text] like '%50000%' or CS.[Text] like '%50k%' or CS.[Text] like '%50 k%')
			then '50k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%60,000%' or CS.[Text] like '%60000%' or CS.[Text] like '%60k%' or CS.[Text] like '%60 k%')
			then '60k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%65,000%' or CS.[Text] like '%65000%' or CS.[Text] like '%65k%' or CS.[Text] like '%65 k%')
			then '65k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%70,000%' or CS.[Text] like '%70000%' or CS.[Text] like '%70k%' or CS.[Text] like '%70 k%')
			then '70k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%75,000%' or CS.[Text] like '%75000%' or CS.[Text] like '%75k%' or CS.[Text] like '%75 k%')
			then '75k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%80,000%' or CS.[Text] like '%80000%' or CS.[Text] like '%80k%' or CS.[Text] like '%80 k%')
			then '80k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%90,000%' or CS.[Text] like '%90000%' or CS.[Text] like '%90k%' or CS.[Text] like '%90 k%')
			then '90k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%100,000%' or CS.[Text] like '%100000%' or CS.[Text] like '%100k%' or CS.[Text] like '%100 k%')
			then '100k'
	when --CS.Title like '%medical%' and 
		(CS.[Text] like '%LTM%' or CS.[Text] like '%Combined%') 
		and (CS.[Text] like '%5,000%' or CS.[Text] like '%5000%' or CS.[Text] like '%5k%' or CS.[Text] like '%5 k%')
			then '5k'
	when CS.Title like '%medical%' 
		and CS.[Text] IN ('Unlimited TI/IUI. No ART coverage.'
						,'Unlimited IUI. No ART coverage'
						,'4 retrieval benefit - plus 2 add’l cycles if one cycle (of the 4 cycles) results in a live birth 6 IUI cycle LTM'
						,'SIX TOTAL IUIs. No cycle count limitations on TI or IVF/ART services.')
		then CS.[Text]
	WHEN cs.TITLE like '%medical%' 
		and CS.[Text] in ('Unlimited for INN. Out-of network coverage limited to $50k LTM. ')
		then 'Unlimited INN; $50k OON'
	when CS.Title like '%medical%' --and CS.[Text] like '%cycle%' 
		and (CS.[Text] like '%1 IVF%' or CS.[Text] like '%1 Retrieval%' or CS.[Text] like '%[1]__[IVF]%' or CS.[Text] like '%1) Retrieval%' or CS.[Text] like '%1 ART%'
			or (CS.[Text] like '%1%' and CS.[Text] like '%retrieval%'))
		then '1 Cycle'
	when CS.Title like '%medical%' and CS.[Text] like '%One (1) embryo transfer (whether fresh or frozen) and the accompanying IVF cycles that it takes to get to one (1) embryo transfer%'
		THEN '1 TRANSFER Cycle'
	when CS.Title like '%medical%' --and CS.[Text] like '%cycle%' 
		and (CS.[Text] like '%2 IVF%' or CS.[Text] like '%2 Retrieval%' or CS.[Text] like '%[2]__[IVF]%' or CS.[Text] like '%2) Retrieval%' or CS.[Text] like '%2 ART%'
			or CS.[Text] like '%[2]__[Cycle]%' or (CS.[Text] like '%2%' and CS.[Text] like '%retrieval%') or (CS.[Text] like '%2%' and CS.[Text] like '%RTV%'))
		then '2 Cycle'
	when CS.Title like '%medical%' and CS.[Text] like '%Three (3) embryo transfers (whether fresh or frozen) and the accompanying IVF cycles that it takes to get to three (3) embryo transfers%'
		then '3 TRANSFERS'
	when CS.Title like '%medical%' --and CS.[Text] like '%cycle%' 
		and (CS.[Text] like '%3 IVF%' or CS.[Text] like '%3 Retrieval%' or CS.[Text] like '%[3]__[IVF]%' or CS.[Text] like '%3) Retrieval%' or CS.[Text] like '%3 ART%'
			or (CS.[Text] like '%3%' and CS.[Text] like '%cycle%') or (CS.[Text] like '%3%' and CS.[Text] like '%retrieval%') or (CS.[Text] like '%3%' and CS.[Text] like '%ART%'))
		then '3 Cycle'
	when CS.Title like '%medical%' and CS.[Text] like '%cycle%' 
		and (CS.[Text] like '%4 IVF%' or CS.[Text] like '%4 Retrieval%'  or CS.[Text] like '%4 Retreival%' --FACEPALM
			or CS.[Text] like '%[4]__[IVF]%' or CS.[Text] like '%4) Retrieval%' or CS.[Text] like '%4 ART%')
		then '4 Cycle'
	when CS.Title like '%medical%' --and CS.[Text] like '%cycle%' 
		and (CS.[Text] like '%6 IVF%' or CS.[Text] like '%6 Retrieval%' or CS.[Text] like '%[6]__[IVF]%' or CS.[Text] like '%6) Retrieval%' or CS.[Text] like '%6 ART%'
		or (CS.[Text] like '%6%' and CS.[Text] like '%cycle%'))
		then '6 Cycle'
	when CS.[Text] like '%Unlimited IUI%' and CS.[Text] like '%No ART coverage%'
		then 'Unlimited IUI; NO ART'
	when 
		  CS.[Text] like '%Unlimited%' 
		or CS.[Text] like '%No cycle limit%'
		or CS.[Text] like '%No cycle count limit%'
		or CS.[Text] like '%No limit%'
		--or (CS.[Text] like '%No%' and CS.[Text] like '%limit%')
		or (CS.[Text] like '%No limitation%' and CS.[Text] like '%cycle%')
		or (CS.[Text] like '%No%' and CS.[Text] like '%maximum%')
		then 'Unlimited'	ELSE '' END as Nvarchar(max)) AS --Medical_
			Limit
into #Med_Rx_Benefits
from [DLDB].[dbo].[dl_dw_luFaxContract] C
left join [DLDB].[dbo].dl_dw_contractspecifications_sand CS 
on c.contractDesc = cs.[contract] 
WHERE 1=1
	and ISNULL(CS.EDITSTATUS,'')=''
	and (CS.title like 'Medical Benefit' or CS.title like 'Pharmacy Benefit')
	and cs.subtitle = 'Limit'
	and isnull(cs.[Text],'')<>''
	and cs.[Text] <> 'N/A'
	and CS.timeofentry >= (
							select max(cs2.timeofentry)
							from DLDB.DBO.dl_dw_contractspecifications_sand Cs2
							where cs.title = cs2.title and cs.contract = cs2.contract
							and cs2.subtitle = 'Limit'
							and isnull(cs2.[Text],'')<>''
							and cs2.[Text] <> 'N/A'
						)
group by C.ContractDesc, CS.Title, CS.[Text], C.Active, C.GoLive_Date --, C.Text 
; 


update med_rx 
set med_rx.Limit = mr2.Limit
	, med_rx.Combined_or_split_benefit = 'Combined'
	, med_rx.Benefit_Type = mr2.Benefit_Type
from #Med_Rx_Benefits med_rx
JOIN #Med_Rx_Benefits mr2
	on med_rx.ContractDesc = mr2.ContractDesc
		and mr2.Title = 'Medical Benefit'
where 1=1
	and med_rx.Limit = ''
	and med_rx.Title = 'Pharmacy Benefit'
	and (med_rx.[Text] like '%Medications limited%' -- to treatment
		or med_rx.[Text] like '%Medication limited%'
	--	or med_rx.[Text] like 'Medications limited to cycle%'
		or med_rx.[Text] like '%no limit on approved prescriptions related to%'
		or med_rx.[Text] like '%Covered for covered treatment cycles%'
		or med_rx.[Text] like '%Unlimited, but tied to cycle benefit%'
		or med_rx.[Text] like '%Pharmacy benefits will be exhausted when medical benefit limit is met%'
		or med_rx.[Text] like '%Subject to an approved treatment cycle%'
		or med_rx.[Text] like '%After ART benefit is exhausted, ART medication coverage expires%'
		or med_rx.[Text] like '%Medications matched to treatment approval%'
		or med_rx.[Text] like '%covered with approved cycle%'
		or med_rx.[Text] like '%Limited to covered%'
		or med_rx.[Text] like '%Subject to match%'
		or med_rx.[Text] like '%No specific fertility Rx limit%'
		or med_rx.[Text] like '%match approved fertility%'
		)


update med_rx 
set med_rx.Combined_or_split_benefit  = 'Combined'
from #Med_Rx_Benefits med_rx
JOIN #Med_Rx_Benefits mr2
	on med_rx.ContractDesc = mr2.ContractDesc
		and mr2.Title = 'Pharmacy Benefit'
where 1=1
	and med_rx.Combined_or_split_benefit = ''
	and med_rx.Title = 'Medical Benefit'
	and mr2.Combined_or_split_benefit = 'Combined'
;

update #Med_Rx_Benefits
set Limit = 'NOT Managed by WIN', Benefit_Type = 'NOT Managed by WIN'
where [Text] like '%warm transfer%'
;

--select '#Med_Rx_Benefits' 'Table'
--select ContractDesc
--	,Title
--	, Benefit_Type
--	, --Medical_
--		Limit
--	, Combined_or_split_benefit
--	, [TExt]
--from #Med_Rx_Benefits
----where Medical_Limit = ''
----where Benefit_Type = 'Cycle'
--order by ContractDesc, Title, [TExt];

DELETE #Med_Rx_Benefits
WHERE [Text] like 'n/a%';

DELETE #Med_Rx_Benefits
WHERE ContractDesc like 'ZYX%' or ContractDesc like 'Womens Integrated Network-Premier';

--select * from #med_rx_benefits
--where [Text] like 'Details unknown%'

--SELECT 
--    COLUMN_NAME,
--    DATA_TYPE,
--    CHARACTER_MAXIMUM_LENGTH
--FROM tempdb.INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME LIKE '#Med_Rx_Benefits%';

UPDATE #Med_Rx_Benefits
set bENEFIT_tYPE = 'Unknown'
, Limit = 'Unknown'
where [Text] like 'Details unknown%'
;

----select '#Med_Rx_Benefits' 'Table'
--select ContractDesc
--	,Title
--	, Benefit_Type
--	, --Medical_
--		Limit
--	, Combined_or_split_benefit
--	, [TExt]
--from #Med_Rx_Benefits
----where Medical_Limit = ''
----where Benefit_Type = 'Cycle'
--where --ContractDesc like 'AG1%' or ContractDesc like 'Allspring%' 
--ContractDesc like 'Baker%' or ContractDesc like 'Berdon%' or ContractDesc like 'BOA%' 
--order by ContractDesc, Title, [TExt];

--with filled_out as
--(
--	select --* --
--		distinct ContractDesc
--	FROM #Med_Rx_Benefits
--	GROUP BY ContractDesc
--	HAVING 
--		sum(
--				case when title = 'Medical Benefit' 
--					and Benefit_Type <> '' 
--					and Limit <> ''
--					and Combined_or_Split_Benefit <> ''
--				then 1	else 0
--				end
--			) > 0
--			and 
--		sum(
--				case when Title = 'Pharmacy Benefit'
--					and Benefit_Type <> ''
--					and Limit <> ''
--					and Combined_or_Split_Benefit <> ''
--				then 1 else 0
--				end
--			) > 0
--)
--select ContractDesc
--	,Title
--	, Benefit_Type
--	, --Medical_
--		Limit
--	, Combined_or_split_benefit
--	, [TExt]
--	from #Med_Rx_Benefits
--where ContractDesc 
--	NOT in (select * from filled_out)
----HAVING 
----	sum(
----			case when Title = 'Medical Benefit'
----				and Benefit_Type <> ''
----				and Limit <> ''
----			then 1 else 0 end
----		) > 0
----	and
----	sum(
----			case when Title = 'Pharmacy Benefit'
----				and Benefit_Type <> ''
----				and Limit <> ''
----			then 1 else 0 end
----		) > 0
	 
--order by ContractDesc, Title
--;

--select distinct [Text]
--FROM #Med_Rx_Benefits
--where [Text] like '%unlimit%'
--	and Limit = ''

select ContractDesc
	,Title
	, Benefit_Type
	, --Medical_
		Limit
	, Combined_or_split_benefit
	, [TExt]
	from #Med_Rx_Benefits
where --Benefit_Type = '' or
Limit = ''
order by ContractDesc, Title;

UPDATE #Med_Rx_Benefits
set Limit = 'Cap on Specific Brands. Otherwise combined'
where 
	title like '%pharmacy%'
	and Limit = ''
	and ([Text] like '%Follistim%' or [Text] like '%Ganirelix%' or [Text] like '%Menopur%')
;


select ContractDesc
	,Title
	, Benefit_Type
	, Limit
	, Combined_or_split_benefit
	, [TExt] 
from #Med_Rx_Benefits
;


select mr.ContractDesc
	, mr.Title
	, mr.Benefit_Type
	, mr.Limit
	, mr.Combined_or_split_benefit
	, mr.[TExt] 
	, fc.Active
from #Med_Rx_Benefits mr
left join DLDB.dbo.DL_DW_LuFaxContract fc
on mr.ContractDesc = fc.ContractDesc
where fc.Active = 1
order by mr.ContractDesc
	, mr.Title
;

with no_limit as
(
	select distinct ContractDesc 
	FROM #Med_Rx_Benefits
	where Limit = ''
)
select ContractDesc
	,Title
	, Benefit_Type
	, Limit
	, Combined_or_split_benefit
	, [TExt] from #Med_Rx_Benefits
where ContractDesc in (select * from no_limit)
--and ([Text] like '%Follistim%' or [Text] like '%Ganirelix%' or [Text] like '%Menopur%')
--and ([Text] like '%surrogacy%' or [Text] like '%adoption%' --or [Text] like '%Menopur%'
--)
order by ContractDesc, Title
;


--select '#Med_Rx_Benefits' 'Table'
--select * from #Med_Rx_Benefits
--where [Text] like 'details unknown%'
--order by ContractDesc, [Text];

--select 'WorkBench.dbo.Contract_Final_FP' 'Table'
--select * from WorkBench.dbo.Contract_Final_FP

--select 'WorkBench.dbo.Contract_Final_FP' 'Distinct Benefit Types'
--select distinct [Medical Benefit Cleaned] as [Medical Benefit Cleaned]
--from WorkBench.dbo.Contract_Final_FP

--select 'WorkBench.dbo.Contract_Final_FP' 'Problem LImits'
--select * from WorkBench.dbo.Contract_Final_FP
--where [Medical Benefit Cleaned]  in
--(
--'3 Cycle Annually, 8 Lifetime Max'
--, '3 Cycles or $100K'
--, '4 - 6 Cycles (6 if you get 1 birth in the first 4)'
--)

--select 'DLDB.DBO.[dl_dw_luFaxContract]' 'top 200 *'
--select top 200 * from 
--DLDB.DBO.[dl_dw_luFaxContract] C

--select 'WINMaster PatientBenefits_WPF WPF w Active Status & GoLive from dl_dw_luFaxContract]' 'ALL - Distinct'
--select distinct WPF.contract, c.active, c.GOLive_Date
-- from

--LEFT JOIN [DLDB].[dbo].[dl_dw_luFaxContract] C --DLDB.DBO.dl_dw_contractspecifications_sand C
--ON wpf.Contract = C.ContractDesc
--WHERE 1=1 
--	and ISNULL(WPF.EDITSTATUS,'')=''
--	--and c.active = 1
--order by WPF.Contract

--select 'WINMaster PatientBenefits_WPF WPF w Active Status & GoLive from dl_dw_luFaxContract]' 'ACTIVE ONLY'
--select distinct WPF.contract, c.active, c.GOLive_Date
-- from
--PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF WPF
--LEFT JOIN [DLDB].[dbo].[dl_dw_luFaxContract] C --DLDB.DBO.dl_dw_contractspecifications_sand C
--ON wpf.Contract = C.ContractDesc
--WHERE 1=1 
--	and ISNULL(WPF.EDITSTATUS,'')=''
--	and c.active = 1
--order by WPF.Contract

--select 'Contract_Final_FP' 'Missing From'
--select distinct WPF.contract--, c.active, c.GOLive_Date
-- from
--PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF WPF
--LEFT JOIN [DLDB].[dbo].[dl_dw_luFaxContract] C --DLDB.DBO.dl_dw_contractspecifications_sand C
--ON wpf.Contract = C.ContractDesc
--WHERE 1=1 
--	and ISNULL(WPF.EDITSTATUS,'')=''
--	and c.active = 1
----order by WPF.Contract
--except
--select distinct contract from WorkBench.dbo.Contract_Final_FP

--select 'ContractName_Rollup_v4' 'Missing From'
--select distinct WPF.contract--, c.active, c.GOLive_Date
-- from
--PROD2WINMASTER.WinData.dbo.PatientBenefits_WPF WPF
--LEFT JOIN [DLDB].[dbo].[dl_dw_luFaxContract] C --DLDB.DBO.dl_dw_contractspecifications_sand C
--ON wpf.Contract = C.ContractDesc
--WHERE 1=1 
--	and ISNULL(WPF.EDITSTATUS,'')=''
--	and c.active = 1
----order by WPF.Contract
--except
--select distinct contract from WorkBench.dbo.ContractName_Rollup_v4