# Base image
FROM quay.io/jupyter/base-notebook:2024-12-31

# Executar comandos como root
USER root

# Instalar dependências do sistema
RUN apt-get -y -qq update \
 && apt-get -y -qq install \
        dbus-x11 \
        xclip \
        xfce4 \
        xfce4-panel \
        xfce4-session \
        xfce4-settings \
        xorg \
        xubuntu-icon-theme \
        fonts-dejavu \
        git \
        wget \
    # Desabilitar o bloqueio automático de tela
 && apt-get -y -qq remove xfce4-screensaver \
    # Corrigir permissões e criar diretório para pacotes adicionais
 && mkdir -p /opt/install \
 && chown -R $NB_UID:$NB_GID $HOME /opt/install \
 && rm -rf /var/lib/apt/lists/*

# Baixar e instalar o Firefox diretamente
RUN wget -q "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=pt-BR" -O /opt/firefox.tar.bz2 \
    && tar -xjf /opt/firefox.tar.bz2 -C /opt \
    && rm /opt/firefox.tar.bz2

# Criar atalho para o Firefox no ambiente gráfico
RUN echo "[Desktop Entry]\n\
Version=1.0\n\
Name=Firefox Browser\n\
Exec=/opt/firefox/firefox %u\n\
Icon=/opt/firefox/browser/chrome/icons/default/default128.png\n\
Type=Application\n\
Categories=Network;WebBrowser;\n\
StartupNotify=true" \
    > /usr/share/applications/firefox.desktop

# Instalar servidor VNC (TigerVNC como padrão)
RUN apt-get -y -qq update \
 && apt-get -y -qq install tigervnc-standalone-server \
 && rm -rf /var/lib/apt/lists/*

# Instalar TurboVNC manualmente usando o pacote .deb
RUN wget https://sourceforge.net/projects/turbovnc/files/latest/download -O /tmp/turbovnc.deb \
    && apt-get install -y /tmp/turbovnc.deb \
    && rm /tmp/turbovnc.deb

# Configurar TurboVNC no PATH
ENV PATH="/opt/TurboVNC/bin:$PATH"

# Corrigir permissões no diretório do usuário
RUN chown -R $NB_UID:$NB_GID $HOME

# Adicionar scripts e pacotes adicionais
ADD . /opt/install
RUN fix-permissions /opt/install

# Retornar ao usuário padrão
USER $NB_USER

# Atualizar o ambiente Conda e instalar pacotes Python
COPY --chown=$NB_UID:$NB_GID environment.yml /tmp/environment.yml
RUN mamba env update --quiet --file /tmp/environment.yml && \
    mamba clean -a -f -y

# Copiar o repositório para o contêiner
COPY --chown=$NB_UID:$NB_GID . /opt/install
RUN pip install --no-cache-dir /opt/install

# Copiar o script de monitoramento para o contêiner
COPY --chown=$NB_UID:$NB_GID monitor.py /opt/install/monitor.py

# Configurar inicialização do VNC e ambiente gráfico
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Comando padrão do contêiner
CMD ["start.sh"]
