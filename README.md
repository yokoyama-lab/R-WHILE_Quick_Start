# R-WHILE_Quick_Start
Dockerfile building a r-while environment using [r-while-web](https://github.com/yokoyama-lab/r-while-web/tree/master).

## Usage
1. Build an image from this Dockerfile.
```
docker build -t rwhile .
```

2. Start a rwhile container. At this time, map port 80 in the container to appropriate port on the Docker host (e.g.: port 80).
```
docker run -it -d --name rwhile_container -p 80:80 rwhile
```

3.  Access localhost:port-number from an internet browser (e.g.: localhost:80).

