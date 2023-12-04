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


### SPARK
ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

RUN curl https://dlcdn.apache.org/spark/spark-3.3.3/spark-3.3.3-bin-hadoop3.tgz -o spark-3.3.3-bin-hadoop3.tgz
RUN tar xvzf spark-3.3.3-bin-hadoop3.tgz --directory /opt/spark --strip-components 1
RUN rm -rf spark-3.3.3-bin-hadoop3.tgz

RUN apt-get install -y rsync openjdk-11-jdk

ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_HOME="/opt/spark"
ENV SPARK_MASTER="spark://spark-master:7077"
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

#COPY ./conf/spark-defaults.conf "$SPARK_HOME/conf"
RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*

ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

#### /SPARK

### HMS
WORKDIR /opt

ENV HADOOP_VERSION=3.2.0
ENV METASTORE_VERSION=3.0.0

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin

RUN curl -L https://apache.org/dist/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf -
RUN curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.2.0.tar.gz | tar zxf -
RUN cp mysql-connector-j-8.2.0/mysql-connector-j-8.2.0.jar ${HIVE_HOME}/lib/ 
RUN rm -rf  mysql-connector-j-8.2.0

COPY conf/metastore-site.xml ${HIVE_HOME}/conf

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
EXPOSE 9083
### /HMS

RUN apt-get install -y telnet mysql-server
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
COPY scripts/hive.sql  /docker-entrypoint-initdb.d/

#RUN pip -y install black
#RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

#ADD "https://api.github.com/repos/oleenger/config/commits?per_page=1" latest_commit
#RUN git clone https://github.com/oleenger/config.git ~/.config

#RUN /usr/bin/nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
#RUN /usr/bin/nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

#ENV LANG en_US.UTF-8
#RUN ln ~/.config/tmux/tmux.conf ~/.tmux.conf
#RUN cp ~/.config/bash/bashrc ~/.bashrc

RUN mkdir /opt/spark/logs

ENTRYPOINT ["/bin/sh", "-c", "/entrypoint.sh"]

#USER oleenger
#WORKDIR /home/oleenger
