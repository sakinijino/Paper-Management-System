require File.dirname(__FILE__) + '/../test_helper'
require 'j_controller'

# Re-raise errors caught by the controller.
class JController; def rescue_action(e) raise e end; end

class JControllerTest < Test::Unit::TestCase
  def setup
    @controller = JController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
