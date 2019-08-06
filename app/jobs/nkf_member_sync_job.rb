# frozen_string_literal: true

class NkfMemberSyncJob < ApplicationJob
  queue_as :default

  def perform(member)
    c = NkfMemberComparison.new(member)
    c.sync
    NkfReplicationMailer.update_members(c).deliver_now if c.errors.any?
    NkfMemberImport.new(member.nkf_member.medlemsnummer)
    report_differences(member.reload)
  end

  private

  def report_differences(member)
    member.nkf_member.attributes.sort.each do |k, v|
      target, mapped_key, mapped_value = NkfMember.rjjk_attribute(k, v)
      next unless mapped_key

      rjjk_value = member.send(target)&.send(mapped_key)
      v = v.strftime('%F %R') if v.is_a?(Time)
      if mapped_value != rjjk_value
        raise "NKF sync: #{member.id} #{k}: #{v}: #{target}, #{mapped_key}, #{mapped_value.inspect}"
      end
    rescue => e
      ExceptionNotifier.notify_exception(e)
    end
  end
end
