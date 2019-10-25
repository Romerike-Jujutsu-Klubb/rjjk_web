# frozen_string_literal: true

class NkfReplicationMailer < ApplicationMailer
  default to: 'uwe@kubosch.no'

  def import_changes(nkf_member_import)
    @import = nkf_member_import
    @title = if @import.exception
               'Det oppsto en feil ved henting av endringer fra NKF'
             else
               "Hentet #{@import.size} endringer fra NKF"
             end
    mail subject: @title
  end

  def update_members(comparison)
    @new_members = comparison.new_members
    @outgoing_changes = comparison.outgoing_changes
    @errors = comparison.errors
    stats = [
      @new_members.any? ? "#{@new_members.size} nye" : nil,
      @errors.any? ? "#{@errors.size} feil" : nil,
    ].compact.join(', ')
    mail subject: "Oppdateringer fra NKF: #{stats}"
  end

  def update_appointments(appointments)
    @appointments = appointments
    mail subject: "Verv fra NKF: #{appointments.size}"
  end
end
