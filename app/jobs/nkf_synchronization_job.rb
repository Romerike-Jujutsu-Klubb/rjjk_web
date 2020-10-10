# frozen_string_literal: true

class NkfSynchronizationJob < ApplicationJob
  extend MonitorMixin

  queue_as :default

  def perform
    self.class.synchronize do
      import
      comparison = compare
      import if comparison.any?
      import_appointments
    end
  end

  private

  def import
    logger.info 'Import memberships from NKF'
    i = NkfMemberImport.new
    trial_import = NkfMemberTrialImport.new i.nkf_agent
    if i.any? || trial_import.any?
      NkfReplicationMailer.import_changes(i, trial_import).deliver_now
      logger.info 'Sent NKF member import mail.'
      logger.info 'Oppdaterer kontrakter'
      NkfMember.update_group_prices
    end
  rescue => e
    handle_exception('Execption sending NKF import email.', e)
  end

  def compare
    ActiveRecord::Base.transaction do
      c = NkfMemberComparison.new.sync
      if c.any?
        NkfReplicationMailer.update_members(c).deliver_now
        logger.info 'Sent update_members mail.'
      end
      c
    end
  rescue => e
    handle_exception('Execption sending update_members email.', e)
  end

  def import_appointments
    a = NkfAppointmentsScraper.import_appointments
    NkfReplicationMailer.update_appointments(a).deliver_now if a.any?
  rescue => e
    handle_exception('Execption sending update_appointments email.', e)
  end

  def handle_exception(context, e)
    logger.error context
    logger.error "#{e.class} #{e.message}"
    logger.error e.backtrace.join("\n")
    ExceptionNotifier.notify_exception(e)
    raise if Rails.env.test?
  end
end
