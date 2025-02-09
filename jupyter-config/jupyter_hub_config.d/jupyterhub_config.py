# Configuração básica do JupyterHub
c = get_config()

# Permitir conexões externas
c.JupyterHub.ip = '0.0.0.0'
c.JupyterHub.port = 8000  # Porta padrão do JupyterHub

# Definições para evitar bloqueios e desconexões
c.Spawner.http_timeout = 14400  # Tempo de espera de 4 horas antes de encerrar
c.JupyterHub.shutdown_on_logout = False  # Não encerra a sessão ao fazer logout
c.ConfigurableHTTPProxy.keep_alive_timeout = 14400  # Mantém o proxy ativo por 4 horas
c.NotebookApp.shutdown_no_activity_timeout = 0  # Desativa encerramento por inatividade

# Permitir acesso de qualquer origem (desativar restrições de CORS)
c.JupyterHub.allow_origin = '*'
c.Spawner.args = ['--NotebookApp.allow_origin=*', '--NotebookApp.port=8888']

# Configuração do Proxy
c.ConfigurableHTTPProxy.api_url = 'http://127.0.0.1:8001'
c.ConfigurableHTTPProxy.auth_token = ''
c.JupyterHub.proxy_cmd = ['configurable-http-proxy']

# Evitar encerramento automático das sessões
c.Spawner.default_url = '/lab'
c.Spawner.environment = {
    'JUPYTER_ENABLE_LAB': 'yes',
    'GRANT_SUDO': 'yes'  # Permitir uso de sudo dentro dos notebooks
}

# Criar usuários padrão automaticamente (caso esteja usando autenticação simples)
c.Authenticator.admin_users = {'admin'}
c.Authenticator.allowed_users = {'admin', 'user'}

# Configurar Spawner para usuários individuais
c.Spawner.cmd = ['jupyter-labhub']
c.Spawner.start_timeout = 600  # Tempo maior para inicialização

# Evitar bloqueio por permissões
c.Spawner.notebook_dir = '/home/jovyan'
c.Spawner.args = ['--NotebookApp.token=""', '--NotebookApp.password=""']

# Aumentar limite de conexões WebSocket para evitar desconexões
c.Spawner.env_keep = ['PYTHONPATH', 'LD_LIBRARY_PATH', 'JUPYTERHUB_API_TOKEN']
