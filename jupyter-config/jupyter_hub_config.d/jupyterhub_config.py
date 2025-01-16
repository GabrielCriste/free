# Configurações de tempo limite
c.Spawner.http_timeout = 14400  # Tempo de 4 horas antes de encerrar
c.JupyterHub.shutdown_on_logout = False  # Não encerra a sessão ao fazer logout
c.ConfigurableHTTPProxy.keep_alive_timeout = 14400  # Proxy ativo por 4 horas
c.NotebookApp.shutdown_no_activity_timeout = 0  # Desativa encerramento por inatividade