module Helpers
  def example_event(ics_name)
    ics_path = File.expand_path "#{File.dirname(__FILE__)}/fixtures/#{ics_name}_event.ics"
    ics_string = File.read(ics_path)
    calendars = Icalendar.parse(ics_string)
    Array(calendars).first.events.first
  end
end

class Fixnum
  def days
    self*60*60*24
  end
end