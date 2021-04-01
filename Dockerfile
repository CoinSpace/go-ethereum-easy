# Build Geth in a stock Go builder container
FROM golang:1.15-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

RUN git clone --depth 1 --branch v1.10.1 https://github.com/ethereum/go-ethereum.git /go-ethereum
RUN sed -i 's/return CalcDifficulty(chain.Config(), time, parent)/return big.NewInt(2)/' /go-ethereum/consensus/ethash/consensus.go
RUN cd /go-ethereum && make geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]
