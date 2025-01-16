import psutil
 def get_system_stats():
  """Obtém estatísticas de uso da CPU e RAM""" 
  cpu_percent = psutil.cpu_percent(interval=1) 
  ram_percent = psutil.virtual_memory().percent 
  return {"cpu": cpu_percent, "ram": ram_percent} 
  if __name__ == "__main__": 
  	stats = get_system_stats() print(f"CPU: {stats['cpu']}%, RAM: {stats['ram']}%")