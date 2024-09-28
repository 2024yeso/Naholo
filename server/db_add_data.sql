-- 데이터베이스 사용
USE Naholo_db;

-- 1. 데이터 삽입: Users
INSERT INTO `Users` (
    `USER_ID`, `USER_PW`, `NAME`, `PHONE`, `BIRTH`, `GENDER`, 
    `NICKNAME`, `USER_CHARACTER`, `LV`, `INTRODUCE`, `IMAGE`, `EXP`
) VALUES
('user1', 'password1', 'Alice', '010-0000-0001', '1990-01-01', TRUE, 'AliceNick', 'Friendly', 5, 'Hello, I am Alice!', 'abcd', 100),
('user2', 'password2', 'Bob', '010-0000-0002', '1991-02-02', FALSE, 'BobNick', 'Adventurous', 3, 'Bob here!', 'abcd', 50),
('user3', 'password3', 'Charlie', '010-0000-0003', '1992-03-03', TRUE, 'CharlieNick', 'Creative', 4, 'Charlie at your service.', 'abcd', 75),
('user4', 'password4', 'Diana', '010-0000-0004', '1993-04-04', FALSE, 'DianaNick', 'Smart', 2, 'Diana says hi!', 'abcd', 30),
('user5', 'password5', 'Eve', '010-0000-0005', '1994-05-05', TRUE, 'EveNick', 'Curious', 1, 'Eve here.', 'abcd', 10);

-- 2. 데이터 삽입: Where
INSERT INTO `Where` (
    `WHERE_NAME`, `WHERE_LOCATE`, `WHERE_RATE`, `WHERE_TYPE`, 
    `LATITUDE`, `LONGITUDE`
) VALUES
('Park', 'Seoul', 4.5, 'Recreation', 37.5665, 126.9780),
('Cafe', 'Busan', 4.0, 'Food', 35.1796, 129.0756),
('Museum', 'Daegu', 4.8, 'Education', 35.8722, 128.6014),
('Restaurant', 'Incheon', 3.9, 'Food', 37.4563, 126.7052),
('Library', 'Gwangju', 4.2, 'Education', 35.1595, 126.8526);

-- 3. 데이터 삽입: Follow
INSERT INTO `Follow` (`USER_ID`, `FOLLOWER`) VALUES
('user1', 'user2'),
('user1', 'user3'),
('user2', 'user3'),
('user2', 'user4'),
('user3', 'user1');

-- 4. 데이터 삽입: LIKES
INSERT INTO `LIKES` (`USER_ID`, `WHERE_ID`) VALUES
('user1', 1),
('user2', 1),
('user3', 2),
('user4', 2),
('user5', 3);

-- 5. 데이터 삽입: WHERE_REVIEW
INSERT INTO `WHERE_REVIEW` (
    `USER_ID`, `WHERE_ID`, `REVIEW_CONTENT`, `WHERE_LIKE`, 
    `WHERE_RATE`, `REASON_MENU`, `REASON_MOOD`, 
    `REASON_SAFE`, `REASON_SEAT`, `REASON_TRANSPORT`, 
    `REASON_PARK`, `REASON_LONG`, `REASON_VIEW`, 
    `REASON_INTERACTION`, `REASON_QUITE`, `REASON_PHOTO`, 
    `REASON_WATCH`
) VALUES
('user1', 1, 'Loved the scenery at the park.', 10, 4.5, TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, FALSE),
('user2', 2, 'Great coffee and ambiance.', 8, 4.0, TRUE, TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE),
('user3', 3, 'Very informative exhibits.', 15, 4.8, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE),
('user4', 4, 'Good food but service was slow.', 5, 3.9, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE),
('user5', 5, 'Quiet and perfect for studying.', 12, 4.2, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE);

-- 6. 데이터 삽입: REVIEW_IMAGE
INSERT INTO `REVIEW_IMAGE` (`REVIEW_ID`, `IMAGE`) VALUES
(1, 'abcd'),
(2, 'abcd'),
(3, 'abcd');

-- 7. 데이터 삽입: WHERE_IMAGE
INSERT INTO `WHERE_IMAGE` (`WHERE_ID`, `IMAGE`) VALUES
(1, 'abcd'),
(2, 'abcd');

-- 8. 데이터 삽입: Journal_post
INSERT INTO `Journal_post` (
    `USER_ID`, `POST_NAME`, `POST_CONTENT`, `POST_CREATE`, `POST_LIKE`
) VALUES
('user1', 'My Day at Park', 'I had a great time at the park today.', '2024-09-26 10:00:00', 5),
('user2', 'Cafe Visit', 'Visited a new cafe in Busan. Loved the coffee!', '2024-09-25 14:30:00', 10),
('user3', 'Museum Tour', 'Spent the afternoon at the museum. Very informative.', '2024-09-24 09:15:00', 8);

-- 9. 데이터 삽입: Post_like
INSERT INTO `Post_like` (`POST_ID`, `USER_ID`) VALUES
(1, 'user2'),
(2, 'user1'),
(3, 'user4');

-- 10. 데이터 삽입: Journal_comment
INSERT INTO `Journal_comment` (
    `POST_ID`, `COMMENT_CONTENT`, `USER_ID`
) VALUES
(1, 'Great post!', 'user2'),
(2, 'Love that cafe!', 'user1'),
(3, 'Nice visit!', 'user4');

-- 11. 데이터 삽입: journal_image
INSERT INTO `journal_image` (`POST_ID`, `IMAGE_DATA`) VALUES
(1, 'abcd'),
(2, 'abcd');
