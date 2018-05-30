# frozen_string_literal: true

# rubocop: disable all
class StoreUserDataWithMemberUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :billing_user, foreign_key: { to_table: :users }
    add_reference :users, :contact_user, foreign_key: { to_table: :users }
    add_reference :users, :guardian_1, foreign_key: { to_table: :users }
    add_reference :users, :guardian_2, foreign_key: { to_table: :users }
    add_column :users, :address, :string, limit: 100
    add_column :users, :birthdate, :date
    add_column :users, :gmaps, :boolean
    add_column :users, :latitude, :decimal, precision: 8, scale: 6
    add_column :users, :longitude, :decimal, precision: 9, scale: 6
    add_column :users, :male, :boolean
    add_column :users, :phone, :string, limit: 32, index: { unique: true }
    add_column :users, :postal_code, :string, limit: 4
    change_column_null :users, :email, true
    change_column_null :users, :login, true
    change_column_null :users, :salt, true
    change_column_null :users, :salted_password, true
    change_column_null :members, :email, true
    remove_index :members, :user_id
    add_foreign_key :members, :users

    Member.order(:id).each do |m|
      puts "Member (#{'%4d' % m.id}) #{m.name} email: #{m.email.inspect}, parent email: #{m.parent_email}, billing email: #{m.billing_email}, phone_mobile: #{m.phone_mobile}, billing_phone_mobile: #{m.billing_phone_mobile}"
      m.email = m.email.presence&.downcase
      m.billing_phone_mobile = m.billing_phone_mobile.presence
      m.parent_email = m.parent_email&.downcase
      m.billing_email = m.billing_email&.downcase

      if m.email == 'post@jujutsu.no' && m.id != 1176
        puts "Member (#{'%4d' % m.id}) #{m.name} email: #{m.email.inspect}: Reset RJJK email"
        m.email = nil
      end

      if m.phone_mobile&.== m.phone_parent
        puts "Member (#{'%4d' % m.id}) #{m.name} phone_mobile: #{m.phone_mobile.inspect}: Reset user phone since it equals parent phone"
        m.phone_mobile = nil
      end

      if m.phone_mobile&.== m.parent_2_mobile
        puts "Member (#{'%4d' % m.id}) #{m.name} phone_mobile: #{m.phone_mobile.inspect}: Reset user phone since it equals parent 2 phone"
        m.phone_mobile = nil
      end

      if m.phone_mobile&.== m.billing_phone_mobile
        puts "Member (#{'%4d' % m.id}) #{m.name} phone_mobile: #{m.phone_mobile.inspect}: Reset user phone since it equals billing phone"
        m.phone_mobile = nil
      end

      if (main_user = m.user)
        main_user.email = main_user.email.presence&.downcase
        main_user.login = main_user.login&.downcase

        if main_user.email =~ /^.* <(.*)>$/
          stripped_user_email = Regexp.last_match(1).presence
          puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: convert email: #{main_user.email.inspect} => #{stripped_user_email.inspect}"
          main_user.email = stripped_user_email
        end
        if main_user.login =~ /^.* <(.*)>$/
          stripped_user_login = Regexp.last_match(1).presence
          puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: convert login: #{main_user.login.inspect} => #{stripped_user_login.inspect}"
          main_user.login = stripped_user_login
        end

        if main_user.email != m.email
          puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: discard user email: #{main_user.email.inspect} for member email #{m.email.inspect}"
          main_user.email = m.email
        end

        if main_user.login == main_user.email
          puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: reset login since it equals email"
          main_user.login = nil
        end

        if main_user.first_name != m.first_name
          puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Change first name: #{main_user.first_name.inspect} => #{m.first_name.inspect}"
          main_user.first_name = m.first_name
        end
        if main_user.last_name != m.last_name
          puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Change last name: #{main_user.last_name.inspect} => #{m.last_name.inspect}"
          main_user.last_name = m.last_name
        end
        main_user.phone = m.phone_mobile

      else
        main_user = m.create_user first_name: m.first_name, last_name: m.last_name, email: m.email, phone: m.phone_mobile
        main_user.save!
        puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: New user: #{main_user.inspect}"
      end

      if main_user.email&.== m.billing_email
        puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Reset user email since it equals billing email"
        main_user.attributes = { login: nil, email: nil }
      end

      if main_user.email && main_user.email == m.parent_email
        puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Reset email since it equals parent email"
        main_user.attributes = { login: nil, email: nil }
      end

      if main_user.email && main_user.email == m.parent_2_email
        puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Reset email since it equals parent 2 email"
        main_user.attributes = { login: nil, email: nil }
      end

      main_user.attributes = {address: m.address, birthdate: m.birthdate, gmaps: m.gmaps, latitude: m.latitude, longitude: m.longitude,
          male: m.male, postal_code: m.postal_code}

      if main_user.changed?
        puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Update: #{main_user.changes.inspect}"
        main_user.save!
      end
      m.save!
    end

    puts 'Link associated users:'

    Member.order(:id).each do |m|
      main_user = m.user
      if m.parent_email || m.phone_parent || (m.age && m.age < 18 && m.parent_name)
        parent_1_user = m.user.guardian_1 ||
            (m.parent_email.present? && User.find_by(email: m.parent_email)) ||
            (m.phone_parent.present? && User.find_by(phone: m.phone_parent)) || User.new
        puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Link parent 1 (#{parent_1_user.id.inspect}): parent_name: #{m.parent_name.inspect}, parent_email: #{m.parent_email.inspect}, parent_phone: #{m.phone_parent.inspect}"
        if m.parent_name.present?
          if parent_1_user.first_name.blank?
            parent_1_user.attributes = { first_name: m.parent_name&.split(/\s+/)&.[](0..-2)&.join(' '), last_name: m.parent_name&.split(/\s+/)&.[](-1) }
          elsif parent_1_user.name != m.parent_name
            puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Discard parent 1 name: #{m.parent_name.inspect} for #{parent_1_user.name.inspect}"
          end
        end
        if m.parent_email.present?
          if parent_1_user.email.blank?
            parent_1_user.email = m.parent_email
          elsif parent_1_user.email != m.parent_email
            puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Discard parent 1 email: #{m.parent_email.inspect}"
          end
        end
        if m.phone_parent.present?
          if parent_1_user.phone.blank?
            parent_1_user.phone = m.phone_parent
          elsif parent_1_user.phone != m.phone_parent
            puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Discard parent 1 phone: #{m.phone_parent.inspect}"
          end
        end
        if parent_1_user.changed?
          puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Update parent 1 (#{parent_1_user.id.inspect}): #{parent_1_user.changes.inspect}"
          parent_1_user.save!
        end
        unless main_user.guardian_1
          puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Link guardian 1 (#{parent_1_user.id.inspect}): #{parent_1_user.email.inspect}"
          main_user.update! guardian_1: parent_1_user
        end
      elsif m.parent_email || m.parent_name || m.phone_parent
        puts "Member (#{'%4d' % m.id}) #{m.name} email: #{main_user.email.inspect}: Discard parent 1: parent_name: #{m.parent_name.inspect}, parent_email: #{m.parent_email.inspect}, parent_phone: #{m.phone_parent.inspect}"
      end

      if m.parent_2_email.present? || m.parent_2_mobile.present? || (m.age && m.age < 18 && m.parent_2_name.present?)
        parent_2_user = m.user.guardian_2 ||
            (m.parent_2_email && User.find_by(email: m.parent_2_email)) ||
            (m.parent_2_mobile && User.find_by(phone: m.parent_2_mobile)) || User.new
        puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Link parent 2 (#{parent_2_user.id.inspect}): parent_2_name: #{m.parent_2_name.inspect}, parent_2_email: #{m.parent_2_email.inspect}, parent_2_mobile: #{m.parent_2_mobile.inspect}"
        if m.parent_2_name.present?
          if parent_2_user.name.blank?
            parent_2_user.attributes = { first_name: m.parent_2_name&.split(/\s+/)&.[](0..-2)&.join(' '), last_name: m.parent_2_name&.split(/\s+/)&.[](-1) }
          elsif parent_2_user.name != m.parent_2_name
            puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Discard parent 2 name: #{m.parent_2_name.inspect}"
          end
        end
        if m.parent_2_email.present?
          if parent_2_user.email.blank?
            parent_2_user.email = m.parent_2_email
          elsif parent_2_user.email != m.parent_2_email
            puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Discard parent 2 email: #{m.parent_2_email.inspect}"
          end
        end
        if m.parent_2_mobile.present?
          if parent_2_user.phone.blank?
            parent_2_user.phone = m.parent_2_mobile
          elsif parent_2_user.phone != m.parent_2_mobile
            puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Discard parent 2 phone: #{m.parent_2_mobile.inspect}"
          end
        end
        if parent_2_user.changed?
          puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Update parent 2 (#{parent_2_user.id.inspect}): #{parent_2_user.changes.inspect}"
          parent_2_user.save!
        end
        unless main_user.guardian_2
          puts "link parent 2"
          main_user.update! guardian_2: parent_2_user
        end
      end

      if m.billing_email.present? || m.billing_phone_mobile.present? || (m.age && m.age < 18 && m.billing_name.present?)
        puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: billing_email: #{m.billing_email.inspect} billing_phone: #{m.billing_phone_mobile.inspect} billing_name: #{m.billing_name}"
        billing_user =
            (m.billing_email.present? && (User.find_by(email: m.billing_email)) ||
                User.find_by("email ilike '%<#{m.billing_email}>'")) ||
            (m.billing_phone_mobile.present? && User.find_by(phone: m.billing_phone_mobile)) || User.new
        if m.billing_name.present?
          if billing_user.name.blank?
            billing_user.first_name = m.billing_name.split(/\s+/)[0..-2].join(' ')
            billing_user.last_name = m.billing_name.split(/\s+/)[-1]
          elsif billing_user.name != m.billing_name
            puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Discard billing name: #{m.billing_name.inspect} for #{billing_user.name.inspect}"
          end
        end
        if m.billing_email.present?
          if billing_user.email.blank?
            billing_user.email = m.billing_email
          elsif billing_user.email != m.billing_email
            puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Discard billing email: #{m.billing_email.inspect}"
          end
        end
        if m.billing_phone_mobile.present?
          if billing_user.phone.blank?
            billing_user.phone = m.billing_phone_mobile
          elsif billing_user.phone != m.billing_phone_mobile
            puts "User (#{'%4d' % main_user.id}) #{main_user.name} email: #{main_user.email.inspect}: Discard billing phone: #{m.billing_phone_mobile.inspect} for #{billing_user.phone.inspect}"
          end
        end

        billing_user.address = m.billing_address if m.billing_address.present?
        billing_user.postal_code = m.billing_postal_code if m.billing_postal_code.present?

        if billing_user.changed?
          puts "Member (#{'%4d' % m.id}) #{m.name} email: #{m.user.email.inspect}: Update billing user (#{billing_user.id.inspect}) #{billing_user.email}: #{billing_user.changes.inspect}"
          billing_user.save!
        end
        if main_user.billing_user_id != billing_user.id
          puts "Member (#{'%4d' % m.id}) #{m.name} email: #{m.user.email.inspect}: Link billing user (#{billing_user.id.inspect}) #{billing_user.email}: #{billing_user.changes.inspect}"
          main_user.update! billing_user: billing_user
        end
      elsif m.billing_email.present? || m.billing_name.present? || m.billing_phone_mobile.present?
        puts "Member (#{'%4d' % m.id}) #{m.name} email: #{m.user.email.inspect}: Discard billing user: billing_user email: #{m.billing_email.inspect}, name: #{m.billing_name.inspect}, phone: #{m.billing_phone_mobile.inspect}"
      end

      if m.email&.!= m.user.email
        puts "Member (#{'%4d' % m.id}) #{m.name} email: #{m.user.email.inspect}: Contact email is not user email: #{m.email.inspect}) != #{m.user.email.inspect}"
        contact_user = [billing_user, parent_1_user, parent_2_user].compact.find{|u| u.email == m.email}
        puts "Member (#{'%4d' % m.id}) #{m.name} email: #{m.user.email.inspect}: Set contact user (#{contact_user.id.inspect}): #{contact_user.email.inspect}"
        main_user.update! contact_user_id: contact_user.id
      end
    end

    puts 'done'

    change_column_null :members, :user_id, false
    remove_column :members, :address
    remove_column :members, :birthdate
    remove_column :members, :email
    remove_column :members, :first_name
    remove_column :members, :gmaps
    remove_column :members, :last_name
    remove_column :members, :latitude
    remove_column :members, :longitude
    remove_column :members, :male
    remove_column :members, :phone_mobile
    remove_column :members, :postal_code

    remove_column :members, :parent_email
    remove_column :members, :parent_name
    remove_column :members, :phone_parent

    remove_column :members, :parent_2_email
    remove_column :members, :parent_2_mobile
    remove_column :members, :parent_2_name

    remove_column :members, :billing_address
    remove_column :members, :billing_email
    remove_column :members, :billing_name
    remove_column :members, :billing_phone_mobile
    remove_column :members, :billing_postal_code

    Member.reset_column_information
    ::Member.reset_column_information

    # if Rails.env.development?
    #   puts 'Replicating NKF memberships'
    #   i = NkfMemberImport.new
    #   raise "Import should have no exception: #{i.exception}" if i.exception
    #   raise "Import should have no error records: #{i.error_records}" if i.error_records.any?
    #   raise "Import should have no new records (i.new_records.size): #{i.new_records}" if i.new_records.any?
    #   if i.changes.any?
    #     raise "Import should have no changes (#{i.changes.size}): #{i.changes.pretty_inspect}"
    #   end
    #   puts 'import ok'
    # end

    puts 'Comparing NKF memberships'
    c = NkfMemberComparison.new
    puts "Members: #{c.members.size}" if c.members.size > 0
    puts 'Synching NKF memberships'
    c.sync
    if c.errors.any?
      3.times{puts '*' * 80}
      puts "Found #{c.errors.size} errors:"
      pp c.errors.map{|r| [r[0], r[2].class.to_s, r[2].id, r[1].to_s]}.first
      first_record = c.errors[0][2]
      if first_record.is_a?(::Member)
        puts "Member (#{'%4d' % first_record.id}): #{first_record.attributes}"
        puts "Member (#{'%4d' % first_record.id}): #{first_record.changes}"
        puts "Member (#{'%4d' % first_record.id}): #{first_record.errors.full_messages}"
        if first_record.billing_user
          puts "Billing User (#{'%4d' % first_record.billing_user.id}): #{first_record.billing_user.attributes}"
          puts "Billing User (#{'%4d' % first_record.billing_user.id}): #{first_record.billing_user.changes}"
          puts "Billing User (#{'%4d' % first_record.billing_user.id}): #{first_record.billing_user.errors&.full_messages}"
        end
        first_user = first_record.user
      else
        first_user = first_record
      end
      puts "User (#{'%4d' % first_user.id}): #{first_user.attributes}"
      puts "User (#{'%4d' % first_user.id}): #{first_user.changes}"
      puts "User (#{'%4d' % first_user.id}): #{first_user.errors.full_messages}"

      if c.errors[0][1].is_a?(Exception)
        puts c.errors[0][1].backtrace.join("\n")
      end

      3.times{puts '*' * 80}
      raise "Comparison should have no errors (#{c.errors.size}): #{c.errors.pretty_inspect}"
    end
    raise "Comparison should have no new members:\n#{c.new_members.pretty_inspect}" if c.new_members.any?
    raise "Comparison should have no changes (#{c.member_changes.size}):\n#{c.member_changes.pretty_inspect}" if c.member_changes.any?
    raise "Comparison should have no outgoing changes (#{c.outgoing_changes.size}):\n#{c.outgoing_changes.pretty_inspect}" if c.outgoing_changes.any?
    puts 'Synch OK'

    # raise 'huh?!'
  end

  class Member < ApplicationRecord
    belongs_to :billing_user, required: false, class_name: :User
    belongs_to :contact_user, class_name: :User, optional: true
    belongs_to :user

    has_one :nkf_member

    def name
      [first_name, last_name].select(&:present?).map(&:strip).join(' ')
    end

    def age
      return nil unless birthdate
      today = Date.current
      age = today.year - birthdate.year
      age -= 1 if today < birthdate + age.years
      age
    end
  end

  class User < ApplicationRecord
    belongs_to :billing_user, class_name: :User, optional: true
    belongs_to :contact_user, class_name: :User, optional: true
    belongs_to :guardian_1, class_name: :User, optional: true
    belongs_to :guardian_2, class_name: :User, optional: true

    has_one :member

    has_many :downstream_user_relationships, class_name: :UserRelationship, dependent: :destroy,
        inverse_of: :upstream_user, foreign_key: :upstream_user_id
    has_many :user_relationships, dependent: :destroy, inverse_of: :downstream_user, foreign_key: :downstream_user_id
    has_many :user_emails

    def name
      [first_name, last_name].select(&:present?).map(&:strip).join(' ')
    end
  end

  private

  def conflicting_user_exists?(mail, user_id, member_id)
    m = User.where.not(id: user_id).where(email: mail).or(User.where "email ilike '%<#{mail}>'").exists? ||
        Member.where.not(id: member_id).where(email: mail).or(Member.where "email ilike '%<#{mail}>'").exists?
    if member_id == 225
      puts "Conflicting user: #{m.inspect}"
    end
    m
  end

end
# rubocop: enable all
