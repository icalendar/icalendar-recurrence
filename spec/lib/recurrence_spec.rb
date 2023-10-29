require 'spec_helper'

describe "Event#occurrences_between" do
  let(:start_time) { event.start_time }

  context "event repeating daily" do
    let(:event) { example_event :daily } # has exclusion on Jan 28th
    it "properly calculates recurrence, including exclusion date" do
      occurrences = event.occurrences_between(start_time, start_time + 2.days)

      expect(occurrences.length).to eq(2)
      expect(occurrences.first.start_time).to eq(Time.parse("2014-01-27"))
      expect(occurrences.last.start_time).to eq(Time.parse("2014-01-29"))
    end
  end

  context "event repeating every other day" do
    let(:event) { example_event :every_other_day }

    it "occurs 3 times over 6 days" do
      occurrences = event.occurrences_between(start_time, start_time + 5.days)

      expect(occurrences.length).to eq(3)
      expect(occurrences[0].start_time).to eq(Time.parse("2014-01-27"))
      expect(occurrences[1].start_time).to eq(Time.parse("2014-01-29"))
      expect(occurrences[2].start_time).to eq(Time.parse("2014-01-31"))
    end
  end

  context "event repeating every monday" do
    let(:event) { example_event :every_monday }

    it "occurs twice over 8 days" do
      occurrences = event.occurrences_between(start_time, start_time + 8.days)

      expect(occurrences.length).to eq(2)
      expect(occurrences[0].start_time).to eq(Time.parse("2014-02-03 16:00:00 -0800"))
      expect(occurrences[1].start_time).to eq(Time.parse("2014-02-10 16:00:00 -0800"))
    end
  end

  context "event repeating on Mon, Wed, Fri" do
    let(:event) { example_event :multi_day_weekly }

    it "occurs 3 times over 7 days" do
      occurrences = event.occurrences_between(start_time, start_time + 7.days)

      expect(occurrences.length).to eq(3)
      expect(occurrences[0].start_time).to eq(Time.parse("2014-02-03 16:00:00 -0800"))
      expect(occurrences[1].start_time).to eq(Time.parse("2014-02-05 16:00:00 -0800"))
      expect(occurrences[2].start_time).to eq(Time.parse("2014-02-07 16:00:00 -0800"))
    end
  end

  context "event repeating every thursday with multiple exceptions" do
    context "exclusions are on a single line" do
      let(:event) { example_event :multiple_exception } # has exclusions in array form
      it "properly calculates recurrence, including exclusion dates" do
        occurrences = event.occurrences_between(start_time, start_time + 1.months)

        expect(occurrences.length).to eq(1)
        expect(occurrences.first.start_time).to eq(Time.parse("2017-11-16 13:40:00 UTC"))
      end
    end

    context "exclusions are on multiple lines" do
      let(:event) { example_event :multiple_exception_multiple_line } # has multiple single exclusions
      it "properly calculates recurrence, including exclusion dates" do
        occurrences = event.occurrences_between(start_time, start_time + 1.months)

        expect(occurrences.length).to eq(1)
        expect(occurrences.first.start_time).to eq(Time.parse("2017-11-16 13:40:00 UTC"))
      end
    end
  end

  context "event repeating bimonthly (DST example)" do
    let(:event) { example_event :on_third_every_two_months }

    it "occurs twice over 60 days" do
      occurrences = event.occurrences_between(start_time, start_time + 60.days)

      expect(occurrences.length).to eq(2)
      expect(occurrences[0].start_time).to eq(Time.parse("2014-02-03 16:00:00 -0800"))
      expect(occurrences[1].start_time).to eq(Time.parse("2014-04-03 16:00:00 -0700"))
    end
  end

  context "event repeating weekly with exdates" do
    let(:event) { example_event :dst_exdate }

    it "properly skips christmas and new years" do
      occurrences = event.occurrences_between(start_time, start_time + 4.months)

      expect(occurrences.length).to eq(14)
      christmas_day = Date.new 2019, 12, 25
      expect(occurrences.all? { |o| o.start_time.to_date != christmas_day }).to eq(true)
      new_years_day = Date.new 2020, 1, 1
      expect(occurrences.all? { |o| o.start_time.to_date != new_years_day }).to eq(true)
    end
  end

  context "event repeating weekly with rdates" do
    let(:event) { example_event :dst_rdate }

    it "properly includes specified rdates" do
      occurrences = event.occurrences_between(start_time, start_time + 4.months)
      extra_day_after_period = Date.new 2020, 02, 01
      occurrence = occurrences.find { |o| o.start_time.to_date == extra_day_after_period }

      expect(occurrences.length).to eq(17)
      expect(occurrence).to_not be_nil

      expect(occurrence.start_time).to eq(Time.new 2020, 02, 01, 19, 0, 0, "+00:00")
      expect(occurrence.end_time).to eq(Time.new 2020, 02, 01, 21, 0, 0, "+00:00")
    end
  end

  context "event repeating yearly" do
    let(:event) { example_event :first_of_every_year }

    it "occurs twice over 366 days" do
      occurrences = event.occurrences_between(start_time, start_time + 365.days)

      expect(occurrences.length).to eq(2)
      expect(occurrences[0].start_time).to eq(Time.parse("2014-01-01"))
      expect(occurrences[1].start_time).to eq(Time.parse("2015-01-01"))
    end
  end

  context "event repeating Mon-Fri" do
    let(:event) { example_event :every_weekday_daily }

    it "occurrs 10 times over two weeks" do
      occurrences = event.occurrences_between(start_time, start_time + 13.days)

      expect(occurrences.length).to eq(10)
      expect(occurrences.map(&:start_time)).to include(Time.parse("2014-01-10"))
      expect(occurrences.map(&:start_time)).to_not include(Time.parse("2014-01-11"))
    end
  end

  context "event repeating daily until January 18th" do
    let(:event) { example_event :monday_until_friday }

    it "occurs from start date until specified 'until' date" do
      occurrences = event.occurrences_between(start_time, start_time + 30.days)

      expected_start_times = [
        Time.parse("2014-01-15 at 12pm").force_zone("America/Los_Angeles").utc,
        Time.parse("2014-01-18 at 12pm").force_zone("America/Los_Angeles").utc
      ]

      expect(occurrences.length).to eq(5)
      expect(occurrences.map(&:start_time)).to include(expected_start_times[0])
      expect(occurrences.map(&:start_time)).to_not include(expected_start_times[1])
    end
  end

  context "event repeating daily with occurrence count of 4" do
    let(:event) { example_event :everyday_for_four_days }

    it "occurs 4 times then stops" do
      occurrences = event.occurrences_between(start_time, start_time + 365.days)
      expect(occurrences.length).to eq(4)
      expect(occurrences.map(&:start_time)).to include(Time.parse("2014-01-15 at 12pm").force_zone("America/Los_Angeles").utc)
      expect(occurrences.map(&:start_time)).to_not include(Time.parse("2014-01-17 at 12pm").force_zone("America/Los_Angeles").utc)
    end
  end

  context "event repeating on first saturday of month event" do
    let(:event) { example_event :first_saturday_of_month }

    it "occurs twice over two months" do
      occurrences = event.occurrences_between(start_time, start_time + 55.days)

      expected_start_times = [
        Time.parse("2014-01-04 at 10am").force_zone("America/Los_Angeles"),
        Time.parse("2014-02-01 at 10am").force_zone("America/Los_Angeles"),
      ]

      expect(occurrences.length).to eq(2)
      expect(occurrences[0].start_time).to eq(expected_start_times[0])
      expect(occurrences[1].start_time).to eq(expected_start_times[1])
    end
  end

  context "event repeating once a month for three months" do
    let(:event) { example_event :one_day_a_month_for_three_months }

    it "only occurs twice when we look for occurrences after the first one" do
      occurrences = event.occurrences_between(start_time + 30.days, start_time + 90.days)

      expect(occurrences.length).to eq(2)
    end
  end

  context "event in UTC time" do
    let(:event) { example_event :utc }

    it "occurs at the correct time" do
      occurrences = event.occurrences_between(Time.parse("2014-01-01"), Time.parse("2014-02-01"))
      expect(occurrences.first.start_time).to eq(Time.parse("20140114T180000Z"))
    end
  end
end

describe "Event#all_occurrences" do
  let(:start_time) { event.start_time }

  context "event repeating once a month for three months" do
    let(:event) { example_event :one_day_a_month_for_three_months }

    it "get all 3 occurences" do
      occurrences = event.all_occurrences

      expect(occurrences.length).to eq(3)
    end
  end

  context "event repeating yearly" do
    let(:event) { example_event :first_of_every_year }

    it "can not get all occurences when not using count or until" do
      expect {
        event.all_occurrences
      }.to raise_error(ArgumentError)
    end
  end

end