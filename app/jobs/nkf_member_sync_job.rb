# frozen_string_literal: true

class NkfMemberSyncJob < ApplicationJob
  queue_as :default

  def perform(member)
    c = NkfMemberComparison.new(member).sync
    NkfReplicationMailer.update_members(c).deliver_now if c.errors.any?
    NkfMemberImport.new(member.nkf_member.medlemsnummer)
    report_differences(member.reload)
  end

  private

  def report_differences(member)
    nkf_member = member.nkf_member
    nkf_member.mapping_changes.each do |changes|
      target, target_attr, rjjk_value, nkf_value =
          changes.fetch_values(:target, :target_attribute, :mapped_rjjk_value, :nkf_value)
      raise "Failed to synchronize value with NKF member: id: #{member.id}, " \
          "RJJK: #{target}.#{target_attr}: #{rjjk_value.inspect}, NKF: #{k}: #{nkf_value.inspect}"
    rescue => e
      ExceptionNotifier.notify_exception(e)
    end
  end
end
