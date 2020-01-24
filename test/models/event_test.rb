# frozen_string_literal: true

require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  def test_body
    assert_equal <<~TXT, events(:one).body
      Dette er den lange beskrivelsen.  Den har mye tekst.  Lorem ipsum etc.

      Dette er den lange beskrivelsen.  Den har mye tekst.  Lorem ipsum etc.

      Dette er den lange beskrivelsen.  Den har mye tekst.  Lorem ipsum etc.
    TXT
  end
end
