# Copyright (c) 2019 Hiroki Takemura (kekeho)
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import time
from lib import utils


def main():
    while True:
        analyzer = utils.LocationAnalzyer(
            'redis', 'db-controller', 8888,'/get_unanalyzed_face_location_images/', '/regist_faces/')
        analyzer.analyze_face_locations()
        count = analyzer.regist()

        if count > 0:
            print(f"Analyzed {count} images")

        time.sleep(5)


if __name__ == "__main__":
    main()
