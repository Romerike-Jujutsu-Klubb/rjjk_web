# frozen_string_literal: true

class NkfSynchronizationJob < ApplicationJob
  queue_as :default

  def perform
    import
    compare
    import_appointments
  end

  private

  def import
    logger.info 'Import memberships from NKF'
    i = NkfMemberImport.new
    if i.any?
      NkfReplicationMailer.import_changes(i).deliver_now
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
