class CreateRanks < ActiveRecord::Migration
  def self.up
    create_table :martial_arts do |t|
      t.column :name, :string, :limit => 16, :null => false
    end
    create_table :ranks do |t|
      t.column :name, :string, :limit => 16, :null => false
      t.column :colour, :string, :limit => 16, :null => false
      t.column :position, :integer, :null => false
      t.column :martial_art_id, :integer, :null => false
    end
    create_table :graduations do |t|
      t.column :held_on, :date, :null => false
      t.column :martial_art_id, :integer, :null => false
    end
    create_table :censors do |t|
      t.column :graduation_id, :integer, :null => false
      t.column :member_id, :integer, :null => false
    end
    create_table :graduates do |t|
      t.column :member_id, :integer, :null => false
      t.column :graduation_id, :integer, :null => false
      t.column :passed, :boolean, :null => false
      t.column :rank_id, :integer, :null => false
      t.column :paid_graduation, :boolean, :null => false
      t.column :paid_belt, :boolean, :null => false
    end

    kwr = MartialArt.create!(:name => 'Kei Wa Ryu')
    aik = MartialArt.create!(:name => 'Aikikai')

    # Rank.create!(:name => 'ugradert', :colour => 'hvitt', :position => 1)
    kyu5   = kwr.ranks.create!(:name => '5.kyu',  :colour => 'gult')
    kyu4   = kwr.ranks.create!(:name => '4.kyu',  :colour => 'oransje')
    kyu3   = kwr.ranks.create!(:name => '3.kyu',  :colour => 'grønt')
    kyu2   = kwr.ranks.create!(:name => '2.kyu',  :colour => 'blått')
    kyu1   = kwr.ranks.create!(:name => '1.kyu',  :colour => 'brunt')
    shodan = kwr.ranks.create!(:name => 'shodan', :colour => 'svart')
    nidan  = kwr.ranks.create!(:name => 'nidan',  :colour => 'svart, 2-striper')
    sandan = kwr.ranks.create!(:name => 'sandan', :colour => 'svart, 3-striper')
    
    g = Array.new()
    g[0] = kwr.graduations.create!(:held_on => '2006-06-24')
    g[1] = kwr.graduations.create!(:held_on => '2006-12-15')
    g[2] = kwr.graduations.create!(:held_on => '2007-06-15')
    
    g[0].censors.create!(:member_id => 85) # Hans Petter Skolsegg
    g[0].censors.create!(:member_id => 81) # Morten Jacobsen

    # Jens-Harald Johansen
    g[0].graduates.create!(:member_id => 111, :passed => true, :rank_id => kyu5.id, :paid_graduation => true, :paid_belt => true)
    
    g[1].censors.create!(:member_id => 78) # Uwe Kubosch
    g[1].censors.create!(:member_id => 29) # Harald T. Løkken
    
    g[1].graduates.create!(:member_id => 111, :passed => true, :rank_id => kyu4.id, :paid_graduation => true, :paid_belt => true)
    
    g[2].censors.create!(:member_id => 81)
    g[2].censors.create!(:member_id => 85)

    g[2].graduates.create!(:member_id => 111, :passed => false, :rank_id => kyu3.id, :paid_graduation => true, :paid_belt => false)
  end

  def self.down
    drop_table :graduates
    drop_table :censors
    drop_table :graduations
    drop_table :ranks
    drop_table :martial_arts
  end
  
  class MartialArt < ActiveRecord::Base
    has_many :ranks
    has_many :graduations
    has_many :censors
  end
  
  class Rank < ActiveRecord::Base
    acts_as_list :scope => :martial_art_id
  end
  class Graduation < ActiveRecord::Base
    has_many :censors
    has_many :graduates
  end
  class Censor < ActiveRecord::Base ;end
  class Graduate < ActiveRecord::Base ;end
  
end
