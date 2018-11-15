# frozen_string_literal: true

class NkfMemberSyncJob < ApplicationJob
  queue_as :default

  def perform(member)
    NkfMemberComparison.new(member).sync
    NkfMemberImport.new(member.nkf_member.medlemsnummer)
  end
end
