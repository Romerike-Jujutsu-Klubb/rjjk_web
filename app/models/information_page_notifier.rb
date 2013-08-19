class InformationPageNotifier
# Flow:
#   Pages should be reviewed at least every 6 months.
#   Old reviewed pages should be sent to new members
#   New pages should be sent to all active members
#   Newly revised pages should be sent to all members unless they got it within the last 6 months,
#     or the change is significat (or should that be in a news item?)
  def self.notify_outdated_pages
    recipients = Member.active(Date.today).includes(:user).where('users.role = ?', 'ADMIN').all
    pages = InformationPage.where('(hidden IS NULL OR hidden = ?) AND (revised_at IS NULL OR revised_at < ?)', false, 6.months.ago).
        order(:revised_at).limit(3).all
    recipients.each do |recipient|
      InformationPageMailer.notify_outdated_pages(recipient, pages).deliver
    end
  rescue
    logger.error 'Execption sending information page notification'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

# Flow:
#   Pages should be reviewed at least every 6 months.
#   Old reviewed pages should be sent to new members
#   New pages should be sent to all active members
#   Newly revised pages should be sent to all members unless they got it within the last 6 months,
#     or the change is significat (or should that be in a news item?)
  def self.send_weekly_info_page
    logger.debug 'Sending weekly info page'
    page = InformationPage.where("
(hidden IS NULL OR hidden = ?) AND
(revised_at > CURRENT_TIMESTAMP - interval '6' month) AND
(mailed_at IS NULL OR mailed_at < CURRENT_TIMESTAMP - interval '6' month)", false).
        order(:mailed_at).first
    if page
      Member.active(Date.today).order(:first_name, :last_name).all.each do |m|
        InformationPageMailer.send_weekly_page(m, page).deliver
      end
      page.update_attributes! :mailed_at => Time.now
    end
    logger.debug 'Sending weekly info page...OK'
  rescue
    logger.error 'Execption sending news'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

end
