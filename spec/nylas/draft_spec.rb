# frozen_string_literal: true

require "spec_helper"

describe NylasV3::Draft do
  # Restrict the ability to filter on a draft.
  it "is not filterable" do
    expect(described_class).not_to be_filterable
  end

  # Allow a draft to be created.
  it "is creatable" do
    expect(described_class).to be_creatable
  end

  # Allow a draft to be displayed.
  it "is showable" do
    expect(described_class).to be_showable
  end

  # Allow a draft to be listed.
  it "is listable" do
    expect(described_class).to be_listable
  end

  # Allow a draft to be updated.
  it "is updatable" do
    expect(described_class).to be_updatable
  end

  # Allow a draft to be destroyed.
  it "is destroyable" do
    expect(described_class).to be_destroyable
  end

  # Update a draft.
  describe "update" do
    # Update a draft using a key from the files hash.
    context "with `files` key" do
      # If the files hash is present, remove it from the payload and set the file_ids hash key.
      it "if `files` present, remove from the payload and sets the proper file_ids key" do
        api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
        file = NylasV3::File.new(id: "abc-123")
        data = {
          id: "draft-1234"
        }
        draft = described_class.from_json(
          JSON.dump(data),
          api: api
        )

        draft.update(subject: "Updated subject", files: [file])

        expect(api).to have_received(:execute).with(
          auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/drafts/draft-1234",
          payload: JSON.dump(
            subject: "Updated subject",
            file_ids: ["abc-123"]
          ),
          query: {}
        )
      end
    end

    # Update a draft when the key from the files hash does not exist.
    context "when `files` key does not exists" do
      # Do not set the file_ids hash key or make changes to the payload.
      it "does not set the file_ids key or make any further changes to the payload" do
        api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
        data = {
          id: "draft-1234"
        }
        draft = described_class.from_json(
          JSON.dump(data),
          api: api
        )

        draft.update(subject: "Updated subject")

        expect(api).to have_received(:execute).with(
          auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/drafts/draft-1234",
          payload: JSON.dump(
            subject: "Updated subject"
          ),
          query: {}
        )
      end
    end

    # Update a local draft object version number.
    it "updates the local draft object version number on update" do
      expected_response = {
        id: "draft-1234",
        version: 1
      }
      api = instance_double(NylasV3::API, execute: expected_response)
      data = {
        id: "draft-1234",
        version: 0
      }
      draft = described_class.from_json(
        JSON.dump(data),
        api: api
      )

      draft.update(**data)

      expect(draft.version).to eq(1)
    end

    # Send a draft's version number if the user does not manually add it.
    it "sends the version number if the user does not manually add it" do
      api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
      data = {
        id: "draft-1234",
        subject: "This is a draft",
        version: 0
      }
      draft = described_class.from_json(
        JSON.dump(data),
        api: api
      )
      updated = {
        subject: "This is an updated draft"
      }

      draft.update(**updated)

      expect(api).to have_received(:execute).with(
        auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
        method: :put,
        path: "/drafts/draft-1234",
        payload: JSON.dump(
          subject: "This is an updated draft",
          version: 0
        ),
        query: {}
      )
    end
  end

  # Create a draft.
  describe "#create" do
    # Create a draft when the key from the files hash exists.
    context "when `files` key exists" do
      # Remove the files hash from the payload and set the file_ids hash key.
      it "removes `files` from the payload and sets the proper file_ids key" do
        api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
        file = NylasV3::File.new(id: "abc-123")
        data = {
          id: "draft-1234",
          files: [file]
        }
        draft = described_class.from_json(
          JSON.dump(data),
          api: api
        )

        draft.create

        expect(api).to have_received(:execute).with(
          auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
          method: :post,
          path: "/drafts",
          payload: JSON.dump(
            id: "draft-1234",
            file_ids: ["abc-123"]
          ),
          query: {}
        )
      end
    end

    # Create a draft when the key from the files hash does not exist.
    context "when `files` key does not exists" do
      # Do not modify the files hash or the filed_ids hash.
      it "does nothing" do
        api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
        data = {
          id: "draft-1234"
        }
        draft = described_class.from_json(
          JSON.dump(data),
          api: api
        )

        draft.create

        expect(api).to have_received(:execute).with(
          auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
          method: :post,
          path: "/drafts",
          payload: JSON.dump(
            id: "draft-1234"
          ),
          query: {}
        )
      end
    end
  end

  # Save a draft.
  describe "save" do
    # Save a draft when the key from the files hash exists.
    context "when `files` key exists" do
      # Remove the files hash from the payload and set the file_ids hash key.
      it "removes `files` from the payload and sets the proper file_ids key" do
        api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
        file = NylasV3::File.new(id: "abc-123")
        data = {
          id: "draft-1234",
          files: [file]
        }
        draft = described_class.from_json(
          JSON.dump(data),
          api: api
        )

        draft.save

        expect(api).to have_received(:execute).with(
          auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/drafts/draft-1234",
          payload: JSON.dump(
            id: "draft-1234",
            file_ids: ["abc-123"]
          ),
          query: {}
        )
      end
    end

    # Save a draft when the key from the files hash does not exist.
    context "when `files` key does not exists" do
      # Do not modify the files hash or the file_ids hash.
      it "does nothing" do
        api = instance_double(NylasV3::API, execute: JSON.parse("{}"))
        data = {
          id: "draft-1234"
        }
        draft = described_class.from_json(
          JSON.dump(data),
          api: api
        )

        draft.save

        expect(api).to have_received(:execute).with(
          auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/drafts/draft-1234",
          payload: JSON.dump(
            id: "draft-1234"
          ),
          query: {}
        )
      end
    end

    # Update the local draft version number when it is saved.
    it "updates the local draft object version number on save" do
      expected_response = {
        id: "draft-1234",
        version: 1
      }
      api = instance_double(NylasV3::API, execute: expected_response)
      data = {
        id: "draft-1234"
      }
      draft = described_class.from_json(
        JSON.dump(data),
        api: api
      )

      draft.save

      expect(draft.version).to eq(1)
    end
  end

  # Send a draft.
  describe "#send!" do
    # Send the payload if the draft was not created on the server.
    it "sends the payload if the draft was not created on the server" do
      api = instance_double(NylasV3::API)
      draft = described_class.from_hash({ reply_to_message_id: "mess-1234",
                                          to: [{ email: "to@example.com", name: "To Example" }],
                                          from: [{ email: "from@example.com", name: "From Example" }],
                                          subject: "A draft emails subject", body: "<h1>A draft Email</h1>" },
                                        api: api)
      update_json = draft.to_json
      allow(api).to receive(:execute)

      draft.send!

      expect(api).to have_received(:execute).with(
        auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
        method: :post,
        path: "/send",
        payload: update_json,
        query: {}
      )
    end

    # Allow tracking when a draft is sent.
    it "includes tracking when sending the draft" do
      api = instance_double(NylasV3::API)
      draft = described_class.from_hash({ id: "draft-1234", "version": 5 }, api: api)
      draft.tracking = { opens: true, links: true, thread_replies: true, payload: "this is a payload" }
      allow(api).to receive(:execute)

      draft.send!

      expect(api).to have_received(:execute).with(
        auth_method: NylasV3::HttpClient::AuthMethod::BEARER,
        method: :post,
        path: "/send",
        payload: JSON.dump(
          draft_id: "draft-1234",
          version: 5,
          tracking: draft.tracking.to_h
        ),
        query: {}
      )
    end
  end

  # Deserialize a draft's JSON attributes into Ruby objects.
  describe ".from_json" do
    it "Deserializes all the attributes into Ruby objects" do
      api = instance_double(NylasV3::API)
      data = { id: "drft-592", version: 0, object: "draft", account_id: "acc-9987", thread_id: "thread-1234",
               reply_to_message_id: "mess-1234", date: 1_513_276_982,
               to: [{ email: "to@example.com", name: "To Example" }],
               from: [{ email: "from@example.com", name: "From Example" }],
               cc: [{ email: "cc@example.com", name: "CC Example" }],
               bcc: [{ email: "bcc@example.com", name: "BCC Example" }],
               reply_to: [{ email: "reply-to@example.com", name: "Reply To Example" }],
               subject: "A draft emails subject",
               snippet: "A draft Email",
               body: "<h1>A draft Email</h1>",
               starred: false, unread: false,
               events: [],
               files: [{ content_type: "text/calendar", filename: nil, id: "file-abc35", size: 1264 },
                       { content_type: "application/ics", filename: "invite.ics", id: "file-xyz-9234",
                         size: 1264 }],
               folder: { display_name: "Inbox", id: "folder-inbox", name: "inbox" },
               labels: [{ display_name: "Inbox", id: "label-inbox", name: "inbox" },
                        { display_name: "All Mail", id: "label-all", name: "all" }],
               metadata: { test: "yes" },
               tracking: { opens: true, links: true, thread_replies: true, payload: "this is a payload" } }

      draft = described_class.from_json(JSON.dump(data), api: api)
      expect(draft.id).to eql "drft-592"
      expect(draft.account_id).to eql "acc-9987"
      expect(draft.thread_id).to eql "thread-1234"
      expect(draft.reply_to_message_id).to eql "mess-1234"
      expect(draft.date).to eql Time.at(1_513_276_982)

      expect(draft.to[0].email).to eql "to@example.com"
      expect(draft.to[0].name).to eql "To Example"

      expect(draft.from[0].email).to eql "from@example.com"
      expect(draft.from[0].name).to eql "From Example"

      expect(draft.cc[0].email).to eql "cc@example.com"
      expect(draft.cc[0].name).to eql "CC Example"

      expect(draft.bcc[0].email).to eql "bcc@example.com"
      expect(draft.bcc[0].name).to eql "BCC Example"

      expect(draft.reply_to[0].email).to eql "reply-to@example.com"
      expect(draft.reply_to[0].name).to eql "Reply To Example"

      expect(draft.subject).to eql "A draft emails subject"
      expect(draft.snippet).to eql "A draft Email"
      expect(draft.body).to eql "<h1>A draft Email</h1>"

      expect(draft).not_to be_starred
      expect(draft).not_to be_unread

      expect(draft.files[0].content_type).to eql "text/calendar"
      expect(draft.files[0].filename).to be_nil
      expect(draft.files[0].id).to eql "file-abc35"
      expect(draft.files[0].size).to be 1264
      expect(draft.files[0].api).to be api

      expect(draft.files[1].content_type).to eql "application/ics"
      expect(draft.files[1].filename).to eql "invite.ics"
      expect(draft.files[1].id).to eql "file-xyz-9234"
      expect(draft.files[1].size).to be 1264
      expect(draft.files[1].api).to be api

      # Note, drafts will either be in a folder *or* labeled, not both.
      expect(draft.folder.display_name).to eql "Inbox"
      expect(draft.folder.name).to eql "inbox"
      expect(draft.folder.id).to eql "folder-inbox"
      expect(draft.folder.api).to be api

      expect(draft.labels[0].display_name).to eql "Inbox"
      expect(draft.labels[0].id).to eql "label-inbox"
      expect(draft.labels[0].name).to eql "inbox"
      expect(draft.labels[0].api).to be api

      expect(draft.labels[1].display_name).to eql "All Mail"
      expect(draft.labels[1].id).to eql "label-all"
      expect(draft.labels[1].name).to eql "all"
      expect(draft.labels[1].api).to be api

      expect(draft.metadata).to eq(test: "yes")

      expect(draft.tracking.opens).to be true
      expect(draft.tracking.links).to be true
      expect(draft.tracking.thread_replies).to be true
      expect(draft.tracking.payload).to eql "this is a payload"
    end
  end
end
