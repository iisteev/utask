FROM node:22 AS js-builder

COPY ./ui /home/node/ui

# dashboard
WORKDIR /home/node/ui/dashboard
RUN BASEHREF=___UTASK_DASHBOARD_BASEHREF___ PREFIX_API_BASE_URL=___UTASK_DASHBOARD_PREFIXAPIBASEURL___ SENTRY_DSN=___UTASK_DASHBOARD_SENTRY_DSN___ make build-prod

FROM golang:1.24

COPY .  /go/src/github.com/ovh/utask
WORKDIR /go/src/github.com/ovh/utask
RUN make re && make makefile && \
    mkdir -p /app/plugins /app/templates /app/config /app/init /app/static/dashboard && \
    mv hack/wait-for-it/wait-for-it.sh /wait-for-it.sh && \
    chmod +x /wait-for-it.sh && \
    go clean -cache && rm -rf /go/pkg/*
WORKDIR /app

COPY --from=js-builder /home/node/ui/dashboard/dist/utask-ui/  /app/static/dashboard/

RUN cp /go/src/github.com/ovh/utask/utask /app/utask && \
    chmod +x /app/utask && \
    cp -r /go/src/github.com/ovh/utask/ui/swagger-ui /app/static/swagger-ui

EXPOSE 8081

CMD ["/app/utask"]
