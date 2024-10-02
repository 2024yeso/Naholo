from fastapi import FastAPI, HTTPException, status, Depends, File, UploadFile, Form, Query, Body
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ValidationError
import mysql.connector
from mysql.connector.errors import IntegrityError
from typing import Optional, List, Dict
import os
from uuid import uuid4
import base64
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
HOST = "0.0.0.0"  # 모든 인터페이스에서 수신
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
    EXP: Optional[int] = 0  # EXP 필드 추가

class Follow(BaseModel):
    USER_ID: str
    FOLLOWER: str

class Like(BaseModel):
    USER_ID: str
    WHERE_ID: str  # VARCHAR(255)이므로 str 타입으로 변경

class UsersImage(BaseModel):
    USER_ID: str
    IMAGE: str

class ReviewImage(BaseModel):
    REVIEW_ID: int
    IMAGE: str

class Where(BaseModel):
    WHERE_ID: str  # VARCHAR(255)이므로 str 타입으로 변경
    WHERE_NAME: str
    WHERE_LOCATE: str
    WHERE_RATE: Optional[float] = 0.0  # 기본값 설정
    WHERE_TYPE: str
    LATITUDE: Optional[float] = None
    LONGITUDE: Optional[float] = None
    IMAGE: Optional[str] = None  # IMAGE 필드 추가

class WhereReview(BaseModel):
    user_id: str
    where_id: str  # place_id를 where_id로 변경
    where_name: str
    where_locate: str
    where_type: str
    where_image:str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    review_content: str
    where_like: int = 0
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
    images: List[str]  # 리뷰 이미지 리스트 (Base64 인코딩된 문자열)

class WhereImage(BaseModel):
    WHERE_ID: str  # VARCHAR(255)이므로 str 타입으로 변경
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
    EXP: Optional[int] = None  # EXP 필드 추가

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
                return {"message": "ID already exists", "available": True}  # 수정: available을 False로 변경
            else:
                logger.info(f"user_id {user_id} is available")
                return {"message": "ID is available", "available": False}  # 수정: available을 True로 변경
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
    INSERT INTO Users (USER_ID, USER_PW, NAME, PHONE, BIRTH, GENDER, NICKNAME, USER_CHARACTER, LV, INTRODUCE, IMAGE, EXP)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    try:
        with mysql.connector.connect(**db_config) as conn:
            with conn.cursor() as cursor:
                cursor.execute(insert_query, (
                    user.USER_ID, user.USER_PW, user.NAME, user.PHONE, user.BIRTH, user.GENDER,
                    user.NICKNAME, user.USER_CHARACTER, user.LV, user.INTRODUCE, user.IMAGE, user.EXP
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
                "exp": user.get('EXP', 0),
                "introduce": user['INTRODUCE'],
                "image": user['IMAGE'],
                "userCharacter": user['USER_CHARACTER']
            }
    except mysql.connector.Error as err:
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 서버 코드에서 추가 또는 수정해야 할 부분

@app.post("/add_review/")
def add_review(review_data: dict, db=Depends(get_db)):
    try:
        with db.cursor() as cursor:
            # 장소가 이미 존재하는지 확인
            check_where_query = """
            SELECT WHERE_ID FROM `Where` WHERE WHERE_ID = %s
            """
            cursor.execute(check_where_query, (review_data['where_id'],))
            where_exists = cursor.fetchone()
    
            # 장소가 존재하지 않으면 새로운 장소 추가
            if not where_exists:
                insert_where_query = """
                INSERT INTO `Where` (
                    WHERE_ID, WHERE_NAME, WHERE_LOCATE, WHERE_TYPE, WHERE_IMAGE, LATITUDE, LONGITUDE
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                """
                cursor.execute(insert_where_query, (
                    review_data['where_id'],
                    review_data['where_name'],
                    review_data['where_locate'],
                    review_data['where_type'],
                    review_data['where_image'],
                    review_data['latitude'],
                    review_data['longitude'],
                ))
                db.commit()
    
        # 리뷰 삽입 및 평균 평점 업데이트는 하나의 트랜잭션으로 처리
        with db.cursor(dictionary=True) as cursor:
            # 리뷰 데이터 삽입
            insert_review_query = """
            INSERT INTO WHERE_REVIEW (
                USER_ID, WHERE_ID, REVIEW_CONTENT, WHERE_LIKE, WHERE_RATE,
                REASON_MENU, REASON_MOOD, REASON_SAFE, REASON_SEAT,
                REASON_TRANSPORT, REASON_PARK, REASON_LONG, REASON_VIEW,
                REASON_INTERACTION, REASON_QUITE, REASON_PHOTO, REASON_WATCH
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(insert_review_query, (
                review_data['user_id'],
                review_data['where_id'],
                review_data['review_content'],
                0,  # WHERE_LIKE 초기값
                review_data['where_rate'],
                int(review_data['reason_menu']),
                int(review_data['reason_mood']),
                int(review_data['reason_safe']),
                int(review_data['reason_seat']),
                int(review_data['reason_transport']),
                int(review_data['reason_park']),
                int(review_data['reason_long']),
                int(review_data['reason_view']),
                int(review_data['reason_interaction']),
                int(review_data['reason_quite']),
                int(review_data['reason_photo']),
                int(review_data['reason_watch']),
            ))
            db.commit()
    
            # 새로운 리뷰의 REVIEW_ID 가져오기
            review_id = cursor.lastrowid
    
            # 이미지 데이터 삽입
            if 'images' in review_data and review_data['images']:
                insert_image_query = """
                INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE) VALUES (%s, %s)
                """
                for image_data in review_data['images']:
                    cursor.execute(insert_image_query, (review_id, image_data))
                db.commit()
    
            # 모든 리뷰의 평균 WHERE_RATE 계산
            avg_rate_query = """
            SELECT AVG(WHERE_RATE) as avg_rate FROM WHERE_REVIEW WHERE WHERE_ID = %s
            """
            cursor.execute(avg_rate_query, (review_data['where_id'],))
            avg_rate_result = cursor.fetchone()
            avg_rate = avg_rate_result['avg_rate']
    
            # Where 테이블의 WHERE_RATE 업데이트
            update_where_rate_query = """
            UPDATE `Where` SET WHERE_RATE = %s WHERE WHERE_ID = %s
            """
            cursor.execute(update_where_rate_query, (avg_rate, review_data['where_id']))
            db.commit()
    
            return {"message": "Review added successfully."}
    except Exception as e:
        db.rollback()
        logger.error(f"Error in add_review: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# 좋아요 추가 엔드포인트
@app.post("/add_like/")
def add_like(like: Like, db=Depends(get_db)):
    logger.info(f"Adding like for user_id: {like.USER_ID}, where_id: {like.WHERE_ID}")
    insert_like_query = """
    INSERT INTO LIKES (USER_ID, WHERE_ID)
    VALUES (%s, %s)
    """
    try:
        with db.cursor() as cursor:
            cursor.execute(insert_like_query, (like.USER_ID, like.WHERE_ID))
            db.commit()
        logger.info("Like added successfully")
        return {"message": "Like added successfully"}
    except IntegrityError as err:
        if err.errno == 1062:
            logger.warning(f"Duplicate like entry for user_id {like.USER_ID} and where_id {like.WHERE_ID}")
            raise HTTPException(status_code=400, detail="이미 좋아요를 누르셨습니다.")
        else:
            logger.error(f"Integrity error: {err}")
            raise HTTPException(status_code=500, detail=f"Integrity error: {err}")
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 좋아요 삭제 엔드포인트
@app.delete("/delete_like/")
def delete_like(like: Like, db=Depends(get_db)):
    logger.info(f"Deleting like for user_id: {like.USER_ID}, where_id: {like.WHERE_ID}")
    delete_like_query = """
    DELETE FROM LIKES WHERE USER_ID = %s AND WHERE_ID = %s
    """
    try:
        with db.cursor() as cursor:
            cursor.execute(delete_like_query, (like.USER_ID, like.WHERE_ID))
            db.commit()
        logger.info("Like deleted successfully")
        return {"message": "Like deleted successfully"}
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 팔로우 추가 엔드포인트
@app.post("/add_follow/")
def add_follow(follow: Follow, db=Depends(get_db)):
    logger.info(f"Adding follow from user_id: {follow.USER_ID} to follower: {follow.FOLLOWER}")
    insert_follow_query = """
    INSERT INTO Follow (USER_ID, FOLLOWER)
    VALUES (%s, %s)
    """
    try:
        with db.cursor() as cursor:
            cursor.execute(insert_follow_query, (follow.USER_ID, follow.FOLLOWER))
            db.commit()
        logger.info("Follow added successfully")
        return {"message": "Follow added successfully"}
    except IntegrityError as err:
        if err.errno == 1062:
            logger.warning(f"Duplicate follow entry for user_id {follow.USER_ID} and follower {follow.FOLLOWER}")
            raise HTTPException(status_code=400, detail="이미 팔로우하셨습니다.")
        else:
            logger.error(f"Integrity error: {err}")
            raise HTTPException(status_code=500, detail=f"Integrity error: {err}")
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 팔로우 삭제 엔드포인트
@app.delete("/delete_follow/")
def delete_follow(follow: Follow, db=Depends(get_db)):
    logger.info(f"Deleting follow from user_id: {follow.USER_ID} to follower: {follow.FOLLOWER}")
    delete_follow_query = """
    DELETE FROM Follow WHERE USER_ID = %s AND FOLLOWER = %s
    """
    try:
        with db.cursor() as cursor:
            cursor.execute(delete_follow_query, (follow.USER_ID, follow.FOLLOWER))
            db.commit()
        logger.info("Follow deleted successfully")
        return {"message": "Follow deleted successfully"}
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

                # REVIEW_IMAGE가 None이거나 존재하지 않으면 빈 리스트로 설정
                for review in reviews:
                    if not review.get('REVIEW_IMAGE'):
                        review['REVIEW_IMAGE'] = []  # 빈 리스트로 설정
    except mysql.connector.Error as err:
        logger.error(f"Database error in call_review: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in call_review: {e}")
    finally:
        return reviews


# 좋아요 호출 함수
def call_wanted(user_id: str) -> List[Dict]:
    query = """
    SELECT 
        w.WHERE_NAME AS WHERE_NAME,
        w.WHERE_LOCATE AS WHERE_LOCATE,
        w.WHERE_RATE AS WHERE_RATE,
        w.IMAGE AS PLACE_IMAGE
    FROM 
        LIKES l
    JOIN 
        `Where` w ON l.WHERE_ID = w.WHERE_ID
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
        # 리뷰 가져오기
        reviews = call_review(user_id)

        # 좋아요한 장소 가져오기
        liked_places = call_wanted(user_id)

        # 유저 정보 가져오기
        with db.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM Users WHERE USER_ID = %s", (user_id,))
            user_info = cursor.fetchone()

        if not user_info:
            logger.warning(f"User with user_id {user_id} not found")
            raise HTTPException(status_code=404, detail="User not found")

        # 팔로잉 수 가져오기 (해당 사용자가 팔로우하는 유저 수)
        with db.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT COUNT(*) AS following_count FROM Follow WHERE FOLLOWER = %s", (user_id,))
            following_count = cursor.fetchone()["following_count"]
            if(following_count==False):
                following_count = 0 

        # 팔로워 수 가져오기 (해당 사용자를 팔로우하는 유저 수)
        with db.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT COUNT(*) AS follower_count FROM Follow WHERE USER_ID = %s", (user_id,))
            follower_count = cursor.fetchone()["follower_count"]
            if(follower_count==False):
                follower_count = 0 
        print(follower_count)
        return {
            "user_info": {
                "USER_ID": user_info["USER_ID"],
                "NICKNAME": user_info["NICKNAME"],
                "LV": user_info["LV"],
                "EXP": user_info["EXP"],
                "INTRODUCE": user_info["INTRODUCE"],
                "IMAGE": user_info["IMAGE"],
                "userCharacter": user_info["USER_CHARACTER"],
                "follower_count": follower_count,       # 팔로워 수 추가
                "following_count": following_count      # 팔로잉 수 추가
            },
            "reviews": reviews,
            "liked_places": liked_places
        }
        
    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error(f"Unexpected error in my_page: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 팔로우 페이지 엔드포인트
@app.get("/follow_page/")
def follow_page(user_id: str, db=Depends(get_db)):
    logger.info(f"Fetching follow_page data for user_id: {user_id}")
    try:
        with db.cursor(dictionary=True) as cursor:
            # 내가 팔로우한 사람
            cursor.execute("""
                SELECT Users.USER_ID, Users.NICKNAME, Users.IMAGE
                FROM Follow
                JOIN Users ON Follow.FOLLOWER = Users.USER_ID
                WHERE Follow.USER_ID = %s
            """, (user_id,))
            following = cursor.fetchall()

            # 나를 팔로우한 사람
            cursor.execute("""
                SELECT Users.USER_ID, Users.NICKNAME, Users.IMAGE
                FROM Follow
                JOIN Users ON Follow.USER_ID = Users.USER_ID
                WHERE Follow.FOLLOWER = %s
            """, (user_id,))
            followers = cursor.fetchall()

        return {"following": following, "followers": followers}
    except mysql.connector.Error as err:
        logger.error(f"Database error in follow_page: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in follow_page: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

@app.get("/where/top-rated")
def get_top_rated_places(db=Depends(get_db)):
    types = ["play", "eat", "sleep", "drink"]
    results = {"by_type": {}, "overall_top_8": []}

    try:
        with db.cursor(dictionary=True) as cursor:
            # 각 타입별로 평점이 높은 순서대로 8개의 항목을 가져오는 쿼리
            for place_type in types:
                query = """
                SELECT w.*
                FROM `Where` w  -- 테이블 이름을 백틱으로 감쌈
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
            SELECT w.*
            FROM `Where` w  -- 테이블 이름을 백틱으로 감쌈
            ORDER BY w.WHERE_RATE DESC
            LIMIT 8;
            """
            logger.debug("Fetching overall top 8 places")
            cursor.execute(overall_query)
            overall_top_8 = cursor.fetchall()
            results["overall_top_8"] = overall_top_8
            logger.debug(f"Fetched {len(overall_top_8)} overall top places")
            print(results)
            
        return {"data": results}
    except mysql.connector.Error as err:
        logger.error(f"Database error in get_top_rated_places: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in get_top_rated_places: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

@app.get("/where/{where_id}")
def get_place_info(where_id: str, db=Depends(get_db)):
    logger.info(f"Fetching place info for WHERE_ID: {where_id}")
    place_query = """
    SELECT *
    FROM `Where`
    WHERE WHERE_ID = %s;
    """
    try:
        with db.cursor(dictionary=True) as cursor:
            # 장소의 정보 가져오기
            logger.debug(f"Executing place_query for WHERE_ID: {where_id}")
            cursor.execute(place_query, (where_id,))
            place_info = cursor.fetchone()

            if not place_info:
                logger.warning(f"Place with WHERE_ID {where_id} not found")
                raise HTTPException(status_code=404, detail="Place not found")

        return {
            "data": place_info
        }
    except mysql.connector.Error as err:
        logger.error(f"Database error in get_place_info: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in get_place_info: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

@app.get("/where/{where_id}/reviews")
def get_place_reviews(where_id: str, user_id: str = Query(None), db=Depends(get_db)):
    logger.info(f"Fetching reviews for WHERE_ID: {where_id}")
    review_query = """
    SELECT wr.*, ri.IMAGE AS REVIEW_IMAGE,
    CASE WHEN rl.USER_ID IS NOT NULL THEN TRUE ELSE FALSE END AS isLiked
    FROM WHERE_REVIEW wr
    LEFT JOIN REVIEW_IMAGE ri ON wr.REVIEW_ID = ri.REVIEW_ID
    LEFT JOIN REVIEW_LIKE rl ON wr.REVIEW_ID = rl.REVIEW_ID AND rl.USER_ID = %s
    WHERE wr.WHERE_ID = %s;
    """
    try:
        with db.cursor(dictionary=True) as cursor:
            cursor.execute(review_query, (user_id, where_id))
            reviews = cursor.fetchall()

        # REVIEW_LIKE로 매핑
        for review in reviews:
            review["REVIEW_LIKE"] = review.get("WHERE_LIKE", 0)
            del review["WHERE_LIKE"]  # 클라이언트에 불필요한 필드 제거

        return {
            "data": reviews
        }
    except mysql.connector.Error as err:
        logger.error(f"Database error in get_place_reviews: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in get_place_reviews: {e}")
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
    INSERT INTO Journal_post 
    (USER_ID, POST_NAME, POST_CONTENT, 혼캎, 혼영, 혼놀, 혼밥, 혼박, 혼술, 기타, POST_CREATE)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    insert_image_query = "INSERT INTO Journal_image (POST_ID, IMAGE_DATA) VALUES (%s, %s)"
    try:
        with db.cursor() as cursor:
            # 현재 시간을 기본값으로 설정
            created_at = journal_post.created_at or datetime.now()

            # Journal_post 테이블에 일지 내용 삽입
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
            logger.debug(f"Inserted Journal_post with POST_ID: {post_id}")

            # Journal_image 테이블에 이미지 데이터 삽입
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

# 저널 메인 엔드포인트 수정본
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
                # POST_ID를 문자열로 변환하고 SQL에 안전하게 포함
                post_ids_list = [str(int(post_id)) for post_id in all_post_ids]
                post_ids_str = ','.join(post_ids_list)
    
                # Post_like 테이블에서 각 POST_ID의 좋아요 개수 조회
                likes_query = f"""
                SELECT POST_ID, COUNT(*) AS like_count
                FROM Post_like
                WHERE POST_ID IN ({post_ids_str})
                GROUP BY POST_ID;
                """
                logger.debug(f"Fetching like counts for POST_IDs: {post_ids_list}")
                cursor.execute(likes_query)
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
                update_data = [(likes_map.get(post_id, 0), post_id) for post_id in all_post_ids]
    
                # 배치 업데이트 실행
                if update_data:
                    cursor.executemany(update_query, update_data)
                    db.commit()
                    logger.debug(f"Updated POST_LIKE for {len(update_data)} posts")
    
                # 현재 사용자가 좋아요를 눌렀는지 여부 조회
                liked_query = f"""
                SELECT POST_ID
                FROM Post_like
                WHERE POST_ID IN ({post_ids_str}) AND USER_ID = %s;
                """
                cursor.execute(liked_query, (user_id,))
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
                images_query = f"""
                SELECT POST_ID, IMAGE_DATA
                FROM Journal_image
                WHERE POST_ID IN ({post_ids_str});
                """
                logger.debug(f"Fetching images for POST_IDs: {post_ids_list}")
                cursor.execute(images_query)
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
    finally:
        logger.debug(f"Final Results with Images: {results}")
    return {"data": results}
    
class JournalComment(BaseModel):
    
    POST_ID: int
    COMMENT_CONTENT: str
    USER_ID: str

# 저널 댓글 추가 엔드포인트
@app.post("/journal/add_comment")
def add_comment(comment: JournalComment, db=Depends(get_db)):
    print(comment)
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

# /journal/get_comments 엔드포인트
class Comment(BaseModel):
    comment_id: int
    post_id: int
    user_id: str
    author: str
    content: str
    created_at: str  # datetime 대신 문자열 사용

class CommentsResponse(BaseModel):
    comments: List[Comment]

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
                    (SELECT NICKNAME FROM Users WHERE Users.USER_ID = Journal_comment.USER_ID) AS author,
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

# 좋아요 추가 엔드포인트
class LikePostRequest(BaseModel):
    post_id: int
    user_id: str

@app.get("/user/journal/")
def get_user_journal_posts(user_id: str, db=Depends(get_db)):
    results = {"latest": [], "top_likes": []}
    
    try:
        with db.cursor(dictionary=True) as cursor:
            
            # 최신순으로 포스트 가져오기
            latest_query = """
            SELECT jp.*, u.IMAGE AS USER_IMAGE
            FROM Journal_post jp
            LEFT JOIN Users u ON jp.USER_ID = u.USER_ID
            WHERE jp.USER_ID = %s
            ORDER BY jp.POST_CREATE DESC;
            """
            cursor.execute(latest_query, (user_id,))
            latest_posts = cursor.fetchall()
            results["latest"] = latest_posts
            
            # 좋아요 순으로 포스트 가져오기
            top_likes_query = """
            SELECT jp.*, u.IMAGE AS USER_IMAGE
            FROM Journal_post jp
            LEFT JOIN Users u ON jp.USER_ID = u.USER_ID
            WHERE jp.USER_ID = %s
            ORDER BY jp.POST_LIKE DESC, jp.POST_CREATE DESC;
            """
            cursor.execute(top_likes_query, (user_id,))
            top_likes_posts = cursor.fetchall()
            results["top_likes"] = top_likes_posts
            
            # 모든 POST_ID 수집
            all_post_ids = set(post['POST_ID'] for post in latest_posts + top_likes_posts)
            
            if all_post_ids:
                post_ids_list = [str(int(post_id)) for post_id in all_post_ids]
                post_ids_str = ','.join(post_ids_list)
                
                # 각 POST_ID의 이미지 조회
                images_query = f"""
                SELECT POST_ID, IMAGE_DATA
                FROM Journal_image
                WHERE POST_ID IN ({post_ids_str});
                """
                cursor.execute(images_query)
                images_data = cursor.fetchall()
                
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
                
                # 혼캎, 혼영 등의 필드를 bool 리스트로 변환
                for key in results:
                    for post in results[key]:
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
        logger.error(f"Database error in get_user_journal_posts: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logger.error(f"Unexpected error in get_user_journal_posts: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")
    
    return {"data": results}

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
                raise HTTPException(status_code=400, detail="이미 좋아요를 누르셨습니다.")

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

# 좋아요 삭제 엔드포인트
class UnlikePostRequest(BaseModel):
    post_id: int
    user_id: str

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
    
@app.post("/reviews/{review_id}/like")
def like_review(review_id: int, like_data: dict = Body(...), db=Depends(get_db)):
    user_id = like_data.get('user_id')
    is_liked = like_data.get('like', True)

    if not user_id:
        raise HTTPException(status_code=400, detail="User ID is required.")

    try:
        with db.cursor(dictionary=True) as cursor:
            # 리뷰가 존재하는지 확인
            check_review_query = """
            SELECT 1 FROM WHERE_REVIEW WHERE REVIEW_ID = %s
            """
            cursor.execute(check_review_query, (review_id,))
            if not cursor.fetchone():
                raise HTTPException(status_code=404, detail="Review not found.")

            # 좋아요 상태 확인
            check_like_query = """
            SELECT 1 FROM REVIEW_LIKE WHERE REVIEW_ID = %s AND USER_ID = %s
            """
            cursor.execute(check_like_query, (review_id, user_id))
            like_exists = cursor.fetchone()

            if is_liked:
                if like_exists:
                    # 이미 좋아요를 누른 상태
                    raise HTTPException(status_code=400, detail="Already liked.")
                else:
                    # 좋아요 추가
                    insert_like_query = """
                    INSERT INTO REVIEW_LIKE (REVIEW_ID, USER_ID) VALUES (%s, %s)
                    """
                    cursor.execute(insert_like_query, (review_id, user_id))
                    # 리뷰의 좋아요 수 증가
                    update_review_like_query = """
                    UPDATE WHERE_REVIEW SET WHERE_LIKE = WHERE_LIKE + 1 WHERE REVIEW_ID = %s
                    """
                    cursor.execute(update_review_like_query, (review_id,))
            else:
                if like_exists:
                    # 좋아요 취소
                    delete_like_query = """
                    DELETE FROM REVIEW_LIKE WHERE REVIEW_ID = %s AND USER_ID = %s
                    """
                    cursor.execute(delete_like_query, (review_id, user_id))
                    # 리뷰의 좋아요 수 감소 (0 이상으로 유지)
                    update_review_like_query = """
                    UPDATE WHERE_REVIEW SET WHERE_LIKE = GREATEST(WHERE_LIKE - 1, 0) WHERE REVIEW_ID = %s
                    """
                    cursor.execute(update_review_like_query, (review_id,))
                else:
                    # 좋아요를 누르지 않은 상태에서 좋아요 취소 시도
                    raise HTTPException(status_code=400, detail="Like does not exist.")

            # 성공 시 현재 좋아요 수를 REVIEW_LIKE로 매핑하여 반환
            cursor.execute("SELECT WHERE_LIKE FROM WHERE_REVIEW WHERE REVIEW_ID = %s", (review_id,))
            result = cursor.fetchone()
            current_like_count = result['WHERE_LIKE'] if result else 0

            db.commit()
            return {"message": "Like status updated successfully.", "REVIEW_LIKE": current_like_count}
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error in like_review: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except HTTPException as http_err:
        # HTTPException은 그대로 전달
        raise http_err
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error in like_review: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 서버 실행
if __name__ == "__main__":
    import uvicorn
    logger.info(f"Starting server at http://{HOST}:{PORT}")
    try:
        uvicorn.run(app, host=HOST, port=PORT)
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
        raise
