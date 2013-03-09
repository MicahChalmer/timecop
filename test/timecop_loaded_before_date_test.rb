# When this test is running under 'bundle exec', it "helpfully" adds
# '-rbundler/setup' to RUBYOPT, which in turn loads the Date/DateTime classes.
# But the bug we're trying to test for here only occurs if timecop was loaded
# before Date/DateTime.  So we have to detect if Date was already loaded here
# and re-execute ourself without that.
if defined?(Date)
  puts "Date already exists...reloading myself without bundler/setup"
  Kernel.exec({'RUBYOPT'=>ENV['RUBYOPT'].gsub(%r{-rbundler/setup},'')},
    (ENV['RUBY'] || 'ruby'), '-I../lib:.', __FILE__)
end

# Require timecop first, before anything else that would load 'date'
require File.join(File.dirname(__FILE__), '..', 'lib', 'timecop')
require File.join(File.dirname(__FILE__), "test_helper")

class TestTimecopWithoutDate < Test::Unit::TestCase
  # just in case...let's really make sure that Timecop is disabled between tests...
  def teardown
    Timecop.return
  end

  def test_freeze_changes_and_resets_date
    t = Date.new(2008, 10, 10)
    assert_not_equal t, Date.today
    Timecop.freeze(2008, 10, 10) do
      assert_equal t, Date.today
    end
    assert_not_equal t, Date.today
  end
end
