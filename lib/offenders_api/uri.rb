require 'addressable/uri'

module OffendersApi
  class URI
    def initialize(uri)
      @uri = Addressable::URI.parse(uri)
    end

    def to_s
      normalized_uri
    end

    private

    attr_reader :uri

    def normalized_uri
      [uri.scheme, '://', uri.host, normalized_path, query_string].compact.join('')
    end

    def normalized_path
      return unless uri.path
      uri.path.gsub('//', '/').sub(/[\/]$/,'')
    end

    def query_string
      return unless uri.query
      '?' + uri.query
    end
  end
end
