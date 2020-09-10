# R-WHILE_Quick_Start
Dockerfile building a r-while environment using [r-while-web](https://github.com/yokoyama-lab/r-while-web/tree/master).

## Usage
1. Create `.env` in `./src` to copy `.env.example`.
```
cp ./src/.env.example ./src/.env
```

2. Edit `.env` according to your environment.
```
APP_URL=`your domain`

DB_HOST=`your domain`
```

3. Build an image from this Dockerfile.
```
docker build -t rwhile .
```

4. Start a rwhile container. At this time, map port 80 in the container to appropriate port on the Docker host (e.g.: port 80).
```
docker run -it -d --name rwhile_container -p 80:80 rwhile
```

5.  Access localhost:port-number from an internet browser (e.g.: localhost:80).

