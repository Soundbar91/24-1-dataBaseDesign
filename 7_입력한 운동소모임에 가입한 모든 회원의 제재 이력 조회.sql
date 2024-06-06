SELECT m.name AS "이름", 
    s.sanction_date AS "가입일자", 
    s.sanction_reason AS "제재사유"
FROM member m
JOIN sanction_log s ON m.member_id = s.member_id
JOIN exercise_clubs_join ecj ON m.member_id = ecj.user_id
WHERE ecj.club_number = &운동소모임id;