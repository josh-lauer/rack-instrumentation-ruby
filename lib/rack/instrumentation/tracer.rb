require "rack/instrumentation/version"
require "opentracing"

module Rack
  module Instrumentation
    class Tracer
      attr_reader :app, :tracer

      # Create a new Rack Tracer middleware.
      #
      # @param app The Rack application/middlewares stack.
      # @param tracer [OpenTracing::Tracer] A tracer to be used when start_span, and extract
      #        is called.
      def initialize(app, tracer: OpenTracing.global_tracer)
        @app = app
        @tracer = tracer
      end

      def call(env)
        tracer.start_active_span(*span_args(env)) do |scope|
          trace_request(env, scope)
        end
      end

      private
    
      def trace_request(env, scope)
        span = scope.span
        env['rack.span'] = span

        app.call(env).tap do |status_code, _headers, _body|
          span.set_tag('http.status_code', status_code)
          span.set_tag('error', true) if status_code >= 500 && status_code < 600

          route = route_from_env(env)
          span.operation_name = route if route
        end
      rescue StandardError => e
        span.set_tag('error', true)
        span.log_kv(
          event: 'error',
          :'error.kind' => e.class.to_s,
          :'error.object' => e,
          message: e.message,
          stack: e.backtrace.join("\n")
        )
        raise
      end

      def span_args(env)
        method = env["REQUEST_METHOD"]
        context = tracer.extract(OpenTracing::FORMAT_RACK, env)

        [
          method,
          child_of: context,
          tags: {
            'component' => 'ruby-rack',
            'span.kind' => 'server',
            'http.method' => method,
            'http.url' => env["REQUEST_URI"]
          }
        ]
      end

      def route_from_env(env)
        rails_controller = env['action_controller.instance']

        if rails_controller
          "#{env["REQUEST_METHOD"]} #{rails_controller.class.name}##{rails_controller.action_name}"
        end
      end
    end
  end
end
