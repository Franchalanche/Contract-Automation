USE [WorkBench]
GO

CREATE PROCEDURE [dbo].[sp_Contract_Rollup_Check]
--ALTER PROCEDURE [dbo].[sp_Contract_Rollup_Check]

SELECT TOP 100 * 
FROM DLDB.dbo.DL_DW_luFaxContract

SELECT TOP 100 * 
FROM DLDB.dbo.DL_DW_luContractCategory

SELECT --TOP 100 
* 
from WorkBench.dbo.ContractName_RollUpName_CrossReference

SELECT --TOP 100 
*
FROM Contract_Final_FP

AS BEGIN

DROP TABLE IF EXISTS WorkBench.dbo.Contract_Staging
SELECT distinct
  fc.luContractCode
, fc.ContractDesc
, r2.RollupName as Does_Rollup_Exist
, string_agg(r3.[Contract],', ') -- WITHIN GROUP (ORDER BY r3.[Contract] asc) 
	as CurrentRollupContracts
, fc.Active
, fc.ContractType
, cc.healthplan
, fc.ContractCategory
, fc.contract_live_dt
, fc.termed_out
into WorkBench.dbo.Contract_Staging
from DLDB.dbo.DL_DW_luFaxContract fc
left join WorkBench.dbo.ContractName_RollUpName_CrossReference r
	on fc.ContractDesc = r.[Contract]
LEFT JOIN (select distinct rollupname
			from WorkBench.dbo.ContractName_RollUpName_CrossReference) r2
	on fc.ContractDesc like r2.RollupName+'%' 
LEFT JOIN (SELECT DISTINCT RollupName, Contract
			FROM WorkBench.dbo.ContractName_RollUpName_CrossReference) r3
	ON R2.RollupName = r3.RollupName
LEFT JOIN DLDB.dbo.DL_DW_luContractCategory CC
	ON FC.ContractDesc = cc.ContractDesc
WHERE fc.Active = 1
	and r.[Contract] IS NULL
group by 
  fc.luContractCode
, fc.ContractDesc
, r2.RollupName --as Does_Rollup_Exist
, fc.Active
, cc.healthplan
, fc.ContractType
, fc.ContractCategory
, fc.contract_live_dt
, fc.termed_out;

DELETE FROM  WorkBench.dbo.Contract_Staging
WHERE ContractDesc like 'Test-%' 
	or ContractDesc like 'ZYX %'  
	or ContractDesc in ('WIN','WINFertilityUKDTC','Womens Integrated Network-Premier')

select * from WorkBench.dbo.Contract_Staging
order by ContractDesc
;

SELECT --TOP 100 
* 
from WorkBench.dbo.ContractName_RollUpName_CrossReference
order by Contract

END