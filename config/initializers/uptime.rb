SERVER_START_TIME = Time.now

def uptime
  Time.now - SERVER_START_TIME
end
