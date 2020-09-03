select
 pos.code
,pos.level
,u.email
,at.display
 from positions pos 
left join user_assignments ua on ua.position_id = pos.id
left join users u on ua.user_id = u.id
left join assignment_types at on ua.assignment_type_id = at.id
where u.email = '***' --Insert User Email here
