FROM ubuntu:24.04

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ARG UID
ARG GID
ARG UNAME

# for proxy
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Setup user and timezone
RUN [ -n "$(id -nu ${UID})" ] && userdel $(id -nu "${UID}") || : && \
    [ -n "$(id -ng ${GID})" ] && groupdel -f $(id -ng "${GID}") || : && \
    useradd -u ${UID} -o -m ${UNAME} && \
    groupmod -g ${GID} ${UNAME} && \
    mkdir -p "/home/${UNAME}" && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

###########################################################
# Setup Node.js repository and update package list
RUN rm -f /etc/apt/sources.list.d/nodesource.list || : && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    rm -rf /tmp/* && \
    apt-get update -y

RUN \
apt-get install -y -o DPkg::options::="--force-confdef" \
python3-full \
python3-pip \
cmake \
gettext \
ninja-build \
libtool \
libtool-bin \
g++ \
pkg-config \
python3-pynvim \
python3-msgpack \
clang \
clangd \
golang-go \
curl \
unzip \
automake \
autoconf \
ca-certificates \
gnupg \
universal-ctags \
gosu \
sudo \
nodejs \
git \
npm \
make \
shellcheck \
socat \
zsh \
tree \
net-tools \
fping \
jq \
iputils-ping \
squashfs-tools \
luarocks \
yacc \
libevent-dev

# install tmux latest
RUN git clone https://github.com/tmux/tmux.git /tmp/tmux && \
cd /tmp/tmux && \
sh autogen.sh && \
./configure && \
make && \
make install && \
cd / && \
rm -rf /tmp/tmux

# install nodejs package
RUN npm install -g \
	neovim \
	clangd \
	bash-language-server \
	vim-language-server \
	pyright \
	diagnostic-languageserver \
	tree-sitter \
	tree-sitter-cli \
	typescript-language-server \
	typescript


# install latest npm and nodejs from n
RUN npm install -g n && \
n latest && \
apt-get purge -y nodejs npm

###########################################################
# Install system tools (Docker) - Low change frequency
###########################################################
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh ./get-docker.sh && \
    rm ./get-docker.sh

###########################################################
# Build Neovim from source - Low change frequency, long build time
###########################################################
RUN apt-get remove -y -o DPkg::options::="--force-confdef" neovim && \
    git clone https://github.com/neovim/neovim.git && \
    make -C neovim CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -C neovim install && \
    rm -rf neovim

###########################################################
# User space tools - Medium to high change frequency
###########################################################
USER "${UNAME}"

# install claude
RUN curl -fsSL https://claude.ai/install.sh | bash

# install Go tools
RUN go install github.com/jesseduffield/lazygit@latest && \
    go install github.com/junegunn/fzf@latest && \
    go install github.com/docker/docker-language-server/cmd/docker-language-server@latest

# install tpm for tmux
RUN mkdir "/home/${UNAME}/.tmux" && \
    git clone https://github.com/tmux-plugins/tpm "/home/${UNAME}/.tmux/plugins/tpm"

# install rust cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# install tools for cargo
ENV PATH=$PATH:/home/${UNAME}/.cargo/bin/
RUN cargo install \
ripgrep \
fd-find \
eza \
bat \
zoxide

RUN rustup component add \
rust-analyzer

# install lua-language-server
RUN git clone https://github.com/LuaLS/lua-language-server ~/lua-language-server && \
cd ~/lua-language-server && \
chmod +x ./make.sh && \
./make.sh

# install tools from pip
RUN pip install --break-system-packages \
autotools-language-server

###########################################################
# Zsh plugins - High change frequency
###########################################################
# install zsh plugins and themes
RUN curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh > /tmp/install.sh && \
    chmod +x /tmp/install.sh && \
    /tmp/install.sh && \
    rm -f /tmp/install.sh && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/mollifier/cd-gitroot ~/.oh-my-zsh/custom/plugins/cd-gitroot && \
    git clone https://github.com/chrissicool/zsh-256color ~/.oh-my-zsh/custom/plugins/zsh-256color && \
    git clone https://github.com/romkatv/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ~/.oh-my-zsh/custom/plugins/zsh-you-should-use && \
    git clone https://github.com/Aloxaf/fzf-tab.git ~/.oh-my-zsh/custom/plugins/fzf-tab && \
    git clone https://github.com/wfxr/forgit.git ~/.oh-my-zsh/custom/plugins/forgit && \
    git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions

###########################################################
# Final configuration
###########################################################
USER root

# Set zsh as default shell
RUN usermod -s /bin/zsh ${UNAME}

# aptのキャッシュと不要なパッケージをクリーンアップ
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
