import requests
import json

# 서버의 베이스 URL
BASE_URL = 'http://localhost:8000'

# 팔로우 토글 API 엔드포인트
TOGGLE_FOLLOW_URL = f'{BASE_URL}/toggle_follow/'

# 팔로우 추가/삭제 테스트 데이터
follow_data = {
    "user_id": "1@1.1",  # 팔로우를 받을 유저의 ID
    "follower_id": "2@1.1"  # 팔로우 하는 유저의 ID
}

# 팔로우 토글 요청 보내기
def toggle_follow(user_id, follower_id):
    # 요청에 보낼 데이터
    data = {
        "user_id": user_id,
        "follower_id": follower_id
    }
    
    try:
        # POST 요청 전송
        response = requests.post(TOGGLE_FOLLOW_URL, headers={'Content-Type': 'application/json'}, data=json.dumps(data))
        
        # 결과 출력
        if response.status_code == 200:
            print("Request successful:")
            print(response.json())  # JSON 결과 출력
        else:
            print(f"Request failed with status code {response.status_code}")
            print(response.json())
    
    except Exception as e:
        print(f"An error occurred: {e}")

# 테스트 실행
if __name__ == "__main__":
    # 팔로우 토글을 테스트
    toggle_follow(follow_data["user_id"], follow_data["follower_id"])
