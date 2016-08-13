require 'user_system'
require 'user'
require 'user_notify'
require 'member'

class CreateMemberImages < ActiveRecord::Migration
  PASSWORD_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a

  def change
    add_column :members, :image_id, :integer
    add_column :members, :user_id, :integer
    add_index :members, :image_id, :unique => true
    add_index :members, :user_id, :unique => true

    execute "UPDATE members SET user_id = (SELECT id FROM users WHERE member_id = members.id)"

    Member.all.each do |m|
      u = User.find_by_member_id(m.id)
      u ||= User.find_by_first_name_and_last_name(m.first_name, m.last_name)
      u ||= User.find_by_email(m.email)
      if u.nil? && !m.email.blank?
        password                      = (1..5).map { PASSWORD_CHARS[rand(PASSWORD_CHARS.size)] }.join('')
        u                             = User.new :login    => m.email, :email => m.email, :first_name => m.first_name, :last_name => m.last_name,
                                                 :password => password, :password_confirmation => password,
                                                 :role     => m.instructor ? 'ADMIN' : nil, :member_id => m.id
        u.password_needs_confirmation = true
        u.save!
        u.generate_security_token
        m.update_attributes! :user_id => u.id
        puts "Created user: #{u.inspect}"
        unless m.left_on || m.birthdate > 13.years.ago.to_date
          UserNotify.created_from_member(u, password).store(u.id, tag: :user_from_member)
          puts "Sent email"
        end
      end

      if m.image
        i = Image.create! :name    => m.image_name, :content_type => m.image_content_type, :content_data => m.image,
                          :user_id => u.id, :description => 'Profilbilde', :public => false, :approved => nil
        m.update_attributes! :image_id => i.id
        puts "Moved image for member: #{m.inspect}"
      end
    end

    remove_column :users, :member_id
    remove_column :members, :image_name
    remove_column :members, :image_content_type
    remove_column :members, :image
  end

  class Image < ActiveRecord::Base end
  class Member < ActiveRecord::Base end
end
