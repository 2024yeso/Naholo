-- 데이터베이스 사용
USE Naholo_db;

-- 'Users' 테이블에 더미 데이터 삽입
INSERT INTO Users (USER_ID, USER_PW, NAME, PHONE, BIRTH, GENDER, NICKNAME, USER_CHARACTER, LV, INTRODUCE, IMAGE)
VALUES 
('user1', 'password1', 'Alice', '010-1234-5678', '1990-01-01', TRUE, 'Alice123', 'Character A', 1, 'Hello!', 1),
('user2', 'password2', 'Bob', '010-2345-6789', '1992-02-02', FALSE, 'Bob456', 'Character B', 2, 'Hi there!', 2),
('user3', 'password3', 'Charlie', '010-3456-7890', '1993-03-03', TRUE, 'Charlie789', 'Character C', 3, 'Howdy!', 3),
('user4', 'password4', 'David', '010-4567-8901', '1994-04-04', FALSE, 'David012', 'Character D', 4, 'Greetings!', 4),
('user5', 'password5', 'Eve', '010-5678-9012', '1995-05-05', TRUE, 'Eve345', 'Character E', 5, 'Nice to meet you!', 5),
('user6', 'password6', 'Frank', '010-6789-0123', '1996-06-06', FALSE, 'Frank678', 'Character F', 6, 'Hello there!', 6),
('user7', 'password7', 'Grace', '010-7890-1234', '1997-07-07', TRUE, 'Grace901', 'Character G', 7, 'Hey!', 7),
('user8', 'password8', 'Hank', '010-8901-2345', '1998-08-08', FALSE, 'Hank234', 'Character H', 8, 'What\'s up!', 8),
('user9', 'password9', 'Ivy', '010-9012-3456', '1999-09-09', TRUE, 'Ivy567', 'Character I', 9, 'Hi!', 9),
('user10', 'password10', 'Jack', '010-0123-4567', '2000-10-10', FALSE, 'Jack890', 'Character J', 10, 'Good day!', 10);

-- 'Where' 테이블에 더미 데이터 삽입
INSERT INTO `Where` (WHERE_NAME, WHERE_LOCATE, WHERE_RATE, WHERE_TYPE)
VALUES 
('Place A', 'Location A', 4.5, 'Type A'),
('Place B', 'Location B', 3.8, 'Type B'),
('Place C', 'Location C', 4.0, 'Type C'),
('Place D', 'Location D', 4.2, 'Type D'),
('Place E', 'Location E', 3.5, 'Type E'),
('Place F', 'Location F', 4.8, 'Type F'),
('Place G', 'Location G', 3.9, 'Type G'),
('Place H', 'Location H', 4.1, 'Type H'),
('Place I', 'Location I', 4.3, 'Type I'),
('Place J', 'Location J', 3.7, 'Type J');

-- 'Follow' 테이블에 더미 데이터 삽입
INSERT INTO Follow (USER_ID, FOLLOWER)
VALUES 
('user1', 'user2'),
('user1', 'user3'),
('user2', 'user1'),
('user2', 'user4'),
('user3', 'user1'),
('user3', 'user5'),
('user4', 'user2'),
('user4', 'user6'),
('user5', 'user3'),
('user5', 'user7'),
('user6', 'user4'),
('user6', 'user8'),
('user7', 'user5'),
('user7', 'user9'),
('user8', 'user6'),
('user8', 'user10'),
('user9', 'user7'),
('user9', 'user1'),
('user10', 'user8'),
('user10', 'user2');

-- 'Users_Image' 테이블에 더미 데이터 삽입
INSERT INTO Users_Image (USER_ID, IMAGE)
VALUES 
('user1', 'image1.jpg'),
('user2', 'image2.jpg'),
('user3', 'image3.jpg'),
('user4', 'image4.jpg'),
('user5', 'image5.jpg'),
('user6', 'image6.jpg'),
('user7', 'image7.jpg'),
('user8', 'image8.jpg'),
('user9', 'image9.jpg'),
('user10', 'image10.jpg');

-- 'LIKES' 테이블에 더미 데이터 삽입
INSERT INTO LIKES (USER_ID, WHERE_ID)
VALUES 
('user1', 1),
('user1', 2),
('user2', 1),
('user2', 3),
('user3', 2),
('user3', 4),
('user4', 3),
('user4', 5),
('user5', 4),
('user5', 6),
('user6', 5),
('user6', 7),
('user7', 6),
('user7', 8),
('user8', 7),
('user8', 9),
('user9', 8),
('user9', 10),
('user10', 9),
('user10', 1);

-- 'WHERE_REVIEW' 테이블에 더미 데이터 삽입
INSERT INTO WHERE_REVIEW (USER_ID, WHERE_ID, REVIEW_CONTENT, WHERE_LIKE, WHERE_RATE)
VALUES 
('user1', 1, 'Amazing place!', 10, 4.5),
('user2', 2, 'Not bad.', 5, 3.8),
('user3', 3, 'Loved it.', 8, 4.0),
('user4', 4, 'Could be better.', 3, 4.2),
('user5', 5, 'Perfect!', 12, 3.5),
('user6', 6, 'Worth a visit.', 7, 4.8),
('user7', 7, 'Good for families.', 9, 3.9),
('user8', 8, 'Highly recommended.', 15, 4.1),
('user9', 9, 'Nice spot.', 11, 4.3),
('user10', 10, 'Would go again.', 6, 3.7);

-- 'Journal_post' 테이블에 더미 데이터 삽입
INSERT INTO Journal_post (USER_ID, WHERE_ID, POST_NAME, POST_CONTENT, POST_CREATE, POST_UPDATE, POST_LIKE)
VALUES 
('user1', 1, 'Post A', 'Content A', '2024-09-01', '2024-09-02', 10),
('user2', 2, 'Post B', 'Content B', '2024-09-03', '2024-09-04', 20),
('user3', 3, 'Post C', 'Content C', '2024-09-05', '2024-09-06', 30),
('user4', 4, 'Post D', 'Content D', '2024-09-07', '2024-09-08', 40),
('user5', 5, 'Post E', 'Content E', '2024-09-09', '2024-09-10', 50),
('user6', 6, 'Post F', 'Content F', '2024-09-11', '2024-09-12', 60),
('user7', 7, 'Post G', 'Content G', '2024-09-13', '2024-09-14', 70),
('user8', 8, 'Post H', 'Content H', '2024-09-15', '2024-09-16', 80),
('user9', 9, 'Post I', 'Content I', '2024-09-17', '2024-09-18', 90),
('user10', 10, 'Post J', 'Content J', '2024-09-19', '2024-09-20', 100);

-- 'Journal_comment' 테이블에 더미 데이터 삽입
INSERT INTO Journal_comment (POST_ID, COMMENT_CONTENT, USER_ID)
VALUES 
(1, 'Great post!', 1),
(2, 'Interesting read.', 2),
(3, 'Nice article.', 3),
(4, 'Good information.', 4),
(5, 'Loved it!', 5),
(6, 'Very helpful.', 6),
(7, 'Awesome!', 7),
(8, 'Well written.', 8),
(9, 'Informative.', 9),
(10, 'Nice tips!', 10);

-- 'Journal_image' 테이블에 더미 데이터 삽입
INSERT INTO Journal_image (POST_ID, IMAGE)
VALUES 
(1, 'journal_image1.jpg'),
(2, 'journal_image2.jpg'),
(3, 'journal_image3.jpg'),
(4, 'journal_image4.jpg'),
(5, 'journal_image5.jpg'),
(6, 'journal_image6.jpg'),
(7, 'journal_image7.jpg'),
(8, 'journal_image8.jpg'),
(9, 'journal_image9.jpg'),
(10, 'journal_image10.jpg');

-- 'REVIEW_IMAGE' 테이블에 더미 데이터 삽입
INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE)
VALUES 
(1, 'review_image1.jpg'),
(2, 'review_image2.jpg'),
(3, 'review_image3.jpg'),
(4, 'review_image4.jpg'),
(5, 'review_image5.jpg'),
(6, 'review_image6.jpg'),
(7, 'review_image7.jpg'),
(8, 'review_image8.jpg'),
(9, 'review_image9.jpg'),
(10, 'review_image10.jpg');

-- 'WHERE_IMAGE' 테이블에 더미 데이터 삽입
INSERT INTO WHERE_IMAGE (WHERE_ID, IMAGE)
VALUES 
(1, 'where_image1.jpg'),
(2, 'where_image2.jpg'),
(3, 'where_image3.jpg'),
(4, 'where_image4.jpg'),
(5, 'where_image5.jpg'),
(6, 'where_image6.jpg'),
(7, 'where_image7.jpg'),
(8, 'where_image8.jpg'),
(9, 'where_image9.jpg'),
(10, 'where_image10.jpg');
