# Un-comment the following two lines if you are running into trouble on DreamHost -- it may resolve the issue?
# ENV['GEM_PATH'] = 'home/ysfc/.gems:/usr/lib/ruby/gems/1.8'
# ENV['RAILS_ENV'] = 'production'

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
YscAlums::Application.initialize!
