# frozen_string_literal: true

require "spec_helper"

describe NylasV3::CalendarCollection do
  # Get availability information from account calendars.
  describe "availability" do
    # Make and send a request to get availability information from a single account's calendar.
    it "makes a request to get single availability" do
      api = instance_double(NylasV3::API, execute: JSON.parse("{}"))

      calendar_collection = described_class.new(model: NylasV3::Calendar, api: api)
      free_busy = NylasV3::FreeBusy.new(
        email: "swag@nylas.com",
        time_slots: [
          {
            object: "time_slot",
            status: "busy",
            start_time: 1_609_439_400,
            end_time: 1_640_975_400
          }
        ]
      )
      open_hours = NylasV3::OpenHours.new(
        emails: ["swag@nylas.com"],
        days: [0],
        timezone: "America/Chicago",
        start: "10:00",
        end: "14:00"
      )

      calendar_collection.availability(
        duration_minutes: 30,
        interval_minutes: 5,
        start_time: 1590454800,
        end_time: 1590780800,
        emails: ["swag@nylas.com"],
        buffer: 5,
        round_robin: "max-fairness",
        event_collection_id: "abc-123",
        free_busy: [free_busy],
        open_hours: [open_hours]
      )

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/calendars/availability",
        payload: JSON.dump(
          duration_minutes: 30,
          interval_minutes: 5,
          start_time: 1590454800,
          end_time: 1590780800,
          emails: ["swag@nylas.com"],
          free_busy: [
            {
              email: "swag@nylas.com",
              time_slots: [
                {
                  object: "time_slot",
                  status: "busy",
                  start_time: 1_609_439_400,
                  end_time: 1_640_975_400
                }
              ]
            }
          ],
          open_hours: [
            {
              timezone: "America/Chicago",
              start: "10:00",
              end: "14:00",
              emails: ["swag@nylas.com"],
              days: [0]
            }
          ],
          calendars: [],
          buffer: 5,
          round_robin: "max-fairness",
          event_collection_id: "abc-123"
        )
      )
    end

    # Omit optional parameters when requesting availability information for a single account.
    it "optional params are omitted when getting single availability" do
      api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
      calendar_collection = described_class.new(model: NylasV3::Calendar, api: api)

      calendar_collection.availability(
        duration_minutes: 30,
        interval_minutes: 5,
        start_time: 1590454800,
        end_time: 1590780800,
        emails: ["swag@nylas.com"]
      )

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/calendars/availability",
        payload: JSON.dump(
          duration_minutes: 30,
          interval_minutes: 5,
          start_time: 1590454800,
          end_time: 1590780800,
          emails: ["swag@nylas.com"],
          free_busy: [],
          open_hours: [],
          calendars: []
        )
      )
    end

    # Make and send a request to get availability information from multiple accounts' calendars.
    it "makes a request to get multiple availability" do
      api = instance_double(NylasV3::API, execute: JSON.parse("{}"))

      calendar_collection = described_class.new(model: NylasV3::Calendar, api: api)
      free_busy = NylasV3::FreeBusy.new(
        email: "swag@nylas.com",
        time_slots: [
          {
            object: "time_slot",
            status: "busy",
            start_time: 1_609_439_400,
            end_time: 1_640_975_400
          }
        ]
      )
      open_hours = NylasV3::OpenHours.new(
        emails: %w[one@example.com two@example.com three@example.com swag@nylas.com],
        days: [0],
        timezone: "America/Chicago",
        start: "10:00",
        end: "14:00"
      )

      calendar_collection.consecutive_availability(
        duration_minutes: 30,
        interval_minutes: 5,
        start_time: 1590454800,
        end_time: 1590780800,
        emails: [["one@example.com"], %w[two@example.com three@example.com]],
        buffer: 5,
        free_busy: [free_busy],
        open_hours: [open_hours]
      )

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/calendars/availability/consecutive",
        payload: JSON.dump(
          duration_minutes: 30,
          interval_minutes: 5,
          start_time: 1590454800,
          end_time: 1590780800,
          emails: [["one@example.com"], %w[two@example.com three@example.com]],
          free_busy: [
            {
              email: "swag@nylas.com",
              time_slots: [
                {
                  object: "time_slot",
                  status: "busy",
                  start_time: 1_609_439_400,
                  end_time: 1_640_975_400
                }
              ]
            }
          ],
          open_hours: [
            {
              timezone: "America/Chicago",
              start: "10:00",
              end: "14:00",
              emails: %w[one@example.com two@example.com three@example.com swag@nylas.com],
              days: [0]
            }
          ],
          calendars: [],
          buffer: 5
        )
      )
    end

    # Omit optional parameters when requesting availability information for multiple accounts.
    it "optional params are omitted when getting multiple availability" do
      api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
      calendar_collection = described_class.new(model: NylasV3::Calendar, api: api)

      calendar_collection.consecutive_availability(
        duration_minutes: 30,
        interval_minutes: 5,
        start_time: 1590454800,
        end_time: 1590780800,
        emails: [["swag@nylas.com"]]
      )

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/calendars/availability/consecutive",
        payload: JSON.dump(
          duration_minutes: 30,
          interval_minutes: 5,
          start_time: 1590454800,
          end_time: 1590780800,
          emails: [["swag@nylas.com"]],
          free_busy: [],
          open_hours: [],
          calendars: []
        )
      )
    end
  end

  # Verify open hours against a calendar collection, and generate and throw errors as necessary.
  describe "verification" do
    # Generate and throw an error if the account associated with a given email address does not
    # exist in the set open hours.
    it "throws an error if an email does not exist in open hours" do
      api = instance_double(NylasV3::API, execute: JSON.parse("{}"))

      calendar_collection = described_class.new(model: NylasV3::Calendar, api: api)
      free_busy = NylasV3::FreeBusy.new(
        email: "one@example.com",
        time_slots: [
          {
            object: "time_slot",
            status: "busy",
            start_time: 1_609_439_400,
            end_time: 1_640_975_400
          }
        ]
      )
      open_hours = NylasV3::OpenHours.new(
        emails: %w[one@example.com two@example.com three@example.com swag@nylas.com],
        days: [0],
        timezone: "America/Chicago",
        start: "10:00",
        end: "14:00"
      )

      expect do
        calendar_collection.consecutive_availability(
          duration_minutes: 30,
          interval_minutes: 5,
          start_time: 1590454800,
          end_time: 1590780800,
          emails: [["one@example.com"], %w[two@example.com three@example.com]],
          buffer: 5,
          free_busy: [free_busy],
          open_hours: [open_hours],
          calendars: []
        )
      end.to raise_error(ArgumentError)
    end
  end

  # Generate and throw an error if at least one email address or calendar is not provided.
  it "throws an error if at least one of 'emails' or 'calendars' is not provided" do
    api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
    calendar_collection = described_class.new(model: NylasV3::Calendar, api: api)

    expect do
      calendar_collection.consecutive_availability(
        duration_minutes: 30,
        interval_minutes: 5,
        start_time: 1590454800,
        end_time: 1590780800,
        buffer: 5
      )
    end.to raise_error(ArgumentError)
  end
end
