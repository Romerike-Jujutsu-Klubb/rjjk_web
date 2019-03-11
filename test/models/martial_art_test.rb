# frozen_string_literal: true

require File.dirname(__FILE__) + '/../test_helper'

class MartialArtTest < ActiveSupport::TestCase
  def test_kwr?
    martial_arts = MartialArt.order(:name).to_a
    assert_equal [false, true], martial_arts.map(&:kwr?)
  end
end
