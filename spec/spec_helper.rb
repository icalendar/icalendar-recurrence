require 'icalendar/recurrence'
include Icalendar::Recurrence

RSpec.configure do |config|
  config.include Icalendar::Recurrence
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
