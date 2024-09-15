-- 데이터베이스 사용
USE Naholo_db;

-- Users 테이블에 더미 데이터 추가
INSERT INTO Users (USER_ID, USER_PW, NAME, PHONE, BIRTH, GENDER, NICKNAME, USER_CHARACTER, LV, INTRODUCE, IMAGE)
VALUES 
('user1', 'password1', 'Alice', '010-1234-5678', '1990-01-01', 1, 'alice01', 'char1', 1, 'Hello, I am Alice.', 1),
('user2', 'password2', 'Bob', '010-2345-6789', '1992-02-02', 0, 'bob02', 'char2', 2, 'Hi, I am Bob.', 2),
('user3', 'password3', 'Charlie', '010-3456-7890', '1993-03-03', 1, 'charlie03', 'char3', 3, 'Hey, I am Charlie.', 3);

-- Where 테이블에 더미 데이터 추가
INSERT INTO `Where` (WHERE_NAME, WHERE_LOCATE, WHERE_RATE, WHERE_TYPE)
VALUES 
('Park', 'Location 1', 4.5, 'play'),
('Restaurant', 'Location 2', 4.7, 'eat'),
('Hotel', 'Location 3', 4.2, 'sleep'),
('Bar', 'Location 4', 4.8, 'drink'),
('Cinema', 'Location 5', 4.3, 'play'),
('Cafe', 'Location 6', 4.6, 'eat'),
('Resort', 'Location 7', 4.4, 'sleep'),
('Club', 'Location 8', 4.9, 'drink');

-- WHERE_IMAGE 테이블에 더미 데이터 추가 (장소당 여러 이미지)
INSERT INTO WHERE_IMAGE (WHERE_ID, IMAGE)
VALUES 
(1, 'park_image1.jpg'), (1, 'park_image2.jpg'),
(2, 'restaurant_image1.jpg'), (2, 'restaurant_image2.jpg'), (2, 'restaurant_image3.jpg'),
(3, 'hotel_image1.jpg'),
(4, 'bar_image1.jpg'), (4, 'bar_image2.jpg'),
(5, 'cinema_image1.jpg'), (5, 'cinema_image2.jpg'),
(6, 'cafe_image1.jpg'),
(7, 'resort_image1.jpg'), (7, 'resort_image2.jpg'),
(8, 'club_image1.jpg'), (8, 'club_image2.jpg'), (8, 'club_image3.jpg');

-- Follow 테이블에 더미 데이터 추가
INSERT INTO Follow (USER_ID, FOLLOWER)
VALUES 
('user1', 'user2'), 
('user2', 'user1'), 
('user1', 'user3'), 
('user3', 'user2');

-- LIKES 테이블에 더미 데이터 추가
INSERT INTO LIKES (USER_ID, WHERE_ID)
VALUES 
('user1', 1), 
('user1', 2), 
('user2', 3), 
('user2', 4), 
('user3', 5), 
('user3', 6);

-- WHERE_REVIEW 테이블에 더미 데이터 추가
INSERT INTO WHERE_REVIEW (USER_ID, WHERE_ID, REVIEW_CONTENT, WHERE_LIKE, WHERE_RATE, 
    REASON_MENU, REASON_MOOD, REASON_SAFE, REASON_SEAT, REASON_TRANSPORT, 
    REASON_PARK, REASON_LONG, REASON_VIEW, REASON_INTERACTION, REASON_QUITE, 
    REASON_PHOTO, REASON_WATCH)
VALUES 
('user1', 1, 'Great place for fun!', 5, 4.5, 
    TRUE, FALSE, TRUE, FALSE, TRUE, 
    TRUE, FALSE, TRUE, FALSE, TRUE, 
    FALSE, TRUE),
('user2', 2, 'Delicious food!', 3, 4.7, 
    TRUE, TRUE, FALSE, FALSE, TRUE, 
    FALSE, TRUE, FALSE, TRUE, FALSE, 
    TRUE, FALSE),
('user3', 3, 'Comfortable stay.', 4, 4.2, 
    FALSE, FALSE, TRUE, TRUE, FALSE, 
    TRUE, TRUE, FALSE, TRUE, FALSE, 
    FALSE, TRUE);

-- REVIEW_IMAGE 테이블에 더미 데이터 추가
INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE)
VALUES 
(1, 'review_image1.jpg'), 
(2, 'review_image2.jpg'), 
(3, 'review_image3.jpg');

-- Journal_post 테이블에 더미 데이터 추가
INSERT INTO Journal_post (USER_ID, WHERE_ID, POST_NAME, POST_CONTENT, POST_CREATE, POST_UPDATE, POST_LIKE)
VALUES 
('user1', 1, 'Amazing Park Visit', 'I had a wonderful time at the park.', '2024-01-01', '2024-01-02', 10),
('user2', 2, 'Best Restaurant Ever', 'The food was absolutely delicious.', '2024-02-01', '2024-02-02', 8),
('user3', 3, 'Comfortable Stay at Hotel', 'The room was clean and cozy.', '2024-03-01', '2024-03-02', 7);

-- Journal_comment 테이블에 더미 데이터 추가
INSERT INTO Journal_comment (POST_ID, COMMENT_CONTENT, USER_ID)
VALUES 
(1, 'Looks amazing!', 'user2'),
(2, 'I want to visit too!', 'user3'),
(3, 'Great review!', 'user1');
