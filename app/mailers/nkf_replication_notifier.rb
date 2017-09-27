# frozen_string_literal: true

class NkfReplicationNotifier
  def self.notify_wrong_contracts
    members = NkfMember.where(medlemsstatus: 'A').to_a
    wrong_contracts = members.select do |m|
      m.member && (
          (m.member.age < 10 && m.kont_sats !~ /^Barn/) ||
          (m.member.age >= 10 && m.member.age <= 25 && m.kont_sats !~ /^Ungdom|Trenere/) ||
          (m.member.age > 25 && m.kont_sats !~ /^(Voksne|Styre|Trenere|Æresmedlem)/)
      )
    end
    return if wrong_contracts.empty?
    recipient = Role[:Leder]
    NkfReplicationMailer.wrong_contracts(wrong_contracts).store(recipient, tag: :wrong_contracts)
  end
end
