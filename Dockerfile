# Use a imagem base do Jupyter
FROM quay.io/jupyter/base-notebook:2024-12-31

# Mude para o usuário root para instalar pacotes
USER root

# Atualize e instale pacotes necessários
RUN apt-get -y -qq update && apt-get -y -qq install \
        dbus-x11 \
        xclip \
        xfce4 \
        xfce4-panel \
        xfce4-session \
        xfce4-settings \
        xorg \
        xubuntu-icon-theme \
        fonts-dejavu \
        openjdk-11-jdk \
        scala \
        wget \
        tigervnc-standalone-server \
        curl \
 && apt-get -y -qq remove xfce4-screensaver \
 && rm -rf /var/lib/apt/lists/*

# Instale o SBT (Scala Build Tool)
RUN curl -sL https://github.com/sbt/sbt/releases/download/v1.8.0/sbt-1.8.0.deb -o sbt.deb && \
    dpkg -i sbt.deb && rm sbt.deb

# Configuração de ambiente para Java e SBT
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:/usr/local/sbt/bin

# Clonar e configurar o repositório Storch
WORKDIR /home/jovyan
RUN git clone https://github.com/GabrielCriste/storch.git
WORKDIR /home/jovyan/storch
RUN sbt compile

# Instalar o kernel Almond para Scala no Jupyter
RUN curl -Lo coursier https://git.io/coursier-cli && \
    chmod +x coursier && \
    ./coursier launch --fork almond -- --install && \
    rm coursier

# Configurar o ambiente Conda e instalar dependências
USER $NB_USER
COPY --chown=$NB_UID:$NB_GID environment.yml /tmp
RUN conda env update --quiet --file /tmp/environment.yml && \
    conda clean -afy

# Copiar o código do Jupyter Remote Desktop Proxy
COPY --chown=$NB_UID:$NB_GID . /opt/install
RUN mamba install -y -q "nodejs>=22" && \
    pip install /opt/install

# Configurar permissões e limpar diretórios
USER root
RUN chown -R $NB_UID:$NB_GID $HOME /opt/install && \
    rm -rf /tmp/*

# Expor portas para Jupyter e Desktop remoto
EXPOSE 8888
EXPOSE 5900

# Definir o comando de inicialização
CMD ["start.sh"]
