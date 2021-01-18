FROM php:7.4-apache
LABEL key="yokoyama-lab"

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
#ADD sudoers /etc
RUN echo 'www-data  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

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

# install composer
RUN cd /home/www-data \
    && curl -sS https://getcomposer.org/installer | php

# sqlite setting for laravel
RUN mkdir /home/www-data/database \
    && touch /home/www-data/database/database.sqlite

# copy R-WHILE source
COPY --chown=www-data:www-data ./r-while /home/www-data/laravel/R-WHILE
COPY --chown=www-data:www-data ./src/.env /home/www-data/laravel/R-WHILE
COPY --chown=www-data:www-data ./src/index.php /home/www-data/laravel/R-WHILE/public

# compile R-WHILE
RUN echo 'export LANG=C.UTF-8' >> ./.bashrc \
    && echo 'export LANGUAGE="C.UTF-8"' >> ./.bashrc \
    && . ./.bashrc \
    && eval `opam config env` \
    && eval $(opam env) \
    && sudo ln -s /home/www-data/.cabal/bin/bnfc /usr/local/bin/bnfc \
    && cd /home/www-data/laravel/R-WHILE/src \
    && PATH=/home/www-data/.opam/default/bin:"$PATH" make \
    && sudo make install

# setting r-while-web
RUN cp -r /home/www-data/laravel/R-WHILE/public/* /var/www/html \
    && cd /home/www-data/laravel/R-WHILE \
    && /home/www-data/composer.phar update \
    && /home/www-data/composer.phar install \
    && php artisan key:generate \
    && php artisan config:clear \
    && cd /var/www/html/ \
    && sudo chmod 777 data \
    && sudo chmod 777 programs 
COPY ./src/.htaccess /var/www/html

# change user
USER root

# setting apache2
COPY ./src/apache2.conf /etc/apache2
RUN /usr/sbin/a2enmod rewrite 
#&& /etc/init.d/apache2 reload

# clear cache
RUN apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*