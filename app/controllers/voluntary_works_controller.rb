# frozen_string_literal: true

class VoluntaryWorksController < EventsController
  before_action {params[:event] ||= params[:voluntary_work]}
  # def self.local_prefixes
  #  super + ['events']
  # end
end
