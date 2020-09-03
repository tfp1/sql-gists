select
	 pro.actual
	,pro.forecast
	,pro.month as calendarMonth
	,pos.code as "position"
	,cat.display as "category"
from "promotionals" pro
left join
	"positions" pos on pos.id = pro.position_id
left join
	"promotional_categories" cat on cat.id = pro.category_id
where pro.fiscal_year = 2018
