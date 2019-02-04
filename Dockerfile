FROM rust:1 AS builder

RUN rustup target add x86_64-unknown-linux-musl

COPY . /opt/sekursranko/

RUN cd /opt/sekursranko \
&&  cargo build --release --target x86_64-unknown-linux-musl

FROM alpine:3.9

RUN mkdir /sekursranko/ \
&&  addgroup -S sekursranko \
&&  adduser -S -G sekursranko sekursranko \
&&  chown sekursranko:sekursranko /sekursranko/ \
&&  chmod 0700 /sekursranko/

VOLUME [ "/sekursranko" ]

COPY --from=builder /opt/sekursranko/target/x86_64-unknown-linux-musl/release/sekursranko /usr/local/bin/sekursranko
COPY --from=builder /opt/sekursranko/config.example.toml /etc/sekursranko/config.toml

RUN sed -i '/listen_on/s/127.0.0.1/[::]/' /etc/sekursranko/config.toml \
&&  sed -i '/backup_dir/c\backup_dir = "/sekursranko/"' /etc/sekursranko/config.toml

WORKDIR /sekursranko

USER sekursranko

CMD [ "sekursranko", "--config", "/etc/sekursranko/config.toml" ]
