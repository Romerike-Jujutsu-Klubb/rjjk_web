json.array!(@survey_requests) do |survey_request|
  json.extract! survey_request, :id, :survey_id, :member_id, :completed_at
  json.url survey_request_url(survey_request, format: :json)
end
