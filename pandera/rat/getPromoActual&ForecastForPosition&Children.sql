with 
targetPosition as (select p.id from "positions" p where 
p.code = 'R0001' -- Enter the parent position here
),
selectedIds as 
   (select
		p.code
	from "positions" p
	where 
		p.parent_id in (select id from targetPosition)
		or 	p.id in (select id from targetPosition)
   )
select
	 pos.code as "position"
	,cat.display as "category"
	,to_char(to_timestamp(pro.month::text, 'MMM'),'TMMonth') as calendarMonth --uncomment this line if you want all months
    ,sum(cast(pro.actual as money)) as "Actual"
    ,sum(cast(pro.forecast as money)) as "Forecast"
from "promotionals" pro
left join
    "positions" pos on pos.id = pro.position_id
left join
    "promotional_categories" cat on cat.id = pro.category_id
where pro.fiscal_year = 2018
and pos.code in (select code from selectedIds)
and cat.display = 'UNALLOCATED'
and pro.month = 4 --calendar month
group by 1,2,3,pos.level
order by pos.level asc,1 asc
