# frozen_string_literal: true

require 'test_helper'

class MemberHistoryGraphTest < ActiveSupport::TestCase
  def test_history_graph
    MemberHistoryGraph.data_set
  end
end
