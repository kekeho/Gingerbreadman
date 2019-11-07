# Gingerbreadman

![gmtitle](docs/logo/gmtitle.svg)  
GUI Tools for Face tacking & Analyze attributes

## Build

Just two steps.

### 1. Clone this repository

```sh
git clone https://github.com/kekeho/gingerbreadman && cd gingerbreadman
```

### 2. Build containers

### CPU

```sh
docker-compose build  # Build containers
docker-compose run -e POSTGRES_PASSWORD=secret db-controller python3.7 manage.py migrate  # migrate DB
```

### GPU

```sh
docker-compose -f docker-compose-gpu.yml build  # Build containers
docker-compose -f docker-compose-gpu.yml run -e POSTGRES_PASSWORD=secret db-controller python3.7 manage.py migrate  # migrate DB
```

## Start

### CPU

```sh
docker-compose up  # Launch containers
```

### GPU

```sh
docker-compose -f docker-compose-gpu.yml up
```


and, open browser [http://localhost:8080](http://localhost:8080)

## Warnings

- **DO NOT BUILD SERVER** of Gingerbreadman.
    This project using non-secure architecture.  
    Please don't open your NAT's port.

## License

MIT [View license file](./LICENSE)
