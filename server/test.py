import requests

# 서버 주소 (로컬에서 FastAPI 서버가 실행 중일 경우)
BASE_URL = "http://127.0.0.1:8000"

def test_get_top_rated_places(page=0):
    """
    /where/top-rated 엔드포인트를 테스트하는 함수.
    :param page: 요청할 페이지 번호 (0이면 1~10번째 장소, 1이면 11~20번째 장소)
    """
    try:
        # 전체 상위 10개의 장소와 각 타입별 장소를 요청하는 URL
        url = f"{BASE_URL}/where/top-rated?page={page}"
        
        # GET 요청을 보내고 응답을 받음
        response = requests.get(url)
        
        # 상태 코드가 200(성공)인지 확인
        if response.status_code == 200:
            # JSON 응답을 딕셔너리로 파싱
            data = response.json()
            
            # 전체 상위 10개 장소 출력
            overall_top_10 = data['data']['overall_top_10']
            print("전체 상위 10개 장소:")
            for place in overall_top_10:
                print(place["WHERE_ID"])  # 딕셔너리 형태로 출력

            # 타입별 상위 장소들 출력 (타입별 딕셔너리)
            by_type = data.get('data', {}).get('by_type', {})
            print("\n타입별 상위 장소들:")
            for place_type, places in by_type.items():
                print(f"\nType: {place_type}")  # 타입 이름 출력
                for place in places:
                    print(place["WHERE_ID"])  # 딕셔너리 형태로 출력
        else:
            print(f"Error: Received status code {response.status_code}")
            print("Response content:", response.content)
    
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # 0번째 페이지 (1~10번째 장소)
    print("==== Testing page 0 (1~10th places) ====")
    test_get_top_rated_places(page=0)
    
    # 1번째 페이지 (11~20번째 장소)
    print("\n==== Testing page 1 (11~20th places) ====")
    test_get_top_rated_places(page=1)
