# frozen_string_literal: true

require 'controller_test'

class NkfMemberTrialsControllerTest < ActionController::TestCase
  setup { login(:uwe) }

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create nkf_member_trial' do
    assert_difference('NkfMemberTrial.count') do
      post :create, params: { nkf_member_trial: {
        adresse_2: 'vei', epost: 'werwer@ertrt.br', epost_faktura: 'sefsdfd@sdfsdf.com',
        etternavn: 'Hansen', fodselsdato: '2000-01-01', fornavn: 'Erik',
        gren_stilart_avd_parti___gren_stilart_avd_parti: 'Jujutsu', innmeldtdato: '2012.03.14', kjonn: 'M',
        mobil: '12345678', postnr: '1234', reg_dato: '1999-12-31', tid: '12345678'
      } }
    end

    assert_redirected_to nkf_member_trial_path(NkfMemberTrial.last)
  end

  test 'should show nkf_member_trial' do
    get :show, params: { id: nkf_member_trials(:hans).to_param }
    assert_response :success
  end
end
