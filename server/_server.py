# _server.py

from fastapi import FastAPI, HTTPException, status, Depends, File, UploadFile, Form, Query, Body
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ValidationError
import mysql.connector
from mysql.connector.errors import IntegrityError
from typing import Optional, List, Dict
import os
from uuid import uuid4
import base64  # Base64 인코딩을 위해 필요
import logging
from datetime import datetime

# 로깅 설정
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 필요에 따라 특정 도메인으로 제한하는 것이 좋습니다.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MySQL 연결 설정
db_config = {
    'user': 'root',
    'password': '1557',
    'host': 'localhost',
    'database': 'naholo_db',
    'port': 3306
}

# 서버의 호스트와 포트 설정
HOST = "127.0.0.1"  # 모든 인터페이스에서 수신
PORT = 8000  # 서버가 실행되는 포트 번호
IMAGE_HOST = "127.0.0.1"  # 에뮬레이터에서 호스트 머신을 가리키는 IP

# Pydantic 모델 정의
class User(BaseModel):
    USER_ID: str
    USER_PW: str
    NAME: Optional[str] = None
    PHONE: Optional[str] = None
    BIRTH: Optional[str] = None  # YYYY-MM-DD 형식
    GENDER: Optional[bool] = None
    NICKNAME: Optional[str] = None
    USER_CHARACTER: Optional[str] = None
    LV: Optional[int] = 0
    INTRODUCE: Optional[str] = "input"
    IMAGE: Optional[str] = None  # 이미지 경로를 문자열로 저장

class Follow(BaseModel):
    USER_ID: str
    FOLLOWER: str

class Like(BaseModel):
    USER_ID: str
    WHERE_ID: int

class UsersImage(BaseModel):
    USER_ID: str
    IMAGE: str

class JournalComment(BaseModel):
    POST_ID: int
    COMMENT_CONTENT: str
    USER_ID: str

class ReviewImage(BaseModel):
    REVIEW_ID: int
    IMAGE: str

class Where(BaseModel):
    WHERE_NAME: str
    WHERE_LOCATE: str
    WHERE_RATE: float
    WHERE_TYPE: str
    LATITUDE: Optional[float] = None
    LONGITUDE: Optional[float] = None

class WhereReview(BaseModel):
    user_id: str
    where_id: int
    review_content: str
    where_like: int
    where_rate: float
    reason_menu: bool
    reason_mood: bool
    reason_safe: bool
    reason_seat: bool
    reason_transport: bool
    reason_park: bool
    reason_long: bool
    reason_view: bool
    reason_interaction: bool
    reason_quite: bool
    reason_photo: bool
    reason_watch: bool
    images: List[str]  # 리뷰 이미지 리스트

class WhereImage(BaseModel):
    WHERE_ID: int
    IMAGE: str

# Database 연결 함수
def get_db():
    conn = mysql.connector.connect(**db_config)
    try:
        yield conn
    finally:
        conn.close()

# 사용자 검색 함수
def get_user(db, username: str) -> Optional[Dict]:
    with db.cursor(dictionary=True) as cursor:
        cursor.execute("SELECT * FROM Users WHERE USER_ID = %s", (username,))
        user = cursor.fetchone()
    return user

# 유저 정보 업데이트 모델 정의 (선택적 필드만 포함)
class UserUpdate(BaseModel):
    USER_PW: Optional[str] = None
    NAME: Optional[str] = None
    PHONE: Optional[str] = None
    BIRTH: Optional[str] = None
    GENDER: Optional[bool] = None
    NICKNAME: Optional[str] = None
    USER_CHARACTER: Optional[str] = None
    LV: Optional[int] = None
    INTRODUCE: Optional[str] = None
    IMAGE: Optional[str] = None

# 유저 정보 업데이트 엔드포인트
@app.put("/update_user/{user_id}")
async def update_user(user_id: str, user_update: UserUpdate, db=Depends(get_db)):
    logger.info(f"Updating user: {user_id}")
    update_fields = []
    update_values = []

    for field, value in user_update.dict(exclude_unset=True).items():
        update_fields.append(f"{field} = %s")
        update_values.append(value)

    if not update_fields:
        logger.warning("No fields to update")
        raise HTTPException(status_code=400, detail="No fields to update")

    update_query = f"UPDATE Users SET {', '.join(update_fields)} WHERE USER_ID = %s"
    update_values.append(user_id)

    try:
        with db.cursor() as cursor:
            cursor.execute(update_query, tuple(update_values))
            db.commit()
        logger.info(f"User {user_id} updated successfully")
        return {"message": "User information updated successfully"}
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 중복확인 엔드포인트
@app.get("/check_id/")
def check_id(user_id: str):
    logger.info(f"Checking availability for user_id: {user_id}")
    try:
        with mysql.connector.connect(**db_config) as conn:
            user = get_user(conn, user_id)
            if user:
                logger.info(f"user_id {user_id} already exists")
                return {"message": "ID already exists", "available": True}
            else:
                logger.info(f"user_id {user_id} is available")
                return {"message": "ID is available", "available": False}
    except mysql.connector.Error as err:
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 회원가입 엔드포인트
@app.post("/add_user/")
def add_user(user: User):
    logger.info(f"Adding new user: {user.USER_ID}")
    insert_query = """
    INSERT INTO Users (USER_ID, USER_PW, NAME, PHONE, BIRTH, GENDER, NICKNAME, USER_CHARACTER, LV, INTRODUCE, IMAGE)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    try:
        with mysql.connector.connect(**db_config) as conn:
            with conn.cursor() as cursor:
                cursor.execute(insert_query, (
                    user.USER_ID, user.USER_PW, user.NAME, user.PHONE, user.BIRTH, user.GENDER,
                    user.NICKNAME, user.USER_CHARACTER, user.LV, user.INTRODUCE, user.IMAGE
                ))
                conn.commit()
        logger.info(f"User {user.USER_ID} added successfully")
        return {"message": "User added successfully"}
    except IntegrityError as err:
        if err.errno == 1062:
            logger.warning(f"Duplicate entry for user_id {user.USER_ID}")
            raise HTTPException(status_code=400, detail="Duplicate entry for primary key")
        else:
            logger.error(f"Integrity error: {err}")
            raise HTTPException(status_code=500, detail=f"Integrity error: {err}")
    except mysql.connector.Error as err:
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 로그인 엔드포인트
@app.get("/login/")
def login(user_id: str, user_pw: str):
    logger.info(f"Login attempt for user_id: {user_id}")
    try:
        with mysql.connector.connect(**db_config) as conn:
            user = get_user(conn, user_id)
            if not user or user['USER_PW'] != user_pw:
                logger.warning(f"Login failed for user_id: {user_id}")
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="유저 정보가 없거나 비밀번호가 맞지 않습니다"
                )
            logger.info(f"User {user_id} logged in successfully")
            return {
                "message": "로그인 성공",
                "user_id": user['USER_ID'],
                "nickname": user['NICKNAME'],
                "lv": user['LV'],
                "exp": user.get('EXP', 0),  # EXP 필드가 있는지 확인 필요
                "introduce": user['INTRODUCE'],
                "image": user['IMAGE'],  # 예시 이미지 URL
                "userCharacter": user['USER_CHARACTER']
            }
    except mysql.connector.Error as err:
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 리뷰 추가 엔드포인트
@app.post("/add_review/")   
async def add_review(review: WhereReview, db=Depends(get_db)):
    logger.info(f"Adding review for user_id: {review.user_id}, where_id: {review.where_id}")
    logger.debug(f"Review data: {review.dict()}")
    insert_review_query = """
    INSERT INTO WHERE_REVIEW (
        USER_ID, WHERE_ID, REVIEW_CONTENT, WHERE_LIKE, WHERE_RATE,
        REASON_MENU, REASON_MOOD, REASON_SAFE, REASON_SEAT, REASON_TRANSPORT,
        REASON_PARK, REASON_LONG, REASON_VIEW, REASON_INTERACTION, REASON_QUITE,
        REASON_PHOTO, REASON_WATCH
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    insert_image_query = """
    INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE) VALUES (%s, %s)
    """
    try:
        with db.cursor() as cursor:
            # 리뷰 데이터 삽입
            cursor.execute(insert_review_query, (
                review.user_id, review.where_id, review.review_content, review.where_like, review.where_rate,
                review.reason_menu, review.reason_mood, review.reason_safe, review.reason_seat, review.reason_transport,
                review.reason_park, review.reason_long, review.reason_view, review.reason_interaction, review.reason_quite,
                review.reason_photo, review.reason_watch
            ))
            review_id = cursor.lastrowid
            logger.debug(f"Inserted WHERE_REVIEW with REVIEW_ID: {review_id}")

            # 리뷰 이미지 삽입
            for base64_image in review.images:
                cursor.execute(insert_image_query, (review_id, base64_image))
                logger.debug(f"Inserted image for REVIEW_ID {review_id}")

            db.commit()
        logger.info("Review and images added successfully")
        return {"message": "Review and images added successfully"}
    except ValidationError as ve:
        logger.error(f"Validation Error: {ve.json()}")
        raise HTTPException(status_code=422, detail=ve.errors())
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 리뷰 호출 함수
def call_review(user_id: str) -> List[Dict]:
    query = """
    SELECT 
        w.WHERE_NAME AS WHERE_NAME,
        w.WHERE_LOCATE AS WHERE_LOCATE,
        w.LATITUDE AS LATITUDE,
        w.LONGITUDE AS LONGITUDE,
        wr.REVIEW_CONTENT AS REVIEW_CONTENT,
        wr.WHERE_RATE AS WHERE_RATE,
        ri.IMAGE AS REVIEW_IMAGE,
        wr.REASON_MENU AS REASON_MENU,
        wr.REASON_MOOD AS REASON_MOOD,
        wr.REASON_SAFE AS REASON_SAFE,
        wr.REASON_SEAT AS REASON_SEAT,
        wr.REASON_TRANSPORT AS REASON_TRANSPORT,
        wr.REASON_PARK AS REASON_PARK,
        wr.REASON_LONG AS REASON_LONG,
        wr.REASON_VIEW AS REASON_VIEW,
        wr.REASON_INTERACTION AS REASON_INTERACTION,
        wr.REASON_QUITE AS REASON_QUITE,
        wr.REASON_PHOTO AS REASON_PHOTO,
        wr.REASON_WATCH AS REASON_WATCH
    FROM 
        WHERE_REVIEW wr
    JOIN 
        `Where` w ON wr.WHERE_ID = w.WHERE_ID
    LEFT JOIN 
        REVIEW_IMAGE ri ON wr.REVIEW_ID = ri.REVIEW_ID
    WHERE 
        wr.USER_ID = %s;
    """
    reviews = []
    try:
        with mysql.connector.connect(**db_config) as conn:
            with conn.cursor(dictionary=True) as cursor:
                logger.debug(f"Executing review query for user_id: {user_id}")
                cursor.execute(query, (user_id,))
                reviews = cursor.fetchall()
                logger.debug(f"Fetched {len(reviews)} reviews")

                # REVIEW_IMAGE가 없을 경우 None으로 설정
                for review in reviews:
                    if not review.get('REVIEW_IMAGE'):
                        review['REVIEW_IMAGE'] = None
    except mysql.connector.Error as err:
        logger.error(f"Database error in call_review: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in call_review: {e}")
    finally:
        return reviews
class PostDetailsResponse(BaseModel):
    likes: int
    comments: int
    liked: bool
@app.get("/journal/post_details", response_model=PostDetailsResponse)
def get_post_details(
    post_id: int = Query(..., description="게시물의 ID"),
    user_id: Optional[str] = Query(None, description="현재 사용자의 ID"),
    db=Depends(get_db)
):
    logger.info(f"Fetching details for post_id: {post_id} by user_id: {user_id}")
    
    try:
        with db.cursor(dictionary=True) as cursor:
            # 좋아요 수 조회
            likes_query = "SELECT COUNT(*) AS likes FROM Post_like WHERE POST_ID = %s;"
            cursor.execute(likes_query, (post_id,))
            likes_result = cursor.fetchone()
            likes = likes_result['likes'] if likes_result else 0
            logger.debug(f"Likes count: {likes}")

            # 댓글 수 조회
            comments_query = "SELECT COUNT(*) AS comments FROM Journal_comment WHERE POST_ID = %s;"
            cursor.execute(comments_query, (post_id,))
            comments_result = cursor.fetchone()
            comments = comments_result['comments'] if comments_result else 0
            logger.debug(f"Comments count: {comments}")

            # 현재 사용자가 좋아요 했는지 여부 조회
            if user_id:
                liked_query = "SELECT * FROM Post_like WHERE POST_ID = %s AND USER_ID = %s;"
                cursor.execute(liked_query, (post_id, user_id))
                liked_result = cursor.fetchone()
                liked = bool(liked_result)
                logger.debug(f"User liked: {liked}")
            else:
                liked = False
                logger.debug("User ID not provided, defaulting liked to False.")

        return PostDetailsResponse(likes=likes, comments=comments, liked=liked)

    except mysql.connector.Error as err:
        logger.error(f"Database error in get_post_details: {err}")
        raise HTTPException(status_code=500, detail="데이터베이스 오류가 발생했습니다.")
    except Exception as e:
        logger.error(f"Unexpected error in get_post_details: {e}")
        raise HTTPException(status_code=500, detail="예상치 못한 오류가 발생했습니다.")

class AddCommentRequest(BaseModel):
    post_id: int
    user_id: str
    content: str

@app.post("/journal/add_comments")
def add_comment(payload: AddCommentRequest, db=Depends(get_db)):
    post_id = payload.post_id
    user_id = payload.user_id
    content = payload.content

    logger.info(f"User {user_id} is adding a comment to post {post_id}")

    try:
        with db.cursor() as cursor:
            # 댓글 추가 쿼리
            insert_query = """
                INSERT INTO Journal_comment (POST_ID, USER_ID, COMMENT_CONTENT) 
                VALUES (%s, %s, %s);
            """
            cursor.execute(insert_query, (post_id, user_id, content))
            
            db.commit()
        
        logger.info(f"Comment added by user {user_id} to post {post_id}")
        return {"message": "댓글이 추가되었습니다."}
    
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error in add_comment: {err}")
        raise HTTPException(status_code=500, detail="데이터베이스 오류가 발생했습니다.")
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error in add_comment: {e}")
        raise HTTPException(status_code=500, detail="예상치 못한 오류가 발생했습니다.")

# 좋아요 호출 함수
def call_wanted(user_id: str) -> List[Dict]:
    query = """
    SELECT 
        w.WHERE_NAME AS WHERE_NAME,
        w.WHERE_LOCATE AS WHERE_LOCATE,
        w.WHERE_RATE AS WHERE_RATE,
        wi.IMAGE AS PLACE_IMAGE
    FROM 
        LIKES l
    JOIN 
        `Where` w ON l.WHERE_ID = w.WHERE_ID
    LEFT JOIN 
        WHERE_IMAGE wi ON w.WHERE_ID = wi.WHERE_ID
    WHERE 
        l.USER_ID = %s;
    """
    where_wanted = []
    try:
        with mysql.connector.connect(**db_config) as conn:
            with conn.cursor(dictionary=True) as cursor:
                logger.debug(f"Executing liked places query for user_id: {user_id}")
                cursor.execute(query, (user_id,))
                where_wanted = cursor.fetchall()
                logger.debug(f"Fetched {len(where_wanted)} liked places")

                # 이미지 경로를 URL로 변환
                for wanted in where_wanted:
                    if wanted.get('PLACE_IMAGE'):
                        wanted['PLACE_IMAGE'] = f"http://{IMAGE_HOST}:{PORT}/images/{wanted['PLACE_IMAGE']}"
    except mysql.connector.Error as err:
        logger.error(f"Database error in call_wanted: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in call_wanted: {e}")
    finally:
        return where_wanted

# 마이페이지 엔드포인트
@app.get("/my_page/")
def my_page(user_id: str, db=Depends(get_db)):
    logger.info(f"Fetching my_page data for user_id: {user_id}")
    try:
        reviews = call_review(user_id)
        liked_places = call_wanted(user_id)
        return {"reviews": reviews, "liked_places": liked_places}
    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error(f"Unexpected error in my_page: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 팔로우페이지 엔드포인트
@app.get("/follow_page/")
def follow_page(user_id: str):
    logger.info(f"Fetching follow_page data for user_id: {user_id}")
    try:
        with mysql.connector.connect(**db_config) as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT FOLLOWER FROM Follow WHERE USER_ID = %s", (user_id,))
                follow = cursor.fetchall()
                cursor.execute("SELECT USER_ID FROM Follow WHERE FOLLOWER = %s", (user_id,))
                follower = cursor.fetchall()
        return {"follow": follow, "follower": follower}
    except mysql.connector.Error as err:
        logger.error(f"Database error in follow_page: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in follow_page: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 각 type별로 상위 8개 항목과 이미지를 불러오는 엔드포인트
@app.get("/where/top-rated")
def get_top_rated_places(db=Depends(get_db)):
    types = ["play", "eat", "sleep", "drink"]
    results = {"by_type": {}, "overall_top_8": []}

    try:
        with db.cursor(dictionary=True) as cursor:
            # 각 타입별로 평점이 높은 순서대로 8개의 항목을 가져오는 쿼리
            for place_type in types:
                query = """
                SELECT w.*, wi.IMAGE
                FROM `Where` w
                LEFT JOIN `WHERE_IMAGE` wi ON w.WHERE_ID = wi.WHERE_ID
                WHERE w.WHERE_TYPE = %s
                ORDER BY w.WHERE_RATE DESC
                LIMIT 8;
                """
                logger.debug(f"Fetching top 8 places for type: {place_type}")
                cursor.execute(query, (place_type,))
                rows = cursor.fetchall()
                results["by_type"][place_type] = rows
                logger.debug(f"Fetched {len(rows)} places for type: {place_type}")

            # 전체 평점이 높은 순서대로 상위 8개의 항목을 가져오는 쿼리
            overall_query = """
            SELECT w.*, wi.IMAGE
            FROM `Where` w
            LEFT JOIN `WHERE_IMAGE` wi ON w.WHERE_ID = wi.WHERE_ID
            ORDER BY w.WHERE_RATE DESC
            LIMIT 8;
            """
            logger.debug("Fetching overall top 8 places")
            cursor.execute(overall_query)
            overall_top_8 = cursor.fetchall()
            results["overall_top_8"] = overall_top_8
            logger.debug(f"Fetched {len(overall_top_8)} overall top places")

        return {"data": results}
    except mysql.connector.Error as err:
        logger.error(f"Database error in get_top_rated_places: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in get_top_rated_places: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 장소 세부 정보를 불러오는 엔드포인트
@app.get("/where/place-info")
def get_place_info(where_id: int, db=Depends(get_db)):
    logger.info(f"Fetching place info for WHERE_ID: {where_id}")
    place_query = """
    SELECT w.*, wi.IMAGE
    FROM `Where` w
    LEFT JOIN `WHERE_IMAGE` wi ON w.WHERE_ID = wi.WHERE_ID
    WHERE w.WHERE_ID = %s;
    """
    review_query = """
    SELECT wr.*, ri.IMAGE AS REVIEW_IMAGE
    FROM `WHERE_REVIEW` wr
    LEFT JOIN `REVIEW_IMAGE` ri ON wr.REVIEW_ID = ri.REVIEW_ID
    WHERE wr.WHERE_ID = %s;
    """
    try:
        with db.cursor(dictionary=True) as cursor:
            # 장소의 기본 정보와 이미지 가져오기
            logger.debug(f"Executing place_query for WHERE_ID: {where_id}")
            cursor.execute(place_query, (where_id,))
            place_info = cursor.fetchone()

            if not place_info:
                logger.warning(f"Place with WHERE_ID {where_id} not found")
                raise HTTPException(status_code=404, detail="Place not found")

            # 장소의 리뷰와 리뷰 이미지 가져오기
            logger.debug(f"Executing review_query for WHERE_ID: {where_id}")
            cursor.execute(review_query, (where_id,))
            reviews = cursor.fetchall()

        return {
            "place_info": place_info,
            "reviews": reviews
        }
    except mysql.connector.Error as err:
        logger.error(f"Database error in get_place_info: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in get_place_info: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 이미지 Base64 인코딩 함수
def encode_image_to_base64(file_content: bytes) -> str:
    return base64.b64encode(file_content).decode('utf-8')

# 프로필 이미지 업로드 엔드포인트
@app.post("/upload_profile_image/")
async def upload_profile_image(
    user_id: str = Form(...),
    file: UploadFile = File(...),
    db=Depends(get_db)
):
    logger.info(f"Uploading profile image for user_id: {user_id}")
    try:
        # 파일 내용을 읽어서 Base64로 인코딩
        file_content = await file.read()
        encoded_image = encode_image_to_base64(file_content)

        with db.cursor() as cursor:
            # Users 테이블 업데이트
            update_users_query = "UPDATE Users SET IMAGE = %s WHERE USER_ID = %s"
            cursor.execute(update_users_query, (encoded_image, user_id))

            # Users_Image 테이블에 데이터가 존재하는지 확인
            check_query = "SELECT * FROM Users_Image WHERE USER_ID = %s"
            cursor.execute(check_query, (user_id,))
            existing_image = cursor.fetchone()

            if existing_image:
                # 이미 데이터가 있는 경우 업데이트
                update_image_query = "UPDATE Users_Image SET IMAGE = %s WHERE USER_ID = %s"
                cursor.execute(update_image_query, (encoded_image, user_id))
                logger.debug(f"Updated image in Users_Image for user_id: {user_id}")
            else:
                # 데이터가 없는 경우 삽입
                insert_image_query = "INSERT INTO Users_Image (USER_ID, IMAGE) VALUES (%s, %s)"
                cursor.execute(insert_image_query, (user_id, encoded_image))
                logger.debug(f"Inserted image into Users_Image for user_id: {user_id}")

            db.commit()

        logger.info(f"Profile image for {user_id} uploaded successfully")
        return {"message": "Profile image uploaded successfully", "image_base64": encoded_image}
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error in upload_profile_image: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Failed to upload profile image: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to upload profile image: {e}")

class LikePostRequest(BaseModel):
    post_id: int
    user_id: str

# /journal/like_post 엔드포인트 수정
@app.post("/journal/like_post")
def like_post(payload: LikePostRequest, db=Depends(get_db)):
    post_id = payload.post_id
    user_id = payload.user_id

    logger.info(f"User {user_id} is trying to like post {post_id}")

    try:
        with db.cursor() as cursor:
            # 이미 좋아요를 눌렀는지 확인
            logger.debug(f"Checking if user {user_id} has already liked post {post_id}")
            check_query = "SELECT * FROM Post_like WHERE POST_ID = %s AND USER_ID = %s;"
            cursor.execute(check_query, (post_id, user_id))
            existing_like = cursor.fetchone()

            if existing_like:
                logger.warning(f"User {user_id} has already liked post {post_id}")
                raise HTTPException(status_code=400, detail="이미 좋아요를 눌렀습니다.")

            # Post_like 테이블에 추가
            insert_query = "INSERT INTO Post_like (POST_ID, USER_ID) VALUES (%s, %s);"
            cursor.execute(insert_query, (post_id, user_id))
            logger.debug(f"Inserted like for user {user_id} on post {post_id}")

            # Journal_post 테이블의 POST_LIKE 수 증가
            update_like_query = "UPDATE Journal_post SET POST_LIKE = POST_LIKE + 1 WHERE POST_ID = %s;"
            cursor.execute(update_like_query, (post_id,))
            logger.debug(f"Incremented POST_LIKE for post {post_id}")

            db.commit()

        logger.info(f"User {user_id} liked post {post_id} successfully")
        return {"message": "좋아요가 추가되었습니다."}

    except HTTPException as he:
        raise he
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error in like_post: {err}")
        raise HTTPException(status_code=500, detail="데이터베이스 오류가 발생했습니다.")
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error in like_post: {e}")
        raise HTTPException(status_code=500, detail="예상치 못한 오류가 발생했습니다.")

# Pydantic 요청 모델 정의
class UnlikePostRequest(BaseModel):
    post_id: int
    user_id: str

# /journal/unlike_post 엔드포인트 수정
@app.post("/journal/unlike_post")
def unlike_post(payload: UnlikePostRequest, db=Depends(get_db)):
    post_id = payload.post_id
    user_id = payload.user_id

    logger.info(f"User {user_id} is trying to unlike post {post_id}")

    try:
        with db.cursor() as cursor:
            # 좋아요가 눌려있는지 확인
            logger.debug(f"Checking if user {user_id} has liked post {post_id}")
            check_query = "SELECT * FROM Post_like WHERE POST_ID = %s AND USER_ID = %s;"
            cursor.execute(check_query, (post_id, user_id))
            existing_like = cursor.fetchone()

            if not existing_like:
                logger.warning(f"User {user_id} has not liked post {post_id}")
                raise HTTPException(status_code=400, detail="좋아요가 눌려있지 않습니다.")

            # Post_like 테이블에서 삭제
            delete_query = "DELETE FROM Post_like WHERE POST_ID = %s AND USER_ID = %s;"
            cursor.execute(delete_query, (post_id, user_id))
            logger.debug(f"Deleted like for user {user_id} on post {post_id}")

            # Journal_post 테이블의 POST_LIKE 수 감소
            update_like_query = "UPDATE Journal_post SET POST_LIKE = POST_LIKE - 1 WHERE POST_ID = %s;"
            cursor.execute(update_like_query, (post_id,))
            logger.debug(f"Decremented POST_LIKE for post {post_id}")

            db.commit()

        logger.info(f"User {user_id} unliked post {post_id} successfully")
        return {"message": "좋아요가 취소되었습니다."}

    except HTTPException as he:
        raise he
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error in unlike_post: {err}")
        raise HTTPException(status_code=500, detail="데이터베이스 오류가 발생했습니다.")
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error in unlike_post: {e}")
        raise HTTPException(status_code=500, detail="예상치 못한 오류가 발생했습니다.")

# 저널 메인 엔드포인트
@app.get("/journal/main")
def get_journal(user_id: str, db=Depends(get_db)):
    logger.info(f"Fetching journal main data for user_id: {user_id}")
    results = {"latest_10": [], "top_10": [], "followers_latest": []}
    try:
        with db.cursor(dictionary=True) as cursor:
            # 최신 10개 게시물 조회
            latest_query = """
            SELECT jp.*, u.IMAGE AS USER_IMAGE
            FROM Journal_post jp
            LEFT JOIN Users u ON jp.USER_ID = u.USER_ID
            ORDER BY jp.POST_CREATE DESC
            LIMIT 10;
            """
            logger.debug("Fetching latest 10 journal posts")
            cursor.execute(latest_query)
            latest_10 = cursor.fetchall()
            results["latest_10"] = latest_10
            logger.debug(f"Fetched {len(latest_10)} latest posts")

            # 인기순 10개 게시물 조회
            top_query = """
            SELECT jp.*, u.IMAGE AS USER_IMAGE
            FROM Journal_post jp
            LEFT JOIN Users u ON jp.USER_ID = u.USER_ID
            ORDER BY jp.POST_LIKE DESC, jp.POST_CREATE DESC
            LIMIT 10;
            """
            logger.debug("Fetching top 10 journal posts by likes")
            cursor.execute(top_query)
            top_10 = cursor.fetchall()
            results["top_10"] = top_10
            logger.debug(f"Fetched {len(top_10)} top liked posts")

            # 팔로우한 사용자들의 최신 10개 게시물 조회
            followers_query = """
            SELECT jp.*, u.IMAGE AS USER_IMAGE
            FROM Journal_post jp
            LEFT JOIN Users u ON jp.USER_ID = u.USER_ID
            WHERE jp.USER_ID IN (
                SELECT f.FOLLOWER
                FROM Follow f
                WHERE f.USER_ID = %s
            )
            ORDER BY jp.POST_CREATE DESC
            LIMIT 10;
            """
            logger.debug(f"Fetching followers' latest 10 posts for user_id: {user_id}")
            cursor.execute(followers_query, (user_id,))
            followers_latest = cursor.fetchall()
            results["followers_latest"] = followers_latest
            logger.debug(f"Fetched {len(followers_latest)} followers' latest posts")

            # 모든 POST_ID 수집
            all_post_ids = set()
            for key in results:
                for post in results[key]:
                    all_post_ids.add(post['POST_ID'])

            if all_post_ids:
                # Post_like 테이블에서 각 POST_ID의 좋아요 개수 조회
                format_strings = ','.join(['%s'] * len(all_post_ids))
                likes_query = f"""
                SELECT POST_ID, COUNT(*) AS like_count
                FROM Post_like
                WHERE POST_ID IN ({format_strings})
                GROUP BY POST_ID;
                """
                logger.debug(f"Fetching like counts for POST_IDs: {all_post_ids}")
                cursor.execute(likes_query, tuple(all_post_ids))
                likes_data = cursor.fetchall()
                logger.debug(f"Fetched like counts: {likes_data}")

                # POST_ID별 좋아요 개수 매핑
                likes_map = {row['POST_ID']: row['like_count'] for row in likes_data}

                # Journal_post의 POST_LIKE 필드 업데이트
                update_query = """
                UPDATE Journal_post
                SET POST_LIKE = %s
                WHERE POST_ID = %s;
                """
                update_data = [(like_count, post_id) for post_id, like_count in likes_map.items()]

                # 배치 업데이트 실행
                if update_data:
                    cursor.executemany(update_query, update_data)
                    db.commit()
                    logger.debug(f"Updated POST_LIKE for {len(update_data)} posts")

                # 현재 사용자가 좋아요를 눌렀는지 여부 조회
                liked_query = f"""
                SELECT POST_ID
                FROM Post_like
                WHERE POST_ID IN ({format_strings}) AND USER_ID = %s;
                """
                cursor.execute(liked_query, tuple(all_post_ids) + (user_id,))
                liked_data = cursor.fetchall()
                liked_post_ids = {row['POST_ID'] for row in liked_data}
                logger.debug(f"User {user_id} has liked POST_IDs: {liked_post_ids}")

                # 결과 데이터에 업데이트된 POST_LIKE 및 liked 상태 반영
                for key in results:
                    for post in results[key]:
                        post_id = post['POST_ID']
                        post['POST_LIKE'] = likes_map.get(post_id, 0)
                        post['liked'] = post_id in liked_post_ids

            # POST_ID별 이미지 데이터 조회
            if all_post_ids:
                format_strings = ','.join(['%s'] * len(all_post_ids))
                images_query = f"""
                SELECT POST_ID, IMAGE_DATA
                FROM journal_image
                WHERE POST_ID IN ({format_strings});
                """
                logger.debug(f"Fetching images for POST_IDs: {all_post_ids}")
                cursor.execute(images_query, tuple(all_post_ids))
                images_data = cursor.fetchall()
                logger.debug(f"Fetched {len(images_data)} images")

                # POST_ID별 이미지 매핑
                post_images_map: Dict[int, List[str]] = {}
                for image in images_data:
                    post_id = image['POST_ID']
                    post_images_map.setdefault(post_id, []).append(image['IMAGE_DATA'])

                # 각 게시물에 이미지 추가
                for key in results:
                    for post in results[key]:
                        post_id = post['POST_ID']
                        post['images'] = post_images_map.get(post_id, [])

                        # 혼캎, 혼영, ... 필드 bool 리스트로 변환
                        post['subjList'] = [
                            bool(post.get('혼캎', False)),
                            bool(post.get('혼영', False)),
                            bool(post.get('혼놀', False)),
                            bool(post.get('혼밥', False)),
                            bool(post.get('혼박', False)),
                            bool(post.get('혼술', False)),
                            bool(post.get('기타', False)),
                        ]
    except mysql.connector.Error as err:
        logger.error(f"Database error in get_journal: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in get_journal: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")
    
    logger.debug(f"Final Results with Images: {results}")
    return {"data": results}

class Comment(BaseModel):
    comment_id: int
    post_id: int
    user_id: str
    author: str
    content: str
    created_at: str  # datetime 대신 문자열 사용

class CommentsResponse(BaseModel):
    comments: List[Comment]

# /journal/get_comments 엔드포인트 추가
@app.get("/journal/get_comments", response_model=CommentsResponse)
def get_comments(post_id: int = Query(..., description="댓글을 가져올 게시물의 ID"), db=Depends(get_db)):
    logger.info(f"Fetching comments for post_id: {post_id}")
    
    try:
        with db.cursor(dictionary=True) as cursor:
            # 댓글 조회 쿼리
            query = """
                SELECT 
                    COMMENT_ID, 
                    POST_ID, 
                    USER_ID, 
                    (SELECT nickName FROM Users WHERE Users.USER_ID = Journal_comment.USER_ID) AS author,
                    COMMENT_CONTENT AS content,
                    COMMENT_CREATE AS created_at
                FROM 
                    Journal_comment
                WHERE 
                    POST_ID = %s
                ORDER BY 
                    COMMENT_CREATE ASC;
            """
            cursor.execute(query, (post_id,))
            results = cursor.fetchall()
            
            comments = [
                Comment(
                    comment_id=row['COMMENT_ID'],
                    post_id=row['POST_ID'],
                    user_id=row['USER_ID'],
                    author=row['author'],
                    content=row['content'],
                    created_at=row['created_at'].strftime('%Y-%m-%d %H:%M:%S')  # datetime을 문자열로 변환
                )
                for row in results
            ]
            
        return CommentsResponse(comments=comments)
    
    except mysql.connector.Error as err:
        logger.error(f"Database error in get_comments: {err}")
        raise HTTPException(status_code=500, detail="데이터베이스 오류가 발생했습니다.")
    except Exception as e:
        logger.error(f"Unexpected error in get_comments: {e}")
        raise HTTPException(status_code=500, detail="예상치 못한 오류가 발생했습니다.")
    
# 저널 댓글 추가 엔드포인트
@app.post("/journal/add_comment")
def add_comment(comment: JournalComment, db=Depends(get_db)):
    logger.info(f"Adding comment to POST_ID: {comment.POST_ID} by USER_ID: {comment.USER_ID}")
    logger.debug(f"Comment data: {comment.dict()}")
    insert_comment_query = """
    INSERT INTO Journal_comment (POST_ID, USER_ID, COMMENT_CONTENT)
    VALUES (%s, %s, %s)
    """
    try:
        with db.cursor() as cursor:
            cursor.execute(insert_comment_query, (comment.POST_ID, comment.USER_ID, comment.COMMENT_CONTENT))
            db.commit()
        logger.info(f"Comment added successfully to POST_ID: {comment.POST_ID}")
        return {"message": "Comment added successfully"}
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error in add_comment: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error in add_comment: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# JournalPost 모델 정의
class JournalPost(BaseModel):
    title: str
    content: str
    혼캎: bool = False
    혼영: bool = False
    혼놀: bool = False
    혼밥: bool = False
    혼박: bool = False
    혼술: bool = False
    기타: bool = False
    images: List[str]  # base64로 인코딩된 이미지 리스트
    created_at: Optional[datetime] = None  # 작성 시간 필드 추가

# 저널 업로드 엔드포인트
@app.post("/journal/upload/")
async def add_journal(
    user_id: str = Query(...),  # user_id를 쿼리 매개변수로 받음
    journal_post: JournalPost = Body(...),  # JournalPost 모델의 JSON 본문으로 데이터를 받음
    db=Depends(get_db)
):
    logger.info(f"Uploading journal post for user_id: {user_id}")
    logger.debug(f"JournalPost data: {journal_post.dict()}")

    insert_post_query = """
    INSERT INTO journal_post 
    (USER_ID, POST_NAME, POST_CONTENT, 혼캎, 혼영, 혼놀, 혼밥, 혼박, 혼술, 기타, POST_CREATE)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    insert_image_query = "INSERT INTO journal_image (POST_ID, IMAGE_DATA) VALUES (%s, %s)"
    try:
        with db.cursor() as cursor:
            # 현재 시간을 기본값으로 설정
            created_at = journal_post.created_at or datetime.now()

            # journal_post 테이블에 일지 내용 삽입
            cursor.execute(insert_post_query, (
                user_id, 
                journal_post.title, 
                journal_post.content,
                journal_post.혼캎, 
                journal_post.혼영, 
                journal_post.혼놀, 
                journal_post.혼밥,
                journal_post.혼박, 
                journal_post.혼술, 
                journal_post.기타, 
                created_at
            ))
            post_id = cursor.lastrowid
            logger.debug(f"Inserted journal_post with POST_ID: {post_id}")

            # journal_image 테이블에 이미지 데이터 삽입
            for image in journal_post.images:
                cursor.execute(insert_image_query, (post_id, image))
                logger.debug(f"Inserted image for POST_ID {post_id}")

            db.commit()
        logger.info(f"Journal post and images added successfully for POST_ID: {post_id}")
        return {"message": "Journal post and images added successfully", "post_id": post_id}
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error in add_journal: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error in add_journal: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 사용자 프로필 조회 엔드포인트
@app.get("/get_user_profile/")
def get_user_profile(user_id: str):
    logger.info(f"Fetching user profile for user_id: {user_id}")
    try:
        with mysql.connector.connect(**db_config) as conn:
            with conn.cursor(dictionary=True) as cursor:
                # 사용자 프로필 정보 가져오기
                logger.debug(f"Fetching profile data for user_id: {user_id}")
                cursor.execute("SELECT NICKNAME, LV, INTRODUCE, IMAGE FROM Users WHERE USER_ID = %s", (user_id,))
                user_data = cursor.fetchone()
                
                if not user_data:
                    logger.warning(f"User with user_id {user_id} not found")
                    raise HTTPException(status_code=404, detail="User not found")

                image = user_data['IMAGE'] if user_data['IMAGE'] else None

                # 팔로워 수 가져오기
                logger.debug(f"Fetching follower count for user_id: {user_id}")
                cursor.execute("SELECT COUNT(*) AS follower_count FROM Follow WHERE USER_ID = %s", (user_id,))
                follower_data = cursor.fetchone()
                follower_count = follower_data['follower_count'] if follower_data else 0
                logger.debug(f"Follower count: {follower_count}")

                # 팔로잉 수 가져오기
                logger.debug(f"Fetching following count for user_id: {user_id}")
                cursor.execute("SELECT COUNT(*) AS following_count FROM Follow WHERE FOLLOWER = %s", (user_id,))
                following_data = cursor.fetchone()
                following_count = following_data['following_count'] if following_data else 0
                logger.debug(f"Following count: {following_count}")

        return {
            "nickname": user_data['NICKNAME'],
            "level": user_data['LV'],
            "introduce": user_data['INTRODUCE'],
            "image": image,
            "followerCount": follower_count,
            "followingCount": following_count
        }
    except mysql.connector.Error as err:
        logger.error(f"Database error in get_user_profile: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in get_user_profile: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 서버 실행
if __name__ == "__main__":
    import uvicorn
    logger.info(f"Starting server at http://{HOST}:{PORT}")
    try:
        uvicorn.run(app, host=HOST, port=PORT, log_level="debug")
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
        raise
