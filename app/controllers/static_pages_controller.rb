class StaticPagesController < ApplicationController
  include Europeana::Styleguide

  layout false

  # Render Home page.
  def index
  end
end
