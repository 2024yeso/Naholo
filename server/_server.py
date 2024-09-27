from fastapi import FastAPI, HTTPException, status, Depends, File, UploadFile, Form, Query, Body
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ValidationError
import mysql.connector
from mysql.connector.errors import IntegrityError
from typing import Optional, List
import os
from uuid import uuid4
import base64  # Base64 인코딩을 위해 필요
import logging
from datetime import datetime
from typing import Dict, List


logging.basicConfig(
    level=logging.DEBUG,  # 로그 레벨을 DEBUG로 설정
    format="%(asctime)s - %(levelname)s - %(message)s",
)

logger = logging.getLogger(__name__)

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 필요한 도메인으로 제한하는 것이 좋습니다.
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
def get_user(db, username: str):
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Users WHERE USER_ID = %s", (username,))
    user = cursor.fetchone()
    cursor.close()
    return user
from fastapi import HTTPException

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
    try:
        cursor = db.cursor()

        # 업데이트할 필드가 있는지 확인
        update_fields = []
        update_values = []

        if user_update.USER_PW is not None:
            update_fields.append("USER_PW = %s")
            update_values.append(user_update.USER_PW)
        if user_update.NAME is not None:
            update_fields.append("NAME = %s")
            update_values.append(user_update.NAME)
        if user_update.PHONE is not None:
            update_fields.append("PHONE = %s")
            update_values.append(user_update.PHONE)
        if user_update.BIRTH is not None:
            update_fields.append("BIRTH = %s")
            update_values.append(user_update.BIRTH)
        if user_update.GENDER is not None:
            update_fields.append("GENDER = %s")
            update_values.append(user_update.GENDER)
        if user_update.NICKNAME is not None:
            update_fields.append("NICKNAME = %s")
            update_values.append(user_update.NICKNAME)
        if user_update.USER_CHARACTER is not None:
            update_fields.append("USER_CHARACTER = %s")
            update_values.append(user_update.USER_CHARACTER)
        if user_update.LV is not None:
            update_fields.append("LV = %s")
            update_values.append(user_update.LV)
        if user_update.INTRODUCE is not None:
            update_fields.append("INTRODUCE = %s")
            update_values.append(user_update.INTRODUCE)
        if user_update.IMAGE is not None:
            update_fields.append("IMAGE = %s")
            update_values.append(user_update.IMAGE)

        if not update_fields:
            raise HTTPException(status_code=400, detail="No fields to update")

        update_query = f"UPDATE Users SET {', '.join(update_fields)} WHERE USER_ID = %s"
        update_values.append(user_id)

        cursor.execute(update_query, tuple(update_values))
        db.commit()

        cursor.close()

        return {"message": "User information updated successfully"}
    
    except mysql.connector.Error as err:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 중복확인 엔드포인트
@app.get("/check_id/")
def check_id(user_id: str):
    try:
        conn = mysql.connector.connect(**db_config)
        db_user = get_user(conn, user_id)
        conn.close()

        if db_user:
            return {"message": "ID already exists", "available": True}
        else:
            return {"message": "ID is available", "available": False}

    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 회원가입 엔드포인트
@app.post("/add_user/")
def add_user(user: User):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        insert_query = """
        INSERT INTO Users (USER_ID, USER_PW, NAME, PHONE, BIRTH, GENDER, NICKNAME, USER_CHARACTER, LV, INTRODUCE, IMAGE)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(insert_query, (
            user.USER_ID, user.USER_PW, user.NAME, user.PHONE, user.BIRTH, user.GENDER,
            user.NICKNAME, user.USER_CHARACTER, user.LV, user.INTRODUCE, user.IMAGE
        ))

        conn.commit()
        cursor.close()
        conn.close()
        return {"message": "User added successfully"}
    
    except IntegrityError as err:
        if err.errno == 1062:
            raise HTTPException(status_code=400, detail="Duplicate entry for primary key")
        else:
            raise HTTPException(status_code=500, detail=f"Integrity error: {err}")

    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 로그인 엔드포인트
@app.get("/login/")
def login(user_id: str, user_pw: str):
    try:
        conn = mysql.connector.connect(**db_config)
        db_user = get_user(conn, user_id)
        conn.close()

        if not db_user or db_user['USER_PW'] != user_pw:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="유저 정보가 없거나 비밀번호가 맞지 않습니다"
            )
        return {
            "message": "로그인 성공",
            "user_id": db_user['USER_ID'],
            "nickname": db_user['NICKNAME'],
            "lv": db_user['LV'],
            "exp" : db_user['EXP'],
            "introduce": db_user['INTRODUCE'],
            "image": db_user['IMAGE'], # 예시 이미지 URL    
            "userCharacter": db_user['USER_CHARACTER']
        }
    
    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

@app.post("/add_review/")   
async def add_review(review: WhereReview, db=Depends(get_db)):
    # 입력된 리뷰 데이터를 로그로 출력
    print(f"Received review data: {review.dict()}")

    try:
        cursor = db.cursor()

        # 리뷰 데이터 삽입
        insert_review_query = """
        INSERT INTO WHERE_REVIEW (
            USER_ID, WHERE_ID, REVIEW_CONTENT, WHERE_LIKE, WHERE_RATE,
            REASON_MENU, REASON_MOOD, REASON_SAFE, REASON_SEAT, REASON_TRANSPORT,
            REASON_PARK, REASON_LONG, REASON_VIEW, REASON_INTERACTION, REASON_QUITE,
            REASON_PHOTO, REASON_WATCH
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(insert_review_query, (
            review.user_id, review.where_id, review.review_content, review.where_like, review.where_rate,
            review.reason_menu, review.reason_mood, review.reason_safe, review.reason_seat, review.reason_transport,
            review.reason_park, review.reason_long, review.reason_view, review.reason_interaction, review.reason_quite,
            review.reason_photo, review.reason_watch
        ))      

        # 삽입된 리뷰의 ID 가져오기
        review_id = cursor.lastrowid

        # 리뷰 이미지 삽입
        insert_image_query = """
        INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE) VALUES (%s, %s)
        """
        for base64_image in review.images:
            # Base64 인코딩된 이미지 데이터 저장
            cursor.execute(insert_image_query, (review_id, base64_image))

        db.commit()
        cursor.close()

        logging.debug("Review and images added successfully")
        return {"message": "Review and images added successfully"}
    
    except ValidationError as ve:
        logging.error(f"Validation Error: {ve.json()}")
        raise HTTPException(status_code=422, detail=ve.errors())
    
    except mysql.connector.Error as err:
        db.rollback()  # 데이터베이스 오류 시 롤백
        logging.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 리뷰 호출 함수
def call_review(user_id):
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
    
    try:
        # 디버그: 데이터베이스 연결 시도
        print("Connecting to the database...")
        conn = mysql.connector.connect(**db_config)
        review_conn = conn.cursor(dictionary=True)

        # 디버그: 쿼리 실행 전 확인
        print(f"Executing query for user_id: {user_id}")
        review_conn.execute(query, (user_id,))
        
        # 디버그: 쿼리 결과 확인
        print("Fetching results...")
        review_list = review_conn.fetchall()
        
        # 디버그: 쿼리 결과 출력
        print(f"Number of reviews fetched: {len(review_list)}")
        for review in review_list:
            print(f"Review: {review}")
        
        # REVIEW_IMAGE가 없을 경우 None으로 설정
        for review in review_list:
            if not review['REVIEW_IMAGE']:
                review['REVIEW_IMAGE'] = None  # 이미지가 없을 경우 None 설정

        review_conn.close()
        conn.close()
        
        return review_list
    
    except mysql.connector.Error as err:
        # 디버그: 데이터베이스 오류 발생 시
        print(f"Database error occurred: {err}")
        return []
    
    except Exception as e:
        # 디버그: 일반 오류 발생 시
        print(f"An error occurred: {e}")
        return []
    
    finally:
        # 디버그: 커넥션과 커서가 올바르게 닫혔는지 확인
        if review_conn:
            review_conn.close()
        if conn:
            conn.close()


# 좋아요 호출 함수
def call_wanted(user_id):
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
    
    conn = mysql.connector.connect(**db_config)
    wanted_conn = conn.cursor(dictionary=True)
    wanted_conn.execute(query, (user_id,))
    where_wanted = wanted_conn.fetchall()
    wanted_conn.close()
    conn.close()
    
    # 이미지 경로를 URL로 변환
    for wanted in where_wanted:
        if wanted['PLACE_IMAGE']:
            wanted['PLACE_IMAGE'] = f"http://{IMAGE_HOST}:{PORT}/images/{wanted['PLACE_IMAGE']}"
    
    return where_wanted

# 마이페이지 엔드포인트
@app.get("/my_page/")
def my_page(user_id: str):
    try:
        r_review = call_review(user_id)
        print(r_review)
        return {"reviews": r_review}
    
    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 팔로우페이지 엔드포인트
@app.get("/follow_page/")
def follow_page(user_id: str):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT FOLLOWER FROM FOLLOW WHERE USER_ID = %s", (user_id,))
        follow = cursor.fetchall()
        cursor.execute("SELECT USER_ID FROM FOLLOW WHERE FOLLOWER = %s", (user_id,))
        follower = cursor.fetchall()
        cursor.close()
        conn.close()

        return {"follow": follow, "follower": follower}
        
    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 각 type별로 상위 8개 항목과 이미지를 불러오는 엔드포인트
@app.get("/where/top-rated")
def get_top_rated_places(db = Depends(get_db)):
    types = ["play", "eat", "sleep", "drink"]
    results = {"by_type": {}, "overall_top_8": []}

    try:
        cursor = db.cursor(dictionary=True)
        
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
            cursor.execute(query, (place_type,))
            rows = cursor.fetchall()
            results["by_type"][place_type] = rows

        # 전체 평점이 높은 순서대로 상위 8개의 항목을 가져오는 쿼리
        overall_query = """
        SELECT w.*, wi.IMAGE
        FROM `Where` w
        LEFT JOIN `WHERE_IMAGE` wi ON w.WHERE_ID = wi.WHERE_ID
        ORDER BY w.WHERE_RATE DESC
        LIMIT 8;
        """
        cursor.execute(overall_query)
        overall_top_8 = cursor.fetchall()
        results["overall_top_8"] = overall_top_8

        cursor.close()
        return {"data": results}

    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 장소 세부 정보를 불러오는 엔드포인트
@app.get("/where/place-info")
def get_place_info(where_id: int, db=Depends(get_db)):
    try:
        # 커서를 buffered=True로 설정하여 모든 결과를 메모리에 버퍼링
        cursor = db.cursor(dictionary=True, buffered=True)

        # 장소의 기본 정보와 이미지 가져오기
        place_query = """
        SELECT w.*, wi.IMAGE
        FROM `Where` w
        LEFT JOIN `WHERE_IMAGE` wi ON w.WHERE_ID = wi.WHERE_ID
        WHERE w.WHERE_ID = %s;
        """
        cursor.execute(place_query, (where_id,))
        place_info = cursor.fetchone()

        if not place_info:
            cursor.close()
            raise HTTPException(status_code=404, detail="Place not found")

        # 장소의 리뷰와 리뷰 이미지 가져오기
        review_query = """
        SELECT wr.*, ri.IMAGE AS REVIEW_IMAGE
        FROM `WHERE_REVIEW` wr
        LEFT JOIN `REVIEW_IMAGE` ri ON wr.REVIEW_ID = ri.REVIEW_ID
        WHERE wr.WHERE_ID = %s;
        """
        cursor.execute(review_query, (where_id,))
        reviews = cursor.fetchall()

        cursor.close()

        # 결과 반환
        return {
            "place_info": place_info,
            "reviews": reviews
        }

    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")
    
def encode_image_to_base64(file_content):
    return base64.b64encode(file_content).decode('utf-8')

import logging

logging.basicConfig(level=logging.INFO)

@app.post("/upload_profile_image/")
async def upload_profile_image(
    user_id: str = Form(...),
    file: UploadFile = File(...),
    db=Depends(get_db)
):
    try:
        # 파일 내용을 읽어서 Base64로 인코딩
        file_content = await file.read()
        encoded_image = encode_image_to_base64(file_content)

        # 데이터베이스에 Base64 인코딩된 이미지 저장
        cursor = db.cursor()

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
        else:
            # 데이터가 없는 경우 삽입
            insert_image_query = "INSERT INTO Users_Image (USER_ID, IMAGE) VALUES (%s, %s)"
            cursor.execute(insert_image_query, (user_id, encoded_image))

        # 커밋하여 변경 사항을 저장
        db.commit()
        cursor.close()

        logging.info(f"Profile image for {user_id} uploaded successfully")
        return {"message": "Profile image uploaded successfully", "image_base64": encoded_image}

    except mysql.connector.Error as err:
        db.rollback()
        logging.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    except Exception as e:
        logging.error(f"Failed to upload profile image: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to upload profile image: {e}")

@app.get("/journal/main")
def get_journal(user_id: str, db=Depends(get_db)):
    results = {"latest_10": [], "top_10": [], "followers_latest": []}

    try:
        cursor = db.cursor(dictionary=True)

        # Fetch latest 10 posts
        latest_query = """
        SELECT jp.*, ui.IMAGE AS USER_IMAGE
        FROM Journal_post jp
        LEFT JOIN Users_Image ui ON jp.USER_ID = ui.USER_ID
        ORDER BY jp.POST_CREATE DESC
        LIMIT 10;
        """
        cursor.execute(latest_query)
        latest_10 = cursor.fetchall()
        results["latest_10"] = latest_10 if latest_10 else []
        logger.debug(f"Latest 10 reviews fetched: {latest_10}")

        # Fetch top 10 posts sorted by likes
        top_query = """
        SELECT jp.*, ui.IMAGE AS USER_IMAGE
        FROM Journal_post jp
        LEFT JOIN Users_Image ui ON jp.USER_ID = ui.USER_ID
        ORDER BY jp.POST_LIKE DESC, jp.POST_CREATE DESC
        LIMIT 10;
        """
        cursor.execute(top_query)
        top_10 = cursor.fetchall()
        results["top_10"] = top_10 if top_10 else []
        logger.debug(f"Top 10 reviews fetched: {top_10}")

        # Fetch latest 10 posts from followed users
        followers_query = """
        SELECT jp.*, ui.IMAGE AS USER_IMAGE
        FROM Journal_post jp
        LEFT JOIN Users_Image ui ON jp.USER_ID = ui.USER_ID
        WHERE jp.USER_ID IN (
            SELECT f.FOLLOWER
            FROM Follow f
            WHERE f.USER_ID = %s
        )
        ORDER BY jp.POST_CREATE DESC
        LIMIT 10;
        """
        cursor.execute(followers_query, (user_id,))
        followers_latest = cursor.fetchall()
        results["followers_latest"] = followers_latest if followers_latest else []
        logger.debug(f"Followers' latest reviews fetched: {followers_latest}")

        # Collect all POST_IDs from the fetched posts using a list to maintain order and remove duplicates
        all_post_ids = []
        seen_post_ids = set()
        for key in results:
            for post in results[key]:
                post_id = post['POST_ID']
                if post_id not in seen_post_ids:
                    all_post_ids.append(post_id)
                    seen_post_ids.add(post_id)

        if all_post_ids:
            # Fetch all images for the collected POST_IDs
            format_strings = ','.join(['%s'] * len(all_post_ids))
            images_query = f"""
            SELECT POST_ID, IMAGE_DATA
            FROM journal_image
            WHERE POST_ID IN ({format_strings});
            """
            try:
                cursor.execute(images_query, all_post_ids)
                images_data = cursor.fetchall()
                logger.debug(f"Fetched images: {images_data}")
            except Exception as e:
                logger.error(f"Error fetching images: {e}")
                raise

            # Map POST_ID to list of images
            post_images_map: Dict[int, List[str]] = {}
            for image in images_data:
                post_id = image['POST_ID']
                if post_id not in post_images_map:
                    post_images_map[post_id] = []
                post_images_map[post_id].append(image['IMAGE_DATA'])

            # Attach images to each post
            for key in results:
                for post in results[key]:
                    post_id = post['POST_ID']
                    post['images'] = post_images_map.get(post_id, [])

                    # Convert integer flags to bool if necessary
                    post['subjList'] = [
                        bool(post.get('혼캎', False)),
                        bool(post.get('혼영', False)),
                        bool(post.get('혼놀', False)),
                        bool(post.get('혼밥', False)),
                        bool(post.get('혼박', False)),
                        bool(post.get('혼술', False)),
                        bool(post.get('기타', False)),
                    ]

        cursor.close()

        logger.debug(f"Final Results with Images: {results}")

        return {"data": results}

    except mysql.connector.Error as err:
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")




# 일지 댓글
@app.get("/journal/comment")
def get_journal_comments(post_id: int):
    try:
        # 데이터베이스 연결
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        # post_id에 맞는 댓글을 가져오는 쿼리
        query = """
        SELECT jc.*, u.NICKNAME, u.USER_CHARACTER, u.LV
        FROM `Journal_comment` jc
        LEFT JOIN `Users` u ON jc.USER_ID = u.USER_ID
        WHERE jc.POST_ID = %s
        ORDER BY jc.COMMENT_ID DESC;
        """
        cursor.execute(query, (post_id,))
        comments = cursor.fetchall()

        # 연결 종료
        cursor.close()
        conn.close()

        return {"comments": comments}

    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

@app.post("/journal/add_comment")
def add_comment(comment: JournalComment, db=Depends(get_db)):
    logger.debug(f"Followers' latest reviews fetched: {comment}")
    try:
        cursor = db.cursor()

        # 댓글 삽입 쿼리
        insert_comment_query = """
        INSERT INTO Journal_comment (POST_ID, USER_ID, COMMENT_CONTENT)
        VALUES (%s, %s, %s)
        """
        cursor.execute(insert_comment_query, (comment.POST_ID, comment.USER_ID, comment.COMMENT_CONTENT))

        # 데이터베이스 커밋
        db.commit()
        cursor.close()

        return {"message": "Comment added successfully"}

    except mysql.connector.Error as err:
        db.rollback()  # 데이터베이스 오류 발생 시 롤백
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")
    
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

@app.post("/journal/upload/")
async def add_journal(
    user_id: str = Query(...),  # user_id를 쿼리 매개변수로 받음
    journal_post: JournalPost = Body(...),  # JournalPost 모델의 JSON 본문으로 데이터를 받음
    db=Depends(get_db)
):
    logger.debug(f"Uploading journal post for user_id: {user_id}")
    logger.debug(f"JournalPost data: {journal_post}")

    try:
        cursor = db.cursor()

        # 현재 시간을 기본값으로 설정
        created_at = journal_post.created_at or datetime.now()

        # journal_post 테이블에 일지 내용 삽입
        insert_post_query = """
        INSERT INTO journal_post 
        (USER_ID, POST_NAME, POST_CONTENT, 혼캎, 혼영, 혼놀, 혼밥, 혼박, 혼술, 기타, POST_CREATE)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
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

        # 삽입된 일지의 POST_ID 가져오기
        post_id = cursor.lastrowid
        logger.debug(f"Inserted journal_post with POST_ID: {post_id}")

        # journal_image 테이블에 이미지 데이터 삽입
        insert_image_query = "INSERT INTO journal_image (POST_ID, IMAGE_DATA) VALUES (%s, %s)"
        for image in journal_post.images:
            cursor.execute(insert_image_query, (post_id, image))
            logger.debug(f"Inserted image for POST_ID {post_id}")

        db.commit()
        cursor.close()

        return {"message": "Journal post and images added successfully", "post_id": post_id}
    
    except mysql.connector.Error as err:
        db.rollback()
        logger.error(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")
    
@app.get("/get_user_profile/")
def get_user_profile(user_id: str):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        # 사용자 프로필 정보 가져오기
        cursor.execute("SELECT NICKNAME, LV, INTRODUCE, IMAGE FROM Users WHERE USER_ID = %s", (user_id,))
        user_data = cursor.fetchone()
        
        # 디버깅을 위한 로그 추가
        if not user_data:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="User not found")

        # 이미지 URL은 upload_profile_image에서 데이터베이스에 저장한 전체 URL을 가져옴
        image = user_data['IMAGE'] if user_data['IMAGE'] else None

        # 팔로워 수 가져오기
        cursor.execute("SELECT COUNT(*) AS follower_count FROM Follow WHERE USER_ID = %s", (user_id,))
        follower_data = cursor.fetchone()
        
        # 디버깅을 위한 로그 추가
        print(f"follower_data: {follower_data}")

        follower_count = follower_data['follower_count'] if follower_data else 0

        # 팔로잉 수 가져오기
        cursor.execute("SELECT COUNT(*) AS following_count FROM Follow WHERE FOLLOWER = %s", (user_id,))
        following_data = cursor.fetchone()
        
        # 디버깅을 위한 로그 추가
        print(f"following_data: {following_data}")

        following_count = following_data['following_count'] if following_data else 0

        cursor.close()
        conn.close()

        return {
            "nickname": user_data['NICKNAME'],
            "level": user_data['LV'],
            "introduce": user_data['INTRODUCE'],
            "image": image,
            "followerCount": follower_count,
            "followingCount": following_count
        }

    except mysql.connector.Error as err:
        print(f"Database error: {err}")
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        print(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=HOST, port=PORT, log_level="debug")
