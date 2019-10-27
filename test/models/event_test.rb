# frozen_string_literal: true

require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  def test_body
    assert_equal <<~TXT, events(:one).body
      This is the long explanation.  It has a lot of text.  Lorem ipsum etc.

      This is the long explanation.  It has a lot of text.  Lorem ipsum etc.

      This is the long explanation.  It has a lot of text.  Lorem ipsum etc.
    TXT
  end
end
