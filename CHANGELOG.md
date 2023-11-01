# icalendar-recurrence CHANGELOG

## 1.2.0 (November 1, 2023)

- Fix exception date handling across DST boundaries (PR #25)
- Add `:parent` to the Occurrence class, to match constructor for Icalendar::Component (PR #23)
- Add `Event#all_occurrences` method (PR #28)
- Move TZInfo to a runtime dependency (PR #31)
- Handle `RDATE` recurrence rules (PR #33)
- Use built-in `.utc` method for occurrence time in all cases (PR #35 & #37)

## 1.1.2 (September 23, 2016)

- Loosen dependency on ice_cube gem to allow minor upgrades (issue #16)
  *Matthew Johnston (@warmwaffles)*
- Change reference to `Fixnum` to `Integer`

## 1.1.1 (September 23, 2016)

- Fix scope issue on convert_duration_to_seconds (issue #11)
  *Paul Tyng (@paultyng)*

## 1.1.0 (July 8, 2015)

- Add support for getting all occurrences (issue #7)
  *Espen Antonsen (@espen)*
- Delgate ical RRULE string parsing to IceCube (also, upgrade to 0.13.0)
