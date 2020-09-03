with 
targetMonth as (
    select pro.month from "promotionals" pro 
    where pro.month in (8,9,10,11,12,1,2,3) -- Enter your calendar months here
    and pro.fiscal_year = 2018), --Enter your fiscal year here
targetPosition as (
  select p.id from "positions" p 
  where p.code = 'A0001'), --Enter the Area or Region Here
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
		'TRAVEL_BUSINESS',
--		'UNALLOCATED')
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
-- Begin the actual Selects
select
	 combined."code"
	,combined."calendarmonth"
	,combined.category
	,sum(combined."Actual") as "Actual"
	,sum(combined."Forecast") as "Forecast"
	,sum(cast((combined."Actual" - combined."Forecast") as money)) as "Variance"
from (
select -- Districts Aggegrate Query
  --pos.code,
   districts."parentPosition" as "code" -- This is parent position. We're grouping by Region 
  ,districts.calendarMonth
  ,districts.category
  ,districts."Actual"
  ,districts."Forecast"
from (
  select -- Districts Sub Query
  	 pos.code as "position"
  	,pos2.code as "parentPosition"
    ,cat.display as "category"
  	,to_char(to_timestamp(pro.month::text, 'MMM'),'TMMonth') as calendarMonth
    ,sum(cast(pro.actual as money)) as "Actual"
    ,sum(cast(pro.forecast as money)) as "Forecast"
  from "promotionals" pro
    left join "positions" pos on pos.id = pro.position_id
    left join "promotional_categories" cat on cat.id = pro.category_id
    left join "positions" pos2 on pos2.id = pos.parent_id
  where pro.fiscal_year = 2018
  and pos.code in (select code from selectedIds)
  and pos.level = 500
  and cat.display in (select display from targetCategories)
  and pro.month in (select month from targetMonth)
  group by 
  	"position"
  	,"parentPosition"
  	,"category"
  	,pos.level
  	,pro.month
  ) as districts
UNION ALL
select -- Regions aggregate query
   regions."position"
  ,regions.calendarMonth
  ,regions.category
  ,regions."Actual"
  ,regions."Forecast"
from (
  select -- Regions sub query
  	 pos.code as "position"
  	,cat.display as "category"
  	,to_char(to_timestamp(pro.month::text, 'MMM'),'TMMonth') as calendarMonth
    ,sum(cast(pro.actual as money)) as "Actual"
    ,sum(cast(pro.forecast as money)) as "Forecast"
  from "promotionals" pro
    left join "positions" pos on pos.id = pro.position_id
    left join "promotional_categories" cat on cat.id = pro.category_id
  where pro.fiscal_year = 2018
        and pos.code in (select code from selectedIds)
        and pos.level = 400
        and cat.display in (select display from targetCategories)
        and pro.month in (select month from targetMonth)
group by 
	"position"
	,"category"
	,pos.level
	,pro.month
) as regions
union all
select -- Areas aggregate query
   areas."position"
  ,areas.calendarMonth
  ,areas.category
  ,areas."Actual"
  ,areas."Forecast"
from (
  select -- Areas sub query
  	 pos.code as "position"
  	,cat.display as "category"
  	,to_char(to_timestamp(pro.month::text, 'MMM'),'TMMonth') as calendarMonth
    ,sum(cast(pro.actual as money)) as "Actual"
    ,sum(cast(pro.forecast as money)) as "Forecast"
  from "promotionals" pro
  left join "positions" pos on pos.id = pro.position_id
  left join "promotional_categories" cat on cat.id = pro.category_id
  where pro.fiscal_year = 2018
        and pos.code in (select code from selectedIds)
        and pos.level = 300
        and cat.display in (select display from targetCategories)
        and pro.month in (select month from targetMonth)
  group by 
  	 "position"
    ,"category"
  	,pos.level
  	,pro.month
  ) as areas
) as combined
Group by combined."code", combined."calendarmonth", combined.category
order by (
   case when combined."calendarmonth" = 'April'     then  1 -- This is to order by fiscal month
		when combined."calendarmonth" = 'May'       then  2
		when combined."calendarmonth" = 'June'      then  3
		when combined."calendarmonth" = 'July'      then  4
		when combined."calendarmonth" = 'August'    then  5
		when combined."calendarmonth" = 'September' then  6
		when combined."calendarmonth" = 'October'   then  7
		when combined."calendarmonth" = 'November'  then  8
		when combined."calendarmonth" = 'December'  then  9
		when combined."calendarmonth" = 'January'   then 10
		when combined."calendarmonth" = 'February'  then 11
		when combined."calendarmonth" = 'March'     then 12
		else 0 end) asc,
combined.code asc
