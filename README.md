# Gingerbreadman

![gmtitle](docs/logo/gmtitle.svg)  
GUI Tools for Face tacking & Analyze attributes

## Let's start

Just two steps.

### 1. Clone this repository

```sh
git clone https://github.com/kekeho/gingerbreadman && cd gingerbreadman
```


### 2. Launch containers

#### CPU

```sh
docker-compose up  # Launch containers
```

#### GPU

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
