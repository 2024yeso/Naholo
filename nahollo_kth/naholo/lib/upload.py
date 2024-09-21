import requests
import json
import os  # os 모듈 임포트

def main():
    # 업로드할 파일의 절대 경로로 변경하세요
    file_path = 'C:/Git/Naholo/nahollo_kth/naholo/lib/images/review1_image2.png'  
    url = 'http://127.0.0.1:8000/upload_image/'  # 서버 주소로 변경하세요

    try:
        # 파일이 존재하는지 확인
        if not os.path.exists(file_path):
            print(f'File not found: {file_path}')
            return

        # 파일 업로드 요청 준비
        with open(file_path, 'rb') as image_file:
            files = {'file': image_file}
            response = requests.post(url, files=files)

        # 요청에 대한 응답 처리
        if response.status_code == 200:
            response_data = response.json()
            print('Image uploaded successfully.')
            print('Image URL:', response_data['image_url'])
        else:
            print(f'Failed to upload image. Status code: {response.status_code}')
            print('Response:', response.text)

    # 예외 처리 추가
    except Exception as e:
        print(f'Error uploading image: {e}')

if __name__ == "__main__":
    main()
