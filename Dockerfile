FROM alpine:3.12 as frontend

RUN apk add --no-cache \
  npm

RUN npm install -g @angular/cli

WORKDIR /build
COPY [ "package.json", "package-lock.json", "/build/" ]
RUN npm install

COPY [ "angular.json", "tsconfig.json", "/build/" ]
COPY [ "src/", "/build/src/" ]
RUN ng build --prod

#--------------#

FROM alpine:3.12

ENV UID=1000 \
  GID=1000 \
  USER=youtube

ENV NO_UPDATE_NOTIFIER=true
ENV FOREVER_ROOT=/app/.forever

RUN addgroup -S $USER -g $GID && adduser -D -S $USER -G $USER -u $UID

RUN apk add --no-cache \
  ffmpeg \
  npm \
  python2 \
  python3 \
  su-exec \
  && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    atomicparsley

WORKDIR /app
COPY --chown=$UID:$GID [ "backend/package.json", "backend/package-lock.json", "/app/" ]
RUN npm install forever -g
RUN npm install && chown -R $UID:$GID ./

COPY --chown=$UID:$GID --from=frontend [ "/build/backend/public/", "/app/public/" ]
COPY --chown=$UID:$GID [ "/backend/", "/app/" ]

ENTRYPOINT [ "/app/backend/entrypoint.sh" ]
CMD [ "forever", "app.js" ]
