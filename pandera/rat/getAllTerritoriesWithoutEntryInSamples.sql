 select
        count(d.name) as "Drug",
        pos2.code as "District",
        u2.email as "DBM",
        pos.code as "Territory",
        u.email as "Rep" 
    from
        positions pos 
    left join
        samples s 
            on pos.id = s.position_id 
    left join
        drugs d 
            on d.id = s.drug_id 
    left join
        user_assignments ua 
            on ua.position_id = pos.id 
    left join
        users u 
            on u.id = ua.user_id 
    left join
        positions pos2 
            on pos2.id = pos.parent_id 
    left join
        user_assignments ua2 
            on ua2.position_id = pos2.id 
    left join
        users u2 
            on u2.id = ua2.user_id 
    where
        pos.business_group_code not in (
            'BG_SSF', 'BG_KAM'
        ) 
        and u.email is not null 
        and u.email != 'unassigned' 
        and pos.level = 600 
    group by
        2,
        3,
        4,
        5 
    having
        count(d.name) < 13 
    union all 
    
    select
        count(d.name) as "Drug",
        pos2.code as "District",
        u2.email as "DBM",
        pos.code as "Territory",
        u.email as "Rep" 
    from positions pos 
    left join samples s on pos.id = s.position_id 
    left join drugs d on d.id = s.drug_id 
    left join user_assignments ua on ua.position_id = pos.id 
    left join users u on u.id = ua.user_id 
    left join positions pos2 on pos2.id = pos.parent_id 
    left join user_assignments ua2 on ua2.position_id = pos2.id 
    left join users u2 on u2.id = ua2.user_id 
    where
        pos.business_group_code not in ('BG_SSF', 'BG_KAM') 
        and u.email is not null 
        and u.email != 'unassigned' 
        and s.id is null 
        and pos.level = 600 
    group by
        2,3,4,5 ;
