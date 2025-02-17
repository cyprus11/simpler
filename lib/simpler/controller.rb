require_relative 'view'
require 'byebug'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action, params)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action
      @request.env['simpler.params'] = params

      set_default_headers
      send(action)
      write_response

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.env['simpler.params']
    end

    def render(template)
      set_header(template)
      @request.env['simpler.template'] = template
    end

    def set_header(template)
      if template.is_a?(Hash)
        @response['Content-Type'] = 'text/plain' if template.include?(:plain)
      end
    end

    def status(status)
      @response.status = status
    end

    def headers
      @response.headers
    end

  end
end
