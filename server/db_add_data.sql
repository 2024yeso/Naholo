-- 1. Users 테이블에 더미 데이터 삽입
INSERT INTO `Users` (`USER_ID`, `USER_PW`, `NAME`, `PHONE`, `BIRTH`, `GENDER`, `NICKNAME`, `USER_CHARACTER`, `LV`, `INTRODUCE`, `IMAGE`, `EXP`) VALUES
('user1', 'password1', 'Alice', '010-1234-5678', '1990-01-01', TRUE, 'Ali', 'A', 1, 'Hello, I am Alice.', 'alice_image.jpg', 100),
('user2', 'password2', 'Bob', '010-2345-6789', '1991-02-02', FALSE, 'Bobby', 'B', 2, 'Hello, I am Bob.', 'bob_image.jpg', 200),
('user3', 'password3', 'Charlie', '010-3456-7890', '1992-03-03', TRUE, 'Char', 'C', 3, 'Hello, I am Charlie.', 'charlie_image.jpg', 300),
('user4', 'password4', 'Diana', '010-4567-8901', '1993-04-04', FALSE, 'Di', 'D', 4, 'Hello, I am Diana.', 'diana_image.jpg', 400),
('user5', 'password5', 'Edward', '010-5678-9012', '1994-05-05', TRUE, 'Ed', 'E', 5, 'Hello, I am Edward.', 'edward_image.jpg', 500);

-- 2. Where 테이블에 더미 데이터 삽입
INSERT INTO `Where` (`WHERE_ID`, `WHERE_NAME`, `WHERE_LOCATE`, `WHERE_RATE`, `WHERE_TYPE`, `LATITUDE`, `LONGITUDE`) VALUES
(1, 'Sunny Cafe', 'Seoul, Korea', 4.5, 'Cafe', 37.5665, 126.9780),
(2, 'Moonlight Restaurant', 'Busan, Korea', 4.2, 'Restaurant', 35.1796, 129.0756),
(3, 'Star Park', 'Incheon, Korea', 4.0, 'Park', 37.4563, 126.7052),
(4, 'Galaxy Museum', 'Daegu, Korea', 3.8, 'Museum', 35.8714, 128.6014),
(5, 'Comet Theater', 'Daejeon, Korea', 4.7, 'Theater', 36.3504, 127.3845);

-- 3. Users_Image 테이블에 더미 데이터 삽입
INSERT INTO `Users_Image` (`USER_ID`, `IMAGE`) VALUES
('user1', 'alice_additional_image.jpg'),
('user2', 'bob_additional_image.jpg'),
('user3', 'charlie_additional_image.jpg'),
('user4', 'diana_additional_image.jpg'),
('user5', 'edward_additional_image.jpg');

-- 4. Follow 테이블에 더미 데이터 삽입
INSERT INTO `Follow` (`USER_ID`, `FOLLOWER`) VALUES
('user1', 'user2'),
('user1', 'user3'),
('user2', 'user3'),
('user2', 'user4'),
('user3', 'user4'),
('user3', 'user5'),
('user4', 'user5'),
('user4', 'user1'),
('user5', 'user1'),
('user5', 'user2');

-- 5. LIKES 테이블에 더미 데이터 삽입
INSERT INTO `LIKES` (`USER_ID`, `WHERE_ID`) VALUES
('user1', 1),
('user1', 2),
('user2', 2),
('user2', 3),
('user3', 3),
('user3', 4),
('user4', 4),
('user4', 5),
('user5', 5),
('user5', 1);

-- 6. WHERE_REVIEW 테이블에 더미 데이터 삽입
INSERT INTO `WHERE_REVIEW` (`USER_ID`, `WHERE_ID`, `REVIEW_CONTENT`, `WHERE_LIKE`, `WHERE_RATE`,
`REASON_MENU`, `REASON_MOOD`, `REASON_SAFE`, `REASON_SEAT`, `REASON_TRANSPORT`,
`REASON_PARK`, `REASON_LONG`, `REASON_VIEW`, `REASON_INTERACTION`, `REASON_QUITE`,
`REASON_PHOTO`, `REASON_WATCH`) VALUES
('user1', 1, 'Amazing coffee and ambiance.', 15, 4.5, TRUE, TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, FALSE),
('user2', 2, 'Delicious food but a bit noisy.', 10, 4.0, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE),
('user3', 3, 'Great place to relax.', 20, 4.2, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
('user4', 4, 'Interesting exhibits but crowded.', 5, 3.8, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE),
('user5', 5, 'Best theater experience!', 25, 4.9, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE);

-- 7. REVIEW_IMAGE 테이블에 더미 데이터 삽입
INSERT INTO `REVIEW_IMAGE` (`REVIEW_ID`, `IMAGE`) VALUES
(1, 'review_image1.jpg'),
(2, 'review_image2.jpg'),
(3, 'review_image3.jpg'),
(4, 'review_image4.jpg'),
(5, 'review_image5.jpg');

-- 8. WHERE_IMAGE 테이블에 더미 데이터 삽입
INSERT INTO `WHERE_IMAGE` (`WHERE_ID`, `IMAGE`) VALUES
(1, 'where_image1.jpg'),
(1, 'where_image1_additional.jpg'),
(2, 'where_image2.jpg'),
(2, 'where_image2_additional.jpg'),
(3, 'where_image3.jpg'),
(3, 'where_image3_additional.jpg'),
(4, 'where_image4.jpg'),
(4, 'where_image4_additional.jpg'),
(5, 'where_image5.jpg'),
(5, 'where_image5_additional.jpg');

-- 9. Journal_post 테이블에 더미 데이터 삽입
INSERT INTO `Journal_post` (`USER_ID`, `POST_NAME`, `POST_CONTENT`, `POST_CREATE`, `POST_LIKE`) VALUES
('user1',  'Morning at Sunny Cafe', 'Had a wonderful morning sipping coffee.',  '2023-01-01', 30),
('user2',  'Dinner at Moonlight', 'Enjoyed a romantic dinner.', '2023-02-01', 20),
('user3', 'Relaxing at Star Park', 'Spent the day reading under the trees.', '2023-03-01',  25),
('user4','Exploring Galaxy Museum', 'Learned a lot about space.', '2023-04-01', 15),
('user5',  'Watching a Play at Comet Theater', 'The performance was breathtaking.', '2023-05-01', , 35);

-- 10. Journal_comment 테이블에 더미 데이터 삽입
INSERT INTO `Journal_comment` (`POST_ID`, `COMMENT_CONTENT`, `USER_ID`) VALUES
(1, 'Sounds like a great start to the day!', 'user2'),
(1, 'I love that place too!', 'user3'),
(2, 'Glad you had a good time.', 'user1'),
(2, 'I should visit there.', 'user4'),
(3, 'That park is so peaceful.', 'user5'),
(3, 'Next time, let\'s go together!', 'user2'),
(4, 'I want to visit the museum.', 'user3'),
(4, 'Great post!', 'user5'),
(5, 'The theater is amazing!', 'user1'),
(5, 'I enjoyed the play as well.', 'user4');

