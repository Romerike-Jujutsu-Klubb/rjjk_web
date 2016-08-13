class Numeric
  def ish(acceptable_delta = 0.001)
    ApproximateValue.new self, acceptable_delta
  end
end

class ApproximateValue
  def initialize(me, acceptable_delta)
    @me = me
    @acceptable_delta = acceptable_delta
  end

  def ==(other)
    (other - @me).abs < @acceptable_delta
  end

  def to_s
    "within #{@acceptable_delta} of #{@me}"
  end
end

class Time
  def ish(acceptable_delta = 5)
    ApproxTime.new(self, acceptable_delta)
  end
end

class ApproxTime
  def initialize(t, acceptable_delta)
    @time = t
    @acceptable_delta = acceptable_delta
  end

  def ==(other)
    return false if @time.nil? || other.nil?
    (@time - other).abs < @acceptable_delta
  end
end
