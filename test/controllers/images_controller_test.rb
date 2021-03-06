# frozen_string_literal: true

require 'controller_test'

class ImagesControllerTest < ActionController::TestCase
  def setup
    @first_id = id(:one)
    login(:uwe)
  end

  def test_index
    get :index
    assert_response :success
  end

  %i[show inline].each do |action|
    test action.to_s do
      get action, params: { id: @first_id, format: 'png' }
      assert_response :success
    end

    test "should redirect #{action} image to correct extension" do
      get action, params: { id: id(:one), width: 320, format: :jpeg }
      assert_redirected_to "http://test.host/images/980190962/#{action}/320.png"
    end

    test "should hide #{action} image from public user" do
      logout
      get action, params: { id: id(:application_step_one), width: 320, format: :jpg }
      assert_redirected_to login_path
    end

    test "should #{action} image to unranked member" do
      login :newbie
      get action, params: { id: id(:application_step_one), width: 320, format: :png }
      assert_response :success
    end

    test "should hide high-rank #{action} image from unranked member" do
      login :newbie
      get action, params: { id: id(:application_step_kneeing), width: 320, format: :jpg }
      assert_redirected_to login_path
    end

    test "should #{action} image to ranked member" do
      login :lars
      get action, params: { id: id(:application_step_one), width: 320, format: :png }
      assert_response :success
    end
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    login :lars

    assert_difference('Image.count') do
      post :create, params: { image: { name: 'new file', content_type: 'image/png', content_data: 'qwerty',
                                       content_length: 6 } }
    end

    assert_response :redirect
    image = Image.last
    assert_redirected_to action: :gallery, id: image.id
    assert_equal 'new file', image.name
    assert_equal 'image/png', image.content_type
    assert_equal 6, image.content_data.length
  end

  def test_create_with_file
    FrontPageSection.destroy_all
    ApplicationVideo.destroy_all
    images(:one).destroy! # same content
    login :lars

    assert_difference('Image.count') do
      post :create, params: { image: {
        name: 'new file', content_type: 'image/png', file: fixture_file_upload('tiny.png')
      } }
    end

    assert_response :redirect
    image = Image.last
    assert_redirected_to action: :gallery, id: image.id
    assert_equal 'new file', image.name
    assert_equal 'image/png', image.content_type
    assert_equal 67, image.content_data.length
  end

  def test_create_with_file_gets_name
    FrontPageSection.destroy_all
    application_videos(:one).destroy! # linked
    images(:one).destroy! # same content
    login :lars

    assert_difference('Image.count') do
      post :create, params: { image: { file: fixture_file_upload('tiny.png', 'image/png') } }
    end

    assert_response :redirect
    image = Image.last
    assert_redirected_to action: :gallery, id: image.id
    assert_equal 'tiny.png', image.name
    assert_equal 'image/png', image.content_type
    assert_equal 67, image.content_data.length
  end

  def test_create_same_content_fails
    login :lars

    assert_no_difference('Image.count') do
      post :create, params: { image: { file: fixture_file_upload('tiny.png') } }
    end

    assert_response :success
  end

  def test_edit
    get :edit, params: { id: @first_id }
    assert_response :success
  end

  def test_edit_without_local_content
    Image.find(@first_id).update!(content_data: nil)
    get :edit, params: { id: @first_id }
    assert_response :success
  end

  def test_update
    post :update, params: { id: @first_id, image: { approved: true } }
    assert_response :redirect
    assert_redirected_to action: :edit, id: @first_id
  end

  def test_reset_google_drive_reference_without_reference
    post :reset_google_drive_reference, params: { id: @first_id }
    assert_redirected_to action: :edit, id: @first_id
    assert_equal 'Bildet har ingen Google Drive referanse.', flash.alert
  end

  def test_reset_google_drive_reference_with_content
    images(:one).update! google_drive_reference: '127EAyqzeJaMogPtwNE1xfTFVtElFJuAy'
    VCR.use_cassette('GoogleDriveImage', match_requests_on: %i[method host path query]) do
      post :reset_google_drive_reference, params: { id: @first_id }
    end
    assert_redirected_to action: :edit, id: @first_id
    assert_equal 'Bildet er ikke tomt.', flash.alert
  end

  def test_reset_google_drive_reference_with_empty_file
    images(:one).update! google_drive_reference: '127EAyqzeJaMogPtwNE1xfTFVtElFJuAy'
    VCR.use_cassette('GoogleDriveEmptyFile', match_requests_on: %i[method host path query]) do
      post :reset_google_drive_reference, params: { id: @first_id }
    end
    assert_redirected_to action: :edit, id: @first_id
    assert_equal 'Google drive referanse er nullstilt.', flash.notice
  end

  def test_destroy
    ApplicationVideo.destroy_all
    FrontPageSection.destroy_all
    assert_nothing_raised do
      Image.find(@first_id)
    end

    post :destroy, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      Image.find(@first_id)
    end
  end

  def test_destroy_fails_for_existing_front_page_section
    assert_raise(ActiveRecord::InvalidForeignKey) do
      post :destroy, params: { id: id(:front_page_1) }
    end
  end

  def test_gallery
    VCR.use_cassette('GoogleDriveGallery') do
      get :gallery, params: { id: @first_id }
    end

    assert_response :success
  end

  def test_mine
    VCR.use_cassette('GoogleDriveGallery') do
      get :mine
    end

    assert_response :success
  end
end
