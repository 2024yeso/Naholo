import requests

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

# 각 테스트 함수 호출
if __name__ == "__main__":
    print("=== Testing ID Check ===")
    check_id()
    print("\n=== Testing User Registration ===")
    test_add_user()
    print("\n=== Testing Login Success ===")
    test_login_success()
    print("\n=== Testing Login Failure (Wrong Password) ===")
    test_login_failure_wrong_password()
    print("\n=== Testing Login Failure (Nonexistent User) ===")
    test_login_failure_nonexistent_user()