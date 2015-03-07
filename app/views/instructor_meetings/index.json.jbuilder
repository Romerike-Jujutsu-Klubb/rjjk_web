json.array!(@instructor_meetings) do |instructor_meeting|
  json.extract! instructor_meeting, :id, :start_at, :end_at, :title, :agenda
  json.url instructor_meeting_url(instructor_meeting, format: :json)
end
