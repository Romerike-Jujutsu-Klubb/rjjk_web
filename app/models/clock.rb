class Clock
  @@time = Time.now

  def self.at(*params)
    eval("Time.at #{params.join(',')}")
  end

  def self.now
    Rails.env == 'test' ? @@time : Time.now
  end

  def self.time=(new_time)
    raise "Cannot set real Clock class" unless Rails.env =='test'
    @@time = new_time
  end

  def self.advance_by_days(days)
    @@time += (days * 60 * 60 * 24)
  end

  def self.advance_by_seconds(seconds)
    @@time += seconds
  end

end
