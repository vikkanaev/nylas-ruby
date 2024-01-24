# frozen_string_literal: true

describe NylasV3::Delta do
  # Initialize Delta.
  it "initialize data" do
    data = {
      object: "message",
      account_id: "acc-id",
      id: "message-id",
      type: "message",
      event: "created",
      cursor: "999",
      namespace_id: "namespace-id",
      date: 1_609_439_400,
      metadata: { key: :value },
      headers: {
        "In-Reply-To": "In-Reply-To",
        "Message-Id": "Message-Id",
        References: %w[References-01 References-02]
      },
      object_attributes:
      {
        headers:
        {
          "In-Reply-To": "In-Reply-To",
          "Message-Id": "Message-Id",
          References: %w[References-01 References-02]
        },
        object: :attributes
      }
    }

    delta = described_class.new(**data)

    expect(delta.object).to eq("message")
    expect(delta.account_id).to eq("acc-id")
    expect(delta.id).to eq("message-id")
    expect(delta.type).to eq("message")
    expect(delta.event).to eq("created")
    expect(delta.cursor).to eq("999")
    expect(delta.namespace_id).to eq("namespace-id")
    expect(delta.date).to eq(Time.at(1_609_439_400))
    expect(delta.metadata).to eq(key: :value)
    expect(delta.headers.in_reply_to).to eq("In-Reply-To")
    expect(delta.headers.message_id).to eq("Message-Id")
    expect(delta.headers.references).to eq(%w[References-01 References-02])
    expect(delta.object_attributes).to eq(
      headers:
      {
        "In-Reply-To": "In-Reply-To",
        "Message-Id": "Message-Id",
        References: %w[References-01 References-02]
      },
      object: :attributes
    )
  end

  # Create a model based on a given object.
  describe "#model" do
    # Create a model based on a given object.
    it "returns model based on given `object`" do
      data = {
        object: "message"
      }

      delta = described_class.new(**data)

      expect(delta.model).to be_a(NylasV3::Message)
    end

    # Return nil if the object is nil.
    it "returns `nil` if `object` is nil" do
      data = {
        type: "message"
      }

      delta = described_class.new(**data)

      expect(delta.model).to eq(nil)
    end
  end
end
