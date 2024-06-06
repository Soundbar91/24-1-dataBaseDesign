-- 기간의 범위 동안 팀 정보 수정요청이 '처리 완료'가 된 정정요청의 개수에 따라 유저 포인트를 업데이트한다. 
UPDATE member m
SET m.point = m.point + 150
WHERE m.member_id IN (
    SELECT tic.user_id
    FROM team_information_correction tic
    WHERE tic.request_process = '처리 완료'
    AND tic.request_date BETWEEN TO_DATE('&시작날짜', 'YYYY-MM-DD') AND TO_DATE('&마감날짜', 'YYYY-MM-DD')
);