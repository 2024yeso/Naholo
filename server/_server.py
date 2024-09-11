from fastapi import FastAPI, HTTPException, status, Depends
from pydantic import BaseModel
import mysql.connector
from mysql.connector.errors import IntegrityError
from typing import Optional

app = FastAPI()

# MySQL 연결 설정
db_config = {
    'user': 'root',
    'password': '1557',
    'host': 'localhost',
    'database': 'naholo_db',
    'port': 3306
}

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
    IMAGE: Optional[int] = None

class Follow(BaseModel):
    USER_ID: str
    FOLLOWER: str

class Like(BaseModel):
    USER_ID: str
    WHERE_ID: int

class UsersImage(BaseModel):
    USER_ID: str
    IMAGE: str

class Where(BaseModel):
    WHERE_NAME: str
    WHERE_LOCATE: str
    WHERE_RATE: float
    WHERE_TYPE: str

class JournalComment(BaseModel):
    POST_ID: int
    COMMENT_CONTENT: str
    USER_ID: str

class ReviewImage(BaseModel):
    REVIEW_ID: int
    IMAGE: str

class WhereReview(BaseModel):
    USER_ID: str
    WHERE_ID: int
    REVIEW_CONTENT: str
    WHERE_LIKE: int
    WHERE_RATE: float

class WhereImage(BaseModel):
    WHERE_ID: int
    IMAGE: str

class JournalImage(BaseModel):
    POST_ID: int
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
        w.WHERE_NAME,
        w.WHERE_LOCATE,
        wr.REVIEW_CONTENT,
        wr.WHERE_RATE,
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
    
    return review_list
        
# 좋아요 호출 함수
def call_wanted(user_id):
    query = """
    SELECT 
        w.WHERE_NAME,
        w.WHERE_LOCATE,
        w.WHERE_RATE,
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


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
