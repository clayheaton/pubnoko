require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Journal.new.valid?
  end
end
