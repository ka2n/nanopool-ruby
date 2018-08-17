require "test_helper"

class Nanopool::VersionTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Nanopool::VERSION
  end
end
