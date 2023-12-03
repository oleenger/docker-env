FROM ubuntu:devel

RUN apt-get update && \
    apt-get install -y sudo apt-utils curl git-core gnupg tmux zsh wget gcc g++ \
    locales fonts-powerline gh vim pip python3-dev libc-dev libffi-dev graphviz \
    graphviz-dev tmuxinator htop python3-pip apt-transport-https

RUN locale-gen en_US.UTF-8

RUN useradd -m oleenger && echo "oleenger:oleenger" | chpasswd && adduser oleenger sudo

RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz -O /tmp/nvim-linux64.tar.gz
RUN tar xzvf /tmp/nvim-linux64.tar.gz -C /opt
RUN ln -s /opt/nvim-linux64/bin/nvim /usr/bin/nvim

RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
RUN chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
RUN apt-get update
RUN apt-get install -y sbt

#RUN pip -y install black
USER oleenger
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

ADD "https://api.github.com/repos/oleenger/config/commits?per_page=1" latest_commit
RUN git clone https://github.com/oleenger/config.git ~/.config

RUN /usr/bin/nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
RUN /usr/bin/nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

ENV LANG en_US.UTF-8
RUN ln ~/.config/tmux/tmux.conf ~/.tmux.conf
RUN cp ~/.config/bash/bashrc ~/.bashrc

CMD ["/bin/bash"]
WORKDIR /home/oleenger
