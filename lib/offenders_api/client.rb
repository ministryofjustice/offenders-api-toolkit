require 'http'

module OffendersApi
  class Client
    attr_reader :client_id, :client_secret, :base_url, :access_token

    def initialize(options = {})
      @client_id = options.fetch(:client_id)
      @client_secret = options.fetch(:client_secret)
      @base_url = options.fetch(:base_url)
    end

    def authorize
      uri = URI.new("#{base_url}/oauth/token")
      response = HTTP.accept(:json).post(uri.to_s, params: authorization_options)
      if response.code == 200
        @access_token = AccessToken.new(mapped_authorization_response(response.parse(:json)))
      end
      response
    end

    def get(path, options = {})
      authorize unless valid_access_token?
      uri = URI.new("#{base_url}/api/#{path}")
      get_options = { params: options.fetch(:params, {}).merge(access_options) }
      HTTP.accept(:json).get(uri.to_s, get_options)
    end

    private

    def valid_access_token?
      access_token && access_token.valid?
    end

    def authorization_options
      credentials.merge(grant_type: 'client_credentials')
    end

    def mapped_authorization_response(response)
      {
        value: response['access_token'],
        type: response['token_type'],
        expires_in: response['expires_in'],
        created_at: response['created_at']
      }
    end

    def access_options
      { access_token: access_token.value }
    end

    def credentials
      {
        client_id: client_id,
        client_secret: client_secret
      }
    end
  end
end
