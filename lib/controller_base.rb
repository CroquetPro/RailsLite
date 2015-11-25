require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require 'json'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Already Built" if already_built_response?
    @res.status = 302
    @res['location'] = url
    session.store_session(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Already Built" if already_built_response?
    @res['Content-Type'] = content_type
    @res.body = [content]
    session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore
    erb = ERB.new(File.read("views/#{controller_name}/#{template_name}.html.erb"))

    render_content(erb.result(binding), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
