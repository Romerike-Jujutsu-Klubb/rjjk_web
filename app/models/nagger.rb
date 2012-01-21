class Nagger
  def self.start
    new.nag
  end

  def nag
    puts 'nagging'
    sleep 60
  end
end