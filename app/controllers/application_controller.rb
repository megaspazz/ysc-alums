class ApplicationController < ActionController::Base

  # Cross-site request forgery safeguard
  # Don't understand, see Chapter 8 of Hartl tutorial
  protect_from_forgery
  
  # Includes an amalgamation of useful global methods used everywhere
  include SessionsHelper
  
  # This helps us render empty div's in HTML by putting &nbsp into them
  # No longer needed, as the Users page was fully revamped
  include HtmlRenderHelper
  
  # This is to include a random string generator to be used in Ruby 1.8.7
  include RandomStrings

  # This is required because will_paginate has a bug that sometimes doesn't paginate arrays!
  require 'will_paginate/array'

end
