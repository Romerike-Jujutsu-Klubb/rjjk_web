# frozen_string_literal: true

require 'controller_test'

class ImagesControllerTest < ActionController::TestCase
  fixtures :images

  def setup
    @first_id = images(:one).id
    @application_step = application_steps(:one)
    login(:admin)
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:images)
  end

  def test_show
    get :show, params: { id: @first_id, format: 'png' }
    assert_response :success
  end

  def test_inline
    get :inline, params: { id: @first_id, format: 'png' }
    assert_response :success
  end

  %i[show inline].each do |action|
    test "should hide #{action} image from public user" do
      logout
      get action, params: { id: @application_step.image_id, width: 320, format: :jpg }
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "should #{action} image to unranked member" do
      login :newbie
      get action, params: { id: @application_step.image_id, width: 320, format: :jpg }
      assert_response :success
    end

    test "should hide high-rank #{action} image from unranked member" do
      login :newbie
      get action, params: { id: id(:application_step_kneeing), width: 320, format: :jpg }
      assert_redirected_to login_path
    end

    test "should #{action} image to ranked member" do
      login :lars
      get action, params: { id: @application_step, width: 320, format: :jpg }
      assert_response :success
    end

    test "should redirect #{action} to dummy image if no image content" do
      login :lars
      get action, params: { id: application_steps(:two).image_id, width: 320, format: :jpg }
      assert_response :redirect
      assert_redirected_to \
          '/assets/pdficon_large-f755e8f306b39714f4efa5d7928e1a54b29571e78af77c96c95f950528468cb4.png'
    end
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:image)
  end

  def test_create
    login :lars

    assert_difference('Image.count') do
      post :create, params: { image: { name: 'new file', content_type: 'image/png', content_data: 'qwerty' } }
    end

    assert_response :redirect
    assert_redirected_to action: :gallery, id: assigns(:image).id
    image = Image.last
    assert_equal 'new file', image.name
    assert_equal 'image/png', image.content_type
    assert_equal 6, image.content_data.length
  end

  def test_create_with_file
    images(:one).destroy! # same content
    login :lars

    assert_difference('Image.count') do
      post :create, params: { image: {
        name: 'new file', content_type: 'image/png', file: fixture_file_upload('files/tiny.png')
      } }
    end

    assert_response :redirect
    assert_redirected_to action: :gallery, id: assigns(:image).id
    image = Image.last
    assert_equal 'new file', image.name
    assert_equal 'image/png', image.content_type
    assert_equal 67, image.content_data.length
  end

  def test_create_with_file_gets_name
    images(:one).destroy! # same content
    login :lars

    assert_difference('Image.count') do
      post :create, params: { image: { file: fixture_file_upload('files/tiny.png', 'image/png') } }
    end

    assert_response :redirect
    assert_redirected_to action: :gallery, id: assigns(:image).id
    image = Image.last
    assert_equal 'tiny.png', image.name
    assert_equal 'image/png', image.content_type
    assert_equal 67, image.content_data.length
  end

  def test_create_same_content_fails
    login :lars

    assert_no_difference('Image.count') do
      post :create, params: { image: { file: fixture_file_upload('files/tiny.png') } }
    end

    assert_response :success
  end

  def test_edit
    get :edit, params: { id: @first_id }

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:image)
    assert assigns(:image).valid?
  end

  def test_edit_without_local_content
    Image.find(@first_id).update!(content_data: nil)

    get :edit, params: { id: @first_id }

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:image)
    assert assigns(:image).valid?
  end

  def test_update
    post :update, params: { id: @first_id, image: { approved: true } }
    assert_response :redirect
    assert_redirected_to action: :edit, id: @first_id
  end

  def test_destroy
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

  def test_gallery
    VCR.use_cassette('GoogleDriveGallery') do
      get :gallery, params: { id: @first_id }
    end

    assert_response :success
    assert_template 'gallery'
    assert_not_nil assigns(:images)
  end

  def test_mine
    VCR.use_cassette('GoogleDriveGallery') do
      get :mine
    end

    assert_response :success
    assert_template 'gallery'
    assert_not_nil assigns(:images)
  end
end
