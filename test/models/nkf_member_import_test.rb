require 'test_helper'

class NkfMemberImportTest < ActiveSupport::TestCase
  def test_import_members
    NkfMemberImport.import_nkf_changes
  end
end
