# Base image
FROM quay.io/jupyter/base-notebook:2024-12-31

# Executar comandos como root
USER root

# Instalar dependências do sistema
RUN apt-get update -qq && apt-get install -y -qq \
        dbus-x11 \
        xclip \
        xfce4 \
        xfce4-panel \
        xfce4-session \
        xfce4-settings \
        xorg \
        xubuntu-icon-theme \
        fonts-dejavu \
        tigervnc-standalone-server \
        wget \
        git && \
    apt-get remove -y -qq xfce4-screensaver && \
    rm -rf /var/lib/apt/lists/*

# Baixar e instalar o Firefox diretamente usando wget
RUN wget -q "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=pt-BR" -O /opt/firefox.tar.bz2 && \
    tar -xjf /opt/firefox.tar.bz2 -C /opt && \
    rm /opt/firefox.tar.bz2

# Criar atalho para o Firefox no ambiente gráfico
RUN echo "[Desktop Entry]\n\
Version=1.0\n\
Name=Firefox Browser\n\
Exec=/opt/firefox/firefox %u\n\
Icon=/opt/firefox/browser/chrome/icons/default/default128.png\n\
Type=Application\n\
Categories=Network;WebBrowser;\n\
StartupNotify=true" > /usr/share/applications/firefox.desktop

# Corrigir permissões e criar diretórios adicionais
RUN mkdir -p /opt/install && \
    chown -R $NB_UID:$NB_GID $HOME /opt/install

# Instalar pacotes adicionais no ambiente Conda
COPY --chown=$NB_UID:$NB_GID environment.yml /tmp
RUN . /opt/conda/bin/activate && \
    mamba env update --quiet --file /tmp/environment.yml && \
    mamba install -y -q "nodejs>=22" && \
    pip install -r /opt/install/requirements.txt && \
    rm /tmp/environment.yml

# Copiar o repositório e scripts para o contêiner
COPY --chown=$NB_UID:$NB_GID . /opt/install
RUN fix-permissions /opt/install

# Retornar ao usuário padrão
USER $NB_USER
