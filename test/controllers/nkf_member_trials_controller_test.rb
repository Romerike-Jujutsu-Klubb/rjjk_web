require File.dirname(__FILE__) + '/../test_helper'

class NkfMemberTrialsControllerTest < ActionController::TestCase
  def setup
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:nkf_member_trials)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create nkf_member_trial' do
    assert_difference('NkfMemberTrial.count') do
      post :create, nkf_member_trial: {
          adresse: 'vei', alder: 16, epost: 'werwer@ertrt.br', epost_faktura: 'sefsdfd@sdfsdf.com',
          etternavn: 'Hansen', fodtdato: '2000-01-01', fornavn: 'Erik', medlems_type: 'EnkeltMedlem',
          mobil: '12345678', postnr: '1234', reg_dato: '2012.03.14', res_sms: '0', sted: 'sted',
          stilart: 'Jujutsu', tid: '12345678'
      }
      assert_no_errors :nkf_member_trial
    end

    assert_redirected_to nkf_member_trial_path(assigns(:nkf_member_trial))
  end

  test 'should show nkf_member_trial' do
    get :show, id: nkf_member_trials(:one).to_param
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: nkf_member_trials(:one).to_param
    assert_response :success
  end

  test 'should update nkf_member_trial' do
    put :update, id: nkf_member_trials(:one).to_param, nkf_member_trial: {}
    assert_no_errors :nkf_member_trial
    assert_redirected_to nkf_member_trial_path(assigns(:nkf_member_trial))
  end

  test 'should destroy nkf_member_trial' do
    assert_difference('NkfMemberTrial.count', -1) do
      delete :destroy, id: nkf_member_trials(:one).to_param
    end

    assert_redirected_to nkf_member_trials_path
  end
end
