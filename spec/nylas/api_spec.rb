# frozen_string_literal: true

require "spec_helper"

# This spec is the only one that should have any webmock stuff going on, everything else should use
# the FakeAPI to see what requests were made and what they included.
describe NylasV3::API do
  # Exchange an authorization code for a token.
  describe "#exchange_code_for_token" do
    # Retrieve an OAuth token using the existing authorization code.
    it "retrieves oauth token with code" do
      client = NylasV3::HttpClient.new(app_id: "fake-app", app_secret: "fake-secret")
      data = {
        "client_id" => "fake-app",
        "client_secret" => "fake-secret",
        "grant_type" => "authorization_code",
        "code" => "fake-code"
      }
      response = {
        account_id: "account-id",
        email_address: "fake@email.com",
        provider: "yahoo",
        token_type: "barer",
        access_token: "fake-token"
      }
      allow(client).to receive(:execute).with(method: :post, path: "/oauth/token", payload: data)
                                        .and_return(response)
      api = described_class.new(client: client)
      expect(api.exchange_code_for_token("fake-code")).to eql("fake-token")
    end

    # Retrieve an authorization response from the server.
    it "retrieves full response from the server" do
      client = NylasV3::HttpClient.new(app_id: "fake-app", app_secret: "fake-secret")
      data = {
        "client_id" => "fake-app",
        "client_secret" => "fake-secret",
        "grant_type" => "authorization_code",
        "code" => "fake-code"
      }
      response = {
        account_id: "account-id",
        email_address: "fake@email.com",
        provider: "yahoo",
        token_type: "barer",
        access_token: "fake-token"
      }
      allow(client).to receive(:execute).with(method: :post, path: "/oauth/token", payload: data)
                                        .and_return(response)
      api = described_class.new(client: client)
      expect(api.exchange_code_for_token("fake-code", return_full_response: true)).to eql(response)
    end
  end

  # Create an authentication URL with either required parameters or required and optional parameters.
  describe "#authentication_url" do
    # Create an authentication URL with required parameters for hosted auth.
    context "with required parameters" do
      it "returns url for hosted_authentication" do
        api = described_class.new(app_id: "2454354")

        hosted_auth_url = api.authentication_url(
          redirect_uri: "http://example.com",
          scopes: %w[email calendar],
          login_hint: "email@example.com",
          state: "some-state"
        )

        expected_url = "https://api.nylas.com/oauth/authorize"\
        "?client_id=2454354"\
        "&redirect_uri=http%3A%2F%2Fexample.com"\
        "&response_type=code"\
        "&login_hint=email%40example.com"\
        "&state=some-state"\
        "&scopes=email%2Ccalendar"
        expect(hosted_auth_url).to eq expected_url
      end
    end

    # Create an authentication URL with required and optional parameters for hosted auth.
    context "with required and optional parameters" do
      it "returns url for hosted_authentication with optional parameters" do
        api = described_class.new(app_id: "2454354")

        hosted_auth_url = api.authentication_url(
          redirect_uri: "http://example.com",
          scopes: %w[email calendar],
          login_hint: "email@example.com",
          state: "some-state",
          provider: "gmail",
          redirect_on_error: true,
          disable_provider_selection: true
        )

        expected_url = "https://api.nylas.com/oauth/authorize"\
        "?client_id=2454354"\
        "&redirect_uri=http%3A%2F%2Fexample.com"\
        "&response_type=code"\
        "&login_hint=email%40example.com"\
        "&state=some-state"\
        "&scopes=email%2Ccalendar"\
        "&provider=gmail"\
        "&redirect_on_error=true"\
        "&disable_provider_selection=true"
        expect(hosted_auth_url).to eq expected_url
      end
    end

    # Generate errors if any required parameters are missing when the authentication URL is
    # created.
    context "when required parameter are missing" do
      # Generate and throw an argument error if the redirect URI is missing.
      it "throws argument error if redirect uri is mising" do
        api = described_class.new(app_id: "2454354")

        expect do
          api.authentication_url(scopes: ["email"])
        end.to raise_error(ArgumentError, /redirect_uri/)
      end

      # Generate and throw an argument error if scopes are missing.
      it "throws argument error if scopes is mising" do
        api = described_class.new(app_id: "2454354")

        expect do
          api.authentication_url(redirect_uri: "http://example.com")
        end.to raise_error(ArgumentError, /scopes/)
      end

      # Generate and throw a wrong URL error if scopes are nil and the redirect URI is nil.
      it "generates wrong url if scopes and redirect_uri is nil" do
        api = described_class.new(app_id: "2454354")

        hosted_auth_url = api.authentication_url(
          redirect_uri: nil,
          scopes: nil
        )

        expected_url = "https://api.nylas.com/oauth/authorize"\
        "?client_id=2454354"\
        "&redirect_uri"\
        "&response_type=code"\
        "&login_hint"
        expect(hosted_auth_url).to eq(expected_url)
      end
    end
  end

  # Return a NylasV3::Collection object for contact group requests.
  describe "#contact_groups" do
    it "returns NylasV3::Collection for contact groups" do
      client = instance_double("NylasV3::HttpClient")
      api = described_class.new(client: client)

      result = api.contact_groups

      expect(result).to be_a(NylasV3::Collection)
    end
  end

  # Retrieve the current acccount based on the provided OAuth token, and set the header.
  describe "#current_account" do
    # Retrieve the account related to the provided OAuth token.
    it "retrieves the account for the current OAuth Access Token" do
      client = NylasV3::HttpClient.new(app_id: "not-real", app_secret: "also-not-real",
                                     access_token: "seriously-unreal")
      allow(client).to receive(:execute).with(method: :get, path: "/account").and_return(id: 1234)
      api = described_class.new(client: client)
      expect(api.current_account.id).to eql("1234")
    end

    # Generate and throw an exception if no OAuth token is set.
    it "raises an exception if there is not an access token set" do
      client = NylasV3::HttpClient.new(app_id: "not-real", app_secret: "also-not-real")
      allow(client).to receive(:execute).with(method: :get, path: "/account").and_return(id: 1234)
      api = described_class.new(client: client)
      expect { api.current_account.id }.to raise_error NylasV3::NoAuthToken,
                                                       "No access token was provided and the " \
                                                       "current_account method requires one"
    end

    # Set the X-NylasV3-Client-Id header.
    it "sets X-NylasV3-Client-Id header" do
      client = NylasV3::HttpClient.new(app_id: "not-real", app_secret: "also-not-real")
      expect(client.default_headers).to include("X-NylasV3-Client-Id" => "not-real")
    end
  end

  # Get an account's status (either free or busy) based on its calendar availability.
  describe "#free_busy" do
    it "returns `NylasV3::FreeBusyCollection` for free busy details" do
      emails = ["test@example.com", "anothertest@example.com"]
      start_time = 1_609_439_400
      end_time = 1_640_975_400
      client = NylasV3::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = described_class.new(client: client)
      free_busy_response = [
        {
          object: "free_busy",
          email: "test@example.com",
          time_slots: [
            {
              object: "time_slot",
              status: "busy",
              start_time: 1_609_439_400,
              end_time: 1_640_975_400
            }
          ]
        }
      ]
      allow(client).to receive(:execute).with(
        method: :post,
        path: "/calendars/free-busy",
        payload: {
          emails: emails,
          start_time: start_time,
          end_time: end_time
        }.to_json
      ).and_return(free_busy_response)

      result = api.free_busy(
        emails: emails,
        start_time: Time.at(start_time),
        end_time: Time.at(end_time)
      )

      expect(result).to be_a(NylasV3::FreeBusyCollection)
      free_busy = result.last
      expect(free_busy.object).to eq("free_busy")
      expect(free_busy.email).to eq("test@example.com")
      time_slot = free_busy.time_slots.last
      expect(time_slot.object).to eq("time_slot")
      expect(time_slot.status).to eq("busy")
      expect(time_slot.start_time.to_i).to eq(start_time)
      expect(time_slot.end_time.to_i).to eq(end_time)
    end
  end

  # Get and update an application's details.
  describe "application details" do
    # Get an application's details (name, icon, redirect URIs, and so on).
    it "gets the application details" do
      client = NylasV3::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real"
      )
      api = described_class.new(client: client)
      application_details_response = {
        application_name: "My New App Name",
        icon_url: "http://localhost/icon.png",
        redirect_uris: %w[http://localhost/callback]
      }
      stub_request(:get, "https://api.nylas.com/a/not-real")
        .to_return(
          status: 200,
          body: application_details_response.to_json,
          headers: { "content-type" => "application/json" }
        )

      app_details = api.application_details

      expect(app_details).to be_a(NylasV3::ApplicationDetail)
      expect(app_details.application_name).to eq("My New App Name")
      expect(app_details.icon_url).to eq("http://localhost/icon.png")
      expect(app_details.redirect_uris).to eq(%w[http://localhost/callback])
    end

    # Update an application's details (name, icon, redirect URIs, and so on).
    it "updates the application details" do
      application_details_response = {
        application_name: "Updated App Name",
        icon_url: "http://localhost/updated_icon.png",
        redirect_uris: %w[http://localhost/callback http://localhost/updated]
      }
      app_details = NylasV3::ApplicationDetail.new
      app_details.application_name = "Updated App Name"
      app_details.icon_url = "http://localhost/updated_icon.png"
      app_details.redirect_uris = %w[http://localhost/callback http://localhost/updated]
      client = NylasV3::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real"
      )
      api = described_class.new(client: client)
      stub_request(:put, "https://api.nylas.com/a/not-real")
        .to_return(
          status: 200,
          body: application_details_response.to_json,
          headers: { "content-type" => "application/json" }
        )

      updated_app_details = api.update_application_details(app_details)

      expect(updated_app_details).to be_a(NylasV3::ApplicationDetail)
    end
  end

  # Execute a set of actions to build an authentication URL, add headers to the request, and send
  # the request. If any exceptions or errors are generated, they are thrown.
  describe "#execute" do
    it "builds the URL based upon the api_server it was initialized with"
    it "adds the nylas headers to the request"
    it "allows you to add more headers"
    it "raises the appropriate exceptions based on the status code it gets back"
    it "includes the passed in query params in the URL"
    it "appropriately sends a string payload as a string"
    it "sends a hash payload as a string of JSON"
    it "yields the response body, request and result to a block and returns the blocks result"
    it "returns the response body if no block is given"
  end
end
