FROM ubuntu:devel

RUN apt-get update && \
    apt-get install -y sudo apt-utils curl git-core gnupg tmux zsh wget gcc g++ \
    locales fonts-powerline gh vim pip python3-dev libc-dev libffi-dev graphviz \
    graphviz-dev tmuxinator htop

RUN locale-gen en_US.UTF-8

RUN useradd -m oleenger && echo "oleenger:oleenger" | chpasswd && adduser oleenger sudo

RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb
RUN apt install ./nvim-linux64.deb

USER oleenger
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

ADD "https://api.github.com/repos/oleenger/config/commits?per_page=1" latest_commit
RUN git clone https://github.com/oleenger/config.git ~/.config


RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

ENV LANG en_US.UTF-8
RUN ln ~/.config/tmux/tmux.conf ~/.tmux.conf
RUN cp ~/.config/bash/bashrc ~/.bashrc

CMD ["/bin/bash"]
WORKDIR /home/oleenger
