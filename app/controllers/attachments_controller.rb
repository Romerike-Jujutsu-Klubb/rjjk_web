# frozen_string_literal: true

class AttachmentsController < ApplicationController
  def destroy
    attachment = ActiveStorage::Attachment.find(params[:id])
    record = attachment.record
    attachment.purge
    back_or_redirect_to polymorphic_path(record, action: :edit), notice: 'Vedlegget ble slettet.'
  end
end
