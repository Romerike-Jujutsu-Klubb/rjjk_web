class NkfReplicationNotifier
  def self.notify_wrong_contracts
    members = NkfMember.where(medlemsstatus: 'A').all
    wrong_contracts = members.select do |m|
      m.member &&
          (m.member.age < 10 && m.kont_sats !~ /^Barn/) ||
          (m.member.age >= 10 && m.member.age < 15 && m.kont_sats !~ /^Ungdom|Trenere/) ||
          (m.member.age >= 15 && m.kont_sats !~ /^(Voksne|Styre|Trenere|Æresmedlem)/)
    end
    if wrong_contracts.any?
      recipient = Role[:Kasserer] || Role[:Leder]
      NkfReplicationMailer.wrong_contracts(wrong_contracts).store(recipient, tag: :wrong_contracts)
    end
  rescue
    logger.error "Exception sending contract message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end
end
