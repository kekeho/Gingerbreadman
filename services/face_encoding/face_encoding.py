# Copyright (C) 2019 Hiroki Takemura (kekeho)
# 
# This file is part of Gingerbreadman.
# 
# Gingerbreadman is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Gingerbreadman is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Gingerbreadman.  If not, see <http://www.gnu.org/licenses/>.

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
