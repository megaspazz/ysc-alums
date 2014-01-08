class SimpleEmailsController < ApplicationController

  # These before_filter's is also in the UsersController, but it might be OK to also have them here instead of globally
  # because it is more specific than having to look in a superclass for these types of filters
  before_filter :signed_in_user
  before_filter :check_confirmed_user

  # Whenever the user is going to the email page, save the target alum!
  before_filter :set_target_alum, :only => :new
  
  # The following actions are restricted to admins only
  before_filter :admin_user, :only => [:destroy, :make_admin, :admin_cp_users]

  # routed here from /users/:id/email
  def new
    # Setting the target alum for use in the 'create' method
    @alum = get_target_alum
    @email = SimpleEmail.new
  end

  # Remember that the param coming in is named :simple_email, and not :email
  def create
    #Get the alum, which should have been set earlier before the 'new' method
    @alum = get_target_alum

    # Set up the email
    @email = SimpleEmail.new(params[:simple_email])
    @email.alum_id = @alum.id
    @email.alum_name = @alum.name
    @email.alum_email = @alum.email
    @email.user_id = current_user.id
    @email.user_name = current_user.name
    @email.user_email = current_user.email
    
    if @email.save
      # Send the email now!  (Don't need a separate method)
      UserMailer.send_to_alum(@email).deliver
      UserMailer.send_to_user(@email).deliver
      flash[:success] = "Email has been sent successfully.  You should receive a confirmation shortly."
      # Where should the redirection go after email sent?
      redirect_to(@alum)
    else
      flash.now[:error] = "You need to have subject and a message!"
      render('new')
    end
  end

  # Not even sure if this is necessary
  def destroy
  end
  
  def admin_cp_emails
    @emails = SimpleEmail.all.reverse
  end
  


  private

    # The following class-static variable gets set on the 'new' method
    # It is used in the create method to set the target alum
    # It's listed down here because I think it should be private?
    @@target_alum_id = :set_target_alum

    # Make sure to set_target_alum before using get_target_alum
    def set_target_alum
      @@target_alum_id = params[:id]
    end

    def get_target_alum
      User.find(@@target_alum_id)
    end
end
