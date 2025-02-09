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
        make \
     
    # Desabilitar o bloqueio automático de tela
 && apt-get -y -qq remove xfce4-screensaver \
    # Corrigir permissões e criar diretório para pacotes adicionais
 && mkdir -p /opt/install \
 && chown -R root:root $HOME /opt/install \
 && rm -rf /var/lib/apt/lists/*

# Instalar servidor VNC (TigerVNC como padrão)
RUN apt-get -y -qq update && apt-get -y -qq install tigervnc-standalone-server && \
    rm -rf /var/lib/apt/lists/*

# Configuração do TurboVNC (opcional)
ENV PATH=/opt/TurboVNC/bin:$PATH
RUN wget -q -O- https://packagecloud.io/dcommander/turbovnc/gpgkey | \
    gpg --dearmor >/etc/apt/trusted.gpg.d/TurboVNC.gpg; \
    wget -O /etc/apt/sources.list.d/TurboVNC.list https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list; \
    apt-get -y -qq update && apt-get -y -qq install turbovnc && \
    rm -rf /var/lib/apt/lists/*

# Corrigir permissões no diretório do usuário
RUN chown -R root:root $HOME

# Adicionar scripts e pacotes adicionais
ADD . /opt/install
RUN fix-permissions /opt/install

# Atualizar o ambiente Conda e instalar pacotes Python
COPY --chown=root:root environment.yml /tmp
RUN . /opt/conda/bin/activate && \
    mamba env update --quiet --file /tmp/environment.yml

# Copiar o repositório para o contêiner
COPY --chown=root:root . /opt/install
RUN . /opt/conda/bin/activate && \
    mamba install -y -q "nodejs>=22" && \
    pip install /opt/install

# Copiar o script de monitoramento para o contêiner
COPY --chown=root:root monitor.py /opt/install/monitor.py

# Garantir que o usuário root seja mantido
USER root

# Configurar inicialização do VNC e ambiente gráfico
CMD ["start.sh"]

