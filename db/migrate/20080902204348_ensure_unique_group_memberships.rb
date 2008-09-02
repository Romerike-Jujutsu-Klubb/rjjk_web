class EnsureUniqueGroupMemberships < ActiveRecord::Migration
  def self.up
    execute 'DELETE FROM groups_members gm1 WHERE EXISTS (SELECT member_id FROM groups_members gm2 WHERE gm2.member_id = gm1.member_id AND gm2.group_id = gm1.group_id AND gm2.created_at < gm1.created_at)'
    add_index :groups_members, [:group_id, :member_id], :unique => true
    remove_column :groups_members, :created_at
    remove_column :groups_members, :updated_at
    
    drop_table :martial_arts_members
  end

  def self.down
    create_table :martial_arts_members, :id => false do |t|
      t.integer :martial_art_id, :null => false
      t.integer :member_id, :null => false
    end
    Member.find(:all).each do |m|
      m.martial_arts = m.groups.map{|g|g.martial_art}
      m.save!
    end

    add_column :groups_members, :updated_at, :datetime
    add_column :groups_members, :created_at, :datetime
    remove_index :groups_members, [:group_id, :member_id]
  end
  
  class Member < ActiveRecord::Base
    has_and_belongs_to_many :martial_arts
    has_and_belongs_to_many :groups
  end
  
end
