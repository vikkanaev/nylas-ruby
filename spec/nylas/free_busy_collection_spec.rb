# frozen_string_literal: true

require "spec_helper"

describe NylasV3::FreeBusyCollection do
  describe "#each" do
    # Get a collection of FreeBusy objects.
    it "returns collection of `FreeBusy` objects" do
      start_time = 1_609_439_400
      end_time = 1_640_975_400
      emails = ["test@example.com", "anothertest@example.com"]
      api = instance_double("NylasV3::API")
      free_busy_response = [
        {
          object: "free_busy",
          email: "test@example.com",
          time_slots: [
            {
              object: "time_slot",
              status: "busy",
              start_time: 1_609_439_400,
              end_time: 1_640_975_400,
              capacity: {
                event_id: "abc-123",
                current_capacity: 2,
                max_capacity: 5
              }
            }
          ]
        },
        {
          object: "free_busy",
          email: "anothertest@example.com",
          time_slots: []
        }
      ]
      allow(api).to receive(:execute).and_return(free_busy_response)
      result = described_class.new(
        api: api,
        emails: emails,
        start_time: start_time.to_i,
        end_time: end_time.to_i
      ).to_a

      expect(result.size).to eq(2)
      first_result = result.first
      expect(first_result.object).to eq("free_busy")
      expect(first_result.email).to eq("test@example.com")
      first_result_time_slot = first_result.time_slots.first
      expect(first_result_time_slot.object).to eq("time_slot")
      expect(first_result_time_slot.status).to eq("busy")
      expect(first_result_time_slot.start_time.to_i).to eq(1_609_439_400)
      expect(first_result_time_slot.end_time.to_i).to eq(1_640_975_400)
      expect(first_result_time_slot.capacity.event_id).to eq("abc-123")
      expect(first_result_time_slot.capacity.current_capacity).to eq(2)
      expect(first_result_time_slot.capacity.max_capacity).to eq(5)
      last_result = result.last
      expect(last_result.object).to eq("free_busy")
      expect(last_result.email).to eq("anothertest@example.com")
      expect(last_result.time_slots).to eq([])
    end
  end
end
