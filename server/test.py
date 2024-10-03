import requests
import json

# FastAPI 서버 URL 설정 (서버가 로컬에서 실행 중인 경우)
BASE_URL = "http://localhost:8000"


# 좋아요 추가/삭제 요청 데이터
data = {
    "user_id": "1@1.1",
    "where_id": "ChIJ48ESEIxEezURC3J0WBPC1hg"
}

# 엔드포인트 URL
url = f"{BASE_URL}/toggle_like"

# 요청 보내기
try:
    response = requests.post(url, headers={'Content-Type': 'application/json'}, data=json.dumps(data))
    response.raise_for_status()  # 응답 코드가 200이 아닌 경우 예외 처리

    # 응답 데이터를 출력
    print(response.json())

except requests.exceptions.HTTPError as err:
    print(f"HTTP error occurred: {err}")
except Exception as e:
    print(f"An error occurred: {e}")


# 엔드포인트 URL
url = f"{BASE_URL}/user_likes/1@1.1"


# 테스트할 유저 ID
user_id = "1@1.1"

# 요청 보내기
try:
    response = requests.get(url)
    response.raise_for_status()  # 응답 코드가 200이 아닌 경우 예외 처리

    # 응답 데이터를 JSON으로 변환
    data = response.json()

    # 응답 출력
    print(json.dumps(data, indent=4, ensure_ascii=False))

except requests.exceptions.HTTPError as err:
    print(f"HTTP error occurred: {err}")
except Exception as e:
    print(f"An error occurred: {e}")
