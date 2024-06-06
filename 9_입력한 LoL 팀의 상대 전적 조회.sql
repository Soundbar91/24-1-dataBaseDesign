SET VERIFY OFF;
WITH input AS (SELECT &LoL팀번호 AS team_number FROM dual)
SELECT 
    (CASE 
        WHEN r1.team_id = input.team_number THEN t2.team_name 
        ELSE t1.team_name 
    END) AS opposing_team_name,
    COUNT(CASE WHEN r1.team_id = input.team_number AND r1.result = 'W' THEN 1 
               WHEN r2.team_id = input.team_number AND r2.result = 'W' THEN 1 
          END) AS wins,
    COUNT(CASE WHEN r1.team_id = input.team_number AND r1.result = 'L' THEN 1 
               WHEN r2.team_id = input.team_number AND r2.result = 'L' THEN 1 
          END) AS losses,
    SUM(CASE WHEN r1.team_id = input.team_number THEN r1.set_win 
             ELSE r2.set_win 
        END) AS set_wins,
    SUM(CASE WHEN r1.team_id = input.team_number THEN r1.set_lose 
             ELSE r2.set_lose 
        END) AS set_losses
FROM 
    LoL_eSports_team_records r1
JOIN 
    LoL_eSports_team_records r2 
    ON (r1.record_id = r2.record_id - 1 AND MOD(r1.record_id, 2) = 1) 
    OR (r1.record_id = r2.record_id + 1 AND MOD(r1.record_id, 2) = 0)
JOIN 
    team t1 ON r1.team_id = t1.team_id
JOIN 
    team t2 ON r2.team_id = t2.team_id
JOIN 
    input ON 1 = 1
WHERE 
    input.team_number IN (r1.team_id, r2.team_id)
GROUP BY 
    CASE 
        WHEN r1.team_id = input.team_number THEN t2.team_name 
        ELSE t1.team_name 
    END;