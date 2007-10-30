class GraduationsImport < ActiveRecord::Migration
  def self.import
    STDERR.puts "Importing C:/stuff/workspace/gradering.csv"
    @data = {}
    IO.read("C:/stuff/workspace/gradering.csv").each {|s_line|
      csv = s_line.chomp.split(';')
      if csv[2] == 0
        @unknown[csv[0]] ||= {}
        @unknown[csv[0]][csv[2]] = csv[1]
      else
        @data[csv[0]] ||= {}
        @data[csv[0]][csv[2]] = csv[1]
      end
    }

    create_table :martial_arts, :force => true do |t|
      t.column :name, :string, :limit => 16, :null => false
    end
    create_table :ranks, :force => true  do |t|
      t.column :name, :string, :limit => 16, :null => false
      t.column :colour, :string, :limit => 16, :null => false
      t.column :position, :integer, :null => false
      t.column :martial_art_id, :integer, :null => false
    end
    create_table :graduations, :force => true do |t|
      t.column :held_on, :date, :null => false
      t.column :martial_art_id, :integer, :null => false
    end
    create_table :censors, :force => true do |t|
      t.column :graduation_id, :integer, :null => false
      t.column :member_id, :integer, :null => false
    end
    create_table :graduates, :force => true do |t|
      t.column :member_id, :integer, :null => false
      t.column :graduation_id, :integer, :null => false
      t.column :passed, :boolean, :null => false
      t.column :rank_id, :integer, :null => false
      t.column :paid_graduation, :boolean, :null => false
      t.column :paid_belt, :boolean, :null => false
    end

    kwr = MartialArt.create!(:name => 'Kei Wa Ryu')
    aik = MartialArt.create!(:name => 'Aikikai')

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

    @data.each {|k,v|
      v.each {|x,y|
        next if x == 0
        mid = Rank.find(:first, :conditions => ['name LIKE ?', y])
        next if !mid
        STDERR.puts "#{k} => #{x} => #{y} => #{mid.id}"
      }
    }

    [@data, @unknown]
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
