# frozen_string_literal: true

class CampsController < EventsController
  before_action { params[:event] ||= params[:camp] }
  # def self.local_prefixes
  #  super + ['events']
  # end
end
