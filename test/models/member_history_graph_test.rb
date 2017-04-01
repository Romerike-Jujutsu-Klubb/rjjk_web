# frozen_string_literal: true

require 'test_helper'

class MemberHistoryGraphTest < ActiveSupport::TestCase
  def test_history_graph
    MemberHistoryGraph.history_graph
  end
end
