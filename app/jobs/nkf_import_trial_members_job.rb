# frozen_string_literal: true

class NkfImportTrialMembersJob < ApplicationJob
  extend MonitorMixin

  queue_as :default

  def perform
    self.class.synchronize do
      logger.info 'Import trial memberships from NKF'
      trial_import = NkfMemberTrialImport.new
      if trial_import.any?
        NkfReplicationMailer.import_changes(nil, trial_import).deliver_now
        logger.info 'Sent NKF member trial import mail.'
      end
    end
  end

  private

  def handle_exception(context, exception)
    logger.error context
    logger.error "#{exception.class} #{exception.message}"
    logger.error exception.backtrace.join("\n")
    ExceptionNotifier.notify_exception(exception)
    raise if Rails.env.test?
  end
end
