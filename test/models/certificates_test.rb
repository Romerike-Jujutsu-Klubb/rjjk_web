require 'test_helper'

class CertificatesTest < ActiveSupport::TestCase
  setup do
    @content = [
        {
            name: 'Jusse Nyleny', rank: 'Supreme Being',
            censor1: { title: 'Santa', name: 'Claus',
                signature: images(:one).content_data },
            censor2: { title: 'Easter', name: 'Bunny' },
            censor3: { title: 'Tooth', name: 'Fairy' },
        },
        {
            name: 'Heinz Doofenschmirz', rank: 'Ruler of the tristate area',
            censor1: { title: 'Santa', name: 'Claus' },
            censor2: { title: 'Easter', name: 'Bunny' },
            censor3: { title: 'Tooth', name: 'Fairy' },
        },
    ]
  end

  teardown do
    @content = nil
  end

  test 'pdf' do
    doc = Certificates.pdf(Date.new(2015, 5, 21), @content)
    assert doc
  end

  test 'pdf layout 1' do
    doc = Certificates.pdf(Date.new(2015, 5, 21), @content, 1)
    assert doc
  end

  test 'pdf layout 2' do
    doc = Certificates.pdf(Date.new(2015, 5, 21), @content, 2)
    assert doc
  end
end
