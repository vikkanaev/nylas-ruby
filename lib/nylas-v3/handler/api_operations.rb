# frozen_string_literal: true

require_relative "http_client"

module NylasV3
  # Allows resources to perform API operations on the NylasV3 API endpoints without exposing the HTTP
  # client to the end user.
  module ApiOperations
    # Performs a GET call to the NylasV3 API.
    module Get
      protected

      include HttpClient
      # Performs a GET call to the NylasV3 API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @return NylasV3 data object and API Request ID.
      def get(path:, query_params: {})
        response = execute(
          method: :get,
          path: path,
          query: query_params,
          payload: nil,
          api_key: api_key,
          timeout: timeout
        )

        [response[:data], response[:request_id]]
      end
    end

    # Performs a POST call to the NylasV3 API.
    module Post
      protected

      include HttpClient
      # Performs a POST call to the NylasV3 API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @param request_body [String, Hash, nil] Request body to pass to the call.
      # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
      # @return NylasV3 data object and API Request ID.
      def post(path:, query_params: {}, request_body: nil, headers: {})
        response = execute(
          method: :post,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        )

        [response[:data], response[:request_id]]
      end
    end

    # Performs a PUT call to the NylasV3 API.
    module Put
      protected

      include HttpClient
      # Performs a PUT call to the NylasV3 API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @param request_body [String, Hash, nil] Request body to pass to the call.
      # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
      # @return NylasV3 data object and API Request ID.
      def put(path:, query_params: {}, request_body: nil, headers: {})
        response = execute(
          method: :put,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        )

        [response[:data], response[:request_id]]
      end
    end

    # Performs a PATCH call to the NylasV3 API.
    module Patch
      protected

      include HttpClient
      # Performs a PATCH call to the NylasV3 API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @param request_body [String, Hash, nil] Request body to pass to the call.
      # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
      # @return NylasV3 data object and API Request ID.
      def patch(path:, query_params: {}, request_body: nil, headers: {})
        response = execute(
          method: :patch,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        )

        [response[:data], response[:request_id]]
      end
    end

    # Performs a DELETE call to the NylasV3 API.
    module Delete
      protected

      include HttpClient
      # Performs a DELETE call to the NylasV3 API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
      # @return NylasV3 data object and API Request ID.
      def delete(path:, query_params: {}, headers: {})
        response = execute(
          method: :delete,
          path: path,
          query: query_params,
          headers: headers,
          payload: nil,
          api_key: api_key,
          timeout: timeout
        )

        [response[:data], response[:request_id]]
      end
    end
  end
end
