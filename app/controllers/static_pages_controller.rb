class StaticPagesController < ApplicationController
	
  def home
  end

  def about
  end

  def help
  end

  def contact
  end

  def test
    @test_string = urlsafe_randstr
    @valid_yale = has_valid_yale_email(current_user)
  end

  VALID_YALE_EMAIL_REGEX = /\A[\w+\-.]+@(aya\.)?yale\.edu\z/i
  def has_valid_yale_email(user)
    VALID_YALE_EMAIL_REGEX === user.email
  end

end
