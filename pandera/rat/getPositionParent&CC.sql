select
	 pos.code,
	 pos.cost_center,
	case when pos.level = 500 then pos.region_code
        when pos.level = 400 then pos.area_code
		end as parent
from "positions" pos
where pos.cost_center is not null
order by 1,2,3;
