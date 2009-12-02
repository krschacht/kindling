require 'test_helper'

class AccessoriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:accessories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create accessory" do
    assert_difference('Accessory.count') do
      post :create, :accessory => { }
    end

    assert_redirected_to accessory_path(assigns(:accessory))
  end

  test "should show accessory" do
    get :show, :id => accessories(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => accessories(:one).to_param
    assert_response :success
  end

  test "should update accessory" do
    put :update, :id => accessories(:one).to_param, :accessory => { }
    assert_redirected_to accessory_path(assigns(:accessory))
  end

  test "should destroy accessory" do
    assert_difference('Accessory.count', -1) do
      delete :destroy, :id => accessories(:one).to_param
    end

    assert_redirected_to accessories_path
  end
end
