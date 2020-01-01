# frozen_string_literal: true

class MoveApplicationStepsToApplicationImageSequence < ActiveRecord::Migration[5.2]
  def change
    add_reference :application_steps, :application_image_sequence, foreign_key: true
    add_index :application_steps, %i[application_image_sequence_id position], unique: true,
        name: 'idx_application_steps__application_image_sequence_id__position'
    TechniqueApplication.all.each do |ta|
      steps_query = ApplicationStep.where(technique_application_id: ta.id)
      next if steps_query.empty?

      ais = ApplicationImageSequence.create! technique_application_id: ta.id, position: 1
      steps_query.update_all application_image_sequence_id: ais.id # rubocop: disable Rails/SkipsModelValidations
    end
    remove_column :application_steps, :technique_application_id, :integer
  end
end
