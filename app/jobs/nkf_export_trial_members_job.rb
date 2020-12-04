# frozen_string_literal: true

class NkfExportTrialMembersJob < ApplicationJob
  extend MonitorMixin
  include NkfForm

  queue_as :default

  def perform
    self.class.synchronize do
      logger.info 'Export trial memberships to NKF'
      new_signups = Signup.where(nkf_member_trial_id: nil).to_a
      if new_signups.any?
        new_signups.each do |signup|
          agent = NkfAgent.new(:signup)
          trial_form_page = agent.new_trial_form
          mapped_changes = signup.mapping_attributes(:new_trial)
          logger.info "Submitting new member trial to NKF: #{mapped_changes}"
          submit_form(trial_form_page, 'ks_bli_medlem', mapped_changes, :new_trial,
              submit_in_development: true)
          NkfReplicationMailer.export_signups(new_signups).deliver_now
          logger.info 'Sent NKF member trial export mail.'
        end
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
