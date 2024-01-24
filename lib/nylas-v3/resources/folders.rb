# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module NylasV3
  # NylasV3 Folder API
  class Folders < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all folders.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @return [Array(Array(Hash), String)] The list of folders and API Request ID.
    def list(identifier:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/folders"
      )
    end

    # Return a folder.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param folder_id [String] The id of the folder to return.
    # @return [Array(Hash, String)] The folder and API request ID.
    def find(identifier:, folder_id:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}"
      )
    end

    # Create a folder.
    #
    # @param identifier [String] Grant ID or email account in which to create the object.
    # @param request_body [Hash] The values to create the folder with.
    # @return [Array(Hash, String)] The created folder and API Request ID.
    def create(identifier:, request_body:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/folders",
        request_body: request_body
      )
    end

    # Update a folder.
    #
    # @param identifier [String] Grant ID or email account in which to update an object.
    # @param folder_id [String] The id of the folder to update.
    # @param request_body [Hash] The values to update the folder with
    # @return [Array(Hash, String)] The updated folder and API Request ID.
    def update(identifier:, folder_id:, request_body:)
      put(
        path: "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}",
        request_body: request_body
      )
    end

    # Delete a folder.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param folder_id [String] The id of the folder to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, folder_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}"
      )

      [true, request_id]
    end
  end
end
