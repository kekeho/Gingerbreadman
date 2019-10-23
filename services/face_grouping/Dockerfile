# Copyright (c) 2019 Hiroki Takemura (kekeho)
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

FROM python:3.7-slim-stretch

# Install dependencies
COPY ./requirements.txt /
RUN pip install -r requirements.txt

WORKDIR /code
CMD ["python", "face_grouping.py"]
