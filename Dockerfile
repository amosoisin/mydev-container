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

# Remove user
RUN [ -n "$(id -nu ${UID})" ] && userdel $(id -nu "${UID}") || :
RUN [ -n "$(id -ng ${GID})" ] && groupdel -f $(id -ng "${GID}") || :

# Add user
RUN useradd -u ${UID} -o -m ${UNAME}
RUN groupmod -g ${GID} ${UNAME}
RUN mkdir -p "/home/${UNAME}"

# zoneinfo
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

###########################################################
# install for neovim
RUN rm /etc/apt/sources.list.d/nodesource.list || :
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt update -y

RUN \
apt install -y -o DPkg::options::="--force-confdef" \
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
libtool \
libtool-bin \
ca-certificates \
gnupg \
universal-ctags \
gosu \
sudo \
nodejs \
git \
npm \
zsh \
make \
shellcheck \
socat

# install latest npm and nodejs from n
RUN npm install -n g && \
n latest && \
apt purge -y nodejs npm

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

USER "${UNAME}"

# install lazygit
RUN go install github.com/jesseduffield/lazygit@latest

# install fzf
RUN go install github.com/junegunn/fzf@latest

# install tpm for tmux
RUN \
mkdir "/home/${UNAME}/.tmux" && \
git clone https://github.com/tmux-plugins/tpm "/home/${UNAME}/.tmux/plugins/tpm"

# install rust cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# install tools for cargo
ENV CARGO=/home/${UNAME}/.cargo/bin/cargo
RUN ${CARGO} install ripgrep

# install zsh plugins and themes
RUN curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh > /tmp/install.sh
RUN chmod +x /tmp/install.sh && /tmp/install.sh
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/mollifier/cd-gitroot ~/.oh-my-zsh/custom/plugins/cd-gitroot
RUN git clone https://github.com/chrissicool/zsh-256color ~/.oh-my-zsh/custom/plugins/zsh-256color
RUN git clone https://github.com/romkatv/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k
RUN git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ~/.oh-my-zsh/custom/plugins/zsh-you-should-use

USER root

# remove neovim package and install neovim manually
RUN \
apt remove -y -o DPkg::options::="--force-confdef" \
neovim

# install neovim
RUN \
git clone https://github.com/neovim/neovim.git && \
make -C neovim CMAKE_BUILD_TYPE=RelWithDebInfo && \
make -C neovim install && \
rm -rf neovim
###########################################################

###########################################################
# for console
RUN \
apt install -y -o DPkg::options::="--force-confdef" \
zsh \
tmux

RUN usermod -s /bin/zsh ${UNAME}
###########################################################

###########################################################
# get-docker
RUN \
curl -fsSL https://get.docker.com -o get-docker.sh && \
sh ./get-docker.sh && \
rm ./get-docker.sh

###########################################################

###########################################################
# others
RUN \
apt install -y -o DPkg::options::="--force-confdef" \
tree \
net-tools \
fping \
jq \
iputils-ping \
squashfs-tools \
luarocks
###########################################################

# aptのキャッシュをクリーンアップ
RUN apt clean; \
rm -rf /var/lib/apt/lists/*
