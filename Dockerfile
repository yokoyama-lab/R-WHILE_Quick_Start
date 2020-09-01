FROM php:7.4-apache
MAINTAINER yokoyama-lab

# system setting
RUN apt-get update \
    && apt-get -y autoremove \
    && apt-get install -y sudo \ 
    && usermod -u 1000 www-data \
    && groupmod -g 1000 www-data \
    && mkdir /home/www-data \
    && chown -hR www-data:www-data /home/www-data \
    && usermod -d /home/www-data www-data

# sudo setting
ADD sudoers /etc

# change user
USER www-data

# install opam (extlib & ocamlfind)
RUN sudo apt-get install -y --no-install-recommends opam \
    && opam init -y --disable-sandboxing \
    && eval `opam config env` \
    && eval $(opam env) \
    && opam update \
    && opam switch \
    && opam install -y extlib ocamlfind

# install haskell (BNFC)
RUN sudo apt-get install -y --no-install-recommends haskell-platform \
    && cabal update \
    && cabal install BNFC

# copy R-WHILE source
COPY ./rwhile/src /var/www/html/src
COPY ./rwhile/web /var/www/html/

# setup R-WHILE
RUN echo 'export LANG=C.UTF-8' >> ./.bashrc \
    && echo 'export LANGUAGE="C.UTF-8"' >> ./.bashrc \
    && . ./.bashrc \
    && eval `opam config env` \
    && eval $(opam env) \
    && sudo ln -s /home/www-data/.cabal/bin/bnfc /usr/local/bin/bnfc \
    && cd /var/www/html/src \
    && sudo make install \
    && cd /var/www/html/ \
    && sudo mkdir data programs \
    && sudo chmod 777 data \
    && sudo chmod 777 programs \
    && sudo rm -rf /var/www/html/src 

# change user
USER root

# clear cache
RUN apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*
