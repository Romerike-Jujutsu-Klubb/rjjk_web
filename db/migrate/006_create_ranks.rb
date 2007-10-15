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
    mon10  = kwr.ranks.create!(:name => '10.mon', :colour => '')
    mon9   = kwr.ranks.create!(:name => '9.mon',  :colour => '')
    mon8   = kwr.ranks.create!(:name => '8.mon',  :colour => '')
    mon7   = kwr.ranks.create!(:name => '7.mon',  :colour => '')
    mon6   = kwr.ranks.create!(:name => '6.mon',  :colour => '')
    mon5   = kwr.ranks.create!(:name => '5.mon',  :colour => '')
    mon4   = kwr.ranks.create!(:name => '4.mon',  :colour => '')
    mon3   = kwr.ranks.create!(:name => '3.mon',  :colour => '')
    mon2   = kwr.ranks.create!(:name => '2.mon',  :colour => '')
    kyu5   = kwr.ranks.create!(:name => '5.kyu',  :colour => 'gult')
    kyu4   = kwr.ranks.create!(:name => '4.kyu',  :colour => 'oransje')
    kyu3   = kwr.ranks.create!(:name => '3.kyu',  :colour => 'grønt')
    kyu2   = kwr.ranks.create!(:name => '2.kyu',  :colour => 'blått')
    kyu1   = kwr.ranks.create!(:name => '1.kyu',  :colour => 'brunt')
    shodan = kwr.ranks.create!(:name => '1.dan',  :colour => 'svart')
    nidan  = kwr.ranks.create!(:name => '2.dan',  :colour => 'svart, 2-striper')
    sandan = kwr.ranks.create!(:name => '3.dan',  :colour => 'svart, 3-striper')
    
    a6kyu  = aik.ranks.create!(:name => '6.kyu',  :colour => 'hvitt')
    a5kyu  = aik.ranks.create!(:name => '5.kyu',  :colour => 'hvitt')
    a4kyu  = aik.ranks.create!(:name => '4.kyu',  :colour => 'hvitt')
    a3kyu  = aik.ranks.create!(:name => '3.kyu',  :colour => 'hvitt')
    a2kyu  = aik.ranks.create!(:name => '2.kyu',  :colour => 'hvitt')
    a1kyu  = aik.ranks.create!(:name => '1.kyu',  :colour => 'hvitt')
    a1dan  = aik.ranks.create!(:name => '1.dan',  :colour => 'svart')
    a2dan  = aik.ranks.create!(:name => '2.dan',  :colour => 'svart')
    a3dan  = aik.ranks.create!(:name => '3.dan',  :colour => 'svart')
    
    agd = {
      '2007-03-22' => {
        149 => a6kyu.id,
      },
    }

    gd = {
      '1989-07-01' => {
          85 => shodan.id,
      },
      '1991-06-11' => {
          78 => kyu3.id,
      },
      '1993-05-25' => {
          78 => kyu2.id,
      },
      '1994-01-22' => {
          85 => nidan.id,
      },
      '1994-11-17' => {
          86 => kyu5.id,
      },
      '1994-11-24' => {
          86 => kyu4.id,
      },
      '1995-05-30' => {
          78 => kyu1.id,
          86 => kyu3.id,
      },
      '1995-12-12' => {
      },
      '1996-06-04' => {
          29 => mon10.id,
          86 => kyu2.id,
      },
      '1996-12-10' => {
          29 => mon9.id,
          29 => mon8.id,
      },
      '1996-12-13' => {
      },
      '1997-06-03' => {
          29 => mon7.id,
          77 => kyu5.id,
          81 => kyu5.id,
          86 => kyu1.id,
      },
      '1997-06-06' => {
      },
      '1997-07-03' => {
          78 => shodan.id,
      },
      '1997-12-11' => {
          77 => kyu4.id,
          81 => kyu4.id,
      },
      '1997-12-13' => {
          29 => mon6.id,
      },
      '1998-01-15' => {
      },
      '1998-05-28' => {
          29 => mon5.id,
          81 => kyu3.id,
      },
      '1998-12-10' => {
          29 => mon4.id,
          77 => kyu3.id,
      },
      '1999-03-02' => {
      },
      '1999-06-03' => {
          29 => mon3.id,
      },
      '1999-07-03' => {
          86 => shodan.id,
      },
      '1999-12-09' => {
          77 => kyu2.id,
          81 => kyu2.id,
      },
      '2000-01-27' => {
      },
      '2000-06-08' => {
          29 => mon2.id,
      },
      '2000-06-12' => {
          29 => kyu5.id,
      },
      '2000-06-13' => {
          29 => kyu4.id,
      },
      '2000-06-15' => {
      },
      '2000-07-08' => {
      },
      '2000-12-05' => {
      },
      '2000-12-06' => {
      },
      '2000-12-07' => {
      },
      '2001-03-17' => {
          85 => sandan.id,
      },
      '2001-03-18' => {
          86 => nidan.id,
          78 => nidan.id,
      },
      '2001-03-18' => {
      },
      '2002-02-26' => {
          81 => kyu1.id,
      },
      '2002-09-01' => {
      },
      '2005-01-01' => {
      },
      '2005-12-06' => {
      },
    }
    g = Array.new()
    gd.each_key { |d|
      grd = kwr.graduations.create!(:held_on => d)
      grd.censors.create!(:member_id => 0)
      if gd[d]
        gd[d].each { |a,b|
          grd.graduates.create!(:member_id => a, :passed => true, :rank_id => b,
                                :paid_graduation => true, :paid_belt => true)
        }
      end
      g.push(grd)
    }
    agd.each_key { |d|
      agrd = aik.graduations.create!(:held_on => d)
      agrd.censors.create!(:member_id => 0)
      if agd[d]
        agd[d].each { |a,b|
          agrd.graduates.create!(:member_id => a, :passed => true, :rank_id => b,
                                :paid_graduation => true, :paid_belt => true)
        }
      end
    }
    
    g[50] = kwr.graduations.create!(:held_on => '2006-06-24')
    g[51] = kwr.graduations.create!(:held_on => '2006-12-15')
    g[52] = kwr.graduations.create!(:held_on => '2007-06-15')
    
    g[50].censors.create!(:member_id => 85) # Hans Petter Skolsegg
    g[50].censors.create!(:member_id => 81) # Morten Jacobsen

    # Jens-Harald Johansen
    g[50].graduates.create!(:member_id => 111, :passed => true, :rank_id => kyu5.id, :paid_graduation => true, :paid_belt => true)
    
    g[51].censors.create!(:member_id => 78) # Uwe Kubosch
    g[51].censors.create!(:member_id => 29) # Harald T. Løkken
    
    g[51].graduates.create!(:member_id => 111, :passed => true, :rank_id => kyu4.id, :paid_graduation => true, :paid_belt => true)
    
    g[52].censors.create!(:member_id => 81)
    g[52].censors.create!(:member_id => 85)

    g[52].graduates.create!(:member_id => 111, :passed => false, :rank_id => kyu3.id, :paid_graduation => true, :paid_belt => false)
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
