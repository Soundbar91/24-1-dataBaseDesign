-- 멤버
CREATE TABLE member (
    member_id          VARCHAR2(20) PRIMARY KEY,
    password           VARCHAR2(20) NOT NULL,
    name               VARCHAR2(30) NOT NULL,
    nickname           VARCHAR2(30) DEFAULT 'user' NOT NULL,
    email              VARCHAR2(100) NOT NULL UNIQUE,
    address            VARCHAR2(100),
    date_of_birth      DATE NOT NULL,
    account_type       VARCHAR2(255) DEFAULT '활동계정' NOT NULL CHECK (account_type IN ('활동계정', '휴면계정')),
    point              NUMBER(7) DEFAULT 0 NOT NULL CHECK (point >= 0),
    registration_date  DATE DEFAULT SYSDATE NOT NULL,
    CHECK (REGEXP_LIKE(email, '^[A-Za-z0-9]+@[A-Za-z0-9]+\.[A-Z|a-z]{2,}$')),
    CHECK (REGEXP_LIKE(member_id, '^[A-Za-z0-9]{6,}$')),
    CHECK (REGEXP_LIKE(password, '^[A-Za-z0-9!@#$%^*+=-]{8,}$'))
);

-- 팀
CREATE TABLE team (
    team_id NUMBER(10) PRIMARY KEY,
    team_name VARCHAR2(255) NOT NULL,
    corporation_name VARCHAR2(255),
    foundation_date DATE,
    league_affiliation VARCHAR2(20) CHECK (league_affiliation IN ('KBO', 'K리그', 'LCK')),
    team_type VARCHAR2(255) CHECK (team_type IN ('시민 구단', '기업 구단', '도민 구단', '군경 구단', '사회적 협동조합구단', '프로게임단')),
    based_in VARCHAR2(255),
    coach VARCHAR2(10),
    captain VARCHAR2(10),
    fan_interest_count NUMBER(8) DEFAULT 0
);

-- 관심팀_등록하다
CREATE TABLE favorite_teams_register (
    user_id VARCHAR2(20),
    team_id NUMBER(10),
    register_date DATE DEFAULT SYSDATE,
    PRIMARY KEY (user_id, team_id),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

-- 제재이력
CREATE TABLE sanction_log (
    member_id         VARCHAR2(20),
    sanction_id       NUMBER(10),
    sanction_date     DATE DEFAULT SYSDATE NOT NULL,
    sanction_reason   VARCHAR2(30) NOT NULL CHECK (sanction_reason IN ('부적절한 게시글 작성', '부적절한 댓글 작성', '예약 불이행', '반납 연체', '기타')),
    PRIMARY KEY (sanction_id),
    FOREIGN KEY (member_id) REFERENCES member(member_id)
);

-- 응원용품
CREATE TABLE cheer_item (
    cheer_item_id NUMBER(10) PRIMARY KEY,
    cheer_item_name VARCHAR2(255) NOT NULL,
    quantity NUMBER(3) NOT NULL CHECK (quantity >= 1),
    description VARCHAR2(2000) NOT NULL,
    guide VARCHAR2(2000) NOT NULL,
    points_consumed NUMBER(7) NOT NULL CHECK (points_consumed >= 1),
    available_for_rent CHAR(1) NOT NULL CHECK (available_for_rent IN ('Y', 'N'))
);

-- 응원용품_찜하다
CREATE TABLE cheer_item_likes (
    user_id VARCHAR2(20),
    cheer_item_id NUMBER(10),
    liked_date DATE DEFAULT SYSDATE NOT NULL,
    PRIMARY KEY (user_id, cheer_item_id),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (cheer_item_id) REFERENCES cheer_item(cheer_item_id)
);

-- 응원용품_대여하다
CREATE TABLE cheer_item_rentals (
    user_id VARCHAR2(20),
    cheer_item_id NUMBER(10),
    rental_date DATE DEFAULT SYSDATE NOT NULL,
    rental_region VARCHAR2(10) NOT NULL CHECK (rental_region IN ('서울', '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주')),
    return_date DATE DEFAULT SYSDATE + 7 NOT NULL,
    rental_quantity NUMBER(3) NOT NULL CHECK (rental_quantity >= 1),
    PRIMARY KEY (user_id, cheer_item_id, rental_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (cheer_item_id) REFERENCES cheer_item(cheer_item_id)
);

-- 응원용품_반납하다
CREATE TABLE cheer_item_returns (
    user_id VARCHAR2(20),
    cheer_item_id NUMBER(10),
    return_date DATE DEFAULT SYSDATE NOT NULL,
    PRIMARY KEY (user_id, cheer_item_id, return_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (cheer_item_id) REFERENCES cheer_item(cheer_item_id)
);

-- 응원용품_문의하다
CREATE TABLE cheer_item_inquires (
    user_id VARCHAR2(20),
    cheer_item_id NUMBER(10),
    inquire_date DATE DEFAULT SYSDATE NOT NULL,
    title VARCHAR2(255) NOT NULL,
    is_public CHAR(1) DEFAULT 'Y' NOT NULL CHECK (is_public IN ('Y', 'N')),
    response VARCHAR2(2000),
    inquiry_content VARCHAR2(2000) NOT NULL,
    PRIMARY KEY (user_id, cheer_item_id, inquire_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (cheer_item_id) REFERENCES cheer_item(cheer_item_id)
);

-- 응원용품_후기작성하다
CREATE TABLE cheer_item_reviews (
    user_id VARCHAR2(20),
    cheer_item_id NUMBER(10),
    review_date DATE DEFAULT SYSDATE,
    likes NUMBER(20) DEFAULT 0 NOT NULL,
    review_content VARCHAR2(2000) NOT NULL,
    PRIMARY KEY (user_id, cheer_item_id, review_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (cheer_item_id) REFERENCES cheer_item(cheer_item_id)
);

-- 게시판
CREATE TABLE board (
    board_id NUMBER(10) PRIMARY KEY,
    board_name VARCHAR2(255) NOT NULL
);

-- 게시글
CREATE TABLE post (
    user_id VARCHAR2(20) NOT NULL,
    board_id NUMBER(10) NOT NULL,
    post_id NUMBER(10) PRIMARY KEY,
    post_header VARCHAR2(20) CHECK (post_header IN ('야구', '축구', 'LOL e스포츠', '운동소모임')),
    post_title VARCHAR2(255) NOT NULL,
    post_context VARCHAR2(2000) NOT NULL,
    created_at DATE DEFAULT SYSDATE NOT NULL,
    likes NUMBER(8) DEFAULT 0 NOT NULL,
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (board_id) REFERENCES board(board_id)
);

-- 댓글
CREATE TABLE comments (
    comment_id NUMBER(10) PRIMARY KEY,
    comment_content VARCHAR2(255) NOT NULL,
    created_at DATE DEFAULT SYSDATE NOT NULL,
    post_id NUMBER(10) NOT NULL,
    user_id VARCHAR2(20) NOT NULL,
    FOREIGN KEY (post_id) REFERENCES post(post_id),
    FOREIGN KEY (user_id) REFERENCES member(member_id)
);

-- 게시글_삭제요청하다
CREATE TABLE post_deletion (
    user_id VARCHAR2(20),
    post_id NUMBER(10),
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) DEFAULT '접수 중' NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, post_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (post_id) REFERENCES post(post_id)
);

-- 댓글_삭제요청하다
CREATE TABLE comment_deletion (
    user_id VARCHAR2(20),
    comment_id NUMBER(10),
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) DEFAULT '접수 중' NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, comment_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (comment_id) REFERENCES comments(comment_id)
);

-- 운동소모임
CREATE TABLE exercise_clubs (
    user_id VARCHAR2(20) NOT NULL,
    club_number NUMBER(10) PRIMARY KEY,
    club_name VARCHAR2(255) NOT NULL,
    region VARCHAR2(10) NOT NULL CHECK (region IN ('서울', '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주')),
    sports VARCHAR2(10) NOT NULL CHECK (sports IN ('야구', '축구', 'LoL')),
    meeting_date DATE NOT NULL,
    current_members NUMBER(8) DEFAULT 1 CHECK (current_members >= 1),
    FOREIGN KEY (user_id) REFERENCES member(member_id)
);

-- 운동소모임_참가하다
CREATE TABLE exercise_clubs_join (
    user_id VARCHAR2(20),
    club_number NUMBER(10),
    join_date DATE DEFAULT SYSDATE NOT NULL,
    secession_date DATE,
    PRIMARY KEY (user_id, club_number, join_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (club_number) REFERENCES exercise_clubs(club_number)
);

-- 굿즈
CREATE TABLE goods (
    goods_id NUMBER(10) PRIMARY KEY,
    goods_type VARCHAR2(20) NOT NULL CHECK (goods_type IN ('유니폼', '모자', '피규어', '스포츠장비', '기타')),
    goods_name VARCHAR2(100) NOT NULL,
    release_date DATE NOT NULL,
    recommend_count NUMBER(10) DEFAULT 0 NOT NULL
);

-- 판매링크
CREATE TABLE salesLink (
    goods_id NUMBER(10),
    sales_site VARCHAR2(100),
    PRIMARY KEY (goods_id, sales_site),
    FOREIGN KEY (goods_id) REFERENCES goods(goods_id)
);

-- 굿즈_관심목록_등록하다
CREATE TABLE goods_favorites (
    user_id VARCHAR2(20),
    goods_id NUMBER(10),
    added_date DATE DEFAULT SYSDATE NOT NULL,
    PRIMARY KEY (user_id, goods_id),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (goods_id) REFERENCES goods(goods_id)
);

-- 선수
CREATE TABLE players (
    player_id NUMBER(10) PRIMARY KEY,
    team_id NUMBER(8),
    name VARCHAR2(20) NOT NULL,
    birthdate DATE NOT NULL,
    nationality VARCHAR2(10) NOT NULL,
    shirt_number NUMBER(2),
    position VARCHAR2(20) CHECK (position IN ('수비수', '미드필더', '공격수', '골키퍼', '투수', '타자', '미드', '정글', '탑', '원딜', '서폿')),
    status VARCHAR2(20) CHECK (status IN ('소속', '무소속')),
    affiliation_date DATE,
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

-- SNS주소
CREATE TABLE social_media_accounts (
    player_id NUMBER(10),
    SNS VARCHAR2(255),
    PRIMARY KEY (player_id, SNS),
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);

-- 선수정보_수정요청하다
CREATE TABLE player_information_correction (
    user_id VARCHAR2(20),
    player_id NUMBER(10),
    request_date DATE,
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, player_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);

-- 팀정보_수정요청하다
CREATE TABLE team_information_correction (
    user_id VARCHAR2(20),
    team_id NUMBER(10),
    request_date DATE,
    request_context VARCHAR2(2000),
    request_process VARCHAR2(20) DEFAULT '접수 중' CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, team_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

-- 야구_타자기록
CREATE TABLE baseball_hitter_records (
    player_id NUMBER(10) NOT NULL,
    record_id NUMBER(10) PRIMARY KEY,
    appearance CHAR(1)NOT NULL CHECK (appearance IN ('Y', 'N')),
    starting_appearance CHAR(1) NOT NULL CHECK (starting_appearance IN ('Y', 'N')),
    plate_appearance NUMBER(10) DEFAULT 0 NOT NULL CHECK (plate_appearance >= 0),
    at_bats NUMBER(10) DEFAULT 0 NOT NULL CHECK (at_bats >= 0),
    hits NUMBER(10) DEFAULT 0 NOT NULL CHECK (hits >= 0),
    doubles NUMBER(10) DEFAULT 0 NOT NULL CHECK (doubles >= 0),
    triples NUMBER(10) DEFAULT 0 NOT NULL CHECK (triples >= 0),
    home_runs NUMBER(10) DEFAULT 0 NOT NULL CHECK (home_runs >= 0),
    runs_batted_in NUMBER(10) DEFAULT 0 NOT NULL CHECK (runs_batted_in >= 0),
    runs_scored NUMBER(10) DEFAULT 0 NOT NULL CHECK (runs_scored >= 0),
    walks NUMBER(10) DEFAULT 0 NOT NULL CHECK (walks >= 0),
    hit_by_pitch NUMBER(10) DEFAULT 0 NOT NULL CHECK (hit_by_pitch >= 0),
    strikeouts NUMBER(10) DEFAULT 0 NOT NULL CHECK (strikeouts >= 0),
    stolen_bases NUMBER(10) DEFAULT 0 NOT NULL CHECK (stolen_bases >= 0),
    caught_stealing NUMBER(10) DEFAULT 0 NOT NULL CHECK (caught_stealing >= 0),
    double_plays NUMBER(10) DEFAULT 0 NOT NULL CHECK (double_plays >= 0),
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);

-- 야구_투수기록
CREATE TABLE baseball_pitcher_records (
    player_id NUMBER(10) NOT NULL,
    record_id NUMBER(10) PRIMARY KEY,
    appearance CHAR(1) NOT NULL CHECK (appearance IN ('Y', 'N')),
    starting_appearance CHAR(1) NOT NULL CHECK (starting_appearance IN ('Y', 'N')),
    result VARCHAR2(10) NOT NULL CHECK (result IN ('승', '패', '세이브', '홀드', 'N')),
    complete_games CHAR(1) NOT NULL CHECK (complete_games IN ('Y', 'N')),
    shutouts CHAR(1) NOT NULL CHECK (shutouts IN ('Y', 'N')),
    innings_pitched NUMBER(10) DEFAULT 0 CHECK (innings_pitched >= 0) NOT NULL,
    strikeouts NUMBER(10) DEFAULT 0 CHECK (strikeouts >= 0) NOT NULL,
    walks NUMBER(10) DEFAULT 0 CHECK (walks >= 0) NOT NULL,
    hit_by_pitch NUMBER(10) DEFAULT 0 CHECK (hit_by_pitch >= 0) NOT NULL,
    runs_allowed NUMBER(10) DEFAULT 0 CHECK (runs_allowed >= 0) NOT NULL,
    earned_runs NUMBER(10) DEFAULT 0 CHECK (earned_runs >= 0) NOT NULL,
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);

-- 야구_팀기록
CREATE TABLE baseball_team_records (
    team_id NUMBER(10) NOT NULL,
    record_id NUMBER(10) PRIMARY KEY,
    game_result VARCHAR2(10) CHECK (game_result IN ('승', '패')),
    runs_scored NUMBER(10) DEFAULT 0 NOT NULL CHECK (runs_scored >= 0),
    runs_allowed NUMBER(10) DEFAULT 0 NOT NULL CHECK (runs_allowed >= 0),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

-- 축구_필더기록
CREATE TABLE soccer_field_records (
    player_id NUMBER(10) NOT NULL,
    record_id NUMBER(10) PRIMARY KEY,
    appearance CHAR(1) NOT NULL CHECK (appearance IN ('Y', 'N')),
    starting_appearance CHAR(1) NOT NULL CHECK (starting_appearance IN ('Y', 'N')),
    goals NUMBER(10) DEFAULT 0 NOT NULL CHECK (goals >= 0),
    assists NUMBER(10) DEFAULT 0 NOT NULL CHECK (assists >= 0),
    corners NUMBER(10) DEFAULT 0 NOT NULL CHECK (corners >= 0),
    free_kicks NUMBER(10) DEFAULT 0 NOT NULL CHECK (free_kicks >= 0),
    penalties NUMBER(10) DEFAULT 0 NOT NULL CHECK (penalties >= 0),
    fouls NUMBER(10) DEFAULT 0 NOT NULL CHECK (fouls >= 0),
    shots NUMBER(10) DEFAULT 0 NOT NULL CHECK (shots >= 0),
    shots_on_target NUMBER(10) DEFAULT 0 NOT NULL CHECK (shots_on_target >= 0),
    offsides NUMBER(10) DEFAULT 0 NOT NULL CHECK (offsides >= 0),
    pass_attempts NUMBER(10) DEFAULT 0 NOT NULL CHECK (pass_attempts >= 0),
    pass_successes NUMBER(10) DEFAULT 0 NOT NULL CHECK (pass_successes >= 0),
    interceptions NUMBER(10) DEFAULT 0 NOT NULL CHECK (interceptions >= 0),
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);

-- 축구_골키퍼기록
CREATE TABLE soccer_goalkeeper_records (
    player_id NUMBER(10) NOT NULL,
    record_id NUMBER(10) PRIMARY KEY,
    appearance CHAR(1) NOT NULL CHECK (appearance IN ('Y', 'N')),
    starting_appearance CHAR(1) NOT NULL CHECK (starting_appearance IN ('Y', 'N')),
    goals_conceded NUMBER(10) DEFAULT 0 NOT NULL CHECK (goals_conceded >= 0),
    saves NUMBER(10) DEFAULT 0 NOT NULL CHECK (saves >= 0),
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);

-- 축구_팀기록
CREATE TABLE soccer_team_records (
    team_id NUMBER(10) NOT NULL,
    record_id NUMBER(10) PRIMARY KEY,
    game_result VARCHAR2(10) NOT NULL CHECK (game_result IN ('승', '패')),
    goals_scored NUMBER(10) DEFAULT 0 NOT NULL CHECK (goals_scored >= 0),
    goals_conceded NUMBER(10) DEFAULT 0 NOT NULL CHECK (goals_conceded >= 0),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

-- LoL_e스포츠_선수기록
CREATE TABLE LoL_eSports_player_records (
    player_id NUMBER(10) NOT NULL,
    record_id NUMBER(10) PRIMARY KEY,
    appearance CHAR(1) NOT NULL CHECK (appearance IN ('Y', 'N')),
    set_result VARCHAR2(10) NOT NULL CHECK (set_result IN ('승', '패', 'N')),
    champion VARCHAR2(50) NOT NULL,
    kill NUMBER(8) NOT NULL,
    deaths NUMBER(8) NOT NULL,
    assist NUMBER(8) NOT NULL,
    gold_earned NUMBER(8) NOT NULL,
    damage_dealt NUMBER(8) NOT NULL,
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);

-- LoL_e스포츠_팀기록
CREATE TABLE LoL_eSports_team_records (
    team_id NUMBER(10) NOT NULL,
    record_id NUMBER(10) PRIMARY KEY,
    game_name VARCHAR2(255),
    result CHAR(8) NOT NULL CHECK (result IN ('W', 'L')),
    set_win NUMBER(8) DEFAULT '0' NOT NULL,
    set_lose NUMBER(8) DEFAULT '0' NOT NULL,
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

-- 야구_투수기록_정정요청하다
CREATE TABLE baseball_pitcher_corr (
    user_id VARCHAR2(20) NOT NULL,
    baseball_pitcher_record_id NUMBER(10) NOT NULL,
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_property VARCHAR2(20) NOT NULL CHECK (request_property IN ('출장여부', '선발출장여부', '경기결과', '완투', '완봉', '이닝', '탈삼진', '볼넷', '사구', '실점', '자책점')),
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, baseball_pitcher_record_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (baseball_pitcher_record_id) REFERENCES baseball_pitcher_records(record_id)
);

-- 야구_타자기록_정정요청하다
CREATE TABLE baseball_hitter_corr (
    user_id VARCHAR2(20) NOT NULL,
    baseball_hitter_record_id NUMBER(10) NOT NULL,
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_property VARCHAR2(20) NOT NULL CHECK (request_property IN ('출장여부', '선발출장여부', '타석', '타수', '안타', '2루타', '3루타', '홈런', '타점', '득점', '볼넷', '사구', '삼진', '도루', '도루실패', '병살타')),
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, baseball_hitter_record_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (baseball_hitter_record_id) REFERENCES baseball_hitter_records(record_id)
);

-- 야구_팀기록_정정요청하다
CREATE TABLE baseball_team_corr (
    user_id VARCHAR2(20) NOT NULL,
    baseball_team_record_id NUMBER(10) NOT NULL,
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_property VARCHAR2(20) NOT NULL CHECK (request_property IN ('경기결과', '득점', '실점')),
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, baseball_team_record_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (baseball_team_record_id) REFERENCES baseball_team_records(record_id)
);

-- 축구_골키퍼기록_정정요청하다
CREATE TABLE soccer_gk_corr (
    user_id VARCHAR2(20) NOT NULL,
    soccer_goalkeeper_record_id NUMBER(10) NOT NULL,
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_property VARCHAR2(20) NOT NULL CHECK (request_property IN ('출장여부', '선발출장여부', '실점', '선방')),
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, soccer_goalkeeper_record_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (soccer_goalkeeper_record_id) REFERENCES soccer_goalkeeper_records(record_id)
);

-- 축구_필더기록_정정요청하다
CREATE TABLE soccer_fielder_corr (
    user_id VARCHAR2(20) NOT NULL,
    soccer_fielder_record_id NUMBER(10) NOT NULL,
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_property VARCHAR2(20) NOT NULL CHECK (request_property IN ('출장여부', '선발출장여부', '득점', '도움', '코너킥', '프리킥', '패널티킥', '파울', '슈팅', '유효슈팅', '오프사이드', '패스시도', '패스성공', '패스성공률', '인터셉트')),
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, soccer_fielder_record_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (soccer_fielder_record_id) REFERENCES soccer_field_records(record_id)
);

-- 축구_팀기록_정정요청하다
CREATE TABLE soccer_team_corr (
    user_id VARCHAR2(20) NOT NULL,
    soccer_team_record_id NUMBER(10) NOT NULL,
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_property VARCHAR2(20) NOT NULL CHECK (request_property IN ('경기결과', '득점', '실점')),
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, soccer_team_record_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (soccer_team_record_id) REFERENCES soccer_team_records(record_id)
);

-- LoL_e스포츠_팀기록_정정요청하다
CREATE TABLE LoL_team_record_correction (
    user_id VARCHAR2(20) NOT NULL,
    lol_team_record_id NUMBER(10) NOT NULL,
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_property VARCHAR2(20) NOT NULL CHECK (request_property IN ('대회명', '결과', '세트승', '세트패')),
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, lol_team_record_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (lol_team_record_id) REFERENCES LoL_eSports_team_records(record_id)
);

-- LoL_e스포츠_선수기록_정정요청하다
CREATE TABLE LoL_player_record_correction (
    user_id VARCHAR2(20) NOT NULL,
    lol_player_record_id NUMBER(10) NOT NULL,
    request_date DATE DEFAULT SYSDATE NOT NULL,
    request_property VARCHAR2(20) NOT NULL CHECK (request_property IN ('출전여부', '세트결과', '포지션', '킬', '데스', '어시스트', '획득골드', '데미지')),
    request_context VARCHAR2(2000) NOT NULL,
    request_process VARCHAR2(20) NOT NULL CHECK (request_process IN ('접수 중', '처리 중', '반려', '처리 완료')),
    PRIMARY KEY (user_id, lol_player_record_id, request_date),
    FOREIGN KEY (user_id) REFERENCES member(member_id),
    FOREIGN KEY (lol_player_record_id) REFERENCES LoL_eSports_player_records(record_id)
);

-- 인덱스 생성
CREATE INDEX mem_name_idx ON member(name);
CREATE INDEX cheer_item_idx ON cheer_item(cheer_item_name);
CREATE INDEX player_name_idx ON players(name);

-- 회원 ㅌ
INSERT INTO member VALUES ('user01', 'password01', '홍길동', '길동이', 'hong01@domain.com', '서울시 강남구', TO_DATE('1990-01-01', 'YYYY-MM-DD'), '활동계정', 1000, SYSDATE);
INSERT INTO member VALUES ('user02', 'password02', '김철수', '철수', 'kimcs@domain.com', '서울시 마포구', TO_DATE('1992-02-02', 'YYYY-MM-DD'), '활동계정', 1500, SYSDATE);
INSERT INTO member VALUES ('user03', 'password03', '이영희', '영희', 'lee@domain.com', '부산시 해운대구', TO_DATE('1993-03-03', 'YYYY-MM-DD'), '휴면계정', 200, SYSDATE);
INSERT INTO member VALUES ('user04', 'password04', '장민호', '민호', 'jang@domain.com', '대구시 중구', TO_DATE('1994-04-04', 'YYYY-MM-DD'), '활동계정', 2500, SYSDATE);
INSERT INTO member VALUES ('user05', 'password05', '윤소라', '소라', 'yoon@domain.com', '인천시 남동구', TO_DATE('1995-05-05', 'YYYY-MM-DD'), '활동계정', 1250, SYSDATE);
INSERT INTO member VALUES ('user06', 'password06', '김철수', '지민', 'parkjm@domain.com', '광주시 서구', TO_DATE('1996-06-06', 'YYYY-MM-DD'), '휴면계정', 500, SYSDATE);
INSERT INTO member VALUES ('ab34cd', 'password07', '홍길동', '윤기', 'choi@domain.com', '울산시 남구', TO_DATE('1997-07-07', 'YYYY-MM-DD'), '활동계정', 3000, SYSDATE);
INSERT INTO member VALUES ('user07', 'password08', '가나다', '호석', 'jeong@domain.com', '대전시 동구', TO_DATE('1998-08-08', 'YYYY-MM-DD'), '활동계정', 1750, SYSDATE);
INSERT INTO member VALUES ('user08', 'password09', '이영희', 'young', 'son@domain.com', '세종시', TO_DATE('1999-09-09', 'YYYY-MM-DD'), '휴면계정', 800, SYSDATE);
INSERT INTO member VALUES ('user09', 'password10', '김태형', DEFAULT, 'kimth@domain.com', '경기도 수원시', TO_DATE('2000-10-10', 'YYYY-MM-DD'), DEFAULT, 2200, SYSDATE);
INSERT INTO member VALUES ('kd03gks', 'password11', '김하늘', DEFAULT, 'kimhn@domain.com', '서울시 종로구', TO_DATE('1991-11-11', 'YYYY-MM-DD'), '활동계정', 1100, SYSDATE);
INSERT INTO member VALUES ('user10', 'password12', '이태리', '태리', 'lee1@domain.com', '부산시 남구', TO_DATE('1992-12-12', 'YYYY-MM-DD'), '활동계정', 1200, SYSDATE);
INSERT INTO member VALUES ('shin99', 'password1!@', '김철수', 'kimchul', 'kimchulsoo@example.com', '서울시 종로구', TO_DATE('1985-08-21', 'YYYY-MM-DD'), DEFAULT, 50, SYSDATE);
INSERT INTO member VALUES ('johndoe25', 'pa$$w0rd', 'John Doe', 'johnd', 'johndoe@example.com', 'New York', TO_DATE('1982-12-10', 'YYYY-MM-DD'), '휴면계정', 75, SYSDATE);
INSERT INTO member VALUES ('amyjohn', '!!!!@@@@@', 'Amy Johnson', 'amyj', 'amjohnson@example.com', NULL, TO_DATE('1988-02-28', 'YYYY-MM-DD'), '활동계정', 300, SYSDATE);
INSERT INTO member VALUES ('user345', 'qwerty12', 'Jane Smith', DEFAULT, 'janesmith@example.com', NULL, TO_DATE('1975-04-30', 'YYYY-MM-DD'), '활동계정', 0, SYSDATE);
INSERT INTO member VALUES ('testuser', 'testpass', 'TestUser', DEFAULT, 'testuser@example.com', 'San Francisco', TO_DATE('1995-07-18', 'YYYY-MM-DD'), '휴면계정', 150, SYSDATE);
INSERT INTO member VALUES ('leeyh7', 'p@ssw0rd', '이영희', 'leeyoung', 'younghee@example.com', '경기도 수원시', TO_DATE('1982-10-20', 'YYYY-MM-DD'), '활동계정', 80, SYSDATE);
INSERT INTO member VALUES ('minmin890', 'pass!@#word', '박민수', 'parkmin', 'minsu@example.com', '인천광역시 남동구', TO_DATE('1991-06-25', 'YYYY-MM-DD'), '휴면계정', 120, SYSDATE);
INSERT INTO member VALUES ('minh5012', 'myp@ssw0rd', '이민호', 'leemin', 'minho@example.com', NULL, TO_DATE('1993-11-05', 'YYYY-MM-DD'), '휴면계정', 180, SYSDATE);
INSERT INTO member VALUES ('3948024', 'qwerty@123', '정유진', 'jungyujin', 'yujin@example.com', '부산광역시 부산진구', TO_DATE('1989-03-10', 'YYYY-MM-DD'), DEFAULT, 250, SYSDATE);
INSERT INTO member VALUES ('kimji1234', 'password@1234', '김지훈', 'kimjihun', 'jihun@example.com', '강원도 춘천시', TO_DATE('1994-09-15', 'YYYY-MM-DD'), '활동계정', 350, SYSDATE);
INSERT INTO member VALUES ('woif308', '78904567', '윤소라', '소라', 'yoonso@domain.com', '인천시 남동구', TO_DATE('1995-05-05', 'YYYY-MM-DD'), '활동계정', 1250, SYSDATE);
INSERT INTO member VALUES ('suuu5678', 'pass-@w0rd', '이수민', DEFAULT, 'sumin@example.com', '경상북도 포항시', TO_DATE('1987-07-30', 'YYYY-MM-DD'), '휴면계정', 220, SYSDATE);

-- 제재이력 ㅌ
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user01', 1, TO_DATE('2024-05-01', 'YYYY-MM-DD'), '부적절한 게시글 작성');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user02', 2, TO_DATE('2024-04-15', 'YYYY-MM-DD'), '부적절한 댓글 작성');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user03', 3, TO_DATE('2024-04-10', 'YYYY-MM-DD'), '예약 불이행');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user04', 4, TO_DATE('2024-03-25', 'YYYY-MM-DD'), '반납 연체');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user01', 5, TO_DATE('2024-03-10', 'YYYY-MM-DD'), '기타');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user02', 6, TO_DATE('2024-02-25', 'YYYY-MM-DD'), '부적절한 게시글 작성');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user03', 7, TO_DATE('2024-02-10', 'YYYY-MM-DD'), '부적절한 댓글 작성');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user04', 8, TO_DATE('2024-01-25', 'YYYY-MM-DD'), '예약 불이행');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user01', 9, TO_DATE('2024-01-10', 'YYYY-MM-DD'), '반납 연체');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user02', 10, TO_DATE('2023-12-25', 'YYYY-MM-DD'), '기타');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user05', 11, TO_DATE('2023-12-10', 'YYYY-MM-DD'), '부적절한 게시글 작성');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user06', 12, TO_DATE('2023-11-25', 'YYYY-MM-DD'), '부적절한 댓글 작성');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user07', 13, TO_DATE('2023-11-10', 'YYYY-MM-DD'), '예약 불이행');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user08', 14, TO_DATE('2023-10-25', 'YYYY-MM-DD'), '반납 연체');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user09', 15, TO_DATE('2023-10-10', 'YYYY-MM-DD'), '기타');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user10', 16, TO_DATE('2023-09-25', 'YYYY-MM-DD'), '부적절한 게시글 작성');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user05', 17, TO_DATE('2023-09-10', 'YYYY-MM-DD'), '부적절한 댓글 작성');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user06', 18, TO_DATE('2023-08-25', 'YYYY-MM-DD'), '예약 불이행');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user07', 19, TO_DATE('2023-08-10', 'YYYY-MM-DD'), '반납 연체');
INSERT INTO sanction_log (member_id, sanction_id, sanction_date, sanction_reason) VALUES ('user08', 20, TO_DATE('2023-07-25', 'YYYY-MM-DD'), '기타');

-- 팀 ㅌ
INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10001, 'LG 트윈스', 'LG스포츠', TO_DATE('1982-01-26', 'YYYY-MM-DD'), 'KBO', '기업 구단', '서울특별시', '염경엽', '김현수', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10002, 'kt wiz', '케이티스포츠', TO_DATE('2013-01-17', 'YYYY-MM-DD'), 'KBO', '기업 구단', '경기도 수원시', '이강철', '박경수', 5000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10003, 'SSG 랜더스', '신세계야구단', TO_DATE('2000-03-31', 'YYYY-MM-DD'), 'KBO', '기업 구단', '인천광역시', '이숭용', '추신수', 8000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10004, 'NC 다이노스', '엔씨다이노스', TO_DATE('2011-03-31', 'YYYY-MM-DD'), 'KBO', '기업 구단', '경상남도 창원시', '강인권', '손아섭', 7000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10005, '두산 베어스', '두산베어스', TO_DATE('1982-01-15', 'YYYY-MM-DD'), 'KBO', '기업 구단', '서울특별시', '이승엽', '양석환', 9000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10006, 'KIA 타이거즈', '기아타이거즈', TO_DATE('1982-01-30', 'YYYY-MM-DD'), 'KBO', '기업 구단', '광주광역시', '이범호', '나성범', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10007, '롯데 자이언츠', '롯데자이언츠', TO_DATE('1975-05-06', 'YYYY-MM-DD'), 'KBO', '기업 구단', '부산광역시', '김태형', '전준우', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10008, '삼성 라이온즈', '삼성라이온즈', TO_DATE('1982-02-03', 'YYYY-MM-DD'), 'KBO', '기업 구단', '대구광역시', '박진만', '구자욱', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10009, '한화 이글스', '한화이글스', TO_DATE('1986-03-08', 'YYYY-MM-DD'), 'KBO', '기업 구단', '대전광역시', '김경문', '채은성', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (10010, '키움 히어로즈', '서울히어로즈', TO_DATE('2008-03-24', 'YYYY-MM-DD'), 'KBO', '기업 구단', '서울특별시', '홍원기', '김혜성', 4000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30001, 'Gen.G', '케이에스브이이이스포츠코리아', TO_DATE('2013-09-07', 'YYYY-MM-DD'), 'LCK', '기업 구단', NULL, '김정수', '손시우', 7000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30002, 'T1', '에스케이텔레콤씨에스티원', TO_DATE('2012-12-13', 'YYYY-MM-DD'), 'LCK', '기업 구단', NULL, '김정균', '이상혁', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30003, 'Hanwha Life Esports', '한화생명', TO_DATE('2014-11-14', 'YYYY-MM-DD'), 'LCK', '기업 구단', NULL, '최인규', '한왕호', 6000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30004, 'Dplus KIA', '에이디이스포츠', TO_DATE('2017-05-28', 'YYYY-MM-DD'), 'LCK', '기업 구단', '서울특별시 종로구', '이재민', '허수', 8000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30005, 'kt Rolster', '케이티스포츠', TO_DATE('2012-10-10', 'YYYY-MM-DD'), 'LCK', '기업 구단', NULL, '강동훈', '김혁규', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30006, 'KWANGDONG FREECS', 'SOOP', TO_DATE('2014-04-01', 'YYYY-MM-DD'), 'LCK', '기업 구단', NULL, '김대호', '문우찬', 7000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30007, 'BNK FearX', '4by4', TO_DATE('2016-12-31', 'YYYY-MM-DD'), 'LCK', '기업 구단', '부산광역시', '유상욱', '김정현', 3000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30008, 'Nongshim RedForce', '농심이스포츠', TO_DATE('2016-05-15', 'YYYY-MM-DD'), 'LCK', '기업 구단', NULL, '박승진', '이승복', 3000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30009, 'DRX', '디알엑스', TO_DATE('2012-05-07', 'YYYY-MM-DD'), 'LCK', '기업 구단', NULL, '김목경', '김광희', 6000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (30010, 'OKSavingsBank BRION', '브리온이스포츠', TO_DATE('2012-02-14', 'YYYY-MM-DD'), 'LCK', '기업 구단', NULL, '최우범', '박루한', 3000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (20001, 'FC 서울', '지에스스포츠', TO_DATE('1983-12-22', 'YYYY-MM-DD'), 'K리그', '기업 구단', '서울특별시', '김기동', '기성용', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (20002, '대전 하나 시티즌', '하나금융축구단', TO_DATE('1997-03-12', 'YYYY-MM-DD'), 'K리그', '기업 구단', '대전광역시', '황선홍', '이순민', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (20003, '전북 현대 모터스', '전북현대모터스에프씨', TO_DATE('1994-12-12', 'YYYY-MM-DD'), 'K리그', '기업 구단', '전북특별자치도', '김두현', '김진수', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (20004, '수원 FC', '수원에프씨', TO_DATE('2003-03-15', 'YYYY-MM-DD'), 'K리그', '시민 구단', '전북특별자치도', '김은중', '이용', 10000);

INSERT INTO team (team_id, team_name, corporation_name, foundation_date, league_affiliation, team_type, based_in, coach, captain, fan_interest_count) 
VALUES (20005, '울산 FC', '울산에프씨', TO_DATE('2004-01-01', 'YYYY-MM-DD'), 'K리그', '시민 구단', '울산광역시', '강동호', '김정준', 12000);

-- 관심팀등록하다 ㅌ
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user01', 10001, TO_DATE('2024-05-20', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user02', 10002, TO_DATE('2024-05-18', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user03', 20003, TO_DATE('2024-05-15', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user04', 30004, TO_DATE('2024-05-12', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user05', 10005, TO_DATE('2024-05-10', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user01', 20005, TO_DATE('2024-05-08', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user02', 30007, TO_DATE('2024-05-06', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user03', 10008, TO_DATE('2024-05-04', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user04', 10003, TO_DATE('2024-05-02', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user05', 10004, TO_DATE('2024-05-01', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user06', 10001, TO_DATE('2024-04-29', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user07', 10002, TO_DATE('2024-04-27', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user08', 20003, TO_DATE('2024-04-25', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user09', 30004, TO_DATE('2024-04-23', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user10', 10005, TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user01', 10006, TO_DATE('2024-04-19', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user02', 20004, TO_DATE('2024-04-17', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user03', 20005, TO_DATE('2024-04-15', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user04', 10009, TO_DATE('2024-04-13', 'YYYY-MM-DD'));
INSERT INTO favorite_teams_register (user_id, team_id, register_date) VALUES ('user05', 20001, TO_DATE('2024-04-11', 'YYYY-MM-DD'));

-- 응원용품 ㅌ
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (1, '대한민국 응원 깃발', 20, '태극기 로고가 그려진 큰 깃발', '응원할 때 높이 흔들기', 150, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (2, '대한민국 피켓', 30, '응원 문구가 적혀있는 피켓', '응원 시에 들어 올리기', 100, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (3, '붉은 악마 티셔츠', 50, '붉은 악마가 그려진 티셔츠', '응원할 때 착용하기', 200, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (4, '응원 손목밴드(레드)', 40, '빨간색 손목밴드', '손목에 착용하기', 50, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (5, '태극기 볼캡 응원모자', 25, '태극기 로고가 있는 모자', '응원할 때 착용하기', 120, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (6, '응원 막대풍선(블루)', 60, '응원용 막대풍선', '응원할 때 두드리기', 30, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (7, '응원 막대풍선(레드)', 35, '응원용 소리나는 막대풍선', '응원할 때 두드리기', 30, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (8, '응원용 조끼(블랙)', 40, '검정색 팀 조끼', '응원할 때 착용하기', 150, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (9, '대한민국 응원 부채', 20, '태극기 로고가 있는 부채', '응원할 때 흔들기', 50, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (10, '응원용 나팔(그린)', 80, '초록색 나팔', '응원할 때 힘껏 불기', 10, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (11, '응원용 나팔(레드)', 80, '빨간색 나팔', '응원할 때 힘껏 불기', 10, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (12, '응원용 나팔(블루)', 80, '파란색 나팔', '응원할 때 힘껏 불기', 10, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (13, '붉은 악마 머리띠', 15, '악마 뿔 달린 머리띠', '응원할 때 착용하기', 60, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (14, '점보 태극기 머리띠', 15, '태극기 로고가 있는 머리띠', '응원할 때 착용하기', 60, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (15, '응원 타올', 50, '응원 문구가 적힌 타올', '응원할 때 흔들기', 20, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (16, '대한민국 응원 팔토시', 40, '태극기 로고가 있는 팔토시', '팔에 착용하기', 30, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (17, '붉은 악마 팔토시', 40, '붉은 악마가 그려진 팔토시', '팔에 착용하기', 30, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (18, '응원용 메가폰(블루)', 35, '파란색 메가폰', '응원할 때 힘껏 불기', 45, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (19, '응원용 메가폰(레드)', 35, '빨간색 메가폰', '응원할 때 힘껏 불기', 45, 'Y');
INSERT INTO cheer_item (cheer_item_id, cheer_item_name, quantity, description, guide, points_consumed, available_for_rent) VALUES (20, '응원 포스터', 30, '응원 문구가 적힌 포스터', '응원할 때 들기', 90, 'Y');

-- 응원용품_찜하다
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user01', 1, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user02', 2, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user03', 3, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user04', 1, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user05', 2, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user06', 3, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user07', 7, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user08', 8, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user09', 9, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('ab34cd', 10, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('kd03gks', 11, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user08', 12, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('shin99', 13, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('johndoe25', 14, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user03', 15, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('testuser', 16, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('amyjohn', 17, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user07', 18, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user07', 19, DEFAULT);
INSERT INTO cheer_item_likes (user_id, cheer_item_id, liked_date) VALUES ('user07', 20, DEFAULT);

-- 응원용품_대여하다 ㅌ
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user01', 1, TO_DATE('2024-03-01', 'YYYY-MM-DD'), '서울', DEFAULT, 2);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user02', 2, TO_DATE('2024-03-10', 'YYYY-MM-DD'), '경기', DEFAULT, 3);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user03', 3, TO_DATE('2024-03-07', 'YYYY-MM-DD'), '강원', DEFAULT, 1);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user04', 4, TO_DATE('2024-03-23', 'YYYY-MM-DD'), '충북', DEFAULT, 2);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user05', 5, TO_DATE('2024-03-15', 'YYYY-MM-DD'), '충남', DEFAULT, 1);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user06', 6, TO_DATE('2024-03-30', 'YYYY-MM-DD'), '전북', DEFAULT, 3);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user07', 7, TO_DATE('2024-04-03', 'YYYY-MM-DD'), '전남', DEFAULT, 2);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user08', 8, TO_DATE('2024-04-09', 'YYYY-MM-DD'), '경북', DEFAULT, 1);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user01', 1, TO_DATE('2024-04-11', 'YYYY-MM-DD'), '경남', DEFAULT, 3);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user02', 2, TO_DATE('2024-04-14', 'YYYY-MM-DD'), '제주', DEFAULT, 2);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user03', 1, TO_DATE('2024-04-15', 'YYYY-MM-DD'), '서울', DEFAULT, 1);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user04', 2, TO_DATE('2024-04-20', 'YYYY-MM-DD'), '경기', DEFAULT, 3);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user05', 3, TO_DATE('2024-04-29', 'YYYY-MM-DD'), '강원', DEFAULT, 2);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user06', 4, TO_DATE('2024-05-07', 'YYYY-MM-DD'), '충북', DEFAULT, 1);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user07', 15, TO_DATE('2024-05-13', 'YYYY-MM-DD'), '충남', DEFAULT, 3);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user08', 16, TO_DATE('2024-05-16', 'YYYY-MM-DD'), '전북', DEFAULT, 2);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('leeyh7', 17, TO_DATE('2024-05-20', 'YYYY-MM-DD'), '전남', DEFAULT, 1);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('minh5012', 18, TO_DATE('2024-05-22', 'YYYY-MM-DD'), '경북', DEFAULT, 3);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('kimji1234', 19, TO_DATE('2024-05-27', 'YYYY-MM-DD'), '경남', DEFAULT, 2);
INSERT INTO cheer_item_rentals (user_id, cheer_item_id, rental_date, rental_region, return_date, rental_quantity) VALUES ('user02', 20, TO_DATE('2024-05-31', 'YYYY-MM-DD'), '제주', DEFAULT, 1);

-- 응원용품_반납하다 ㅌ
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user01', 1, TO_DATE('2024-05-01', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user02', 2, TO_DATE('2024-05-02', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user03', 3, TO_DATE('2024-05-03', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user04', 4, TO_DATE('2024-05-04', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user05', 5, TO_DATE('2024-05-05', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user06', 6, TO_DATE('2024-05-21', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user07', 7, TO_DATE('2024-05-11', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user08', 8, TO_DATE('2024-05-31', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user01', 1, TO_DATE('2024-07-01', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user02', 2, TO_DATE('2024-08-11', 'YYYY-MM-DD'));
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user03', 1, DEFAULT);
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user04', 2, DEFAULT);
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user05', 3, DEFAULT);
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user06', 4, DEFAULT);
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user07', 15, DEFAULT);
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user08', 16, DEFAULT);
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('leeyh7', 17, DEFAULT);
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('minh5012', 18, DEFAULT);
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('kimji1234', 19, DEFAULT);
INSERT INTO cheer_item_returns (user_id, cheer_item_id, return_date) VALUES ('user02', 20, DEFAULT);

-- 응원용품_문의하다 ㅐ
INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user01', 1, DEFAULT, '응원 깃발 문의', 'Y', NULL, '응원 깃발의 정확한 크기는 어떻게 되나요?');
INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user02', 2, DEFAULT, '피켓 문의', 'N', '안녕하세요. 해당 제품의 피켓은 폼보드로 제작되었습니다.', '안녕하세요, 피켓의 재질은 무엇인지 알 수 있나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user03', 3, DEFAULT, '티셔츠 사이즈관련 문의', 'Y', NULL, '티셔츠 로고가 훼손되어 있는지 환불 가능한가요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user04', 4, DEFAULT, '손목밴드 색상관련 질문이요', 'Y', '안녕하세요. 현재 손목밴드의 색상은 빨간색 밖에 없는 점 양해부탁드립니다.', '손목밴드의 색상은 빨간색 외에 다른 색상은 아직 준비 중인가요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user05', 5, DEFAULT, '볼캡 모자 사이즈 문의입니다', 'Y', '안녕하세요. 해당 제품의 모자 사이즈는 56~58cm로 제작되어 있습니다.', '혹시 모자의 사이즈는 어떻게 되나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user06', 6, DEFAULT, '막대풍선 소리 관련해서 궁금합니다', 'N', NULL, '막대풍선을 두드리면 어떤 소리가 나나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user07', 7, DEFAULT, '막대풍선 색상 더 없나요', 'Y', '안녕하세요. 막대풍선 색상은 빨간색 이외에도 파란색도 있습니다.', '막대풍선의 색상은 빨간색 외에 다른 색은 없나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user08', 8, DEFAULT, '응원 조끼 사이즈 문의사항', 'N', NULL, '응원 조끼의 사이즈는 어떻게 되나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user09', 9, DEFAULT, '안녕하세요. 응원 부채 크기가 궁금합니다.', 'Y', NULL, '응원 부채의 크기는 어떻게 되나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user10', 10, DEFAULT, '나팔 배송일자가 궁금합니다', 'Y', '안녕하세요. 해당 제품을 주문하시면 주문일 3~5일 정도 도착할 예정입니다.', '혹시 초록색 나팔을 주문하면 언제 도착하는지 알 수 있나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user01', 11, DEFAULT, '나팔 재질관련 질문', 'N', '안녕하세요. 해당 제품의 재질은 PP로 되어있으며, 햇빛에 과도하게 방치하면 변형될 수 있는 점 유의바랍니다.', '빨간색 나팔의 재질이 어떻게 되나요? 쉽게 망가지나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user02', 12, DEFAULT, '나팔 크기가 궁금합니다', 'Y', NULL, '휴대용으로 들고다니고 싶은데 나팔의 크기는 어떻게 되나요? ');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user03', 13, DEFAULT, '머리띠 배송관련 문의', 'Y', '안녕하세요. 해당 제품의 배송 문제로 이틀 뒤로 배송받으실 예정입니다.', '주문한지 3일이 지났는데 배송받지 못했습니다. 언제 오나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user04', 14, DEFAULT, '머리띠 환불 문의입니다', 'N', NULL, '2일 전 배송받은 태극기 머리띠 상태가 불량같아 환불 신청을 하려고합니다');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user05', 15, DEFAULT, '응원 타올 재질이 궁금해요', 'Y', '안녕하세요. 해당 제품은 폴리에스터 재질로 되어 있습니다.', '응원 타올의 재질은 어떻게 되나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user06', 16, DEFAULT, '팔토시 불량이예요', 'N', NULL, '배송받은 팔토시가 두 짝을 주문했는데 한 짝만 왔어요');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user07', 17, DEFAULT, '해당 제품 팔토시 길이는 어떻게 되나요', 'Y', '안녕하세요. 문의하신 팔토시 제품의 길이는 38cm로 되어 있습니다.', '붉은 악마 팔토시의 길이는 어떻게 되나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user09', 18, DEFAULT, '메가폰 크기관련 문의입니다', 'N', NULL, '구매하려는 파란색 메가폰이 있는데 전체적인 크기 어떻게 되나요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user08', 19, DEFAULT, '메가폰 소리 매우 큰가요?', 'Y', NULL, '빨간색 메가폰에서 발생하는 소리는 얼마나 큰지 알 수 있을까요?');

INSERT INTO cheer_item_inquires (user_id, cheer_item_id, inquire_date, title, is_public, response, inquiry_content) 
VALUES ('user10', 20, DEFAULT, '포스터 재질이 궁금해요!', 'N', '안녕하세요. 해당 포스터의 재질은 백상지 용지로 제작되었습니다.', '안녕하세요~ 응원 포스터의 재질은 어떤건지 알 수 있나요?');

-- 응원용품_후기작성하다 ㅐ
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user01', 1, TO_DATE('2024-03-01', 'YYYY-MM-DD'), 10, '응원 깃발이 크고 질이 좋아서 응원할 때 너무 좋았어요!');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user02', 2, TO_DATE('2024-03-10', 'YYYY-MM-DD'), 8, '피켓의 문구가 재미있고 눈에 잘 띄어서 마음에 들었습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user03', 3, TO_DATE('2024-03-07', 'YYYY-MM-DD'), 15, '붉은 악마 티셔츠는 매우 편안하고 디자인도 멋졌습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user04', 4, TO_DATE('2024-03-23', 'YYYY-MM-DD'), 7, '손목밴드가 착용하기 편리하고 응원할 때 포인트가 되었습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user05', 5, TO_DATE('2024-03-15', 'YYYY-MM-DD'), 12, '응원 모자는 잘 맞고 착용감이 좋아서 만족합니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user06', 6, TO_DATE('2024-03-30', 'YYYY-MM-DD'), 0, '막대풍선의 소리가 크고 응원할 때 분위기를 살렸습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user07', 7, TO_DATE('2024-04-03', 'YYYY-MM-DD'), 1, '막대풍선 색상이 선명하고 튼튼해서 좋았습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user08', 8, TO_DATE('2024-04-09', 'YYYY-MM-DD'), 6, '응원 조끼는 착용감이 좋고 응원할 때 유용했습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user01', 1, TO_DATE('2024-04-11', 'YYYY-MM-DD'), 4, '응원 부채가 크고 견고해서 만족했습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user02', 2, TO_DATE('2024-04-14', 'YYYY-MM-DD'), 11, '응원용 나팔은 소리가 크고 멀리까지 들려서 응원에 최적이었습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user03', 3, TO_DATE('2024-04-15', 'YYYY-MM-DD'), 10, '빨간색 나팔의 디자인이 마음에 들고 사용하기 편리했습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user04', 4, TO_DATE('2024-04-20', 'YYYY-MM-DD'), 14, '파란색 나팔의 소리가 매우 인상적이었습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user05', 3, TO_DATE('2024-04-29', 'YYYY-MM-DD'), 3, '붉은 악마 머리띠가 착용감이 좋고 응원할 때 포인트가 되었습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user06', 4, TO_DATE('2024-05-07', 'YYYY-MM-DD'), 7, '점보 태극기 머리띠는 크고 튼튼해서 좋았습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user07', 15, TO_DATE('2024-05-13', 'YYYY-MM-DD'), 5, '응원 타올은 크고 견고해서 매우 만족합니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user08', 16, TO_DATE('2024-05-16', 'YYYY-MM-DD'), 13, '대한민국 응원 팔토시는 착용감이 좋고 디자인도 멋졌습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('leeyh7', 17, TO_DATE('2024-05-20', 'YYYY-MM-DD'), 2, '붉은 악마 팔토시가 착용감이 좋고 응원할 때 유용했습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('minh5012', 18, TO_DATE('2024-05-22', 'YYYY-MM-DD'), 8, '파란색 메가폰의 소리가 크고 응원할 때 매우 유용했습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('kimji1234', 19, TO_DATE('2024-05-27', 'YYYY-MM-DD'), 4, '빨간색 메가폰은 소리가 크고 멀리까지 들려서 좋았습니다.');
INSERT INTO cheer_item_reviews (user_id, cheer_item_id, review_date, likes, review_content) VALUES ('user02', 20, TO_DATE('2024-05-31', 'YYYY-MM-DD'), 6, '응원 포스터는 크고 문구가 선명해서 마음에 들었습니다.');

-- 게시판 ㅌ
INSERT INTO board (board_id, board_name) VALUES (1, '야구 게시판');
INSERT INTO board (board_id, board_name) VALUES (2, '축구 게시판');
INSERT INTO board (board_id, board_name) VALUES (3, 'LOL 게시판');
INSERT INTO board (board_id, board_name) VALUES (4, '운동소모임 게시판');

-- 게시글 ㅐ
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user01', 1, 1, '야구', '야구 경기 결과', '오늘 경기는 정말 재미있었습니다.', DEFAULT, 10);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user02', 2, 2, '축구', '축구 경기 분석', '어제 경기 분석글입니다.', DEFAULT, 20);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user03', 3, 3, 'LOL e스포츠', '결승전 재밌었다', '진팀도 이긴팀도 모두잘한거같아.', DEFAULT, 30);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user04', 4, 4, '운동소모임', '대구 주말 등산 모임', '이번 주말에 등산활동 수요조사를 실시합니다. .', DEFAULT, 5);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user05', 1, 5, '야구', '우리 동네 야구장 방문기', '야구장 분위기가 정말 좋았습니다.', DEFAULT, 15);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user06', 2, 6, '축구', '축구 선수 인터뷰모음집', '좋아하는 선수의 인터뷰를 모아봤습니다.', DEFAULT, 25);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user07', 3, 7, 'LOL e스포츠', 'LOL 챔피언 분석', '이번 패치의 op챔피언을 알아보자.', DEFAULT, 35);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user08', 4, 8, '운동소모임', '자전거 동호회', '자전거 타기 좋은 계절이 왔네요.', DEFAULT, 10);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user09', 1, 9, '야구', '야구장 간식 추천', '경기 보면서 먹기 좋은 간식 추천합니다.', DEFAULT, 20);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user10', 2, 10, '축구', '축구 경기 후기', '어제 경기는 정말 아쉬웠습니다.', DEFAULT, 30);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user01', 3, 11, 'LOL e스포츠', 'LOL 대회 일정', '이번 주 대회 일정입니다.', DEFAULT, 40);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user02', 4, 12, '운동소모임', '탁구 동호회 모집', '탁구 좋아하시는 분들 모집합니다.', DEFAULT, 10);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user03', 1, 13, '야구', '야구 투수 분석', '최고의 투수를 분석해봅시다.', DEFAULT, 15);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user04', 2, 14, '축구', '축구 경기 예상', '다음 경기는 어디가 이길것 같나요?', DEFAULT, 25);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user05', 3, 15, 'LOL e스포츠', 'LOL 팀 전략', '이번 경기의 팀 전략 분석글입니다.', DEFAULT, 35);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user07', 1, 16, '야구', '논란의 야구 선수 이적 소식', '최근 이적한 선수 소식을 전합니다.', DEFAULT, 20);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user06', 2, 17, '축구', '유망한 신인 선수 소개', '이번 시즌에 주목해야 할 신인 선수를 소개합니다.', DEFAULT, 18);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user08', 3, 18, 'LOL e스포츠', '강화된 챔피언 분석', '최근 패치로 강화된 챔피언을 분석해봅니다.', DEFAULT, 30);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user09', 1, 19, '야구', '팀 승률 예측', '다음 시즌 팀의 승률을 예측해봅니다.', DEFAULT, 22);
INSERT INTO post (user_id, board_id, post_id, post_header, post_title, post_context, created_at, likes) VALUES ('user10', 2, 20, '축구', '축구 테크닉 강의', '축구의 기본 테크닉부터 고급 기술까지 소개하는 강의 영상입니다.', DEFAULT, 40);


-- 댓글 ㅐ
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (1, 1, 'user01', '맞아요 정말 재미있었어요!', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (1, 2, 'user02', '다음 경기도 기대됩니다.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (2, 3, 'user03', '분석 잘 보았습니다. 감사합니다!', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (3, 4, 'user04', '맞아 정말 한끝차이였어', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (4, 5, 'user05', '등산 가고 싶네요.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (5, 6, 'user06', '야구장 분위기가 정말 좋아 보여요!', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (6, 7, 'user07', '인터뷰 내용에 재미있는게 많네요.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (7, 8, 'user08', '챔피언 분석 글 잘 봤습니다!', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (8, 9, 'user09', '자전거 타기 좋은 계절이네요. 함께하고 싶어요.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (9, 10, 'user10', '간식 추천 감사합니다!', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (10, 11, 'user01', '경기가 아쉬웠지만 좋은 후기였습니다.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (11, 12, 'user02', '이번주에 재미있는 대진이 많네요.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (13, 13, 'user03', '아니 당연히 xxx가 최고지 뇌가없나다들.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (14, 14, 'user04', '제 생각에는 큰 이변은 없을것 같아요.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (15, 15, 'user05', '경기 결과를 보니 확실히 준비를 많이해온 팀이 이겼군요.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (16, 16, 'user06', '애휴 예전 행보를 보면 가서도 잘못할듯', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (16, 17, 'user07', '포인트드려요 환전가능 1e34-567 절찬리운영중', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (14, 18, 'user04', '저는 xxx팀이 이길 것 같습니다!', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (15, 19, 'user05', '이번 경기의 전략은 xx을 중심으로 펼쳐질 것 같아요.', DEFAULT);
INSERT INTO comments (post_id, comment_id, user_id, comment_content, created_at) VALUES (16, 20, 'user06', '이적 소식으로 팀의 전략이 어떻게 바뀔지 궁금하네요.', DEFAULT);


-- 게시글_삭제요청하다 ㅐ
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user06', 1, TO_DATE('2024-05-01', 'YYYY-MM-DD'), '개인정보가 노출되었습니다.', '접수 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user07', 4, TO_DATE('2024-05-02', 'YYYY-MM-DD'), '개인정보가 노출되었습니다.', '접수 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user01', 6, TO_DATE('2024-05-03', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '접수 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user02', 6, TO_DATE('2024-05-04', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '접수 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user08', 13, TO_DATE('2024-05-05', 'YYYY-MM-DD'), '저작권 침해 게시물입니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user01', 13, TO_DATE('2024-05-06', 'YYYY-MM-DD'), '저작권 침해 게시물입니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user02', 13, TO_DATE('2024-05-07', 'YYYY-MM-DD'), '저작권 침해 게시물입니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user01', 15, TO_DATE('2024-05-08', 'YYYY-MM-DD'), '잘못된 정보의 게시글입니다.', '반려');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user02', 15, TO_DATE('2024-05-09', 'YYYY-MM-DD'), '잘못된 정보의 게시글입니다.', '반려');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user02', 16, TO_DATE('2024-05-10', 'YYYY-MM-DD'), '부적절한 내용으로 인한 삭제 요청입니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user02', 16, TO_DATE('2024-05-11', 'YYYY-MM-DD'), '부적절한 내용으로 인한 삭제 요청입니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user04', 6, TO_DATE('2024-05-12', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '접수 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user01', 6, TO_DATE('2024-05-13', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '접수 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user02', 16, TO_DATE('2024-05-14', 'YYYY-MM-DD'), '부적절한 내용으로 인한 삭제 요청입니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user05', 16, TO_DATE('2024-05-15', 'YYYY-MM-DD'), '부적절한 내용으로 인한 삭제 요청입니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user05', 16, TO_DATE('2024-05-16', 'YYYY-MM-DD'), '부적절한 내용으로 인한 삭제 요청입니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user05', 16, TO_DATE('2024-05-17', 'YYYY-MM-DD'), '부적절한 내용으로 인한 삭제 요청입니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user05', 7, TO_DATE('2024-05-18', 'YYYY-MM-DD'), '부적절한 내용이 게시되었습니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user03', 8, TO_DATE('2024-05-19', 'YYYY-MM-DD'), '개인정보가 노출되었습니다.', '처리 중');
INSERT INTO post_deletion (user_id, post_id, request_date, request_context, request_process) VALUES ('user10', 9, TO_DATE('2024-05-20', 'YYYY-MM-DD'), '부적절한 내용이 게시되었습니다.', '접수 중');

-- 댓글_삭제요청하다 ㅐ
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user02', 2, TO_DATE('2024-05-21', 'YYYY-MM-DD'), '개인정보를 요구하는 댓글입니다.', '반려');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user03', 3, TO_DATE('2024-05-22', 'YYYY-MM-DD'), '개인정보를 요구하는 댓글입니다.', '반려');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user04', 4, TO_DATE('2024-05-23', 'YYYY-MM-DD'), '개인정보를 요구하는 댓글입니다.', '반려');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user05', 7, TO_DATE('2024-05-24', 'YYYY-MM-DD'), '개인정보를 요구하는 댓글입니다.', '반려');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user06', 9, TO_DATE('2024-05-25', 'YYYY-MM-DD'), '개인정보를 요구하는 댓글입니다.', '반려');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user07', 13, TO_DATE('2024-05-26', 'YYYY-MM-DD'), '욕설이 포함되어 있습니다.', '접수 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user08', 13, TO_DATE('2024-05-27', 'YYYY-MM-DD'), '욕설이 포함되어 있습니다.', '접수 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user09', 13, TO_DATE('2024-05-28', 'YYYY-MM-DD'), '욕설이 포함되어 있습니다.', '접수 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user08', 16, TO_DATE('2024-05-29', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user09', 16, TO_DATE('2024-05-30', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user10', 16, TO_DATE('2024-05-31', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user03', 16, TO_DATE('2024-06-01', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user02', 17, TO_DATE('2024-06-02', 'YYYY-MM-DD'), '광고성 댓글 삭제 요청입니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user08', 17, TO_DATE('2024-06-03', 'YYYY-MM-DD'), '광고성 댓글 삭제 요청입니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user07', 17, TO_DATE('2024-06-04', 'YYYY-MM-DD'), '광고성 댓글 삭제 요청입니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user06', 18, TO_DATE('2024-06-05', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user08', 18, TO_DATE('2024-06-06', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user06', 18, TO_DATE('2024-06-07', 'YYYY-MM-DD'), '부적절한 내용이 포함되어 있습니다.', '처리 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user08', 19, TO_DATE('2024-06-08', 'YYYY-MM-DD'), '광고성 댓글 삭제 요청입니다.', '접수 중');
INSERT INTO comment_deletion (user_id, comment_id, request_date, request_context, request_process) VALUES ('user09', 19, TO_DATE('2024-06-09', 'YYYY-MM-DD'), '광고성 댓글 삭제 요청입니다.', '접수 중');

-- 운동소모임 ㅐ
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user01', 100, '서울 야구 클럽', '서울', '야구', TO_DATE('2024-06-15', 'YYYY-MM-DD'), 15);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user01', 101, '제주 야구 클럽', '제주', '야구', TO_DATE('2024-06-15', 'YYYY-MM-DD'), 15);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user02', 102, '경북 야구 클럽', '경북', '야구', TO_DATE('2024-06-15', 'YYYY-MM-DD'), 15);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user05', 103, '경기 축구 클럽', '경기', '축구', TO_DATE('2024-07-01', 'YYYY-MM-DD'), 10);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user02', 104, '경북 축구 클럽', '경북', '축구', TO_DATE('2024-07-01', 'YYYY-MM-DD'), 10);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user06', 105, '경남 축구 클럽', '경남', '축구', TO_DATE('2024-07-01', 'YYYY-MM-DD'), 10);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user06', 106, '강원 LOL 모임', '강원', 'LoL', TO_DATE('2024-06-20', 'YYYY-MM-DD'), 8);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user03', 107, '충남 LOL 모임', '충남', 'LoL', TO_DATE('2024-06-20', 'YYYY-MM-DD'), 8);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user03', 108, '충북 LOL 모임', '충북', 'LoL', TO_DATE('2024-06-20', 'YYYY-MM-DD'), 8);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user04', 109, '충북 야구 모임', '충북', '야구', TO_DATE('2024-06-25', 'YYYY-MM-DD'), 12);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user04', 110, '제주 야구 모임', '제주', '야구', TO_DATE('2024-06-25', 'YYYY-MM-DD'), 12);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user04', 111, '경북 야구 모임', '경북', '야구', TO_DATE('2024-06-25', 'YYYY-MM-DD'), 12);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user05', 112, '서울 축구 모임', '서울', '축구', TO_DATE('2024-07-05', 'YYYY-MM-DD'), 9);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user02', 113, '충남 축구 모임', '충남', '축구', TO_DATE('2024-07-05', 'YYYY-MM-DD'), 9);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user05', 114, '제주 축구 모임', '제주', '축구', TO_DATE('2024-07-05', 'YYYY-MM-DD'), 9);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user06', 115, '전북 야구 클럽', '전북', '야구', TO_DATE('2024-06-30', 'YYYY-MM-DD'), 7);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user04', 116, '경남 야구 클럽', '경남', '야구', TO_DATE('2024-06-30', 'YYYY-MM-DD'), 7);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user05', 117, '경기 야구 클럽', '경기', '야구', TO_DATE('2024-06-30', 'YYYY-MM-DD'), 7);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user07', 118, '전남 축구 모임', '전남', '축구', TO_DATE('2024-07-10', 'YYYY-MM-DD'), 13);
INSERT INTO exercise_clubs (user_id, club_number, club_name, region, sports, meeting_date, current_members) VALUES ('user08', 119, '강원 야구 클럽', '강원', '야구', TO_DATE('2024-06-15', 'YYYY-MM-DD'), 15);

-- 운동소모임_참가하다 ㅐ
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user01', 100, TO_DATE('2023-01-01', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user01', 101, TO_DATE('2023-01-02', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user03', 102, TO_DATE('2023-01-03', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user05', 102, TO_DATE('2023-01-04', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user03', 103, TO_DATE('2023-01-05', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user07', 103, TO_DATE('2023-01-06', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user08', 103, TO_DATE('2023-01-07', 'YYYY-MM-DD'), TO_DATE('2023-08-01', 'YYYY-MM-DD'));
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user02', 104, TO_DATE('2023-01-08', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user05', 104, TO_DATE('2023-01-09', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user03', 104, TO_DATE('2023-01-10', 'YYYY-MM-DD'), TO_DATE('2023-09-01', 'YYYY-MM-DD'));
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user07', 105, TO_DATE('2023-01-11', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user02', 105, TO_DATE('2023-01-12', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user08', 106, TO_DATE('2023-01-13', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user08', 106, TO_DATE('2023-01-14', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user09', 107, TO_DATE('2023-01-15', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user10', 107, TO_DATE('2023-01-16', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user10', 107, TO_DATE('2023-01-17', 'YYYY-MM-DD'), TO_DATE('2023-10-01', 'YYYY-MM-DD'));
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user06', 104, TO_DATE('2023-01-18', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user09', 104, TO_DATE('2023-01-19', 'YYYY-MM-DD'), NULL);
INSERT INTO exercise_clubs_join (user_id, club_number, join_date, secession_date) VALUES ('user04', 104, TO_DATE('2023-01-20', 'YYYY-MM-DD'), NULL);

-- 굿즈 ㅌ
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (1, '유니폼', '울산FC 유니폼', TO_DATE('2024-05-01', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (2, '모자', '롯데 자이언츠 모자', TO_DATE('2024-05-05', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (3, '피규어', '강원FC 마스코트 피규어', TO_DATE('2024-05-10', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (4, '스포츠장비', '삼성 라이온즈 글러브', TO_DATE('2024-05-15', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (5, '기타', '전북 현대 모터스 가방', TO_DATE('2024-05-20', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (6, '유니폼', '두산 베어스 유니폼', TO_DATE('2024-05-01', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (7, '모자', 'KIA 타이거즈 모자', TO_DATE('2024-05-05', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (8, '피규어', 'LG 트윈스 마스코트 피규어', TO_DATE('2024-05-10', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (9, '스포츠장비', 'NC 다이노스 방망이', TO_DATE('2024-05-15', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (10, '기타', 'KT 위즈 모자', TO_DATE('2024-05-20', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (11, '유니폼', 'FC서울 유니폼', TO_DATE('2024-05-01', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (12, '모자', '전북 현대 모터스 모자', TO_DATE('2024-05-05', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (13, '피규어', '경남FC 마스코트 피규어', TO_DATE('2024-05-10', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (14, '스포츠장비', '수원 삼성 블루윙스 골대', TO_DATE('2024-05-15', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (15, '기타', '대전 하나시티스 가방', TO_DATE('2024-05-20', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (16, '유니폼', 'T1 유니폼', TO_DATE('2024-05-20', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (17, '모자', '젠지 모자', TO_DATE('2024-05-15', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (18, '기타', '디플러스 가방', TO_DATE('2024-05-20', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (19, '기타', '한화 마우스', TO_DATE('2024-05-20', 'YYYY-MM-DD'));
INSERT INTO goods (goods_id, goods_type, goods_name, release_date)VALUES (20, '유니폼', 'KT 유니폼', TO_DATE('2024-05-20', 'YYYY-MM-DD'));

-- 판매링크 ㅌ
INSERT INTO salesLink (goods_id, sales_site) VALUES (1, 'www.electronics-shop.com/product/1');
INSERT INTO salesLink (goods_id, sales_site) VALUES (1, 'www.best-deals.com/product/1');
INSERT INTO salesLink (goods_id, sales_site) VALUES (2, 'www.electronics-shop.com/product/2');
INSERT INTO salesLink (goods_id, sales_site) VALUES (3, 'www.gadget-world.com/product/3');
INSERT INTO salesLink (goods_id, sales_site) VALUES (4, 'www.tech-mart.com/product/4');
INSERT INTO salesLink (goods_id, sales_site) VALUES (4, 'www.electronics-shop.com/product/4');
INSERT INTO salesLink (goods_id, sales_site) VALUES (5, 'www.best-deals.com/product/5');
INSERT INTO salesLink (goods_id, sales_site) VALUES (6, 'www.tech-mart.com/product/6');
INSERT INTO salesLink (goods_id, sales_site) VALUES (7, 'www.gadget-world.com/product/7');
INSERT INTO salesLink (goods_id, sales_site) VALUES (7, 'www.electronics-shop.com/product/7');
INSERT INTO salesLink (goods_id, sales_site) VALUES (8, 'www.best-deals.com/product/8');

-- 굿즈_관심목록_등록하다 ㅐ
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user01', 1, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user02', 2, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user03', 3, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user04', 4, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user05', 5, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user06', 6, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user07', 7, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user08', 7, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user09', 7, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user10', 10, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user01', 11, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user02', 12, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user03', 13, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user04', 14, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user05', 15, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user06', 16, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user08', 18, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user09', 19, DEFAULT);
INSERT INTO goods_favorites (user_id, goods_id, added_date) VALUES ('user10', 20, DEFAULT);

-- 선수
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (11001, 10001, '김현수', TO_DATE('1988-01-12', 'YYYY-MM-DD'), '한국', 22, '타자', '소속', TO_DATE('2020-03-01', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (12001, 10002, '이강철', TO_DATE('1984-03-26', 'YYYY-MM-DD'), '한국', 4, '투수', '소속', TO_DATE('2015-05-01', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (11002, 10003, '추신수', TO_DATE('1982-07-13', 'YYYY-MM-DD'), '한국', 17, '타자', '소속', TO_DATE('2021-03-02', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (12002, 10004, '송명기', TO_DATE('1988-03-18', 'YYYY-MM-DD'), '한국', 31, '투수', '소속', TO_DATE('2022-03-15', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (12003, 10005, '박치국', TO_DATE('1991-09-25', 'YYYY-MM-DD'), '한국', 18, '투수', '소속', TO_DATE('2021-05-12', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (11003, 10006, '나성범', TO_DATE('1989-10-03', 'YYYY-MM-DD'), '한국', 24, '타자', '소속', TO_DATE('2020-03-18', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (11004, 10007, '전준우', TO_DATE('1986-08-25', 'YYYY-MM-DD'), '한국', 8, '타자', '소속', TO_DATE('2010-06-12', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (11005, 10008, '구자욱', TO_DATE('1993-02-12', 'YYYY-MM-DD'), '한국', 65, '타자', '소속', TO_DATE('2014-07-01', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (12004, 10009, '문동주', TO_DATE('1990-08-31', 'YYYY-MM-DD'), '한국', 55, '투수', '소속', TO_DATE('2023-01-25', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (12005, 10010, '김성민', TO_DATE('1999-01-27', 'YYYY-MM-DD'), '한국', 13, '투수', '소속', TO_DATE('2017-05-02', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15001, 30001, '손시우', TO_DATE('2001-04-15', 'YYYY-MM-DD'), '한국', 7, '서폿', '소속', TO_DATE('2020-09-01', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15002, 30002, '이상혁', TO_DATE('1996-05-07', 'YYYY-MM-DD'), '한국', 11, '미드', '소속', TO_DATE('2013-12-13', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15003, 30003, '한왕호', TO_DATE('1998-11-20', 'YYYY-MM-DD'), '한국', 3, '정글', '소속', TO_DATE('2018-11-14', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15004, 30004, '허수', TO_DATE('1997-02-15', 'YYYY-MM-DD'), '한국', 10, '미드', '소속', TO_DATE('2017-11-27', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15005, 30005, '김혁규', TO_DATE('1999-08-08', 'YYYY-MM-DD'), '한국', 1, '원딜', '소속', TO_DATE('2015-09-10', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15006, 30006, '문우찬', TO_DATE('1995-12-03', 'YYYY-MM-DD'), '한국', 5, '서폿', '소속', TO_DATE('2014-05-01', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15007, 30007, '김정현', TO_DATE('1993-06-14', 'YYYY-MM-DD'), '한국', 9, '정글', '소속', TO_DATE('2016-12-31', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15008, 30008, '이승복', TO_DATE('2002-03-22', 'YYYY-MM-DD'), '한국', 20, '정글', '소속', TO_DATE('2016-05-15', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15009, 30009, '김광희', TO_DATE('2000-07-05', 'YYYY-MM-DD'), '한국', 12, '탑', '소속', TO_DATE('2012-05-07', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (15010, 30010, '박루한', TO_DATE('1994-11-11', 'YYYY-MM-DD'), '한국', 25, '탑', '소속', TO_DATE('2012-02-14', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (13001, 20001, '기성용', TO_DATE('1989-01-24', 'YYYY-MM-DD'), '한국', 16, '미드필더', '소속', TO_DATE('2020-06-22', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (13002, 20002, '이순민', TO_DATE('1994-02-11', 'YYYY-MM-DD'), '한국', 5, '미드필더', '소속', TO_DATE('2017-07-15', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (13003, 20003, '김진수', TO_DATE('1992-06-13', 'YYYY-MM-DD'), '한국', 3, '수비수', '소속', TO_DATE('2014-12-12', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (13004, 20004, '이용', TO_DATE('1986-12-08', 'YYYY-MM-DD'), '한국', 2, '수비수', '소속', TO_DATE('2003-03-15', 'YYYY-MM-DD'));
INSERT INTO players (player_id, team_id, name, birthdate, nationality, shirt_number, position, status, affiliation_date) VALUES (14001, 20005, '조현우', TO_DATE('1991-09-25', 'YYYY-MM-DD'), '한국', 2, '골키퍼', '소속', TO_DATE('2020-03-25', 'YYYY-MM-DD'));

-- SNS주소 ㅌ
INSERT INTO social_media_accounts (player_id, SNS) VALUES (11001, 'https://twitter.com/kimhyunsu22');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (12001, 'https://instagram.com/leekangcheol');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (11002, 'https://facebook.com/chooshinsoo17');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (12002, 'https://twitter.com/songmyeonggi31');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (12003, 'https://instagram.com/parkchikook18');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (11003, 'https://facebook.com/naseongbeom24');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (11004, 'https://twitter.com/jeonjunwoo8');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (11005, 'https://instagram.com/gujauq65');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (12004, 'https://facebook.com/moondongju55');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (12005, 'https://twitter.com/kimseongmin13');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15001, 'https://instagram.com/sonsiwoo7');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15002, 'https://facebook.com/leesanghyeok11');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15003, 'https://twitter.com/hanwangho3');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15004, 'https://instagram.com/heusoo10');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15005, 'https://facebook.com/kimhyukgyu1');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15006, 'https://twitter.com/moonwoochan5');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15007, 'https://instagram.com/kimjeonghyun9');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15008, 'https://facebook.com/leesungbok20');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15009, 'https://twitter.com/kimkwanghee12');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (15010, 'https://instagram.com/parkroohan25');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (13001, 'https://facebook.com/kisungyong16');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (13002, 'https://twitter.com/leesoonmin5');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (13003, 'https://instagram.com/kimjinsu3');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (13004, 'https://facebook.com/leeyong2');
INSERT INTO social_media_accounts (player_id, SNS) VALUES (14001, 'https://instagram.com/hyeonwoo2rin');

-- 선수정보_수정요청하다 ㅐ
INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user01', 11001, TO_DATE('2024-06-01', 'YYYY-MM-DD'), '선수 소속일자에 오타가 있습니다.', '접수 중');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user02', 12001, TO_DATE('2024-06-02', 'YYYY-MM-DD'), '선수의 생년월일이 잘못되었습니다.', '처리 중');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user03', 11002, TO_DATE('2024-06-03', 'YYYY-MM-DD'), '선수의 포지션이 잘못되었습니다.', '반려');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user04', 12002, TO_DATE('2024-06-04', 'YYYY-MM-DD'), '국적 정보가 잘못되었습니다.', '처리 완료');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user05', 12003, TO_DATE('2024-06-05', 'YYYY-MM-DD'), '등번호가 업데이트되지 않았습니다.', '접수 중');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user06', 11003, TO_DATE('2024-06-06', 'YYYY-MM-DD'), '선수의 이적 정보가 업데이트되지 않았습니다.', '처리 중');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user07', 11004, TO_DATE('2024-06-07', 'YYYY-MM-DD'), '선수의 이름에 오타가 있습니다.', '반려');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user08', 11005, TO_DATE('2024-06-08', 'YYYY-MM-DD'), '선수의 소속팀이 잘못되었습니다.', '처리 완료');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user09', 12004, TO_DATE('2024-06-09', 'YYYY-MM-DD'), '선수의 등번호가 업데이트되지 않았습니다.', '접수 중');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user10', 12005, TO_DATE('2024-06-10', 'YYYY-MM-DD'), '선수의 경력 정보가 잘못되었습니다.', '처리 중');
INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user01', 15001, TO_DATE('2024-06-11', 'YYYY-MM-DD'), '선수의 생년월일이 잘못되었습니다.', '반려');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user02', 15002, TO_DATE('2024-06-12', 'YYYY-MM-DD'), '선수의 이름에 오타가 있습니다.', '처리 완료');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user03', 15003, TO_DATE('2024-06-13', 'YYYY-MM-DD'), '선수의 포지션 정보가 정확하지 않습니다.', '접수 중');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user04', 15004, TO_DATE('2024-06-14', 'YYYY-MM-DD'), '선수의 생년월일이 잘못되었습니다.', '처리 중');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user05', 15005, TO_DATE('2024-06-15', 'YYYY-MM-DD'), '선수 소속일자에 오타가 있습니다.', '반려');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user06', 15006, TO_DATE('2024-06-16', 'YYYY-MM-DD'), '선수의 이름에 오타가 있습니다.', '처리 완료');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user07', 15007, TO_DATE('2024-06-17', 'YYYY-MM-DD'), '선수의 생년월일이 잘못되었습니다.', '접수 중');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user08', 15008, TO_DATE('2024-06-18', 'YYYY-MM-DD'), '선수의 포지션 정보가 정확하지 않습니다.', '처리 중');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user09', 15009, TO_DATE('2024-06-19', 'YYYY-MM-DD'), '국적 정보가 잘못되었습니다.', '반려');

INSERT INTO player_information_correction (user_id, player_id, request_date, request_context, request_process)
VALUES ('user10', 15010, TO_DATE('2024-06-20', 'YYYY-MM-DD'), '등번호 정보가 잘못되었습니다.', '처리 완료');

-- 팀정보_수정요청하다 ㅐ
INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user01', 10001, TO_DATE('2024-05-01', 'YYYY-MM-DD'), '팀명을 "LG Twins"로 변경해 주세요.', '접수 중');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user02', 10002, TO_DATE('2024-05-02', 'YYYY-MM-DD'), '법인명을 "케이티스포츠"으로 수정해 주세요.', '처리 완료');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user03', 10003, TO_DATE('2024-05-03', 'YYYY-MM-DD'), '창단일을 2000-04-01로 업데이트 해 주세요.', '반려');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user04', 10004, TO_DATE('2024-05-04', 'YYYY-MM-DD'), '소속 리그를 "아시아 챔피언스 리그"로 업데이트 해 주세요.', '접수 중');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user05', 10005, TO_DATE('2024-05-05', 'YYYY-MM-DD'), '팀 형태를 "아마추어 구단"으로 변경해 주세요.', '접수 중');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user06', 10006, TO_DATE('2024-05-06', 'YYYY-MM-DD'), '연고지를 "전라도"로 변경해 주세요.', '반려');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user07', 10007, TO_DATE('2024-05-07', 'YYYY-MM-DD'), '감독을 "김기동"으로 업데이트 해 주세요.', '반려');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user08', 10008, TO_DATE('2024-05-08', 'YYYY-MM-DD'), '주장을 "홍길동"으로 변경해 주세요.', '처리 완료');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user09', 10009, TO_DATE('2024-05-09', 'YYYY-MM-DD'), '팀명을 "빙그레 이글스"로 변경해 주세요.', '접수 중');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user10', 10010, TO_DATE('2024-05-10', 'YYYY-MM-DD'), '법인명을 "서울 히어로즈 주식회사"로 수정해 주세요.', '처리 중');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user01', 30001, TO_DATE('2024-05-11', 'YYYY-MM-DD'), '창단일을 2014-01-01로 업데이트 해 주세요.', '반려');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user02', 30002, TO_DATE('2024-05-12', 'YYYY-MM-DD'), '소속 리그를 "국제 리그"로 업데이트 해 주세요.', '처리 완료');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user03', 30003, TO_DATE('2024-05-13', 'YYYY-MM-DD'), '팀 형태를 "유소년 구단"으로 변경해 주세요.', '접수 중');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user04', 30004, TO_DATE('2024-05-14', 'YYYY-MM-DD'), '연고지를 "부산광역시"로 변경해 주세요.', '처리 중');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user05', 30005, TO_DATE('2024-05-15', 'YYYY-MM-DD'), '감독을 "김철수"로 업데이트 해 주세요.', '반려');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user06', 30006, TO_DATE('2024-05-16', 'YYYY-MM-DD'), '주장을 "이영희"로 변경해 주세요.', '처리 완료');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user07', 30007, TO_DATE('2024-05-17', 'YYYY-MM-DD'), '팀명을 "BNK FearX 어벤져스"로 변경해 주세요.', '접수 중');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user08', 30008, TO_DATE('2024-05-18', 'YYYY-MM-DD'), '법인명을 "농심 레드포스 주식회사"로 수정해 주세요.', '처리 중');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user09', 30009, TO_DATE('2024-05-19', 'YYYY-MM-DD'), '창단일을 2015-01-01로 업데이트 해 주세요.', '반려');

INSERT INTO team_information_correction (user_id, team_id, request_date, request_context, request_process) 
VALUES ('user10', 30010, TO_DATE('2024-05-20', 'YYYY-MM-DD'), '소속 리그를 "국내 리그"로 업데이트 해 주세요.', '처리 완료');

-- 야구_타자기록 ㅌ
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11001, 21001, 'Y', 'Y', 5, 3, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11001, 21002, 'Y', 'N', 4, 3, 2, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11001, 21003, 'Y', 'Y', 6, 4, 2, 0, 0, 1, 2, 1, 0, 0, 2, 1, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11001, 21004, 'Y', 'Y', 3, 3, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11002, 21005, 'Y', 'N', 3, 2, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11002, 21006, 'Y', 'Y', 5, 4, 2, 0, 0, 1, 3, 2, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11002, 21007, 'Y', 'N', 2, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11002, 21008, 'Y', 'Y', 4, 3, 1, 1, 0, 0, 2, 1, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11003, 21009, 'Y', 'Y', 5, 4, 2, 1, 0, 0, 2, 1, 1, 0, 0, 1, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11003, 21010, 'Y', 'Y', 4, 3, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11003, 21011, 'Y', 'N', 3, 3, 2, 0, 1, 0, 2, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11003, 21012, 'Y', 'Y', 6, 4, 2, 0, 0, 2, 3, 2, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11004, 21013, 'Y', 'N', 4, 3, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11004, 21014, 'Y', 'Y', 5, 4, 2, 0, 1, 1, 2, 2, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11004, 21015, 'Y', 'Y', 3, 2, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11004, 21016, 'Y', 'N', 4, 3, 2, 1, 0, 0, 2, 1, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11005, 21017, 'Y', 'Y', 4, 3, 2, 0, 0, 1, 3, 2, 1, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11005, 21018, 'Y', 'N', 5, 4, 2, 1, 0, 0, 2, 1, 0, 0, 1, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11005, 21019, 'Y', 'Y', 3, 2, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0);
INSERT INTO baseball_hitter_records (player_id, record_id, appearance, starting_appearance, plate_appearance, at_bats, hits, doubles, triples, home_runs, runs_batted_in, runs_scored, walks, hit_by_pitch, strikeouts, stolen_bases, caught_stealing, double_plays)
VALUES (11005, 21020, 'Y', 'N', 4, 3, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0);

-- 야구_투수기록 ㅌ
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12001, 22001, 'Y', 'Y', '승', 'N', 'N', 6, 5, 2, 1, 1, 1);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12001, 22002, 'Y', 'N', '홀드', 'N', 'N', 7.0, 6, 3, 2, 1, 1);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12001, 22003, 'Y', 'Y', '패', 'N', 'N', 5.1, 4, 2, 1, 3, 2);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12001, 22004, 'Y', 'N', '세이브', 'N', 'N', 6.2, 5, 3, 1, 2, 2);

INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12002, 22005, 'Y', 'Y', 'N', 'N', 'N', 7.1, 5, 2, 0, 2, 1);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12002, 22006, 'Y', 'N', '승', 'N', 'N', 6.0, 4, 2, 0, 1, 1);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12002, 22007, 'Y', 'Y', '패', 'N', 'N', 6.2, 5, 3, 1, 3, 2);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12002, 22008, 'Y', 'N', '홀드', 'N', 'N', 7.0, 6, 3, 2, 2, 1);

INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12003, 22009, 'Y', 'Y', '패', 'N', 'N', 6.1, 5, 2, 1, 2, 2);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12003, 22010, 'Y', 'N', '세이브', 'N', 'N', 5.0, 4, 2, 1, 1, 1);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12003, 22011, 'Y', 'Y', '홀드', 'N', 'N', 6.2, 5, 3, 2, 3, 2);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12003, 22012, 'Y', 'N', '승', 'N', 'N', 7.0, 6, 3, 1, 2, 1);

INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12004, 22013, 'Y', 'Y', '패', 'N', 'N', 6.0, 6, 2, 1, 2, 2);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12004, 22014, 'Y', 'N', '세이브', 'N', 'N', 7.0, 7, 3, 2, 1, 1);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12004, 22015, 'Y', 'Y', '홀드', 'N', 'N', 6.1, 5, 2, 1, 2, 1);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12004, 22016, 'Y', 'N', '승', 'N', 'N', 5.2, 4, 2, 1, 1, 2);

INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12005, 22017, 'Y', 'Y', '승', 'N', 'N', 5.1, 4, 3, 1, 3, 2);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12005, 22018, 'Y', 'N', 'N', 'N', 'N', 4.0, 3, 2, 0, 2, 2);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12005, 22019, 'Y', 'Y', '패', 'N', 'N', 5.2, 4, 2, 1, 3, 3);
INSERT INTO baseball_pitcher_records (player_id, record_id, appearance, starting_appearance, result, complete_games, shutouts, innings_pitched, strikeouts, walks, hit_by_pitch, runs_allowed, earned_runs)
VALUES (12005, 22020, 'Y', 'N', '승', 'N', 'N', 6.0, 5, 3, 2, 2, 1);

-- 야구_팀기록 ㅌ
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10001, 23001, '패', 7, 8);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10002, 23002, '패', 4, 6);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10003, 23003, '패', 0, 9);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10003, 23004, '패', 3, 7);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10004, 23005, '패', 2, 3);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10004, 23006, '패', 0, 7);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10004, 23007, '패', 2, 6);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10005, 23008, '승', 5, 3);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10005, 23009, '승', 7, 2);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10006, 23010, '승', 6, 1);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10007, 23011, '승', 4, 3);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10007, 23012, '승', 8, 0);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10007, 23013, '승', 5, 4);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10008, 23014, '승', 9, 1);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10009, 23015, '승', 7, 3);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10009, 23016, '승', 6, 2);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10010, 23017, '승', 8, 0);
INSERT INTO baseball_team_records (team_id, record_id, game_result, runs_scored, runs_allowed)
VALUES (10010, 23018, '승', 5, 3);

-- 축구_필더기록 ㅌ
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13001, 24001, 'Y', 'Y', 0, 1, 2, 0, 0, 1, 3, 2, 0, 15, 12, 4);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13001, 24002, 'Y', 'Y', 1, 0, 1, 0, 0, 2, 4, 3, 0, 20, 17, 2);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13001, 24003, 'Y', 'Y', 0, 2, 0, 1, 0, 1, 2, 1, 1, 18, 14, 3);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13001, 24004, 'Y', 'Y', 2, 1, 3, 0, 0, 2, 5, 4, 0, 22, 19, 5);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13001, 24005, 'N', 'N', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13002, 24006, 'Y', 'Y', 1, 1, 2, 0, 0, 2, 4, 3, 1, 19, 16, 2);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13002, 24007, 'Y', 'Y', 0, 0, 1, 0, 0, 1, 2, 1, 0, 17, 13, 2);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13002, 24008, 'Y', 'Y', 1, 0, 0, 1, 0, 2, 3, 2, 0, 21, 18, 3);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13002, 24009, 'Y', 'Y', 0, 1, 2, 0, 0, 1, 4, 2, 0, 16, 13, 2);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13002, 24010, 'Y', 'Y', 2, 0, 3, 0, 0, 1, 6, 4, 1, 25, 20, 4);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13003, 24011, 'Y', 'Y', 1, 1, 1, 1, 0, 1, 3, 2, 0, 23, 19, 3);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13003, 24012, 'Y', 'Y', 0, 0, 2, 0, 0, 2, 4, 3, 0, 20, 16, 3);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13003, 24013, 'Y', 'Y', 0, 2, 0, 0, 0, 1, 3, 1, 1, 17, 14, 2);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13003, 24014, 'Y', 'Y', 1, 0, 1, 0, 0, 1, 5, 3, 0, 18, 15, 2);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13003, 24015, 'Y', 'Y', 2, 1, 3, 0, 0, 2, 6, 5, 0, 24, 20, 4);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13004, 24016, 'Y', 'Y', 1, 1, 1, 1, 0, 1, 3, 2, 0, 22, 18, 3);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13004, 24017, 'Y', 'Y', 0, 0, 2, 0, 0, 2, 4, 3, 0, 19, 16, 2);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13004, 24018, 'Y', 'Y', 0, 2, 0, 0, 0, 1, 3, 1, 1, 17, 14, 2);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13004, 24019, 'Y', 'Y', 1, 0, 1, 0, 0, 1, 5, 3, 0, 18, 15, 2);
INSERT INTO soccer_field_records (player_id, record_id, appearance, starting_appearance, goals, assists, corners, free_kicks, penalties, fouls, shots, shots_on_target, offsides, pass_attempts, pass_successes, interceptions)
VALUES (13004, 24020, 'Y', 'Y', 2, 1, 3, 0, 0, 2, 6, 5, 0, 24, 20, 4);

-- 축구_골키퍼기록 ㅌ
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25001, 'Y', 'Y', 3, 4);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25002, 'Y', 'Y', 2, 4);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25003, 'Y', 'Y', 1, 5);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25004, 'Y', 'N', 1, 2);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25005, 'N', 'N', 0, 0);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25006, 'Y', 'Y', 2, 4);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25007, 'Y', 'Y', 1, 5);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25008, 'Y', 'Y', 3, 4);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25009, 'Y', 'Y', 2, 4);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25010, 'Y', 'Y', 1, 5);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25011, 'Y', 'Y', 0, 5);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25012, 'Y', 'Y', 4, 0);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25013, 'Y', 'Y', 2, 4);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25014, 'Y', 'Y', 1, 5);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25015, 'Y', 'Y', 3, 4);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25016, 'Y', 'Y', 2, 4);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25017, 'Y', 'Y', 1, 3);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25018, 'Y', 'Y', 0, 5);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25019, 'Y', 'N', 0, 0);
INSERT INTO soccer_goalkeeper_records (player_id, record_id, appearance, starting_appearance, goals_conceded, saves)
VALUES (14001, 25020, 'Y', 'Y', 2, 4);

-- 축구_팀기록 ㅌ
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20001, 26001, '승', 2, 1);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20001, 26002, '패', 1, 2);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20001, 26003, '승', 3, 0);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20001, 26004, '승', 2, 1);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20001, 26005, '패', 0, 3);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20001, 26006, '승', 3, 0);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20001, 26007, '패', 1, 2);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20002, 26008, '승', 2, 1);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20002, 26009, '승', 2, 0);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20002, 26010, '패', 0, 3);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20002, 26011, '패', 1, 2);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20003, 26012, '승', 3, 0);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20003, 26013, '승', 2, 1);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20003, 26014, '패', 1, 2);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20003, 26015, '승', 3, 0);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20004, 26016, '승', 2, 1);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20004, 26017, '패', 0, 3);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20004, 26018, '승', 2, 1);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20004, 26019, '승', 1, 0);
INSERT INTO soccer_team_records (team_id, record_id, game_result, goals_scored, goals_conceded)
VALUES (20004, 26020, '패', 0, 2);

-- LoL_e스포츠_선수기록 ㅌ
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15001, 27001, 'Y', '패', '이즈리얼', 10, 2, 8, 15000, 25000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15001, 27002, 'Y', '패', '카사딘', 5, 7, 3, 12000, 18000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15001, 27003, 'Y', '패', '아칼리', 12, 1, 4, 18000, 30000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15002, 27004, 'Y', '승', '야스오', 8, 3, 9, 16000, 28000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15002, 27005, 'N', 'N', 0, 0, 0, 0, 0, 0);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15002, 27006, 'Y', '패', '이블린', 3, 8, 5, 11000, 15000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15003, 27007, 'Y', '승', '다이애나', 7, 4, 6, 14000, 22000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15003, 27008, 'Y', '패', '블라디미르', 6, 5, 2, 13000, 20000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15004, 27009, 'Y', '승', '트위치', 9, 2, 10, 17000, 27000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15004, 27010, 'N', 'N', 0, 0, 0, 0, 0, 0);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15004, 27011, 'Y', '패', '레넥톤', 4, 9, 3, 10000, 17000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15004, 27012, 'Y', '패', '쓰레쉬', 2, 11, 6, 9000, 13000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15005, 27013, 'Y', '승', '이즈리얼', 11, 1, 7, 16000, 25000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15006, 27014, 'Y', '승', '야스오', 10, 4, 5, 17000, 28000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15006, 27015, 'Y', '패', '르블랑', 3, 6, 2, 11000, 16000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15007, 27016, 'Y', '패', '카사딘', 5, 8, 4, 12000, 19000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15008, 27017, 'Y', '승', '바루스', 8, 3, 9, 15000, 24000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15009, 27018, 'Y', '승', '아칼리', 9, 2, 5, 21000, 42000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15009, 27019, 'Y', '승', '아칼리', 9, 2, 7, 16000, 26000);
INSERT INTO LoL_eSports_player_records (player_id, record_id, appearance, set_result, champion, kill, deaths, assist, gold_earned, damage_dealt)
VALUES (15010, 27020, 'Y', '패', '이블린', 4, 7, 3, 12000, 17000);

-- LoL_e스포츠_팀기록 ㅌ
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30001, 28001, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30002, 28002, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30003, 28003, 'LoL Championship', 'W', 2, 0);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30004, 28004, 'LoL Championship', 'L', 0, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30005, 28005, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30006, 28006, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30007, 28007, 'LoL Championship', 'W', 2, 0);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30008, 28008, 'LoL Championship', 'L', 0, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30009, 28009, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30010, 28010, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30001, 28011, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30002, 28012, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30003, 28013, 'LoL Championship', 'L', 0, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30004, 28014, 'LoL Championship', 'W', 2, 0);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30005, 28015, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30006, 28016, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30007, 28017, 'LoL Championship', 'L', 0, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30008, 28018, 'LoL Championship', 'W', 2, 0);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30009, 28019, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30010, 28020, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30001, 28021, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30003, 28022, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30001, 28023, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30004, 28024, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30001, 28025, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30005, 28026, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30002, 28027, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30003, 28028, 'LoL Championship', 'W', 2, 1);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30002, 28029, 'LoL Championship', 'L', 1, 2);
INSERT INTO LoL_eSports_team_records (team_id, record_id, game_name, result, set_win, set_lose) VALUES (30004, 28030, 'LoL Championship', 'W', 2, 1);


-- 야구_타자기록_정정요청하다 ㅐ
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 21001, TO_DATE('2024-06-01', 'YYYY-MM-DD'), '출장여부', '요청된 날짜에 해당 선수가 경기에 출장했습니다.', '접수 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 21002, TO_DATE('2024-06-01', 'YYYY-MM-DD'), '타수', '요청된 날짜에 해당 선수의 타수는 4입니다.', '처리 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 21003, TO_DATE('2024-06-02', 'YYYY-MM-DD'), '홈런', '요청된 날짜에 해당 선수의 홈런을 한개 기록했습니다. 반영 바랍니다.', '처리 완료');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 21004, TO_DATE('2024-06-02', 'YYYY-MM-DD'), '볼넷', '요청된 날짜에 해당 선수가 받은 볼넷 수는 2입니다.', '반려');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 21005, TO_DATE('2024-06-03', 'YYYY-MM-DD'), '타점', '요청된 날짜에 해당 선수가 기록한 타점 수는 3입니다.', '처리 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 21006, TO_DATE('2024-06-03', 'YYYY-MM-DD'), '득점', '요청된 날짜에 해당 선수가 기록한 득점 수는 2입니다.', '접수 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 21007, TO_DATE('2024-06-04', 'YYYY-MM-DD'), '볼넷', '요청된 날짜에 해당 선수가 기록한 볼넷을 기록하지 못했습니다.', '처리 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 21008, TO_DATE('2024-06-04', 'YYYY-MM-DD'), '사구', '요청된 날짜에 해당 선수가 기록한 사구 수는 1입니다.', '처리 완료');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 21009, TO_DATE('2024-06-05', 'YYYY-MM-DD'), '삼진', '요청된 날짜에 해당 선수가 기록한 삼진 수는 3입니다.', '반려');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 21010, TO_DATE('2024-06-05', 'YYYY-MM-DD'), '도루', '요청된 날짜에 해당 선수가 기록한 도루 수는 2입니다.', '처리 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 21011, TO_DATE('2024-06-06', 'YYYY-MM-DD'), '도루실패', '요청된 날짜에 해당 선수가 기록한 도루실패 수는 1입니다.', '처리 완료');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 21012, TO_DATE('2024-06-06', 'YYYY-MM-DD'), '병살타', '요청된 날짜에 해당 선수가 기록한 병살타 수는 1입니다.', '접수 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 21013, TO_DATE('2024-06-15', 'YYYY-MM-DD'), '출장여부', '요청된 날짜에 선수는 출장하지 않았습니다.', '처리 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 21013, TO_DATE('2024-06-07', 'YYYY-MM-DD'), '출장여부', '요청된 날짜에 선수는 출장하지 않았습니다.', '처리 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 21014, TO_DATE('2024-06-07', 'YYYY-MM-DD'), '선발출장여부', '요청된 날짜에 해당 선수는 선발로 출장하지 않았습니다.', '처리 완료');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 21015, TO_DATE('2024-06-08', 'YYYY-MM-DD'), '타수', '요청된 날짜에 해당 선수의 타수는 5입니다.', '반려');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 21016, TO_DATE('2024-06-08', 'YYYY-MM-DD'), '안타', '요청된 날짜에 해당 선수의 안타 수는 3입니다.', '처리 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 21017, TO_DATE('2024-06-09', 'YYYY-MM-DD'), '2루타', '요청된 날짜에 해당 선수의 2루타 수는 1입니다.', '접수 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 21018, TO_DATE('2024-06-09', 'YYYY-MM-DD'), '3루타', '요청된 날짜에 해당 선수의 3루타 수는 1입니다.', '처리 중');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 21019, TO_DATE('2024-06-10', 'YYYY-MM-DD'), '홈런', '요청된 날짜에 해당 선수의 홈런 수는 3입니다.', '처리 완료');
INSERT INTO baseball_hitter_corr (user_id, baseball_hitter_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 21020, TO_DATE('2024-06-10', 'YYYY-MM-DD'), '타점', '요청된 날짜에 해당 선수가 기록한 타점 수는 2입니다.', '반려');

-- 야구_투수기록_정정요청하다 ㅐ
INSERT INTO baseball_pitcher_corr VALUES ('user01', 22001, TO_DATE('2023-02-01', 'YYYY-MM-DD'), '경기결과', '경기결과 기록이 잘못되었습니다.', '접수 중');
INSERT INTO baseball_pitcher_corr VALUES ('user02', 22002, TO_DATE('2023-02-22', 'YYYY-MM-DD'), '경기결과', '경기결과 기록이 잘못 입력됨.', '처리 중');
INSERT INTO baseball_pitcher_corr VALUES ('user03', 22003, TO_DATE('2023-03-13', 'YYYY-MM-DD'), '경기결과', '경기결과 기록 업데이트 요청.', '반려');
INSERT INTO baseball_pitcher_corr VALUES ('user04', 22004, TO_DATE('2023-03-24', 'YYYY-MM-DD'), '경기결과', '경기결과 기록이 누락됨.', '처리 완료');
INSERT INTO baseball_pitcher_corr VALUES ('user05', 22005, TO_DATE('2023-04-05', 'YYYY-MM-DD'), '완투', '완투 기록 추가 요청.', '접수 중');
INSERT INTO baseball_pitcher_corr VALUES ('user06', 22006, TO_DATE('2023-04-16', 'YYYY-MM-DD'), '완봉', '완봉승 기록이 잘못됨.', '처리 중');
INSERT INTO baseball_pitcher_corr VALUES ('user07', 22007, TO_DATE('2023-05-03', 'YYYY-MM-DD'), '이닝', '이닝 수 정정 요청.', '반려');
INSERT INTO baseball_pitcher_corr VALUES ('user08', 22008, TO_DATE('2023-05-18', 'YYYY-MM-DD'), '탈삼진', '탈삼진 수가 잘못 기록됨.', '처리 완료');
INSERT INTO baseball_pitcher_corr VALUES ('user09', 22009, TO_DATE('2023-06-09', 'YYYY-MM-DD'), '볼넷', '볼넷 수 정정 요청.', '접수 중');
INSERT INTO baseball_pitcher_corr VALUES ('user10', 22010, TO_DATE('2023-07-01', 'YYYY-MM-DD'), '사구', '사구 기록이 누락됨.', '처리 중');
INSERT INTO baseball_pitcher_corr VALUES ('user01', 22011, TO_DATE('2023-07-05', 'YYYY-MM-DD'), '실점', '실점 기록이 잘못 입력됨.', '반려');
INSERT INTO baseball_pitcher_corr VALUES ('user02', 22012, TO_DATE('2023-07-12', 'YYYY-MM-DD'), '자책점', '자책점 수 정정 요청.', '처리 완료');
INSERT INTO baseball_pitcher_corr VALUES ('user03', 22013, TO_DATE('2023-08-13', 'YYYY-MM-DD'), '경기결과', '경기결과 기록 업데이트 요청.', '접수 중');
INSERT INTO baseball_pitcher_corr VALUES ('user04', 22014, TO_DATE('2023-08-24', 'YYYY-MM-DD'), '사구', '사구 기록이 잘못 입력됨.', '처리 중');
INSERT INTO baseball_pitcher_corr VALUES ('user05', 22015, TO_DATE('2023-09-15', 'YYYY-MM-DD'), '완투', '완투 기록 정정 요청.', '반려');
INSERT INTO baseball_pitcher_corr VALUES ('user06', 22016, TO_DATE('2023-09-21', 'YYYY-MM-DD'), '완봉', '완봉승 기록이 누락됨.', '처리 완료');
INSERT INTO baseball_pitcher_corr VALUES ('user07', 22017, TO_DATE('2023-10-17', 'YYYY-MM-DD'), '이닝', '이닝 수가 잘못됨.', '접수 중');
INSERT INTO baseball_pitcher_corr VALUES ('user08', 22018, TO_DATE('2023-10-28', 'YYYY-MM-DD'), '탈삼진', '탈삼진 수 정정 요청.', '처리 중');
INSERT INTO baseball_pitcher_corr VALUES ('user09', 22019, TO_DATE('2023-11-19', 'YYYY-MM-DD'), '볼넷', '볼넷 기록이 잘못 입력됨.', '반려');
INSERT INTO baseball_pitcher_corr VALUES ('user10', 22020, TO_DATE('2023-12-20', 'YYYY-MM-DD'), '사구', '사구 기록 업데이트 요청.', '처리 완료');

-- 야구_팀기록_정정요청하다 ㅐ
INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 23001, TO_DATE('2024-06-01', 'YYYY-MM-DD'), '경기결과', '야구 팀의 경기 결과를 확인하고 싶습니다.', '처리 완료');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 23002, TO_DATE('2024-06-02', 'YYYY-MM-DD'), '득점', '야구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 23003, TO_DATE('2024-06-03', 'YYYY-MM-DD'), '실점', '야구 팀의 실점에 대한 자세한 내용을 알려주세요.', '접수 중');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 23004, TO_DATE('2024-06-04', 'YYYY-MM-DD'), '경기결과', '야구 팀의 경기 결과를 확인하고 싶습니다.', '반려');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 23005, TO_DATE('2024-06-05', 'YYYY-MM-DD'), '득점', '야구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 23006, TO_DATE('2024-06-06', 'YYYY-MM-DD'), '실점', '야구 팀의 실점에 대한 자세한 내용을 알려주세요.', '처리 완료');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 23007, TO_DATE('2024-06-07', 'YYYY-MM-DD'), '경기결과', '야구 팀의 경기 결과를 확인하고 싶습니다.', '처리 완료');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 23008, TO_DATE('2024-06-08', 'YYYY-MM-DD'), '득점', '야구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 23009, TO_DATE('2024-06-09', 'YYYY-MM-DD'), '실점', '야구 팀의 실점에 대한 자세한 내용을 알려주세요.', '접수 중');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 23010, TO_DATE('2024-06-10', 'YYYY-MM-DD'), '경기결과', '야구 팀의 경기 결과를 확인하고 싶습니다.', '반려');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 23011, TO_DATE('2024-06-11', 'YYYY-MM-DD'), '득점', '야구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 23012, TO_DATE('2024-06-12', 'YYYY-MM-DD'), '실점', '야구 팀의 실점에 대한 자세한 내용을 알려주세요.', '처리 완료');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 23013, TO_DATE('2024-06-13', 'YYYY-MM-DD'), '경기결과', '야구 팀의 경기 결과를 확인하고 싶습니다.', '처리 완료');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 23014, TO_DATE('2024-06-14', 'YYYY-MM-DD'), '득점', '야구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 23015, TO_DATE('2024-06-15', 'YYYY-MM-DD'), '실점', '야구 팀의 실점에 대한 자세한 내용을 알려주세요.', '접수 중');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 23016, TO_DATE('2024-06-16', 'YYYY-MM-DD'), '경기결과', '야구 팀의 경기 결과를 확인하고 싶습니다.', '반려');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 23017, TO_DATE('2024-06-17', 'YYYY-MM-DD'), '득점', '야구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 23018, TO_DATE('2024-06-18', 'YYYY-MM-DD'), '실점', '야구 팀의 실점에 대한 자세한 내용을 알려주세요.', '처리 완료');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 23018, TO_DATE('2024-06-19', 'YYYY-MM-DD'), '경기결과', '야구 팀의 경기 결과를 확인하고 싶습니다.', '처리 완료');

INSERT INTO baseball_team_corr (user_id, baseball_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 23018, TO_DATE('2024-06-20', 'YYYY-MM-DD'), '득점', '야구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

-- 축구_필더기록_정정요청하다 ㅐ
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user01', 24001, TO_DATE('2023-06-01', 'YYYY-MM-DD'), '출장여부', '선수 출전 여부 확인 부탁드립니다.', '접수 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user02', 24002, TO_DATE('2023-06-02', 'YYYY-MM-DD'), '선발출장여부', '선발 출장 여부 확인해주세요.', '처리 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user03', 24003, TO_DATE('2023-06-03', 'YYYY-MM-DD'), '득점', '선수의 득점 기록 확인 부탁드립니다.', '처리 완료');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user04', 24004, TO_DATE('2023-06-04', 'YYYY-MM-DD'), '도움', '선수의 도움 기록을 알려주세요.', '접수 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user05', 24005, TO_DATE('2023-06-05', 'YYYY-MM-DD'), '코너킥', '선수의 코너킥 기록을 알려주세요.', '처리 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user06', 24006, TO_DATE('2023-06-06', 'YYYY-MM-DD'), '프리킥', '프리킥 성공률을 확인하고 싶습니다.', '반려');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user07', 24007, TO_DATE('2023-06-07', 'YYYY-MM-DD'), '패널티킥', '선수의 패널티킥 기록을 알려주세요.', '처리 완료');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user08', 24008, TO_DATE('2023-06-08', 'YYYY-MM-DD'), '파울', '선수가 받은 파울 수를 알고 싶습니다.', '접수 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user09', 24009, TO_DATE('2023-06-09', 'YYYY-MM-DD'), '슈팅', '선수의 슈팅 기록을 확인하고 싶습니다.', '처리 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user10', 24010, TO_DATE('2023-06-10', 'YYYY-MM-DD'), '유효슈팅', '선수의 유효슈팅 수를 알려주세요.', '접수 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user01', 24011, TO_DATE('2023-06-11', 'YYYY-MM-DD'), '오프사이드', '선수의 오프사이드 기록을 확인하고 싶습니다.', '처리 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user02', 24012, TO_DATE('2023-06-12', 'YYYY-MM-DD'), '패스시도', '선수의 패스 시도 횟수를 알고 싶습니다.', '처리 완료');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user03', 24013, TO_DATE('2023-06-13', 'YYYY-MM-DD'), '패스성공', '선수의 패스 성공 횟수를 확인해주세요.', '접수 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user04', 24014, TO_DATE('2023-06-14', 'YYYY-MM-DD'), '패스성공률', '선수의 패스 성공률을 알고 싶습니다.', '처리 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user05', 24015, TO_DATE('2023-06-15', 'YYYY-MM-DD'), '인터셉트', '선수의 인터셉트 기록을 확인해주세요.', '반려');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user06', 24016, TO_DATE('2023-06-16', 'YYYY-MM-DD'), '출장여부', '선수의 출장 여부를 확인하고 싶습니다.', '접수 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user07', 24017, TO_DATE('2023-06-17', 'YYYY-MM-DD'), '선발출장여부', '선수의 선발 출장 여부를 확인해주세요.', '처리 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user08', 24018, TO_DATE('2023-06-18', 'YYYY-MM-DD'), '득점', '선수의 득점 기록을 알고 싶습니다.', '반려');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user09', 24019, TO_DATE('2023-06-19', 'YYYY-MM-DD'), '도움', '선수의 도움 기록을 알려주세요.', '접수 중');
INSERT INTO soccer_fielder_corr (user_id, soccer_fielder_record_id, request_date, request_property, request_context, request_process)
VALUES ('user10', 24020, TO_DATE('2023-06-20', 'YYYY-MM-DD'), '코너킥', '선수의 코너킥 기록을 확인하고 싶습니다.', '처리 중');

-- 축구_골키퍼기록_정정요청하다 ㅐ
INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 25001, TO_DATE('2023-06-01', 'YYYY-MM-DD'), '출장여부', '해당 골키퍼의 출장 여부를 확인하고 싶습니다.', '접수 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 25002, TO_DATE('2023-06-02', 'YYYY-MM-DD'), '선발출장여부', '해당 골키퍼가 선발 출장한 여부를 확인하고 싶습니다.', '처리 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 25003, TO_DATE('2023-06-03', 'YYYY-MM-DD'), '실점', '해당 골키퍼가 입은 실점의 수를 알고 싶습니다.', '반려');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 25004, TO_DATE('2023-06-04', 'YYYY-MM-DD'), '선방', '해당 골키퍼의 선방 횟수를 확인하고 싶습니다.', '처리 완료');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 25005, TO_DATE('2023-06-05', 'YYYY-MM-DD'), '출장여부', '해당 골키퍼의 출장 여부를 확인하고 싶습니다.', '처리 완료');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 25006, TO_DATE('2023-06-06', 'YYYY-MM-DD'), '선발출장여부', '해당 골키퍼가 선발 출장한 여부를 확인하고 싶습니다.', '처리 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 25007, TO_DATE('2023-06-07', 'YYYY-MM-DD'), '실점', '해당 골키퍼가 입은 실점의 수를 알고 싶습니다.', '접수 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 25008, TO_DATE('2023-06-08', 'YYYY-MM-DD'), '선방', '해당 골키퍼의 선방 횟수를 확인하고 싶습니다.', '처리 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 25009, TO_DATE('2023-06-09', 'YYYY-MM-DD'), '출장여부', '해당 골키퍼의 출장 여부를 확인하고 싶습니다.', '반려');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 25010, TO_DATE('2023-06-10', 'YYYY-MM-DD'), '선발출장여부', '해당 골키퍼가 선발 출장한 여부를 확인하고 싶습니다.', '처리 완료');
INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 25011, TO_DATE('2023-06-11', 'YYYY-MM-DD'), '실점', '해당 골키퍼가 입은 실점의 수를 알고 싶습니다.', '처리 완료');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 25012, TO_DATE('2023-06-12', 'YYYY-MM-DD'), '선방', '해당 골키퍼의 선방 횟수를 확인하고 싶습니다.', '처리 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 25013, TO_DATE('2023-06-13', 'YYYY-MM-DD'), '출장여부', '해당 골키퍼의 출장 여부를 확인하고 싶습니다.', '접수 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 25014, TO_DATE('2023-06-14', 'YYYY-MM-DD'), '선발출장여부', '해당 골키퍼가 선발 출장한 여부를 확인하고 싶습니다.', '처리 완료');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 25015, TO_DATE('2023-06-15', 'YYYY-MM-DD'), '실점', '해당 골키퍼가 입은 실점의 수를 알고 싶습니다.', '처리 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 25016, TO_DATE('2023-06-16', 'YYYY-MM-DD'), '선방', '해당 골키퍼의 선방 횟수를 확인하고 싶습니다.', '반려');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 25017, TO_DATE('2023-06-17', 'YYYY-MM-DD'), '출장여부', '해당 골키퍼의 출장 여부를 확인하고 싶습니다.', '처리 완료');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 25018, TO_DATE('2023-06-18', 'YYYY-MM-DD'), '선발출장여부', '해당 골키퍼가 선발 출장한 여부를 확인하고 싶습니다.', '처리 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 25019, TO_DATE('2023-06-19', 'YYYY-MM-DD'), '실점', '해당 골키퍼가 입은 실점의 수를 알고 싶습니다.', '접수 중');

INSERT INTO soccer_gk_corr (user_id, soccer_goalkeeper_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 25020, TO_DATE('2023-06-20', 'YYYY-MM-DD'), '선방', '해당 골키퍼의 선방 횟수를 확인하고 싶습니다.', '반려');

-- 축구_팀기록_정정요청하다 ㅐ
INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 26001, TO_DATE('2023-06-01', 'YYYY-MM-DD'), '경기결과', '축구 팀의 경기 결과를 확인하고 싶습니다.', '처리 완료');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 26002, TO_DATE('2023-06-02', 'YYYY-MM-DD'), '득점', '축구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 26003, TO_DATE('2023-06-03', 'YYYY-MM-DD'), '실점', '축구 팀의 실점에 대한 자세한 내용을 알려주세요.', '접수 중');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 26004, TO_DATE('2023-06-04', 'YYYY-MM-DD'), '경기결과', '축구 팀의 경기 결과를 확인하고 싶습니다.', '반려');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 26005, TO_DATE('2023-06-05', 'YYYY-MM-DD'), '득점', '축구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 26006, TO_DATE('2023-06-06', 'YYYY-MM-DD'), '실점', '축구 팀의 실점에 대한 자세한 내용을 알려주세요.', '처리 완료');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 26007, TO_DATE('2023-06-07', 'YYYY-MM-DD'), '경기결과', '축구 팀의 경기 결과를 확인하고 싶습니다.', '처리 완료');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 26008, TO_DATE('2023-06-08', 'YYYY-MM-DD'), '득점', '축구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 26009, TO_DATE('2023-06-09', 'YYYY-MM-DD'), '실점', '축구 팀의 실점에 대한 자세한 내용을 알려주세요.', '접수 중');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 26010, TO_DATE('2023-06-10', 'YYYY-MM-DD'), '경기결과', '축구 팀의 경기 결과를 확인하고 싶습니다.', '반려');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 26011, TO_DATE('2023-06-11', 'YYYY-MM-DD'), '득점', '축구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 26012, TO_DATE('2023-06-12', 'YYYY-MM-DD'), '실점', '축구 팀의 실점에 대한 자세한 내용을 알려주세요.', '처리 완료');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 26013, TO_DATE('2023-06-13', 'YYYY-MM-DD'), '경기결과', '축구 팀의 경기 결과를 확인하고 싶습니다.', '처리 완료');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 26014, TO_DATE('2023-06-14', 'YYYY-MM-DD'), '득점', '축구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 26015, TO_DATE('2023-06-15', 'YYYY-MM-DD'), '실점', '축구 팀의 실점에 대한 자세한 내용을 알려주세요.', '접수 중');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 26016, TO_DATE('2023-06-16', 'YYYY-MM-DD'), '경기결과', '축구 팀의 경기 결과를 확인하고 싶습니다.', '반려');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 26017, TO_DATE('2023-06-17', 'YYYY-MM-DD'), '득점', '축구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 26018, TO_DATE('2023-06-18', 'YYYY-MM-DD'), '실점', '축구 팀의 실점에 대한 자세한 내용을 알려주세요.', '처리 완료');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 26019, TO_DATE('2023-06-19', 'YYYY-MM-DD'), '경기결과', '축구 팀의 경기 결과를 확인하고 싶습니다.', '처리 완료');

INSERT INTO soccer_team_corr (user_id, soccer_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 26020, TO_DATE('2023-06-20', 'YYYY-MM-DD'), '득점', '축구 팀의 득점에 대한 정보를 요청합니다.', '처리 중');

-- LoL_e스포츠_팀기록_정정요청하다 ㅐ
INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 28001, TO_DATE('2024-05-01', 'YYYY-MM-DD'), '대회명', '대회명을 LoL Championship 2024로 변경', '접수 중');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 28002, TO_DATE('2024-05-02', 'YYYY-MM-DD'), '세트승', '세트승 수를 2으로 정정 요청', '반려');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 28003, TO_DATE('2024-05-03', 'YYYY-MM-DD'), '세트패', '세트패 수를 0으로 정정 요청', '처리 완료');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 28004, TO_DATE('2024-05-04', 'YYYY-MM-DD'), '결과', '결과 기록을 L로 변경 요청', '처리 완료');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 28005, TO_DATE('2024-05-05', 'YYYY-MM-DD'), '결과', '결과 기록을 W으로 변경 요청', '접수 중');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 28006, TO_DATE('2024-05-06', 'YYYY-MM-DD'), '세트승', '세트승 수를 0으로 정정 요청', '반려');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 28007, TO_DATE('2024-05-07', 'YYYY-MM-DD'), '세트승', '세트승 수를 2로 정정 요청', '처리 완료');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 28008, TO_DATE('2024-05-08', 'YYYY-MM-DD'), '세트패', '세트패 수를 2로 정정 요청', '처리 완료');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 28009, TO_DATE('2024-05-09', 'YYYY-MM-DD'), '결과', '결과 기록을 L로 변경 요청', '반려');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 28010, TO_DATE('2024-05-10', 'YYYY-MM-DD'), '결과', '결과 기록을 L로 변경 요청', '처리 완료');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 28011, TO_DATE('2024-05-11', 'YYYY-MM-DD'), '대회명', '대회명을 LoL Summer Championship로 변경', '반려');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 28012, TO_DATE('2024-05-12', 'YYYY-MM-DD'), '세트승', '세트승 수를 3으로 정정 요청', '처리 완료');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 28013, TO_DATE('2024-05-13', 'YYYY-MM-DD'), '세트패', '세트패 수를 2로 정정 요청', '접수 중');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 28014, TO_DATE('2024-05-14', 'YYYY-MM-DD'), '결과', '결과 기록을 L로 변경 요청', '반려');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 28015, TO_DATE('2024-05-15', 'YYYY-MM-DD'), '결과', '결과 기록을 L로 변경 요청', '처리 완료');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 28016, TO_DATE('2024-05-16', 'YYYY-MM-DD'), '대회명', '대회명을 LoL Spring Championship로 변경', '반려');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 28017, TO_DATE('2024-05-17', 'YYYY-MM-DD'), '세트승', '세트승 수를 2로 정정 요청', '반려');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 28018, TO_DATE('2024-05-18', 'YYYY-MM-DD'), '세트패', '세트패 수를 1로 정정 요청', '처리 중');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 28019, TO_DATE('2024-05-19', 'YYYY-MM-DD'), '세트승', '세트승 수를 2로 정정 요청', '반려');

INSERT INTO LoL_team_record_correction (user_id, lol_team_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 28020, TO_DATE('2024-05-20', 'YYYY-MM-DD'), '세트승', '세트승 수를 2로 정정 요청', '처리 완료');

-- LoL_e스포츠_선수기록_정정요청하다 ㅐ
INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 27001, TO_DATE('2024-06-01', 'YYYY-MM-DD'), '출전여부', 'LoL 경기에서의 출전 여부를 확인하고 싶습니다.', '처리 완료');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 27002, TO_DATE('2024-06-02', 'YYYY-MM-DD'), '세트결과', 'LoL 경기의 세트 결과를 알려주세요.', '처리 중');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 27003, TO_DATE('2024-06-03', 'YYYY-MM-DD'), '포지션', 'LoL 경기에서 선수의 포지션 정보를 요청합니다.', '접수 중');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 27004, TO_DATE('2024-06-04', 'YYYY-MM-DD'), '킬', 'LoL 경기에서 선수의 킬 정보를 확인하고 싶습니다.', '반려');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 27005, TO_DATE('2024-06-05', 'YYYY-MM-DD'), '데스', 'LoL 경기에서 선수의 데스 정보를 알려주세요.', '처리 중');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 27006, TO_DATE('2024-06-06', 'YYYY-MM-DD'), '어시스트', 'LoL 경기에서 선수의 어시스트 정보를 확인하고 싶습니다.', '처리 완료');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 27007, TO_DATE('2024-06-07', 'YYYY-MM-DD'), '획득골드', 'LoL 경기에서 선수의 획득골드 정보를 요청합니다.', '처리 완료');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 27008, TO_DATE('2024-06-08', 'YYYY-MM-DD'), '데미지', 'LoL 경기에서 선수의 가한 데미지에 대한 정보를 요청합니다.', '처리 중');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 27009, TO_DATE('2024-06-09', 'YYYY-MM-DD'), '출전여부', 'LoL 경기에서의 출전 여부를 확인하고 싶습니다.', '접수 중');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 27010, TO_DATE('2024-06-10', 'YYYY-MM-DD'), '세트결과', 'LoL 경기의 세트 결과를 알려주세요.', '반려');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user01', 27011, TO_DATE('2024-06-11', 'YYYY-MM-DD'), '포지션', 'LoL 경기에서 선수의 포지션 정보를 요청합니다.', '처리 중');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user02', 27012, TO_DATE('2024-06-12', 'YYYY-MM-DD'), '킬', 'LoL 경기에서 선수의 킬 정보를 확인하고 싶습니다.', '처리 완료');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user03', 27013, TO_DATE('2024-06-13', 'YYYY-MM-DD'), '데스', 'LoL 경기에서 선수의 데스 정보를 알려주세요.', '처리 완료');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user04', 27014, TO_DATE('2024-06-14', 'YYYY-MM-DD'), '어시스트', 'LoL 경기에서 선수의 어시스트 정보를 확인하고 싶습니다.', '처리 중');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user05', 27015, TO_DATE('2024-06-15', 'YYYY-MM-DD'), '획득골드', 'LoL 경기에서 선수의 획득골드 정보를 요청합니다.', '접수 중');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user06', 27016, TO_DATE('2024-06-16', 'YYYY-MM-DD'), '데미지', 'LoL 경기에서 선수의 가한 데미지에 대한 정보를 요청합니다.', '반려');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user07', 27017, TO_DATE('2024-06-17', 'YYYY-MM-DD'), '출전여부', 'LoL 경기에서의 출전 여부를 확인하고 싶습니다.', '처리 중');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user08', 27018, TO_DATE('2024-06-18', 'YYYY-MM-DD'), '세트결과', 'LoL 경기의 세트 결과를 알려주세요.', '처리 완료');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user09', 27019, TO_DATE('2024-06-19', 'YYYY-MM-DD'), '포지션', 'LoL 경기에서 선수의 포지션 정보를 요청합니다.', '처리 완료');

INSERT INTO LoL_player_record_correction (user_id, lol_player_record_id, request_date, request_property, request_context, request_process) 
VALUES ('user10', 27020, TO_DATE('2024-06-20', 'YYYY-MM-DD'), '킬', 'LoL 경기에서 선수의 킬 정보를 확인하고 싶습니다.', '처리 중');