require 'rackstash'

module Rackstash
  class LogMiddleware

    def initialize(app)
      @app = app
    end

    def call(env)
      Rackstash.with_log_buffer do
        request = Rack::Request.new(env)
        fields = {
          :method => request.request_method,
          :scheme => request.scheme,
          :path => (request.fullpath rescue "unknown"),
          :host => (request.host rescue ''),
          :user_agent => (request.user_agent rescue '')
        }
        begin
          status, headers, result = @app.call(env)
        ensure
          fields[:status] = status
          Rackstash.logger.fields.reverse_merge!(fields) if Rackstash.logger.fields
        end
      end
    end
  end
end
