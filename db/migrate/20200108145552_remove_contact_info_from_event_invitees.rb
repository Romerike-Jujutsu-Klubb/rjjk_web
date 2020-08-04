# frozen_string_literal: true

class RemoveContactInfoFromEventInvitees < ActiveRecord::Migration[6.0]
  def change
    fields = %i[name address]
    EventInvitee.includes(:user).each do |ei|
      raise "User is missing: #{ei.inspect}" unless ei.user

      fields.each do |field|
        ei_value = ei.send(field)
        user_value = ei.user.send(field)
        next unless ei_value.present? && ei_value != user_value
        if user_value.present?
          raise "User.#{field} differs (#{ei.id}): #{ei_value.inspect} <=> #{user_value.inspect}"
        end

        ei.user.update! field => ei_value
      end
      ei_email = ei.email
      if ei_email.present? && ei.user.emails.exclude?(ei_email)
        raise "User.email differs (#{ei.id}): #{ei_email.inspect} <=> #{ei.user.emails.inspect}"
      end

      ei_phone = ei.phone
      if ei_phone.present? && ei.user.phones.exclude?(ei_phone)
        if (existing_user = User.find_by(phone: ei_phone))
          ei.user.update! contact_user_id: existing_user.id
        else
          ei.user.update! phone: ei_phone
        end
      end
    end
    fields.each { |field| remove_column :event_invitees, field, :string }
    remove_column :event_invitees, :email, :string
    remove_column :event_invitees, :phone, :string
  end
end
