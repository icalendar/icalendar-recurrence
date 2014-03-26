module Icalendar
  module Recurrence
    module EventExtensions
      def start
        dtstart
      end

      def end
        dtend
      end

      def occurrences_between(begin_time, closing_time)
        schedule.occurrences_between(begin_time, closing_time)
      end

      def schedule
        @schedule ||= Schedule.new(self)
      end
    end
  end

  class Event
    include Icalendar::Recurrence::EventExtensions
  end
end