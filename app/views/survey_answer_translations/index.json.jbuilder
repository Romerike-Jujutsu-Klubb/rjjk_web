json.array!(@survey_answer_translations) do |survey_answer_translation|
  json.extract! survey_answer_translation, :id, :answer, :normalized_answer
  json.url survey_answer_translation_url(survey_answer_translation, format: :json)
end
