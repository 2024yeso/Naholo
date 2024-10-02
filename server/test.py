import requests
import json

# FastAPI 서버의 기본 URL
BASE_URL = "http://127.0.0.1:8000"

# 출석 체크 테스트 함수
import requests

# 서버에 출석 체크 요청 보내기
url = "http://localhost:8000/attendance/check"
data = {
    "username": "john_doe"
}

response = requests.post(url, json=data)

# 응답을 JSON으로 변환
response_data = response.json()

# 키에 해당하는 밸류값 출력
message = response_data.get('message')
attendance_dates = response_data.get('attendance_dates')

print(f"Message: {message}")
print(f"Attendance Dates: {attendance_dates}")
