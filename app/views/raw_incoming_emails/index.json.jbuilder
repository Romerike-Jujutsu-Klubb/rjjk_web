json.array!(@raw_incoming_emails) do |raw_incoming_email|
  json.extract! raw_incoming_email, :id, :content
  json.url raw_incoming_email_url(raw_incoming_email, format: :json)
end
