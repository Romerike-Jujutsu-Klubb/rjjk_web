# frozen_string_literal: true

class NkfMemberSyncJob < ApplicationJob
  queue_as :default

  def perform(member)
    NkfMemberComparison.new.sync_member(member)
    NkfMemberImport.new(member.nkf_member.medlemsnummer)
  end
end
