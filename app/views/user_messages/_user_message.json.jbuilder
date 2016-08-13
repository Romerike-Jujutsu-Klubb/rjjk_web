json.extract! user_message, :id, :user_id, :tag, :from, :subject, :key, :body, :sent_at, :read_at, :created_at, :updated_at
json.url user_message_url(user_message, format: :json)