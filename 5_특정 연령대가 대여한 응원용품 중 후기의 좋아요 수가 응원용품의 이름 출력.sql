SELECT ci.cheer_item_name as "인기 상품 TOP 3"
FROM cheer_item ci
JOIN (
    SELECT c.cheer_item_id, SUM(r.likes) AS total_likes
    FROM cheer_item_rentals c
    JOIN cheer_item_reviews r ON c.cheer_item_id = r.cheer_item_id
    JOIN (
        SELECT m.member_id
        FROM member m
        WHERE (EXTRACT(YEAR FROM SYSDATE) - TO_CHAR(date_of_birth, 'YYYY')) BETWEEN &startage AND &endage
    ) a ON c.user_id = a.member_id
    GROUP BY c.cheer_item_id
    ORDER BY total_likes DESC
) most_liked_item ON ci.cheer_item_id = most_liked_item.cheer_item_id
WHERE ROWNUM <= 3;