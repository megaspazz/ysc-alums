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
  end

end
