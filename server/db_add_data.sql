-- 데이터베이스 사용
USE Naholo_db;

-- 'Users' 테이블에 더미 데이터 삽입
INSERT INTO Users (USER_ID, USER_PW, NAME, PHONE, BIRTH, GENDER, NICKNAME, USER_CHARACTER, LV, INTRODUCE, IMAGE)
VALUES 
('user1', 'password1', 'Alice', '010-1234-5678', '1990-01-01', TRUE, 'Alice123', 'Character A', 1, 'Hello!', 1),
('user2', 'password2', 'Bob', '010-2345-6789', '1992-02-02', FALSE, 'Bob456', 'Character B', 2, 'Hi there!', 2);

-- 'Where' 테이블에 더미 데이터 삽입
INSERT INTO `Where` (WHERE_NAME, WHERE_LOCATE, WHERE_RATE, WHERE_TYPE)
VALUES 
('Place A', 'Location A', 4.5, 'Type A'),
('Place B', 'Location B', 3.8, 'Type B');

-- 'Users_Image' 테이블에 더미 데이터 삽입
INSERT INTO Users_Image (USER_ID, IMAGE)
VALUES 
('user1', 'image1.jpg'),
('user2', 'image2.jpg');

-- 'Journal_post' 테이블에 더미 데이터 삽입 (외래 키 참조: Users, Where)
INSERT INTO Journal_post (USER_ID, WHERE_ID, POST_NAME, POST_CONTENT, POST_CREATE, POST_UPDATE, POST_LIKE)
VALUES 
('user1', 1, 'Post A', 'Content A', '2024-09-01', '2024-09-02', 10),
('user2', 2, 'Post B', 'Content B', '2024-09-03', '2024-09-04', 20);

-- 'Journal_image' 테이블에 더미 데이터 삽입 (외래 키 참조: Journal_post)
INSERT INTO Journal_image (POST_ID, IMAGE)
VALUES 
(1, 'journal_image1.jpg'),
(2, 'journal_image2.jpg');

-- 'Journal_comment' 테이블에 더미 데이터 삽입 (외래 키 참조: Journal_post)
INSERT INTO Journal_comment (POST_ID, COMMENT_CONTENT, USER_ID)
VALUES 
(1, 'Great post!', 1),
(2, 'Interesting read.', 2);

-- 'WHERE_REVIEW' 테이블에 더미 데이터 삽입 (외래 키 참조: Users, Where)
INSERT INTO WHERE_REVIEW (USER_ID, WHERE_ID, REVIEW_CONTENT, WHERE_LIKE, WHERE_RATE)
VALUES 
('user1', 1, 'Amazing place!', 10, 4.5),
('user2', 2, 'Not bad.', 5, 3.8);

-- 'REVIEW_IMAGE' 테이블에 더미 데이터 삽입 (외래 키 참조: WHERE_REVIEW)
INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE)
VALUES 
(1, 'review_image1.jpg'),
(2, 'review_image2.jpg');

-- 'WHERE_IMAGE' 테이블에 더미 데이터 삽입 (외래 키 참조: Where)
INSERT INTO WHERE_IMAGE (WHERE_ID, IMAGE)
VALUES 
(1, 'where_image1.jpg'),
(2, 'where_image2.jpg');

-- 'LIKES' 테이블에 더미 데이터 삽입 (외래 키 참조: Users, Where)
INSERT INTO LIKES (USER_ID, WHERE_ID)
VALUES 
('user1', 1),
('user2', 2);

-- 'Follow' 테이블에 더미 데이터 삽입 (외래 키 참조: Users)
INSERT INTO Follow (USER_ID, FOLLOWER)
VALUES 
('user1', 'user2'),
('user2', 'user1');
