SELECT p.name AS "선수 이름",
       b.total_hits AS "총 안타수",
       b.total_at_bats AS "총 타수",
       TO_CHAR(b.total_hits / NULLIF(b.total_at_bats, 0), '0.000') AS "타율"
FROM players p
JOIN (
  SELECT player_id,
         SUM(hits) AS total_hits,
         SUM(at_bats) AS total_at_bats
  FROM baseball_hitter_records
  GROUP BY player_id
) b ON p.player_id = b.player_id
WHERE p.position = '타자' AND EXTRACT(YEAR FROM p.birthdate) < 1990
ORDER BY "타율" DESC;