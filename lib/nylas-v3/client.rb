# frozen_string_literal: true

require_relative "resources/calendars"
require_relative "resources/connectors"
require_relative "resources/messages"
require_relative "resources/events"
require_relative "resources/auth"
require_relative "resources/webhooks"
require_relative "resources/applications"
require_relative "resources/folders"

module NylasV3
  # Methods to retrieve data from the NylasV3 API as Ruby objects.
  class Client
    attr_reader :api_key, :api_uri, :timeout

    # Initializes a client session.
    #
    # @param api_key [String, nil] API key to use for the client session.
    # @param api_uri [String] Client session's host.
    # @param timeout [String, nil] Timeout value to use for the client session.
    def initialize(api_key:,
                   api_uri: Config::DEFAULT_REGION_URL,
                   timeout: nil)
      @api_key = api_key
      @api_uri = api_uri
      @timeout = timeout || 30
    end

    # The application resources for your NylasV3 application.
    #
    # @return [NylasV3::Applications] Application resources for your NylasV3 application.
    def applications
      Applications.new(self)
    end

    # The attachments resources for your NylasV3 application.
    #
    # @return [NylasV3::Attachments] Attachment resources for your NylasV3 application.
    def attachments
      Attachments.new(self)
    end

    # The auth resources for your NylasV3 application.
    #
    # @return [NylasV3::Auth] Auth resources for your NylasV3 application.
    def auth
      Auth.new(self)
    end

    # The calendar resources for your NylasV3 application.
    #
    # @return [NylasV3::Calendars] Calendar resources for your NylasV3 application.
    def calendars
      Calendars.new(self)
    end

    # The connector resources for your NylasV3 application.
    #
    # @return [NylasV3::Connectors] Connector resources for your NylasV3 application.
    def connectors
      Connectors.new(self)
    end

    # The contact resources for your NylasV3 application.
    #
    # @return [NylasV3::Contacts] Contact resources for your NylasV3 application.
    def contacts
      Contacts.new(self)
    end

    # The draft resources for your NylasV3 application.
    #
    # @return [NylasV3::Drafts] Draft resources for your NylasV3 application.
    def drafts
      Drafts.new(self)
    end

    # The event resources for your NylasV3 application.
    #
    # @return [NylasV3::Events] Event resources for your NylasV3 application
    def events
      Events.new(self)
    end

    # The folder resources for your NylasV3 application.
    #
    # @return [NylasV3::Folder] Folder resources for your NylasV3 application
    def folders
      Folders.new(self)
    end

    # The grants resources for your NylasV3 application.
    #
    # @return [NylasV3::Grants] Grant resources for your NylasV3 application
    def grants
      Grants.new(self)
    end

    # The message resources for your NylasV3 application.
    #
    # @return [NylasV3::Messages] Message resources for your NylasV3 application
    def messages
      Messages.new(self)
    end

    # The thread resources for your NylasV3 application.
    #
    # @return [NylasV3::Threads] Thread resources for your NylasV3 application.
    def threads
      Threads.new(self)
    end

    # The webhook resources for your NylasV3 application.
    #
    # @return [NylasV3::Webhooks] Webhook resources for your NylasV3 application.
    def webhooks
      Webhooks.new(self)
    end
  end
end
