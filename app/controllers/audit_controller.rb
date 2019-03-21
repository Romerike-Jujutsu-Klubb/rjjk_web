# frozen_string_literal: true

class AuditController < ApplicationController
  def index
    @versions = PaperTrail::Version
        .where(item_type: params[:item_type], item_id: params[:item_id])
        .order(created_at: :desc)
        .to_a
  end
end
