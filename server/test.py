import requests
import json

# FastAPI 서버 URL 설정 (서버가 로컬에서 실행 중일 때)
BASE_URL = "http://localhost:8000"

# 테스트할 user_id
user_id = "1@1.1"

# 엔드포인트 URL
url = f"{BASE_URL}/user_journals/{user_id}"

# API 요청 보내기
def test_user_journals():
    try:
        # GET 요청 보내기
        response = requests.get(url)
        
        # 상태 코드가 200이 아니면 예외 발생
        response.raise_for_status()
        
        # JSON 응답 데이터 파싱
        data = response.json()
        
        # 응답 출력
        print(json.dumps(data, indent=4, ensure_ascii=False))

    except requests.exceptions.HTTPError as err:
        print(f"HTTP error occurred: {err}")
    except Exception as e:
        print(f"An error occurred: {e}")

# 테스트 함수 실행
if __name__ == "__main__":
    test_user_journals()
