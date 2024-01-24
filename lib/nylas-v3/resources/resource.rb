# frozen_string_literal: true

module NylasV3
  # NOTE: BaseResource is the base class for all NylasV3 API resources.
  # Used by all NylasV3 API resources
  class Resource
    # Initializes a resource.
    def initialize(sdk_instance)
      @api_key = sdk_instance.api_key
      @api_uri = sdk_instance.api_uri
      @timeout = sdk_instance.timeout
    end

    private

    attr_reader :resource_name, :api_key, :api_uri, :timeout
  end
end
