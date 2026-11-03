FROM debian:13-slim

ARG DEBIAN_FRONTEND=noninteractive

USER root
RUN \
	apt-get -y update && \
	# Install required utilities and Flutter Linux/Web dependencies
	apt-get -y install --no-install-recommends \
		locales apt-transport-https ca-certificates curl gnupg htop make nano \
		openssh-client openssl pinentry-curses pinentry-tty sudo unzip wget \
		zip zsh bat git git-flow xz-utils libglu1-mesa clang cmake \
		ninja-build pkg-config libgtk-3-dev && \
	# Configure locale
	echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen && \
	# Refresh & upgrade packages
	apt-get -y update && apt-get -y upgrade && \
	# Clean apt cache
	apt-get -y clean && apt-get -y autoremove && \
	# Create user web (UID 1000)
	useradd -s /bin/zsh -m -d /home/web -U -u 1000 web && \
	usermod --password $(echo web | openssl passwd -1 -stdin) web && \
	usermod -aG sudo web && \
	mkdir -p /etc/sudoers.d && \
	echo 'web ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/web && \
	mkdir -p /home/web/sites/cloud/UPN-INVENTARIO2 /home/web/.vscode-server /home/web/.pub-cache /home/web/.gnupg && \
	chmod 700 /home/web/.gnupg && \
	chown -R web:web /home/web && \
	# Starship prompt
	curl -sS https://starship.rs/install.sh | sh -s -- --yes

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV FLUTTER_HOME=/home/web/flutter
ENV PUB_CACHE=/home/web/.pub-cache
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PUB_CACHE}/bin:${PATH}"

USER web
RUN \
	mkdir -p /home/web/.config /home/web/.zsh && \
	printf 'alias bat="batcat -P"\n\n' >> /home/web/.zshrc && \
	# Setup .zsh history
	printf 'HISTFILE="$HOME/.zsh_history"\nHISTSIZE=500000\nSAVEHIST=500000\nsetopt EXTENDED_HISTORY\nsetopt INC_APPEND_HISTORY\nsetopt SHARE_HISTORY\nsetopt HIST_EXPIRE_DUPS_FIRST\nsetopt HIST_IGNORE_DUPS\nsetopt HIST_IGNORE_ALL_DUPS\nsetopt HIST_FIND_NO_DUPS\nsetopt HIST_IGNORE_SPACE\nsetopt HIST_SAVE_NO_DUPS\nsetopt HIST_REDUCE_BLANKS\nsetopt HIST_VERIFY\nsetopt HIST_BEEP\n\n' >> /home/web/.zshrc && \
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions && \
	printf 'source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh\n\n' >> /home/web/.zshrc && \
	git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting && \
	printf 'source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\n\n' >> /home/web/.zshrc && \
	# Install Flutter SDK (stable)
	git clone https://github.com/flutter/flutter.git -b stable --depth 1 /home/web/flutter && \
	printf 'export FLUTTER_HOME="$HOME/flutter"\nexport PUB_CACHE="$HOME/.pub-cache"\nexport PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PUB_CACHE/bin:$PATH"\nexport GPG_TTY=$(tty)\n\n' >> /home/web/.zshrc && \
	flutter config --no-analytics && \
	flutter config --enable-web && \
	flutter precache --web && \
	# Init starship
	wget -O /home/web/.config/starship.toml https://starship.rs/presets/toml/gruvbox-rainbow.toml && \
	printf 'eval "$(starship init zsh)"\n\n' >> /home/web/.zshrc

EXPOSE 8080
