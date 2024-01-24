# frozen_string_literal: true

require "spec_helper"

describe NylasV3::Thread do
  it "is filterable" do
    expect(described_class).to be_filterable
  end

  it "is listable" do
    expect(described_class).to be_listable
  end

  it "is updatable" do
    expect(described_class).to be_updatable
  end

  it "can be deserialized from JSON" do
    api = instance_double(NylasV3::API)
    json = JSON.dump(id: "thread-2345", account_id: "acc-1234", draft_ids: ["dra-987"],
                     first_message_timestamp: 1_510_080_143, has_attachments: false,
                     labels: [{ display_name: "All Mail", id: "label-all-mail", name: "all" },
                              { display_name: "Inbox", id: "label-inbox", name: "inbox" }],
                     folders: [{ display_name: "All Mail", id: "folder-all-mail", name: "all" },
                               { display_name: "Inbox", id: "folder-inbox", name: "inbox" }],
                     last_message_received_timestamp: 1_510_080_143, last_message_sent_timestamp: nil,
                     last_message_timestamp: 1_510_080_143, message_ids: ["mess-0987"],
                     messages: [{ account_id: "acc-1234", bcc: [], cc: [], date: 1_510_080_788, files: [],
                                  from: [{ email: "andy-noreply@google.com", name: "Andy" }],
                                  id: "message-123", labels: [], object: "message", reply_to: [],
                                  snippet: "One", starred: false, subject: "Thread Test",
                                  thread_id: "thread-2345", to: [{ email: "hellocohere@gmail.com",
                                                                   name: "John Smith" }], unread: false }],
                     object: "thread", participants: [{ email: "hellocohere@gmail.com", name: "" },
                                                      { email: "andy-noreply@google.com",
                                                        name: "Andy from Google" }],
                     snippet: "Hi there!", starred: false, subject: "Hello!", "unread": false, "version": 2)

    thread = described_class.from_json(json, api: api)
    expect(thread.id).to eql "thread-2345"
    expect(thread.account_id).to eql "acc-1234"
    expect(thread.draft_ids).to eql ["dra-987"]
    expect(thread.first_message_timestamp).to eql Time.at(1_510_080_143)
    expect(thread.has_attachments).to be false

    expect(thread.labels[0].id).to eql "label-all-mail"
    expect(thread.labels[0].name).to eql "all"
    expect(thread.labels[0].display_name).to eql "All Mail"
    expect(thread.labels[0].api).to be api

    expect(thread.labels[1].id).to eql "label-inbox"
    expect(thread.labels[1].name).to eql "inbox"
    expect(thread.labels[1].display_name).to eql "Inbox"
    expect(thread.labels[1].api).to be api

    expect(thread.last_message_received_timestamp).to eql Time.at(1_510_080_143)
    expect(thread.last_message_timestamp).to eql Time.at(1_510_080_143)

    expect(thread.messages[0].account_id).to eql "acc-1234"
    expect(thread.messages[0].thread_id).to eql "thread-2345"
    expect(thread.messages[0].object).to eql "message"
    expect(thread.messages[0].subject).to eql "Thread Test"
    expect(thread.messages[0].from[0].email).to eql "andy-noreply@google.com"
    expect(thread.messages[0].to[0].email).to eql "hellocohere@gmail.com"

    expect(thread.message_ids).to eql(["mess-0987"])
    expect(thread.object).to eql "thread"
    expect(thread.participants[0].email).to eql "hellocohere@gmail.com"
    expect(thread.participants[0].name).to eql ""
    expect(thread.participants[1].email).to eql "andy-noreply@google.com"
    expect(thread.participants[1].name).to eql "Andy from Google"
    expect(thread.snippet).to eql "Hi there!"
    expect(thread).not_to be_starred
    expect(thread.subject).to eql "Hello!"
    expect(thread).not_to be_unread
    expect(thread.version).to be 2
  end

  describe "update_folder" do
    it "moves thread to new `folder`" do
      folder_id = "9999"
      api = instance_double(NylasV3::API, execute: "{}")
      thread = described_class.from_json('{ "id": "thread-1234" }', api: api)
      allow(api).to receive(:execute)

      thread.update_folder(folder_id)

      expect(api).to have_received(:execute).with(
        auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
        method: :put,
        path: "/threads/thread-1234",
        payload: { folder_id: folder_id }.to_json,
        query: {}
      )
    end
  end

  describe "#update" do
    it "let's you set the starred, unread, folder, and label ids" do
      api =  instance_double(NylasV3::API, execute: {})
      thread = described_class.from_json('{ "id": "thread-1234" }', api: api)

      thread.update(
        starred: true,
        unread: false,
        folder_id: "folder-1234",
        label_ids: %w[label-1234 label-4567]
      )

      expect(api).to have_received(:execute).with(
        auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
        method: :put,
        path: "/threads/thread-1234",
        payload: JSON.dump(
          starred: true, unread: false,
          folder_id: "folder-1234",
          label_ids: %w[label-1234
                        label-4567]
        ),
        query: {}
      )
    end

    it "raises an argument error if the data has any keys that aren't allowed to be updated" do
      api =  instance_double(NylasV3::API, execute: "{}")
      thread = described_class.from_json('{ "id": "thread-1234" }', api: api)
      expect do
        thread.update(subject: "A new subject!")
      end.to raise_error ArgumentError, "Cannot update [:subject] only " \
                                        "#{described_class::UPDATABLE_ATTRIBUTES} are updatable"
    end
  end
end
