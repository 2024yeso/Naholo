-- 데이터베이스 사용
USE Naholo_db;

-- 1. Users 테이블에 테스트 데이터 삽입
INSERT INTO `Users` (`USER_ID`, `USER_PW`, `NAME`, `PHONE`, `BIRTH`, `GENDER`, `NICKNAME`, `USER_CHARACTER`, `LV`, `INTRODUCE`, `IMAGE`)
VALUES 
('user1', 'password1', 'John Doe', '010-1234-5678', '1990-01-01', 1, 'johnny', 'A', 5, 'Hello, I am John!', 'user1.png'),
('user2', 'password2', 'Jane Smith', '010-8765-4321', '1992-02-02', 0, 'jane', 'B', 3, 'I am Jane!', 'user2.png');

-- 2. Where 테이블에 테스트 데이터 삽입
INSERT INTO `Where` (`WHERE_NAME`, `WHERE_LOCATE`, `WHERE_RATE`, `WHERE_TYPE`, `LATITUDE`, `LONGITUDE`)
VALUES 
('Place1', 'Seoul', 4.5, 'eat', 37.5665, 126.9780),
('Place2', 'Busan', 3.8, 'play', 35.1796, 129.0756),
('Place3', 'Incheon', 4.2, 'sleep', 37.4563, 126.7052);

-- 3. Users_Image 테이블에 테스트 데이터 삽입
INSERT INTO `Users_Image` (`USER_ID`, `IMAGE`)
VALUES 
('user1', 'user1_image.png'),
('user2', 'user2_image.png');

-- 4. Follow 테이블에 테스트 데이터 삽입
INSERT INTO `Follow` (`USER_ID`, `FOLLOWER`)
VALUES 
('user1', 'user2'),
('user2', 'user1');

-- 5. LIKES 테이블에 테스트 데이터 삽입
INSERT INTO `LIKES` (`USER_ID`, `WHERE_ID`)
VALUES 
('user1', 1),
('user2', 2);

-- 6. WHERE_REVIEW 테이블에 테스트 데이터 삽입
INSERT INTO `WHERE_REVIEW` (
    `USER_ID`, `WHERE_ID`, `REVIEW_CONTENT`, `WHERE_LIKE`, `WHERE_RATE`,
    `REASON_MENU`, `REASON_MOOD`, `REASON_SAFE`, `REASON_SEAT`, `REASON_TRANSPORT`,
    `REASON_PARK`, `REASON_LONG`, `REASON_VIEW`, `REASON_INTERACTION`, `REASON_QUITE`,
    `REASON_PHOTO`, `REASON_WATCH`
)
VALUES 
('user1', 1, 'Great place to eat!', 10, 4.5, TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE),
('user2', 2, 'Fun place to play!', 5, 3.8, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE);

-- 7. REVIEW_IMAGE 테이블에 테스트 데이터 삽입
INSERT INTO `REVIEW_IMAGE` (`REVIEW_ID`, `IMAGE`)
VALUES 
(1, 'review1_image1.png'),
(1, 'review1_image2.png'),
(2, 'review2_image1.png');

-- 8. WHERE_IMAGE 테이블에 테스트 데이터 삽입
INSERT INTO `WHERE_IMAGE` (`WHERE_ID`, `IMAGE`)
VALUES 
(1, 'place1_image.png'),
(2, 'place2_image.png');

-- 9. Journal_post 테이블에 테스트 데이터 삽입
INSERT INTO `Journal_post` (`USER_ID`, `WHERE_ID`, `POST_NAME`, `POST_CONTENT`, `POST_CREATE`, `POST_UPDATE`, `POST_LIKE`)
VALUES 
('user1', 1, 'John\'s Post', 'This is my first post.', '2023-01-01', '2023-01-01', 15),
('user2', 2, 'Jane\'s Post', 'Hello, this is Jane!', '2023-02-02', '2023-02-02', 20);

-- 10. Journal_comment 테이블에 테스트 데이터 삽입
INSERT INTO `Journal_comment` (`POST_ID`, `COMMENT_CONTENT`, `USER_ID`)
VALUES 
(1, 'Nice post, John!', 'user2'),
(2, 'Interesting, Jane!', 'user1');
