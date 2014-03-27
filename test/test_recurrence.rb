class TestEventRecurrence < Test::Unit::TestCase
  include Icalendar

  # Added for convenience in tests
  class Icalendar::Event
    def start_time
      Icalendar::TimeUtil.to_time(start)
    end
  end

  test "occurrences_between with a daily event" do
    daily_event = example_event :daily
    occurrences = daily_event.occurrences_between(daily_event.start_time, daily_event.start_time + 2.days)

    assert_equal 2,                        occurrences.length,        "Event has 2 occurrences over 3 days"
    assert_equal Time.parse("2014-01-27"), occurrences.first.start_time, "Event occurrs on the 27th"
    assert_equal Time.parse("2014-01-29"), occurrences.last.start_time,  "Event occurrs on the 29th"
  end

  test "occurrences_between with an every-other-day event" do
    every_other_day_event = example_event :every_other_day
    start_time = every_other_day_event.start_time
    occurrences = every_other_day_event.occurrences_between(start_time, start_time + 5.days)

    assert_equal 3, occurrences.length, "Event has 3 occurrences over 6 days"
    assert_equal Time.parse("2014-01-27"), occurrences[0].start_time, "Event occurs on the 27th"
    assert_equal Time.parse("2014-01-29"), occurrences[1].start_time, "Event occurs on the 29th"
    assert_equal Time.parse("2014-01-31"), occurrences[2].start_time, "Event occurs on the 31st"
  end

  test "occurrences_between with an every-monday event" do
    every_monday_event = example_event :every_monday
    start_time = every_monday_event.start_time
    occurrences = every_monday_event.occurrences_between(start_time, start_time + 8.days)

    assert_equal 2, occurrences.length, "Event has 2 occurrences over 8 days"
    assert_equal Time.parse("2014-02-03 at 4pm"), occurrences[0].start_time, "Event occurs on the 3rd"
    assert_equal Time.parse("2014-02-10 at 4pm"), occurrences[1].start_time, "Event occurs on the 10th"
  end

  test "occurrences_between with a mon,wed,fri weekly event" do
    multi_day_weekly_event = example_event :multi_day_weekly
    start_time = multi_day_weekly_event.start_time
    occurrences = multi_day_weekly_event.occurrences_between(start_time, start_time + 7.days)

    assert_equal 3, occurrences.length, "Event has 3 occurrences over 7 days"
    assert_equal Time.parse("2014-02-03 16:00:00 -0800"), occurrences[0].start_time, "Event occurs on the 3rd"
    assert_equal Time.parse("2014-02-05 16:00:00 -0800"), occurrences[1].start_time, "Event occurs on the 10th"
    assert_equal Time.parse("2014-02-07 16:00:00 -0800"), occurrences[2].start_time, "Event occurs on the 10th"
  end

  test "occurrences_between with monthy event (dst example)" do
    on_third_every_two_months_event = example_event :on_third_every_two_months
    start_time = on_third_every_two_months_event.start_time
    occurrences = on_third_every_two_months_event.occurrences_between(start_time, start_time + 60.days)

    assert_equal 2, occurrences.length, "Event has 2 occurrences over 61 days"
    assert_equal Time.parse("2014-02-03 16:00:00 -0800"), occurrences[0].start_time, "Event occurs on February 3rd"
    assert_equal Time.parse("2014-04-03 16:00:00 -0700"), occurrences[1].start_time, "Event occurs on April 3rd"
  end

  test "occurrences_between with yearly event" do
    first_of_every_year_event = example_event :first_of_every_year
    start_time = first_of_every_year_event.start_time
    occurrences = first_of_every_year_event.occurrences_between(start_time, start_time + 365.days)

    assert_equal 2, occurrences.length, "Event has 2 occurrences over 366 days"
    assert_equal Time.parse("2014-01-01"), occurrences[0].start_time, "Event occurs on January 1st, 2014"
    assert_equal Time.parse("2015-01-01"), occurrences[1].start_time, "Event occurs on January 1st, 2015"
  end

  test "occurrences_between with every-weekday daily event" do
    every_weekday_daily_event = example_event :every_weekday_daily
    start_time = every_weekday_daily_event.start_time
    occurrences = every_weekday_daily_event.occurrences_between(start_time, start_time + 6.days)

    assert_equal 5, occurrences.length, "Event has 5 occurrences over 7 days"
    assert_true occurrences.map(&:start_time).include?(Time.parse("2014-01-10")), "Event occurs on Friday January 10th"
    assert_false occurrences.map(&:start_time).include?(Time.parse("2015-01-11")), "Event does not occur on Saturday January 11th"
  end

  test "occurrences_between with daily event with until date" do
    monday_until_friday_event = example_event :monday_until_friday
    start_time = monday_until_friday_event.start_time
    occurrences = monday_until_friday_event.occurrences_between(start_time, start_time + 30.days)

    assert_equal 5, occurrences.length, "Event has 5 occurrences over 31 days"
    assert_true occurrences.map(&:start_time).include?(Time.parse("2014-01-15 at 12pm")), "Event occurs on Wednesday January 15th"
    assert_false occurrences.map(&:start_time).include?(Time.parse("2014-01-18 at 12pm")), "Event does not occur on Saturday January 18th"
  end

  test "occurrences_between with daily event with limited count" do
    everyday_for_four_days = example_event :everyday_for_four_days
    start_time = everyday_for_four_days.start_time
    occurrences = everyday_for_four_days.occurrences_between(start_time, start_time + 30.days)

    assert_equal 4, occurrences.length, "Event has 4 occurrences over 31 days"
    assert_true occurrences.map(&:start_time).include?(Time.parse("2014-01-15 at 12pm")), "Event occurs on Wednesday January 15th"
    assert_false occurrences.map(&:start_time).include?(Time.parse("2014-01-17 at 12pm")), "Event does not occur on Saturday January 18th"
  end

  test "occurrences_between with first saturday of month event" do
    first_saturday_of_month_event = example_event :first_saturday_of_month
    start_time = first_saturday_of_month_event.start_time
    occurrences = first_saturday_of_month_event.occurrences_between(start_time, start_time + 45.days)

    assert_equal 2, occurrences.length, "Event has 2 occurrences over 46 days"
    assert_true occurrences.map(&:start_time).include?(Time.parse("2014-01-04")), "Event occurs on Jan 04"
    assert_true occurrences.map(&:start_time).include?(Time.parse("2014-02-01")), "Event occurs on Feb 08"
  end

  test "occurrences_between for proper count-limited event with first event in the past" do
    one_day_a_month_for_three_months_event = example_event :one_day_a_month_for_three_months
    start_time = one_day_a_month_for_three_months_event.start_time
    occurrences = one_day_a_month_for_three_months_event.occurrences_between(start_time + 30.days, start_time + 90.days)

    assert_equal 2, occurrences.length, "Event has 2 occurrences from 30 days after first event to 90 days after first event"
  end

  test "occurrences_between with UTC times" do
    utc_event = example_event :utc
    occurrences = utc_event.occurrences_between(Time.parse("2014-01-01"), Time.parse("2014-02-01"))
    assert_equal Time.parse("20140114T180000Z"), occurrences.first.start_time, "Event start time is in UTC"
  end

  def example_event(ics_name)
    ics_path = File.expand_path "#{File.dirname(__FILE__)}/../fixtures/recurrence_examples/#{ics_name}_event.ics"
    ics_string = File.read(ics_path)
    calendars = Icalendar.parse(ics_string)
    Array(calendars).first.events.first
  end
end