module OffendersApi
  class AccessToken
    DEFAULT_EXPIRES_IN = 0

    include HashExtensions

    attr_reader :value, :type, :expires_in, :created_at

    def initialize(options)
      _options = symbolize_keys(options)
      @value = _options.fetch(:value)
      @type = _options[:type]
      @expires_in = _options.fetch(:expires_in, DEFAULT_EXPIRES_IN)
      @created_at = Time.at(_options.fetch(:created_at) { Time.now.utc.to_i }).utc
    end

    def valid?
      !expired?
    end

    def expired?
      Time.now.utc > expires_at
    end

    def expires_at
      created_at + expires_in
    end
  end
end
