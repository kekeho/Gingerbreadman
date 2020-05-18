<!--
 Copyright (c) 2020 Hiroki Takemura (kekeho)
 
 This software is released under the MIT License.
 https://opensource.org/licenses/MIT
-->

# Build and Launch

In advance, you should clone the repository and enter directory by following the steps below.

```sh
git clone https://github.com/kekeho/gingerbreadman
cd gingerbreadman
```

## Server

Just three steps.

### 1. Build

```sh
docker-compose build  # CPU only
docker-compose -f docker-compose-gpu.yml build  # with Nvidia GPU
```

### 2. Set Password to Database

```sh
echo "DB_PASSWORD=password" > .env
```

### 3. Launch

```sh
docker-compose up  # CPU only
docker-compose -f docker-compose-gpu.yml up  # with Nvidia GPU
```

## Front

### 1. Init

```sh
cd ./front
npm init
```

### 2. Build

os: "linux" or "mac" or "win"

```sh
npm run build:[os]
```

## Worker

### 1. Build

```sh
docker-compose -f docker-compose-worker.yml build  # amd64
docker-compose -f docker-compose-worker-arm.yml build  # arm (tested on raspberry pi 3 64bit)

# arm with GPU (tested on jetson nano)
xargs -n 1 cp /usr/lib/aarch64-linux-gnu/libcudnn.so <<< "./service/face_location ./service/face_encoding"
docker-compose -f docker-compose-worker-arm-gpu.yml build
```

### 2. Config

Edit `worker.env`

```env
NGINX_HOST=192.168.x.x
NGINX_PORT=8000
```

### 3. Launch

```sh
docker-compose -f docker-compose-worker.yml up  # amd64
docker-compose -f docker-compose-worker-arm.yml up  # arm (tested on raspberry pi 3 64bit)
docker-compose -f docker-compose-worker-arm-gpu.yml up  # arm with GPU (tested on jetson nano)
```
