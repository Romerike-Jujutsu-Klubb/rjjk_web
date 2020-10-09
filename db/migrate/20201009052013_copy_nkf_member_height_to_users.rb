# frozen_string_literal: true

# rubocop: disable Rails/Output,Layout/LineLength
class CopyNkfMemberHeightToUsers < ActiveRecord::Migration[6.0]
  def change
    NkfMember.includes(member: :user)
        .sort_by { |nkfm| [nkfm.utmeldtdato.present? ? Date.parse(nkfm.utmeldtdato) : Date.tomorrow, nkfm.innmeldtdato] }.each do |nkfm|
      member = nkfm.member
      unless member
        puts "#{nkfm.fornavn} #{nkfm.etternavn}: No member"
        next
      end
      user = member.user
      puts "#{user.name}: ut: #{nkfm.utmeldtdato.inspect}, inn: #{nkfm.innmeldtdato.inspect} #{user.height.inspect} => #{nkfm.hoyde.inspect} #{user.email.inspect}"
      puts "Updated: #{user.height.inspect} => #{nkfm.hoyde}" if user.height.present?
      raise 'HOYDE is blank!' if nkfm.hoyde.blank?

      user.height = nkfm.hoyde
      user.save! validate: false
    end
  end
end
# rubocop: enable Rails/Output,Layout/LineLength
