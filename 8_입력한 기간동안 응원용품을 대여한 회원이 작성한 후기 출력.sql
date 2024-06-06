SELECT
    member.member_id as "회원id",
    member.name AS "회원명",
    member.nickname AS "닉네임",
    cheer_item_rentals.cheer_item_id as "응원용품id",
    cheer_item_reviews.review_date as "후기날짜",
    cheer_item_reviews.likes as "추천수",
    cheer_item_reviews.review_content as "후기내용",
    cheer_item_rentals.rental_region as "대여권역",
    cheer_item_rentals.rental_date as "대여날짜"
FROM member
JOIN cheer_item_rentals ON member.member_id = cheer_item_rentals.user_id
LEFT JOIN cheer_item_reviews ON member.member_id = cheer_item_reviews.user_id AND cheer_item_rentals.cheer_item_id = cheer_item_reviews.cheer_item_id
WHERE cheer_item_rentals.rental_date BETWEEN TO_DATE('&시작날짜', 'YYYY-MM-DD') AND TO_DATE('&마감날짜', 'YYYY-MM-DD')
ORDER BY member.member_id, cheer_item_rentals.rental_date;