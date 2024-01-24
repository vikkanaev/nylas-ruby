# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/MessageSpies
# rubocop:disable Rspec/NestedGroups
# rubocop:disable RSpec/MultipleMemoizedHelpers

describe NylasV3::NativeAuthentication do
  describe "#authenticate" do
    context "when called return_full_response parameter" do
      let(:client) do
        NylasV3::HttpClient.new(app_id: "not-real", app_secret: "also-not-real",
                              access_token: "seriously-unreal")
      end
      let(:api) { NylasV3::API.new(client: client) }
      let(:scopes) { "email,calendar,contacts" }
      let(:scopes_array) { %w[email calendar contacts] }
      let(:token_response) { { access_token: "fake-token", other_data: "other-data" } }

      shared_examples "a successful authentication" do |return_full_response|
        it "returns the expected value" do
          expect(client).to receive(:execute).with(
            method: :post, path: "/connect/authorize",
            payload: be_json_including("scopes" => scopes)
          ).and_return(code: 1234)
          expect(client).to receive(:execute).with(
            method: :post, path: "/connect/token",
            payload: be_json_including("code" => 1234)
          ).and_return(token_response)
          expect(
            api.authenticate(
              name: "fake",
              email_address: "fake@example.com",
              provider: :gmail,
              settings: {},
              scopes: scopes_array,
              return_full_response: return_full_response
            )
          ).to eql(expected_result)
        end
      end

      context "when return_full_response is not set" do
        let(:expected_result) { "fake-token" }

        it_behaves_like "a successful authentication"
      end

      context "when return_full_response is false" do
        let(:expected_result) { "fake-token" }

        it_behaves_like "a successful authentication", false
      end

      context "when return_full_response is true" do
        let(:expected_result) { token_response }

        it_behaves_like "a successful authentication", true
      end
    end

    it "sets all scopes by default" do
      client = NylasV3::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/authorize",
        payload: be_json_including("scopes" => "email,calendar,contacts")
      ).and_return(code: 1234)
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/token",
        payload: be_json_including("code" => 1234)
      ).and_return(access_token: "fake-token")
      api = NylasV3::API.new(client: client)

      expect(
        api.authenticate(
          name: "fake",
          email_address: "fake@example.com",
          provider: :gmail,
          settings: {}
        )
      ).to eql("fake-token")
    end

    it "allows arrays of one scope" do
      client = NylasV3::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/authorize",
        payload: be_json_including("scopes" => "email")
      ).and_return(code: 1234)
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/token",
        payload: be_json_including("code" => 1234)
      ).and_return(access_token: "fake-token")
      api = NylasV3::API.new(client: client)

      expect(
        api.authenticate(
          name: "fake",
          email_address: "fake@example.com",
          provider: :gmail,
          settings: {},
          scopes: ["email"]
        )
      ).to eql("fake-token")
    end

    it "allows arrays of two scopes" do
      client = NylasV3::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/authorize",
        payload: be_json_including("scopes" => "email,contacts")
      ).and_return(code: 1234)
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/token",
        payload: be_json_including("code" => 1234)
      ).and_return(access_token: "fake-token")
      api = NylasV3::API.new(client: client)

      expect(
        api.authenticate(
          name: "fake",
          email_address: "fake@example.com",
          provider: :gmail,
          settings: {},
          scopes: %w[email contacts]
        )
      ).to eql("fake-token")
    end

    it "allows string scopes" do
      client = NylasV3::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/authorize",
        payload: be_json_including("scopes" => "calendar")
      ).and_return(code: 1234)
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/token",
        payload: be_json_including("code" => 1234)
      ).and_return(access_token: "fake-token")
      api = NylasV3::API.new(client: client)

      expect(
        api.authenticate(
          name: "fake",
          email_address: "fake@example.com",
          provider: :gmail,
          settings: {},
          scopes: "calendar"
        )
      ).to eql("fake-token")
    end
  end
end

# rubocop:enable RSpec/MessageSpies
# rubocop:enable Rspec/NestedGroups
# rubocop:enable RSpec/MultipleMemoizedHelpers
