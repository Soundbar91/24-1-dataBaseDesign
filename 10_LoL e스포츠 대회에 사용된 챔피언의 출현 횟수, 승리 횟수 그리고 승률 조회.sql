SELECT champion AS "챔피언 이름",
       COUNT(*) AS "픽률",
       SUM(CASE WHEN set_result = '승' THEN 1 ELSE 0 END) AS "승리 횟수",
       ROUND(SUM(CASE WHEN set_result = '승' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS "승률"
FROM LoL_eSports_player_records
WHERE appearance = 'Y'
GROUP BY champion
ORDER BY "픽률" DESC;