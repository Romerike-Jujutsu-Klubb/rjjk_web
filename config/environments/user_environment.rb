module UserSystem
  CONFIG = {
    # Source address for user emails
    :email_from => 'uwe@kubosch.no',

    # Destination email for system errors
    :admin_email => 'uwe@kubosch.no',

    # Sent in emails to users
    :app_url => 'http://jujutsu.no/',

    # Sent in emails to users
    :app_name => 'RJJK\'s Nettsted',

    # Email charset
    :mail_charset => 'utf-8',

    # Security token lifetime in hours
    :security_token_life_hours => 24 * 7,
  }
end
