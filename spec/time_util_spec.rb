$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'test/unit'
require 'timecop'

require 'icalendar/recurrence'

class TestTimeUtil < Test::Unit::TestCase
  include Icalendar::Recurrence

  test "converts DateTimee to Time, preserving UTC offset" do
    utc_datetime = Icalendar::Values::DateTime.new(DateTime.parse("20140114T180000Z"))
    assert_equal 0, TimeUtil.datetime_to_time(utc_datetime).utc_offset, "UTC datetime converts to time with no offset"

    pst_datetime = Icalendar::Values::DateTime.new(DateTime.parse("2014-01-27T12:55:21-08:00"))
    assert_equal -8*60*60, TimeUtil.datetime_to_time(pst_datetime).utc_offset, "PST datetime converts to time with 8 hour offset"
  end

  test "converts DateTime to Time correctly" do
    datetime = Icalendar::Values::DateTime.new(DateTime.parse("2014-01-27T12:55:21-08:00"))
    correct_time = Time.parse("2014-01-27T12:55:21-08:00")
    assert_equal correct_time, TimeUtil.datetime_to_time(datetime), "Converts DateTime to Time object with correct time"
  end

  test "DateTime with icalendar_tzid  overrides utc offset when coverted to a Time object" do
    datetime = Icalendar::Values::DateTime.new(DateTime.parse("2014-01-27T12:55:21+00:00"), "tzid" => "America/Los_Angeles")
    
    assert_equal Time.parse("2014-01-27T12:55:21-08:00"), TimeUtil.to_time(datetime)
  end

  test "converts Date to Time correctly" do
    assert_equal Time.parse("2014-01-01"), TimeUtil.date_to_time(Date.parse("2014-01-01")), "Converts Date to Time object"
  end

  test ".timezone_to_hour_minute_utc_offset" do
    Timecop.freeze("2014-01-01") # avoids DST changing offsets on us
    assert_equal "-08:00", TimeUtil.timezone_to_hour_minute_utc_offset("America/Los_Angeles"),                           "Handles negative offsets"
    assert_equal "+01:00", TimeUtil.timezone_to_hour_minute_utc_offset("Europe/Amsterdam"),                              "Handles positive offsets"
    assert_equal "+00:00", TimeUtil.timezone_to_hour_minute_utc_offset("GMT"),                                           "Handles UTC zones"
    assert_equal nil,      TimeUtil.timezone_to_hour_minute_utc_offset("Foo/Bar"),                                       "Returns nil when it doesn't know about the timezone"
    assert_equal "-08:00", TimeUtil.timezone_to_hour_minute_utc_offset("\"America/Los_Angeles\""),                       "Handles quoted strings (you get these from ICS files)"
    assert_equal "-07:00", TimeUtil.timezone_to_hour_minute_utc_offset("America/Los_Angeles", Date.parse("2014-05-01")), "Handles daylight savings offset"
    Timecop.return
  end

  test ".timezone_to_hour_minute_utc_offset (daylight savings cases)" do
    # FYI, clocks turn forward an hour on Nov 2 at 9:00:00 UTC
    minute_before_clocks_change = Time.parse("Nov 2 at 08:59:00 UTC") # on west coast
    actual = TimeUtil.timezone_offset("America/Los_Angeles", moment: minute_before_clocks_change)
    assert_equal "-07:00", actual, "Correctly determines offset at shortly before it occurs"

    minute_after_clocks_change = Time.parse("Nov 2 at 09:01:00 UTC") # on west coast
    actual = TimeUtil.timezone_offset("America/Los_Angeles", moment: minute_after_clocks_change)
    assert_equal "-08:00", actual, "Correctly determines offset at shortly after it occurs"
  end
end