class UsersController < ApplicationController

  ### EVERY TIME YOU CREATE A NEW PAGE, MAKE SURE TO MODIFY THE FILTERS BELOW AS WELL!!! ###

  # The user must be signed in to view all pages *EXCEPT* the following.
  before_filter :signed_in_user, :except => [:new, :create, :destroy]

  # The user must have confirmed their email to view the following pages
  before_filter :check_confirmed_user, :only => [:index, :show]

  # The user must be the correct user (or an admin) when changing settings, i.e. no modifying other people's settings of equal or higher rank!
  before_filter :correct_user, :only => [:edit, :update, :change_settings, :change_password]

  # The following actions are restricted to admins only
  before_filter :admin_user, :only => [:destroy, :make_admin]

  # Remember which edit page you came from so that you can re-render it if it fails verification
  before_filter :save_edit_type, :only => [:edit, :change_settings, :change_password]

  # Make sure a user can't resend a confirmation email if they have already confirmed
  before_filter :dont_resend_confirmation, :only => [:resend_confirmation]

  # A class-static topics hash to be used in multiple methods
  @@topics = { :church_comm =>    "Church and Community",
               :voca_min =>       "Vocational Ministry",
               :finan_stew =>     "Financial Stewardship",
               :miss_int_dev =>   "Missions and International Development",
               :trial_dis =>      "Trials and Disappointment",
               :career_changes => "Career Changes",
               :marriage =>       "Marriage",
               :raise_child =>    "Raising Young Children",
               :raise_teen =>     "Parenting Teenagers",
               :retirement =>     "Retirement" }
  
  # A class-static variable for default search distance
  @@default_distance = 50
  
  # Numbers shown per page (used by them bootstrap-paginate gem)
  @@users_shown_per_page = 10

  # This index method is quite inefficient and primitive without a sophisticated full-text search (which can't be run on DreamHost)
  # So what it does it first use geocoder's "near" method to sort the users based on distance if the field is filled in
  # And then uses my primitive search method to filter and/or sort the final results, which finally gets passed to the view
  def index
    @users = User.all
    if (params[:search_location].present?)
      @users = User.near(params[:search_location], if params[:search_distance].present? then params[:search_distance] else @@default_distance end, :order => :distance)
    end
    if (params[:search_fields].present?)
      @users = search_users_for(@users, params[:search_fields], true, !params[:search_location].present?)
    end
    @users = @users.paginate(:page => params[:page], :per_page => @@users_shown_per_page)
  end
  
  # Eric's primitive method for searching an array of users given a search_string
  def search_users_for(initial_user_array, search_string, remove_unmatched, sort_after)
    results = initial_user_array
    (results = results.delete_if { |user| user.search_score(search_string) == 0 }) if remove_unmatched
    if sort_after
      scores = results.map { |user| user.search_score(search_string) }
      # The following one-liner is quite elegant, but may not be the fastest approach for sorting based on search_score
      results = scores.zip(results).transpose.last
    end
    # Return the results, unless it's nil, in which case return an empty array, which can get paginated for use with will_paginate
    if results.nil? then [] else results end
  end

  def edit
    @user = User.find(params[:id])
    @topic_hash = @@topics
  end

  def change_settings
  	@user = User.find(params[:id])
  end

  def change_password
  	@user = User.find(params[:id])
  end

  def settings
  end

  # This method has lots of logic!  But it assumes that it's impossible for any user to guess his own or another user's confirmation code
  def confirm_code
    @code = params[:confirm_code]
    @user = User.find_by_confirmation_code(params[:confirm_code])
    if (@user.nil?)
      if (current_user.admin?)      # Admin came too late or got it wrong
        flash[:error] = "This account has most likely been confirmed already (unless you manually typed the link incorrectly)."
        redirect_to(current_user)
      else
        if confirmed_user?          # User has already confirmed himself
          flash[:info] = "Your account has already confirmed, so it doesn't have to be confirmed again =)"
          redirect_to(current_user)
        elsif                       # User got the confirmation code wrong
          flash[:error] = "You have the wrong confirmation code... check your email or get a new code!"
          redirect_to(settings_url)
        end
      end
    else                            # Account will be confirmed
      flash.now[:success] = "This account has been confirmed."
		  @user.confirmation_code = nil
		  @user.save(:validate => false)
		  if (@user == current_user)    # Don't sign an admin into user
        sign_in(@user)
      end
    end
  end

  # Now this checks if you need auth'ation or validation -- see private methods
  def update
    @user = User.find(params[:id])

    set_user_validations

    if should_update_topics
      update_topics
    end

    if ((!should_auth || @user.authenticate(params[:old_password])) && @user.update_attributes(params[:user]))
      flash[:success] = "You successfully updated your information/settings!"
      sign_in(@user) if (current_user?(@user))    # only sign in again if you are the current user, since admins can now change other people's settings!
      redirect_to(@user)
    else
      flash_appropriate_error_messages
      render(session[:edit_loc])
    end
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Thanks for signing up!  Please take a moment to update your information."
      sign_in(@user)
      send_conditional_confirmation_email
      redirect_to(edit_user_url(@user))
    else
      render('new')
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "The user has been deleted."
    redirect_to(users_url)
  end
  
  def make_admin
    @user = User.find(params[:id])
    @user.admin = true
    @user.save(:validate => false)
    flash[:success] = "You've just added a new admin!"
    redirect_to(users_url)
  end

  def resend_confirmation
    @user = current_user
    send_conditional_confirmation_email
  end


  private

    # Admins are allowed to change people's settings!
    def correct_user
      @user = User.find(params[:id])
      unless (current_user?(@user) || (current_user.admin? && !@user.admin?))
        flash[:error] = "That isn't your account, and you don't have sufficient privileges to change stuff!"
        redirect_to(@user)
      end
    end

    def admin_user
      unless current_user.admin?
        flash[:error] = "You must be an admin to do that!"
        redirect_to(root_path)
      end
    end

    def save_edit_type
    	session[:edit_loc] = self.action_name
    end

    # Every time an action that changes a user should validate (i.e. requires password check), add a condition to this method!
    def should_validate_password
      session[:edit_loc] == 'change_password'
    end

    # Every time an action that changes a user should authenticate/authorize (i.e. requires password check), add a condition to this method!
    def should_auth
      session[:edit_loc] == 'change_password'
    end

    def should_update_topics
      session[:edit_loc] == 'edit'
    end
    
    def flash_appropriate_error_messages
      if session[:edit_loc] == 'change_password'
        flash[:error] = "Changes couldn't be saved... some of the information/settings aren't quite right... perhaps you didn't input your old password correctly?"
      elsif session[:edit_loc] == 'edit'
        flash[:error] = "Changes couldn't be saved... there's probably something wrong with your profile picture... see the error messages below."
      end
    end

    # This deletes everything from the topics and then repopulates as necessary
    # Slightly inefficient, but less code, and less repetition of string constants
    def update_topics
      @topics = @user.topics

      @topics.each do |t|
        t.destroy
      end

      @topic_hash = @@topics

      @topic_hash.each_pair do |k, v|
        if params[k]
          @topics.create(:content => v)
        #else
          # Boolean short-circuit is very OP
          #(@topic = @topics.find_by_content(v)) && @topic.destroy
        end
      end
    end

    def set_user_validations
        @user.should_validate_email = @user.should_validate_name = (should_update_topics || (session[:edit_loc] == 'change_settings'))
        @user.should_validate_password = should_validate_password
    end

    # sets a new confirmation code, and re-logs them in, since changing a User logs them out
    def set_new_confirmation_code
      @user.confirmation_code = urlsafe_randstr
      @user.save(:validate => false)
      sign_in(@user)
    end
    
    # Sends the email to the user if it passes the yale REGEX.  Otherwise, sends it to admins list
    # It will flash a message accordingly
    # This only checks the current user!
    def send_conditional_confirmation_email
      if has_valid_yale_email?(current_user)    # has a '@yale.edu' or '@aya.yale.edu' email
        flash[:info] = "A confirmation email has been sent to #{@user.email}.  You should get it shortly."
        send_confirmation_email
      else                                      # still needs admin confirmation
        send_admin_confirmation_email
        flash[:info] = "Because you didn't have an '@yale.edu' or '@aya.yale.edu' email, an admin has to confirm your email."
      end
    end

    def send_confirmation_email
      set_new_confirmation_code
      UserMailer.confirm_email(@user).deliver
    end

    def dont_resend_confirmation
      if confirmed_user?
        flash[:info] = "You already confirmed your email, so why resend a confirmation?"
        redirect_to(current_user)
      end
    end

    def send_admin_confirmation_email
      set_new_confirmation_code
      UserMailer.admin_confirm_email(@user, get_admin_email_list).deliver
    end

    # get_admin_list returns an array of all admins's emails
    def get_admin_email_list
      User.all(:conditions => {:admin => true}).map { |a| a.email }
    end

    VALID_YALE_EMAIL_REGEX = /\A[\w+\-.]+@(aya\.)?yale\.edu\z/i
    def has_valid_yale_email?(user)
      VALID_YALE_EMAIL_REGEX === user.email
    end
end
