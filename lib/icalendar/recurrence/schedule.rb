require 'ice_cube'

module Icalendar
  module Recurrence
    class Occurrence < Struct.new(:start_time, :end_time)
    end

    class Schedule
      attr_reader :event

      def initialize(event)
        @event = event
      end

      def timezone
        event.tzid
      end

      def rrules
        event.rrule
      end

      def start_time
        TimeUtil.to_time(event.start)
      end

      def end_time
        if event.end
          TimeUtil.to_time(event.end)
        else
          start_time + convert_duration_to_seconds(event.duration)
        end
      end

      def occurrences_between(begin_time, closing_time)
        ice_cube_occurrences = ice_cube_schedule.occurrences_between(TimeUtil.to_time(begin_time), TimeUtil.to_time(closing_time))

        ice_cube_occurrences.map do |occurrence|
          convert_ice_cube_occurrence(occurrence)
        end
      end

      def convert_ice_cube_occurrence(ice_cube_occurrence)
        if timezone
          begin
            tz = TZInfo::Timezone.get(timezone)
            start_time = tz.local_to_utc(ice_cube_occurrence.start_time)
            end_time = tz.local_to_utc(ice_cube_occurrence.end_time)
          rescue TZInfo::InvalidTimezoneIdentifier => e
            warn "Unknown TZID specified in ical event (#{timezone.inspect}), ignoring (will likely cause event to be at wrong time!)"
          end
        end

        start_time ||= ice_cube_occurrence.start_time
        end_time ||= ice_cube_occurrence.end_time
        
        Icalendar::Recurrence::Occurrence.new(start_time, end_time)
      end

      def ice_cube_schedule
        schedule = IceCube::Schedule.new
        schedule.start_time = start_time
        schedule.end_time = end_time

        rrules.each do |rrule|
          ice_cube_recurrence_rule = convert_rrule_to_ice_cube_recurrence_rule(rrule)
          schedule.add_recurrence_rule(ice_cube_recurrence_rule)
        end

        event.exdate.each do |exception_date|
          exception_date = Time.parse(exception_date) if exception_date.is_a?(String)
          schedule.add_exception_time(TimeUtil.to_time(exception_date))
        end

        schedule
      end

      def transform_byday_to_hash(byday_entries)
        hashable_array = Array(byday_entries).map {|byday| convert_byday_to_ice_cube_day_of_week_hash(byday) }.flatten(1)
        hash = Hash[*hashable_array]

        if hash.values.include?([0]) # byday interval not specified (e.g., BYDAY=SA not BYDAY=1SA)
          hash.keys
        else
          hash
        end
      end

      # private


      def convert_rrule_to_ice_cube_recurrence_rule(rrule)
        ice_cube_recurrence_rule = base_ice_cube_recurrence_rule(rrule.frequency, rrule.interval)

        ice_cube_recurrence_rule.tap do |r|
          days = transform_byday_to_hash(rrule.by_day)

          r.month_of_year(rrule.by_month) unless rrule.by_month.nil?
          r.day_of_month(rrule.by_month_day.map(&:to_i)) unless rrule.by_month_day.nil?
          r.day_of_week(days) if days.is_a?(Hash) and !days.empty?
          r.day(days) if days.is_a?(Array) and !days.empty?
          r.until(TimeUtil.to_time(rrule.until)) if rrule.until
          r.count(rrule.count)
        end

        ice_cube_recurrence_rule
      end

      def base_ice_cube_recurrence_rule(frequency, interval)
        interval ||= 1
        if frequency == "DAILY"
          IceCube::DailyRule.new(interval)
        elsif frequency == "WEEKLY"
          IceCube::WeeklyRule.new(interval)
        elsif frequency == "MONTHLY"
          IceCube::MonthlyRule.new(interval)
        elsif frequency == "YEARLY"
          IceCube::YearlyRule.new(interval)
        else
          raise "Unknown frequency: #{rrule.frequency}"
        end
      end

      def convert_byday_to_ice_cube_day_of_week_hash(ical_byday)
        data = parse_ical_byday(ical_byday)
        day_code = data.fetch(:day_code)
        position = data.fetch(:position)

        day_symbol = case day_code.to_s
        when "SU" then :sunday
        when "MO" then :monday
        when "TU" then :tuesday
        when "WE" then :wednesday
        when "TH" then :thursday
        when "FR" then :friday
        when "SA" then :saturday
        else
          raise ArgumentError.new "Unexpected ical_day: #{ical_day.inspect}"
        end

        [day_symbol, Array(position)]
      end

      # Parses ICAL BYDAY value to day and position array
      # 1SA => {day_code: "SA", position: 1}
      # MO  => {day_code: "MO", position: nil
      def parse_ical_byday(ical_byday)
        match = ical_byday.match(/(\d*)([A-Z]{2})/)
        {day_code: match[2], position: match[1].to_i}
      end

      def convert_duration_to_seconds(ical_duration)
        return 0 unless ical_duration

        conversion_rates = { seconds: 1, minutes: 60, hours: 3600, days: 86400, weeks: 604800 }
        seconds = conversion_rates.inject(0) { |sum, (unit, multiplier)| sum + ical_duration[unit] * multiplier }
        seconds * (ical_duration.past ? -1 : 1)
      end
    end
  end
end