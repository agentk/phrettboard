FROM docker.io/zmkfirmware/zmk-dev-arm:3.5

WORKDIR /app
RUN git clone https://github.com/zmkfirmware/zmk.git

WORKDIR /app/zmk
RUN \
  west init --local app && \
  west update && \
  west zephyr-export

WORKDIR /app/zmk/app

ENTRYPOINT ["bash"]

