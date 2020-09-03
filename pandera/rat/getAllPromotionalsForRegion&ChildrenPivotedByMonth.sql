with 
targetMonth as (
    select pro.month from "promotionals" pro 
    where  pro.fiscal_year = 2018), --Enter your fiscal year here
targetPosition as (
  select p.id from "positions" p 
  where p.code in (
  'R0001',
  'R0002',
  'R0006',
  'R0009',
  'R0010',
  'R0012',
  'R0003',
  'R0004',
  'R0005',
  'R0007',
  'R0008',
  'R0011'
  )
  ), --Region(s) Here
childrenPositions as (
  select p.id from "positions" p 
  where p.parent_id in (
      select id from targetPosition)
  ),
targetCategories as (
  select cat.display from "promotional_categories" cat 
  where cat.code in ( --select your categories here
--		'ADMINISTRATIVE',
--		'COMMUNICATIONS',
--		'DISTRICT_MEETING',
--		'HOMETEAM',
--		'MISC',
		'PROMOTIONAL',
--		'TRAINING',
		'TRAVEL_BUSINESS'
--		,'UNALLOCATED'
		)
),
selectedIds as ( 
  -- This gets us a list of parents, children and grandchildren. It's really built for getting the sum of Areas or Regions. Can be modified to get a District
    select p.code
  	from "positions" p
  	where 
  		p.parent_id in (select id from childrenPositions)
  		or p.id in (select id from targetPosition)
  		or p.id in (select id from childrenPositions)
     )
select
 sub.position
,sub.category
,sum(sub."July") as "July"
,sum(sub."August") as "August"
,sum(sub."September") as "September"
,sum(sub."October") as "October"
,sum(sub."November") as "November"
,sum(sub."December") as "December"
,sum(sub."January") as "January"
,sum(sub."February") as "February"
,sum(sub."March") as "March"
from
	(select
	 pos.code as "position"
	,cat.display as "category"
	,sum((case when pro.month =  7 then pro.forecast else 0 end)::money) as "July"
	,sum((case when pro.month =  8 then pro.forecast else 0 end)::money) as "August"
	,sum((case when pro.month =  9 then pro.forecast else 0 end)::money) as "September"
	,sum((case when pro.month = 10 then pro.forecast else 0 end)::money) as "October"
	,sum((case when pro.month = 11 then pro.forecast else 0 end)::money) as "November"
	,sum((case when pro.month = 12 then pro.forecast else 0 end)::money) as "December"
	,sum((case when pro.month =  1 then pro.forecast else 0 end)::money) as "January"
	,sum((case when pro.month =  2 then pro.forecast else 0 end)::money) as "February"
	,sum((case when pro.month =  3 then pro.forecast else 0 end)::money) as "March"
	from "promotionals" pro
	left join "positions" pos on pos.id = pro.position_id
	left join "promotional_categories" cat on cat.id = pro.category_id
	where pro.fiscal_year = 2018
	    and pos.code in (select code from selectedIds)
	    and cat.display in (select display from targetCategories)
	    and pos.level = 400
	group by 
	 "position"
	,"category"
	union all
	select
	-- pos.code as "position"
	 pos2.code as "position"
	,cat.display as "category"
	,sum((case when pro.month =  7 then pro.forecast else 0 end)::money) as "July"
	,sum((case when pro.month =  8 then pro.forecast else 0 end)::money) as "August"
	,sum((case when pro.month =  9 then pro.forecast else 0 end)::money) as "September"
	,sum((case when pro.month = 10 then pro.forecast else 0 end)::money) as "October"
	,sum((case when pro.month = 11 then pro.forecast else 0 end)::money) as "November"
	,sum((case when pro.month = 12 then pro.forecast else 0 end)::money) as "December"
	,sum((case when pro.month =  1 then pro.forecast else 0 end)::money) as "January"
	,sum((case when pro.month =  2 then pro.forecast else 0 end)::money) as "February"
	,sum((case when pro.month =  3 then pro.forecast else 0 end)::money) as "March"
	from "promotionals" pro
	left join "positions" pos on pos.id = pro.position_id
	left join "promotional_categories" cat on cat.id = pro.category_id
	left join "positions" pos2 on pos2.id = pos.parent_id
	where pro.fiscal_year = 2018
	    and pos.code in (select code from selectedIds)
	    and cat.display in (select display from targetCategories)
	    and pos.level = 500
	group by 
	 "position"
	,"category") as sub
group by 1, 2
order by 2,
case 
	when "position" = 'R0001' then  1
	when "position" = 'R0002' then  2
	when "position" = 'R0006' then  3
	when "position" = 'R0009' then  4
	when "position" = 'R0010' then  5
	when "position" = 'R0012' then  6
	when "position" = 'R0003' then  7
	when "position" = 'R0004' then  8
	when "position" = 'R0005' then  9
	when "position" = 'R0007' then 10
	when "position" = 'R0008' then 11
	when "position" = 'R0011' then 12 end
