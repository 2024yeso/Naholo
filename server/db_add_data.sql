
-- 데이터베이스 사용
USE Naholo_db;

-- 1. Users 테이블에 데이터 삽입
INSERT INTO `Users` (`USER_ID`, `USER_PW`, `NAME`, `PHONE`, `BIRTH`, `GENDER`, `NICKNAME`, `USER_CHARACTER`, `LV`, `INTRODUCE`, `IMAGE`, `EXP`) VALUES
('user1', 'password1', 'Alice', '010-1234-5678', '1990-01-01', TRUE, 'AliceWonder', 'Character1', 1, 'Hello, I am Alice.', 'YmFzZTY0MTE=', 100),
('user2', 'password2', 'Bob', '010-8765-4321', '1992-02-02', FALSE, 'BobBuilder', 'Character2', 2, 'Hi, Bob here.', 'YmFzZTY0aW1hZ2VfdXNlcjI=', 200),
('user3', 'password3', 'Charlie', '010-5555-6666', '1995-03-03', TRUE, 'CharlieChap', 'Character3', 3, 'Hello, Charlie here.', 'YmFzZTY0aW1hZ2VfdXNlcjM=', 300),
('user4', 'password4', 'Diana', '010-7777-8888', '1994-04-04', FALSE, 'DianaDiva', 'Character4', 4, 'I love traveling.', 'YmFzZTY0aW1hZ2VfdXNlcjQ=', 400),
('user5', 'password5', 'Eve', '010-9999-0000', '1996-05-05', TRUE, 'EveAdventurer', 'Character5', 5, 'I enjoy hiking and nature.', 'YmFzZTY0aW1hZ2VfdXNlcjU=', 500);

-- 2. Where 테이블에 데이터 삽입
INSERT INTO `Where` (WHERE_ID, `WHERE_NAME`, `WHERE_LOCATE`, `WHERE_RATE`, `WHERE_TYPE`,WHERE_IMaGE, `LATITUDE`, `LONGITUDE`) VALUES
('1','Coffee Shop A', 'Seoul', 4.5, 'play','YmFzZTY0aW1hZ2VfcmV2aWV3NQ==', 37.5665, 126.9780),
('2','Restaurant B', 'Busan', 4.0, 'play','YmFzZTY0aW1hZ2VfcmV2aWV3NQ==', 35.1796, 129.0756),
('3','Park C', 'Incheon', 4.8, 'eat', 'YmFzZTY0aW1hZ2VfcmV2aWV3NQ==',37.4563, 126.7052),
('4','Museum D', 'Daegu', 4.3, 'sleep', 'YmFzZTY0aW1hZ2VfcmV2aWV3NQ==',35.8714, 128.6014),
('5','Library E', 'Sejong', 4.9, 'sleep', 'YmFzZTY0aW1hZ2VfcmV2aWV3NQ==',36.4875, 127.2817);

-- 3. Follow 테이블에 데이터 삽입
INSERT INTO `Follow` (`USER_ID`, `FOLLOWER`) VALUES
('user1', 'user2'),
('user2', 'user1'),
('user3', 'user1'),
('user4', 'user2'),
('user5', 'user3');

-- 4. LIKES 테이블에 데이터 삽입
INSERT INTO `LIKES` (`USER_ID`, `WHERE_ID`) VALUES
('user1', 1),
('user2', 2),
('user3', 3),
('user4', 4),
('user5', 5);

-- 5. WHERE_REVIEW 테이블에 데이터 삽입
INSERT INTO `WHERE_REVIEW` (`USER_ID`, `WHERE_ID`, `REVIEW_CONTENT`, `WHERE_LIKE`, `WHERE_RATE`, `REASON_MENU`, `REASON_MOOD`, `REASON_SAFE`, `REASON_SEAT`, `REASON_TRANSPORT`, `REASON_PARK`, `REASON_LONG`, `REASON_VIEW`, `REASON_INTERACTION`, `REASON_QUITE`, `REASON_PHOTO`, `REASON_WATCH`) VALUES
('user1', 1, 'Great coffee and atmosphere.', 10, 4.5, TRUE, TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE),
('user2', 2, 'Delicious food!', 5, 4.0, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE),
('user3', 3, 'Beautiful park, very relaxing.', 7, 4.8, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE),
('user4', 4, 'Interesting museum, learned a lot.', 12, 4.3, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE),
('user5', 5, 'Quiet and peaceful library, perfect for reading.', 15, 4.9, FALSE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, TRUE);

-- 6. REVIEW_IMAGE 테이블에 데이터 삽입
INSERT INTO `REVIEW_IMAGE` (`REVIEW_ID`, `IMAGE`) VALUES
(1, 'YmFzZTY0aW1hZ2VfcmV2aWV3MQ=='),
(1, 'YmFzZTY0aW1hZ2VfcmV2aWV3MV8y'),
(2, 'YmFzZTY0aW1hZ2VfcmV2aWV3Mg=='),
(3, 'YmFzZTY0aW1hZ2VfcmV2aWV3Mw=='),
(4, 'YmFzZTY0aW1hZ2VfcmV2aWV3NA=='),
(5, 'YmFzZTY0aW1hZ2VfcmV2aWV3NQ==');

-- 8. Journal_post 테이블에 데이터 삽입
INSERT INTO `Journal_post` (`USER_ID`, `POST_NAME`, `POST_CONTENT`, `POST_CREATE`, `POST_LIKE`, `혼캎`, `혼영`, `혼놀`, `혼밥`, `혼박`, `혼술`, `기타`) VALUES
('user1', 'My Solo Trip to Seoul', 'I had a great time visiting Seoul alone.', '2023-10-01 12:00:00', 15, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE),
('user2', 'Solo Dining Experience', 'Tried a new restaurant alone.', '2023-10-02 13:00:00', 5, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE),
('user3', 'Solo Park Walk', 'I enjoyed a peaceful walk in the park today.', '2023-10-03 14:00:00', 10, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE),
('user4', 'Museum Exploration', 'Spent the day at the museum and learned so much.', '2023-10-04 15:00:00', 8, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE),
('user5', 'Library Day', 'Spent the day reading at the library, so peaceful.', '2023-10-05 16:00:00', 20, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE);

-- 9. Journal_comment 테이블에 데이터 삽입
INSERT INTO `Journal_comment` (`POST_ID`, `COMMENT_CONTENT`, `USER_ID`) VALUES
(1, 'Sounds fun!', 'user2'),
(2, 'Glad you enjoyed it!', 'user1'),
(3, 'I love that park too!', 'user4'),
(4, 'Museums are the best for learning.', 'user3'),
(5, 'I should visit that library.', 'user1');

-- 10. Post_like 테이블에 데이터 삽입
INSERT INTO `Post_like` (`POST_ID`, `USER_ID`) VALUES
(1, 'user2'),
(2, 'user1'),
(3, 'user4'),
(4, 'user3'),
(5, 'user5');

-- 11. journal_image 테이블에 데이터 삽입
INSERT INTO `journal_image` (`POST_ID`, `IMAGE_DATA`) VALUES
(1, 'YmFzZTY0aW1hZ2VfcG9zdDE='),
(1, 'YmFzZTY0aW1hZ2VfcG9zdDFfMg=='),
(2, 'YmFzZTY0aW1hZ2VfcG9zdDI='),
(3, 'YmFzZTY0aW1hZ2VfcG9zdDM='),
(4, 'YmFzZTY0aW1hZ2VfcG9zdDQ='),
(5, 'YmFzZTY0aW1hZ2VfcG9zdDU=');

-- 12. Journal_post 테이블에서 POST_LIKE 업데이트
UPDATE `Journal_post` SET `POST_LIKE` = (SELECT COUNT(*) FROM `Post_like` WHERE `Post_like`.`POST_ID` = `Journal_post`.`POST_ID`);

-- 13. Follow 테이블에 추가 데이터 삽입
INSERT INTO `Follow` (`USER_ID`, `FOLLOWER`) VALUES
('user3', 'user5'),
('user4', 'user1'),
('user5', 'user2');

-- 14. Journal_post 테이블에서 POST_LIKE 다시 업데이트
UPDATE `Journal_post` SET `POST_LIKE` = (SELECT COUNT(*) FROM `Post_like` WHERE `Post_like`.`POST_ID` = `Journal_post`.`POST_ID`);
