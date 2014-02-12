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
    return if pages.empty?
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
    page = InformationPage.where('
(hidden IS NULL OR hidden = ?) AND
(revised_at > ?) AND
(mailed_at IS NULL OR mailed_at < ?)', false, 6.months.ago, 6.months.ago).
        order(:mailed_at).first
    if page
      Member.active(Date.today).order(:first_name, :last_name).each do |m|
        if m.user
          InformationPageMailer.send_weekly_page(m, page).deliver
        else
          logger.error "Member without user: #{m.inspect}"
        end
      end
      page.update_attributes! :mailed_at => Time.now
    end
  rescue
    logger.error 'Execption sending news'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

end
