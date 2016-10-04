# frozen_string_literal: true
class StaticPagesController < ApplicationController
  include Europeana::Styleguide

  layout false

  # Render Home page.
  def index
  end
end
