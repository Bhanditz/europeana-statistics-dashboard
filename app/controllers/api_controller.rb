# frozen_string_literal: true
class ApiController < ApplicationController
  layout false

  # render a datacast instance's output.
  def datacast
    identifier = params["identifier"]
    return_datacast = Core::Datacast.find_by_identifier(identifier)
    render json: return_datacast.run('json')["query_output"]
  end
end
