# frozen_string_literal: true

describe NylasV3::Calendar do
  # Set and modify JSON calendar attributes.
  describe "JSONs" do
    let(:calendar) do
      api = instance_double(NylasV3::API)
      data = {
        id: "cal-8766",
        object: "calendar",
        account_id: "acc-1234",
        name: "My Calendar",
        description: "Ruby Test Calendar",
        location: "Ruby SDK",
        timezone: "America/New_York",
        job_status_id: "job-1234",
        metadata: {
          lang: "ruby"
        },
        hex_color: "#0099EE",
        is_primary: false,
        read_only: true
      }

      described_class.from_json(JSON.dump(data), api: api)
    end

    # Deserialize all JSON calendar attributes into Ruby objects.
    it "Deserializes all the attributes into Ruby objects" do
      expect(calendar.id).to eql "cal-8766"
      expect(calendar.object).to eql "calendar"
      expect(calendar.account_id).to eql "acc-1234"
      expect(calendar.name).to eql "My Calendar"
      expect(calendar.description).to eql "Ruby Test Calendar"
      expect(calendar.location).to eql "Ruby SDK"
      expect(calendar.timezone).to eql "America/New_York"
      expect(calendar.job_status_id).to eql "job-1234"
      expect(calendar.metadata).to eq(lang: "ruby")
      expect(calendar.hex_color).to eql "#0099EE"
      expect(calendar.is_primary).to be false
      expect(calendar.read_only).to be true
    end

    # Serialize all JSON calendar attributes that are not Read-only for the NylasV3 API.
    it "Serializes all non-read only attributes for the API" do
      expected_json = {
        id: "cal-8766",
        account_id: "acc-1234",
        object: "calendar",
        name: "My Calendar",
        description: "Ruby Test Calendar",
        is_primary: false,
        location: "Ruby SDK",
        timezone: "America/New_York",
        read_only: true,
        metadata: {
          lang: "ruby"
        }
      }.to_json

      json = calendar.attributes.serialize_for_api

      expect(json).to eql expected_json
    end
  end

  # Serialize all calendar attributes into Ruby objects.
  describe "read on" do
    it "Serializes all the attributes into Ruby objects" do
      api = instance_double(NylasV3::API)
      data = {
        id: "cal-8766",
        object: "calendar",
        account_id: "acc-1234",
        name: "My Calendar",
        description: "Ruby Test Calendar",
        location: "Ruby SDK",
        timezone: "America/New_York",
        job_status_id: "job-1234",
        metadata: {
          lang: "ruby"
        },
        hex_color: "#0099EE",
        is_primary: false,
        read_only: true
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar.id).to eql "cal-8766"
      expect(calendar.object).to eql "calendar"
      expect(calendar.account_id).to eql "acc-1234"
      expect(calendar.name).to eql "My Calendar"
      expect(calendar.description).to eql "Ruby Test Calendar"
      expect(calendar.location).to eql "Ruby SDK"
      expect(calendar.timezone).to eql "America/New_York"
      expect(calendar.job_status_id).to eql "job-1234"
      expect(calendar.metadata).to eq(lang: "ruby")
      expect(calendar.hex_color).to eql "#0099EE"
      expect(calendar.is_primary).to be false
      expect(calendar.read_only).to be true
    end
  end

  # Check if a calendar is Read-only.
  describe "#read_only?" do
    # Sends a call to the NylasV3 API and returns `true` when the calendar is Read-only.
    it "returns true when read_only attribute from API return true" do
      api = instance_double(NylasV3::API)
      data = {
        read_only: true
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar).to be_read_only
    end

    # Send a call to the NylasV3 API. Returns false when the calendar is not Read-only.
    it "returns false when read_only attribute from API return false" do
      api = instance_double(NylasV3::API)
      data = {
        read_only: false
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar).not_to be_read_only
    end
  end

  # Check if a calendar is the primary for an account.
  describe "#primary?" do
    # Send a call to the NylasV3 API. Returns true when the calendar is the primary for an account.
    it "returns true when is_primary attribute from API return true" do
      api = instance_double(NylasV3::API)
      data = {
        is_primary: true
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar).to be_primary
    end

    # Send a call to the NylasV3 API. Returns false when the calendar is not the primary for an account.
    it "returns false when is_primary attribute from API return false" do
      api = instance_double(NylasV3::API)
      data = {
        is_primary: false
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar).not_to be_primary
    end
  end

  # Set constraints for retrieveng events from a calendar.
  describe "#events" do
    it "sets the constraints properly for getting child events" do
      api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
      events = NylasV3::EventCollection.new(model: NylasV3::Event, api: api)
      allow(api).to receive(:events).and_return(events)
      data = {
        id: "cal-123"
      }
      calendar = described_class.from_json(JSON.dump(data), api: api)

      event_collection = calendar.events

      expect(event_collection).to be_a NylasV3::EventCollection

      event_collection.execute

      expect(api).to have_received(:execute).with(
        auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
        headers: {},
        method: :get,
        path: "/events",
        query: { calendar_id: "cal-123", limit: 100, offset: 0 }
      )
    end
  end
end
