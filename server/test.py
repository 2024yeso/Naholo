import requests
import json

# 서버 주소와 포트
BASE_URL = "http://127.0.0.1:8000"

#중복 id 테스트
def check_id():
    params = {
        "user_id":"user123"
    }
    response = requests.get(f"{BASE_URL}/check_id/", params=params)
    
    if response.status_code == 200:
        print("중복 ID 여부", response.json()["available"])
    else:
        print("Test Login Failed:", response.status_code, response.json())

def test_add_user():
    # 회원가입 테스트
    data = {
        "USER_ID": "test_user",
        "USER_PW": "password123",
        "NAME": "Test User",
        "PHONE": "010-1234-5678",
        "BIRTH": "1990-01-01",
        "GENDER": True,
        "NICKNAME": "Tester",
        "USER_CHARACTER": "Hero",
        "LV": 1,
        "INTRODUCE": "Hello, I am a test user!",
        "IMAGE": 1
    }
    response = requests.post(f"{BASE_URL}/add_user/", json=data)
    print("Add User Response:", response.json())

def test_login_success():
    # 로그인 성공 테스트
    params = {
        "user_id": "test_user",
        "user_pw": "password123"
    }
    response = requests.get(f"{BASE_URL}/login/", params=params)
    print("Login Success Response:", response.json())

def test_login_failure_wrong_password():
    # 잘못된 비밀번호로 로그인 실패 테스트
    params = {
        "user_id": "test_user",
        "user_pw": "wrongpassword"
    }
    response = requests.get(f"{BASE_URL}/login/", params=params)
    print("Login Failure (Wrong Password) Response:", response.json())

def test_login_failure_nonexistent_user():
    # 존재하지 않는 사용자로 로그인 실패 테스트
    params = {
        "user_id": "nonexistent_user",
        "user_pw": "password123"
    }
    response = requests.get(f"{BASE_URL}/login/", params=params)
    print("Login Failure (Nonexistent User) Response:", response.json())
    
import urllib.parse    
BASE_URL = 'http://127.0.0.1:8000'  # Adjust as necessary

def test_get_journal():
    try:
        user_id = '1@1.1'
        response = requests.get(BASE_URL + "/user/journal/", params={'user_id': user_id})
        print(response.status_code)
        if response.status_code == 200:
            print("Request successful!")
            print("Response Data:")
            print(json.dumps(response.json(), indent=4))
        else:
            print(f"Failed to get data. Status Code: {response.status_code}")
            print("Response Text:", response.text)
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")

# 각 테스트 함수 호출
if __name__ == "__main__":
    print("=== Testing ID Check ===")
    test_get_journal()