# Usa uma imagem base com Jupyter Notebook
FROM quay.io/jupyter/base-notebook:2024-12-31

# Garante que tudo seja executado como root
USER root

# Atualiza pacotes e instala dependências do sistema
RUN apt-get update -y && apt-get install -y \
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
    sudo \
    curl \
    wget \
    tigervnc-standalone-server \
    proot \
    && rm -rf /var/lib/apt/lists/*

# Adiciona um novo usuário com permissões de sudo
RUN useradd -m -s /bin/bash admin && echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configura permissões para evitar problemas de acesso
RUN chown -R root:root /opt /usr/local/bin

# Instala TurboVNC
RUN wget -q -O- https://packagecloud.io/dcommander/turbovnc/gpgkey | gpg --dearmor > /etc/apt/trusted.gpg.d/TurboVNC.gpg; \
    wget -O /etc/apt/sources.list.d/TurboVNC.list https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list; \
    apt-get update -y && apt-get install -y turbovnc && \
    rm -rf /var/lib/apt/lists/*

# Define o usuário padrão como root
USER root

# Copia o ambiente Conda e instala pacotes Python
COPY --chown=root:root environment.yml /tmp
RUN . /opt/conda/bin/activate && \
    mamba env update --quiet --file /tmp/environment.yml

# Instala Node.js (se necessário)
RUN . /opt/conda/bin/activate && \
    mamba install -y -q "nodejs>=22"

# Copia os arquivos do repositório para o contêiner
COPY . /opt/install
RUN chown -R root:root /opt/install && chmod -R 777 /opt/install

# Configura inicialização do VNC e ambiente gráfico
CMD ["/bin/bash"]

