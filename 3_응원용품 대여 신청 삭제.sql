-- 유저id, 응원용품id를 입력받아 대여 신청을 취소한다
DELETE FROM cheer_item_rentals
where user_id = '&유저id'
AND cheer_item_id = '&응원용품id'
AND return_date > SYSDATE;
