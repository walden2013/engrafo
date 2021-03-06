# Version from https://hub.docker.com/_/debian/
FROM debian:testing-20181011

# LaTeX stuff first, because it's enormous and doesn't change much
# Change logs here: https://packages.debian.org/buster/texlive-full
RUN apt-get update -qq && apt-get install -qy texlive-full=2018.20181009*

RUN apt-get update -qq && apt-get install -qy curl gnupg2 \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    # runs apt-get update for us \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -qy \
    # Node.js dependencies \
    ca-certificates \
    nodejs=8.12.0* \
    git-core \
    yarn=1.10.* \
    # latexml dependencies \
    libarchive-zip-perl libfile-which-perl libimage-size-perl  \
    libio-string-perl libjson-xs-perl libtext-unidecode-perl \
    libparse-recdescent-perl liburi-perl libuuid-tiny-perl libwww-perl \
    libxml2 libxml-libxml-perl libxslt1.1 libxml-libxslt-perl  \
    imagemagick libimage-magick-perl perl-doc build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/latexml
WORKDIR /usr/src/latexml
ENV LATEXML_COMMIT=2af9ee02cdcbc50cde5ec68bdc0100e07a866a9e
RUN curl -L https://github.com/brucemiller/LaTeXML/tarball/$LATEXML_COMMIT | tar --strip-components 1 -zxf - \
    && perl Makefile.PL \
    && make \
    && make install

RUN mkdir -p /app
WORKDIR /app

# Node
COPY package.json yarn.lock /app/
RUN yarn install --pure-lockfile && yarn cache clean

ENV PATH="/app/bin:/app/node_modules/.bin:${PATH}"

COPY . /app

# Build production CSS and JS
RUN yarn run build
