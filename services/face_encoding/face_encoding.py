import time
from lib import utils


def main():
    while True:
        analyzer = utils.EncodingAnalzyer(
            'db-controller', 8888, 'get_unanalyzed_face_encodings/', 'regist_face_encodings/'
        )
        analyzer.analyze_face_encodings()
        count = analyzer.regist()

        if count > 0:
            print(f'Analyzed {count} images')
        
        time.sleep(5)

if __name__ == "__main__":
    main()
