class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.integer :martial_art_id, :null => false
      t.string :name, :null => false
      t.integer :from_age, :null => false
      t.integer :to_age, :null => false

      t.timestamps
    end
    create_table :groups_members, :id => false do |t|
      t.integer :group_id, :null => false
      t.integer :member_id, :null => false

      t.timestamps
    end
    keiwaryu = MartialArt.find_by_name('Kei Wa Ryu')
    aikikai = MartialArt.find_by_name('Aikikai')
    if keiwaryu && aikikai
      Group.create! :martial_art_id => keiwaryu.id, :name => 'Aspiranter', :from_age => 6, :to_age => 9
      j = Group.create! :martial_art_id => keiwaryu.id, :name => 'Juniorer', :from_age => 10, :to_age => 14
      s = Group.create! :martial_art_id => keiwaryu.id, :name => 'Seniorer', :from_age => 14, :to_age => 999
      a = Group.create! :martial_art_id => aikikai.id, :name => 'Seniorer', :from_age => 14, :to_age => 999
      Member.all.each do |m|
        m.martial_arts.each do |ma|
          if ma == aikikai
            group = a
          else
            group = m.senior ? s : j
          end
          puts "Adding #{m.name} to #{group.martial_art.name} #{group.name}"
          m.groups << group
        end
      end
    end
    remove_column :cms_members, :senior
    remove_column :members, :senior
  end

  def self.down
    add_column :members, :senior, :boolean
    add_column :cms_members, :senior, :boolean
    s = Group.find_by_name 'Seniorer'
    Member.all.each do |m|
      senior = m.groups.include? s
      puts "Marking #{m.name} senior: #{senior}"
      m.update_attributes! :senior => senior
    end
    drop_table :groups_members
    drop_table :groups
  end

  class Group < ActiveRecord::Base; end
  class MartialArt < ActiveRecord::Base; end
  class Member < ActiveRecord::Base; end
end
