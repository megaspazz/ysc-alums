class UsersController < ApplicationController

  # make before_filter for pages that require user to be confirmed to view
  before_filter :signed_in_user, :only => [:index, :edit, :update, :show, :change_password, :change_settings, :settings]
  before_filter :check_confirmed_user, :only => [:index, :show]
  before_filter :correct_user, :only => [:edit, :update]

  before_filter :admin_user, :only => [:destroy, :make_admin]

  # Remember which edit page you came from so that you can re-render it if it fails verification
  before_filter :save_edit_type, :only => [:edit, :change_settings, :change_password]

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

  def index
    @users = User.paginate(:page => params[:page], :per_page => 10)
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

  def confirm_code
    @code = params[:confirm_code]
    @user = User.find_by_confirmation_code(params[:confirm_code])
    if current_user.confirmation_code.nil?
      flash[:info] = "You have already confirmed, so you don't have to do it again =)"
      redirect_to(current_user)
		elsif !@user.nil?
      flash[:success] = "You got it right."
		  @user.confirmation_code = nil
		  @user.save(:validate => false)
		  sign_in(@user)
    else
      flash[:error] = "You have the wrong confirmation code... check your email or get a new code!"
      redirect_to(settings_url)
    end
  end

  # Now this checks if you need auth'ation or validation -- see private methods
  def update
    @user = User.find(params[:id])

    set_user_validations

    if should_update_topics
      flash[:error] = "update tpx"
      update_topics
    end

    if ((!should_auth || @user.authenticate(params[:old_password])) && @user.update_attributes(params[:user]))
      flash[:success] = "You did it chump"
      sign_in(@user)
      redirect_to(@user)
    else
      flash[:failure] = "Didn't quite make it..."
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
    @user.confirmation_code = urlsafe_randstr
    if @user.save
      UserMailer.confirm_email(@user).deliver
      sign_in(@user)
      flash[:success] = "Thanks for signing up!  Please take a moment to update your information."
      redirect_to(edit_user_url(@user))
    else
      render('new')
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to(users_url)
  end
  
  def make_admin
    #redirect_to(change_settings_url)
    @user = User.find(params[:id])
    @user.admin = true
    @user.save(:validate => false)
    flash[:success] = "Created an admin."
    redirect_to(users_url)
  end

  private

    def check_confirmed_user
      unless confirmed_user? || (self.action_name == 'show' && User.find(params[:id]) == current_user)
			  flash[:error] = "You need need to confirm your email to view this page.  You can resend your confirmation email here."
			  redirect_to(settings_url) # will redirect later
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(edit_user_url(current_user), :notice => "dat aint your account... edit your own stuff mang!") unless (current_user?(@user) || current_user.admin?)
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
          flash[:info] = (params[k])
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
end
