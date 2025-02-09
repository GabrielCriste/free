c.JupyterHub.ip = '0.0.0.0'  # Permitir conexões externas
c.JupyterHub.port = 8000  # Porta do JupyterHub
c.Spawner.args = ['--NotebookApp.allow_origin=*', '--NotebookApp.port=8888']
