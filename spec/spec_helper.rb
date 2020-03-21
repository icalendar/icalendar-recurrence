require 'support/helpers'

# Support gems
require 'awesome_print'
require 'timecop'
require 'pry'

# Gem under test
require 'icalendar/recurrence'

include Icalendar::Recurrence
include Helpers

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
