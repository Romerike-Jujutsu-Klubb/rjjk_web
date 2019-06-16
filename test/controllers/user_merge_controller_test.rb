# frozen_string_literal: true

require 'integration_test'

class UserMergeControllerTest < IntegrationTest
  test 'show' do
    get user_merge_path(id(:uwe))
  end
end
