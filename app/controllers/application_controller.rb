class ApplicationController < ActionController::Base

  # Cross-site request forgery safeguard
  # Don't understand, see Chapter 8 of Hartl tutorial
  protect_from_forgery
  
  # This updates the last_visited field for users when they visit pages when they're logged in
  before_filter :update_last_visited
    
  # Includes an amalgamation of useful global methods used everywhere
  include SessionsHelper
  
  # This helps us render empty div's in HTML by putting &nbsp into them
  # No longer needed, as the Users page was fully revamped
  include HtmlRenderHelper
  
  # This is to include a random string generator to be used in Ruby 1.8.7
  include RandomStrings

  # This is required because will_paginate has a bug that sometimes doesn't paginate arrays!
  require 'will_paginate/array'
  
  def update_last_visited
    if (signed_in?)
      temp_user = current_user
       current_user.last_visited = Time.current
       current_user.save(:validate => false)
      sign_in(temp_user)
    end
  end

end
