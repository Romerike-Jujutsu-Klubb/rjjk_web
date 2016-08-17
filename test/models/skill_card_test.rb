# frozen_string_literal: true
require 'test_helper'

class SkillCardTest < ActiveSupport::TestCase
  test 'pdf' do
    doc = SkillCard.pdf([ranks(:kyu_5), ranks(:kyu_4), ranks(:kyu_1)])
    assert doc
  end
end
