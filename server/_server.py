# server.py

from fastapi import FastAPI, HTTPException, status, Depends, File, UploadFile
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import mysql.connector
from mysql.connector.errors import IntegrityError
from typing import Optional, List
import os
from uuid import uuid4

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
HOST = "0.0.0.0"      # 모든 인터페이스에서 수신
PORT = 8000           # 서버가 실행되는 포트 번호
IMAGE_HOST = "10.0.2.2"  # 에뮬레이터에서 호스트 머신을 가리키는 IP

# 이미지 업로드 디렉토리 설정
UPLOAD_DIRECTORY = "uploaded_images"

# 업로드 디렉토리가 존재하지 않으면 생성
if not os.path.exists(UPLOAD_DIRECTORY):
    os.makedirs(UPLOAD_DIRECTORY)

# 정적 파일 라우팅 설정 (이미지 제공)
app.mount("/images", StaticFiles(directory=UPLOAD_DIRECTORY), name="images")

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
    USER_ID: str
    WHERE_ID: int
    REVIEW_CONTENT: str
    WHERE_LIKE: int
    WHERE_RATE: float
    REASON_MENU: bool
    REASON_MOOD: bool
    REASON_SAFE: bool
    REASON_SEAT: bool
    REASON_TRANSPORT: bool
    REASON_PARK: bool
    REASON_LONG: bool
    REASON_VIEW: bool
    REASON_INTERACTION: bool
    REASON_QUITE: bool
    REASON_PHOTO: bool
    REASON_WATCH: bool
    IMAGES: List[str]  # 리뷰 이미지 리스트

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

        return {"message": "로그인 성공", 
                "NICKNAME": db_user['NICKNAME'],
                "USER_CHARACTER": db_user['USER_CHARACTER'],
                "LV": db_user['LV'],
                "INTRODUCE": db_user['INTRODUCE']}
    
    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
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
        ri.IMAGE AS REVIEW_IMAGE
    FROM 
        WHERE_REVIEW wr
    JOIN 
        `Where` w ON wr.WHERE_ID = w.WHERE_ID
    LEFT JOIN 
        REVIEW_IMAGE ri ON wr.REVIEW_ID = ri.REVIEW_ID
    WHERE 
        wr.USER_ID = %s;
    """
    
    conn = mysql.connector.connect(**db_config)
    review_conn = conn.cursor(dictionary=True)
    review_conn.execute(query, (user_id,))
    review_list = review_conn.fetchall()
    review_conn.close()
    conn.close()
    
    # 이미지 경로를 URL로 변환
    for review in review_list:
        if review['REVIEW_IMAGE']:
            # REVIEW_IMAGE가 전체 URL인지 확인
            if not review['REVIEW_IMAGE'].startswith('http'):
                review['REVIEW_IMAGE'] = f"http://{IMAGE_HOST}:{PORT}/images/{review['REVIEW_IMAGE']}"
                
    return review_list
        
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
        r_wanted = call_wanted(user_id)

        return {"reviews": r_review, "wanted": r_wanted}
    
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

    
# 이미지 업로드 엔드포인트
@app.post("/upload_image/")
async def upload_image(file: UploadFile = File(...)):
    try:
        # 고유한 파일 이름 생성
        filename = f"{uuid4()}_{file.filename}"
        file_path = os.path.join(UPLOAD_DIRECTORY, filename)

        # 파일을 서버에 저장
        with open(file_path, "wb") as image_file:
            content = await file.read()
            image_file.write(content)

        # 이미지에 접근할 수 있는 URL 생성
        image_url = f"http://{IMAGE_HOST}:{PORT}/images/{filename}"

        return {"message": "Image uploaded successfully", "image_url": image_url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload image: {e}")

    
@app.post("/add_review/")
def add_review(review: WhereReview, db=Depends(get_db)):
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
            review.USER_ID, review.WHERE_ID, review.REVIEW_CONTENT, review.WHERE_LIKE, review.WHERE_RATE,
            review.REASON_MENU, review.REASON_MOOD, review.REASON_SAFE, review.REASON_SEAT, review.REASON_TRANSPORT,
            review.REASON_PARK, review.REASON_LONG, review.REASON_VIEW, review.REASON_INTERACTION, review.REASON_QUITE,
            review.REASON_PHOTO, review.REASON_WATCH
        ))      

        # 삽입된 리뷰의 ID 가져오기
        review_id = cursor.lastrowid

        # 리뷰 이미지 삽입
        insert_image_query = """
        INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE) VALUES (%s, %s)
        """
        for filename in review.IMAGES:
            # 파일 이름을 저장
            cursor.execute(insert_image_query, (review_id, filename))

        db.commit()
        cursor.close()

        return {"message": "Review and images added successfully"}
    
    except mysql.connector.Error as err:
        db.rollback()  # 데이터베이스 오류 시 롤백
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

# 일지 메인페이지
@app.get("/journal/main")
def get_journal(db=Depends(get_db)):
    results = {"latest_10": [], "top_10": []}

    try:
        cursor = db.cursor(dictionary=True)

        # 최신순으로 10개의 일지를 가져오는 쿼리
        latest_query = """
        SELECT jp.*, ui.IMAGE AS USER_IMAGE
        FROM `Journal_post` jp
        LEFT JOIN `Users_Image` ui ON jp.USER_ID = ui.USER_ID
        ORDER BY jp.POST_UPDATE DESC
        LIMIT 10;
        """
        cursor.execute(latest_query)
        latest_10 = cursor.fetchall()
        results["latest_10"] = latest_10

        # 인기순으로 10개의 일지를 가져오는 쿼리 (POST_LIKE 순으로 정렬)
        top_query = """
        SELECT jp.*, ui.IMAGE AS USER_IMAGE
        FROM `Journal_post` jp
        LEFT JOIN `Users_Image` ui ON jp.USER_ID = ui.USER_ID
        ORDER BY jp.POST_LIKE DESC, jp.POST_UPDATE DESC
        LIMIT 10;
        """
        cursor.execute(top_query)
        top_10 = cursor.fetchall()
        results["top_10"] = top_10

        cursor.close()
        return {"data": results}

    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
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

# 사용자 프로필 정보를 제공하는 엔드포인트 추가
@app.get("/get_user_profile/")
def get_user_profile(user_id: str):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        # 사용자 프로필 정보 가져오기
        cursor.execute("SELECT NICKNAME, LV, INTRODUCE FROM Users WHERE USER_ID = %s", (user_id,))
        user_data = cursor.fetchone()
        if not user_data:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="User not found")

        # 사용자 이미지 가져오기
        cursor.execute("SELECT IMAGE FROM Users_Image WHERE USER_ID = %s", (user_id,))
        image_data = cursor.fetchone()
        if image_data and image_data['IMAGE']:
            image_url = f"http://{IMAGE_HOST}:{PORT}/images/{image_data['IMAGE']}"
        else:
            image_url = None

        # 팔로워 수 가져오기
        cursor.execute("SELECT COUNT(*) AS follower_count FROM Follow WHERE USER_ID = %s", (user_id,))
        follower_data = cursor.fetchone()
        follower_count = follower_data['follower_count'] if follower_data else 0

        # 팔로잉 수 가져오기
        cursor.execute("SELECT COUNT(*) AS following_count FROM Follow WHERE FOLLOWER = %s", (user_id,))
        following_data = cursor.fetchone()
        following_count = following_data['following_count'] if following_data else 0

        cursor.close()
        conn.close()

        return {
            "nickname": user_data['NICKNAME'],
            "level": user_data['LV'],
            "introduce": user_data['INTRODUCE'],
            "imageUrl": image_url,
            "followerCount": follower_count,
            "followingCount": following_count
        }

    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {e}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=HOST, port=PORT)
