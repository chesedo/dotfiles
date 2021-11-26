FROM alpine

RUN apk add --no-cache \
  # To install neovim provider
  py3-pip \
  # The neovim provider
  npm \
  # Required by the neovim provider for pip in neovim setup script
  gcc g++ python3-dev musl-dev \
  # Needed by my own neovim setup script
  git curl \
  # Needed by neovim plugins
  ripgrep

# Needed by some packages.json
RUN apk add --no-cache make

RUN apk add --no-cache neovim --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
RUN npm install -g typescript typescript-language-server
RUN pip3 install pynvim
RUN npm install -g neovim

RUN addgroup -g 1000 -S developer && \
    adduser -u 1000 -S developer -G developer
USER developer

WORKDIR /src

CMD nvim
