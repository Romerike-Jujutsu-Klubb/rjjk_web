# frozen_string_literal: true

require 'user_system'
require 'user'
require 'member'

class CreateMemberImages < ActiveRecord::Migration
  PASSWORD_CHARS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

  def change
    add_column :members, :image_id, :integer
    add_column :members, :user_id, :integer
    add_index :members, :image_id, unique: true
    add_index :members, :user_id, unique: true

    reversible do |dir|
      dir.up do
        execute 'UPDATE members SET user_id = (SELECT id FROM users WHERE member_id = members.id)'
      end
    end

    Member.all.each do |m|
      u = User.find_by(member_id: m.id)
      u ||= User.find_by(first_name: m.first_name, last_name: m.last_name)
      u ||= User.find_by(email: m.email)
      if u.nil? && m.email.present?
        password = (1..5).map { PASSWORD_CHARS[rand(PASSWORD_CHARS.size)] }.join('')
        u = User.new login: m.email, email: m.email, first_name: m.first_name,
                     last_name: m.last_name, password: password, password_confirmation: password,
                     role: m.instructor ? 'ADMIN' : nil, member_id: m.id
        u.password_needs_confirmation = true
        u.save!
        u.generate_security_token
        m.update! user_id: u.id
        unless m.left_on || m.birthdate > 13.years.ago.to_date
          UserMailer.created_from_member(u, password).store(u.id, tag: :user_from_member)
        end
      end

      next unless m.image
      i = Image.create! name: m.image_name, content_type: m.image_content_type,
                        content_data: m.image, user_id: u.id, description: 'Profilbilde',
                        public: false, approved: nil
      m.update! image_id: i.id
    end

    remove_column :users, :member_id, :integer
    remove_column :members, :image_name, :string
    remove_column :members, :image_content_type, :string
    remove_column :members, :image, :binary
  end

  class Image < ApplicationRecord; end
  class Member < ApplicationRecord; end
end
