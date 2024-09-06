-- 데이터베이스 사용
USE Naholo_db;

-- 'Where' 테이블에 더미 데이터 삽입
INSERT INTO `Where` (WHERE_NAME, WHERE_LOCATE, WHERE_RATE, WHERE_TYPE)
VALUES 
('Place A', 'Location A', 4.5, 'Type A'),
('Place B', 'Location B', 3.8, 'Type B');

-- 'Users' 테이블에 더미 데이터 삽입
INSERT INTO Users (ID, PW, NAME, PHONE, BIRTH, GENDER, NICKNAME, USER_CHARACTER, LV, INTRODUCE, IMAGE)
VALUES 
('user1', 'password1', 'Alice', '010-1234-5678', '1990-01-01', 1, 'Alice123', 'Character A', 1, 'Hello!', 1),
('user2', 'password2', 'Bob', '010-2345-6789', '1992-02-02', 0, 'Bob456', 'Character B', 2, 'Hi there!', 2);

-- 'Users_Image' 테이블에 더미 데이터 삽입
INSERT INTO Users_Image (ID, IMAGE)
VALUES 
('user1', 'image1.jpg'),
('user2', 'image2.jpg');

-- 'Journal_image' 테이블에 더미 데이터 삽입
INSERT INTO Journal_image (JOURNAL_ID, IMAGE)
VALUES 
(1, 'journal_image1.jpg'),
(2, 'journal_image2.jpg');

-- 'Journal_comment' 테이블에 더미 데이터 삽입
INSERT INTO Journal_comment (POST_ID, COMMENT_CONTENT, USER_ID)
VALUES 
(1, 'Great post!', 'user1'),
(2, 'Interesting read.', 'user2');

-- 'WHERE_REVIEW' 테이블에 더미 데이터 삽입
INSERT INTO WHERE_REVIEW (USER_ID, WHERE_ID, REVIEW_CONTENT, WHERE_LIKE, WHERE_RATE)
VALUES 
('user1', 1, 'Amazing place!', 10, 4.5),
('user2', 2, 'Not bad.', 5, 3.8);

-- 'REVIEW_IMAGE' 테이블에 더미 데이터 삽입
INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE)
VALUES 
(1, 'review_image1.jpg'),
(2, 'review_image2.jpg');

-- 'WHERE_IMAGE' 테이블에 더미 데이터 삽입
INSERT INTO WHERE_IMAGE (WHERE_ID, IMAGE)
VALUES 
(1, 'where_image1.jpg'),
(2, 'where_image2.jpg');

-- 'LIKES' 테이블에 더미 데이터 삽입
INSERT INTO LIKES (USER_ID, WHERE_ID)
VALUES 
('user1', 1),
('user2', 2);

-- 'Follow' 테이블에 더미 데이터 삽입
INSERT INTO Follow (ID, FOLLOWER)
VALUES 
('user1', 'user2'),
('user2', 'user1');
