require 'test_helper'

class JournalsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Journal.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Journal.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Journal.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to journal_url(assigns(:journal))
  end

  def test_edit
    get :edit, :id => Journal.first
    assert_template 'edit'
  end

  def test_update_invalid
    Journal.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Journal.first
    assert_template 'edit'
  end

  def test_update_valid
    Journal.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Journal.first
    assert_redirected_to journal_url(assigns(:journal))
  end

  def test_destroy
    journal = Journal.first
    delete :destroy, :id => journal
    assert_redirected_to journals_url
    assert !Journal.exists?(journal.id)
  end
end
