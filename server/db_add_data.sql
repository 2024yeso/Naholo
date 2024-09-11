-- 데이터베이스 사용
USE Naholo_db;

-- Users 테이블에 더미 데이터 추가
INSERT INTO Users (USER_ID, USER_PW, NAME, PHONE, BIRTH, GENDER, NICKNAME, USER_CHARACTER, LV, INTRODUCE, IMAGE)
VALUES 
('user1', 'password1', 'Alice', '010-1234-5678', '1990-01-01', 1, 'alice01', 'char1', 1, 'Hello, I am Alice.', 1),
('user2', 'password2', 'Bob', '010-2345-6789', '1992-02-02', 0, 'bob02', 'char2', 2, 'Hi, I am Bob.', 2),
('user3', 'password3', 'Charlie', '010-3456-7890', '1993-03-03', 1, 'charlie03', 'char3', 3, 'Hey, I am Charlie.', 3);

-- Where 테이블에 더미 데이터 추가 (각 type별로 10개 이상의 항목 추가)
INSERT INTO `Where` (WHERE_NAME, WHERE_LOCATE, WHERE_RATE, WHERE_TYPE)
VALUES 
('Park', 'Location 1', 4.5, 'play'),
('Cinema', 'Location 2', 4.3, 'play'),
('Playground', 'Location 3', 4.6, 'play'),
('Amusement Park', 'Location 4', 4.7, 'play'),
('Zoo', 'Location 5', 4.4, 'play'),
('Museum', 'Location 6', 4.8, 'play'),
('Arcade', 'Location 7', 4.2, 'play'),
('Stadium', 'Location 8', 4.1, 'play'),
('Aquarium', 'Location 9', 4.9, 'play'),
('Theater', 'Location 10', 4.0, 'play'),
('Restaurant', 'Location 11', 4.7, 'eat'),
('Cafe', 'Location 12', 4.6, 'eat'),
('Diner', 'Location 13', 4.2, 'eat'),
('Bistro', 'Location 14', 4.4, 'eat'),
('Bakery', 'Location 15', 4.1, 'eat'),
('Buffet', 'Location 16', 4.3, 'eat'),
('Food Truck', 'Location 17', 4.0, 'eat'),
('Steakhouse', 'Location 18', 4.8, 'eat'),
('Sushi Bar', 'Location 19', 4.5, 'eat'),
('Pizzeria', 'Location 20', 4.9, 'eat'),
('Hotel', 'Location 21', 4.2, 'sleep'),
('Resort', 'Location 22', 4.4, 'sleep'),
('Motel', 'Location 23', 4.0, 'sleep'),
('Hostel', 'Location 24', 4.3, 'sleep'),
('Inn', 'Location 25', 4.1, 'sleep'),
('Bed & Breakfast', 'Location 26', 4.7, 'sleep'),
('Guesthouse', 'Location 27', 4.5, 'sleep'),
('Villa', 'Location 28', 4.8, 'sleep'),
('Lodge', 'Location 29', 4.6, 'sleep'),
('Apartment', 'Location 30', 4.9, 'sleep'),
('Bar', 'Location 31', 4.8, 'drink'),
('Club', 'Location 32', 4.9, 'drink'),
('Pub', 'Location 33', 4.3, 'drink'),
('Cocktail Bar', 'Location 34', 4.7, 'drink'),
('Wine Bar', 'Location 35', 4.6, 'drink'),
('Brewery', 'Location 36', 4.5, 'drink'),
('Distillery', 'Location 37', 4.2, 'drink'),
('Beer Garden', 'Location 38', 4.4, 'drink'),
('Karaoke Bar', 'Location 39', 4.1, 'drink'),
('Whiskey Lounge', 'Location 40', 4.0, 'drink');

-- WHERE_IMAGE 테이블에 더미 데이터 추가 (각 장소에 대해 하나 이상의 이미지 추가)
INSERT INTO WHERE_IMAGE (WHERE_ID, IMAGE)
VALUES 
(1, 'image1.jpg'), (2, 'image2.jpg'), (3, 'image3.jpg'), (4, 'image4.jpg'), (5, 'image5.jpg'),
(6, 'image6.jpg'), (7, 'image7.jpg'), (8, 'image8.jpg'), (9, 'image9.jpg'), (10, 'image10.jpg'),
(11, 'image11.jpg'), (12, 'image12.jpg'), (13, 'image13.jpg'), (14, 'image14.jpg'), (15, 'image15.jpg'),
(16, 'image16.jpg'), (17, 'image17.jpg'), (18, 'image18.jpg'), (19, 'image19.jpg'), (20, 'image20.jpg'),
(21, 'image21.jpg'), (22, 'image22.jpg'), (23, 'image23.jpg'), (24, 'image24.jpg'), (25, 'image25.jpg'),
(26, 'image26.jpg'), (27, 'image27.jpg'), (28, 'image28.jpg'), (29, 'image29.jpg'), (30, 'image30.jpg'),
(31, 'image31.jpg'), (32, 'image32.jpg'), (33, 'image33.jpg'), (34, 'image34.jpg'), (35, 'image35.jpg'),
(36, 'image36.jpg'), (37, 'image37.jpg'), (38, 'image38.jpg'), (39, 'image39.jpg'), (40, 'image40.jpg');

-- FOLLOW 테이블에 더미 데이터 추가
INSERT INTO Follow (USER_ID, FOLLOWER)
VALUES 
('user1', 'user2'), ('user2', 'user1'), ('user1', 'user3'), ('user3', 'user2');

-- LIKES 테이블에 더미 데이터 추가
INSERT INTO LIKES (USER_ID, WHERE_ID)
VALUES 
('user1', 1), ('user1', 2), ('user2', 3), ('user2', 4), ('user3', 5), ('user3', 6);

-- WHERE_REVIEW 테이블에 더미 데이터 추가
INSERT INTO WHERE_REVIEW (USER_ID, WHERE_ID, REVIEW_CONTENT, WHERE_LIKE, WHERE_RATE)
VALUES 
('user1', 1, 'Great place for fun!', 5, 4.5),
('user2', 2, 'Delicious food!', 3, 4.7),
('user3', 3, 'Comfortable stay.', 4, 4.2);

-- REVIEW_IMAGE 테이블에 더미 데이터 추가
INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE)
VALUES 
(1, 'review_image1.jpg'), (2, 'review_image2.jpg'), (3, 'review_image3.jpg');

-- JOURNAL_POST 테이블에 더미 데이터 추가
INSERT INTO Journal_post (USER_ID, WHERE_ID, POST_NAME, POST_CONTENT, POST_CREATE, POST_UPDATE, POST_LIKE)
VALUES 
('user1', 1, 'Amazing Park Visit', 'I had a wonderful time at the park.', '2024-01-01', '2024-01-02', 10),
('user2', 2, 'Best Restaurant Ever', 'The food was absolutely delicious.', '2024-02-01', '2024-02-02', 8),
('user3', 3, 'Comfortable Stay at Hotel', 'The room was clean and cozy.', '2024-03-01', '2024-03-02', 7);

-- JOURNAL_IMAGE 테이블에 더미 데이터 추가
INSERT INTO Journal_image (POST_ID, IMAGE)
VALUES 
(1, 'journal_image1.jpg'), (2, 'journal_image2.jpg'), (3, 'journal_image3.jpg');

-- JOURNAL_COMMENT 테이블에 더미 데이터 추가
INSERT INTO Journal_comment (POST_ID, COMMENT_CONTENT, USER_ID)
VALUES 
(1, 'Looks amazing!', 'user2'),
(2, 'I want to visit too!', 'user3'),
(3, 'Great review!', 'user1');

