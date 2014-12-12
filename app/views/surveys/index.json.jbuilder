json.array!(@surveys) do |survey|
  json.extract! survey, :id, :category, :group_id, :title, :position, :expires_at, :header, :footer
  json.url survey_url(survey, format: :json)
end
