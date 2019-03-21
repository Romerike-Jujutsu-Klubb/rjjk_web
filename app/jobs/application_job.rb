# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  around_perform { |_job, block| PaperTrail.request(whodunnit: self.class.name) { block.call } }
end
