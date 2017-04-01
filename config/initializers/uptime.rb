# frozen_string_literal: true

SERVER_START_TIME = Time.current

def uptime
  Time.current - SERVER_START_TIME
end
