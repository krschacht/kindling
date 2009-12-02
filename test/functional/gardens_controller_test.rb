require 'test_helper'

class GardensControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gardens)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create garden" do
    assert_difference('Garden.count') do
      post :create, :garden => { }
    end

    assert_redirected_to garden_path(assigns(:garden))
  end

  test "should show garden" do
    get :show, :id => gardens(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => gardens(:one).to_param
    assert_response :success
  end

  test "should update garden" do
    put :update, :id => gardens(:one).to_param, :garden => { }
    assert_redirected_to garden_path(assigns(:garden))
  end

  test "should destroy garden" do
    assert_difference('Garden.count', -1) do
      delete :destroy, :id => gardens(:one).to_param
    end

    assert_redirected_to gardens_path
  end
end
