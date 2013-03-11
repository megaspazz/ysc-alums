class UsersController < ApplicationController

  before_filter :signed_in_user, only: [:index, :edit, :update]
  before_filter :correct_user, only: [:edit, :update]

  before_filter :admin_user, only: [:destroy, :make_admin]

  # Remember which edit page you came from so that you can re-render it if it fails verification
  before_filter :save_edit_type, only: [:edit, :change_settings, :change_password]


  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

  def edit
    @user = User.find(params[:id])
  end

  def change_settings
  	@user = User.find(params[:id])
  end

  def change_password
  	@user = User.find(params[:id])
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
    if @user.save
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
    @user.save(validate: false)
    flash[:success] = "Created an admin."
    redirect_to(users_url)
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(edit_user_url(current_user), notice: "dat aint your account... edit your own stuff mang!") unless (current_user?(@user) || current_user.admin?)
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

      @topic_hash = { church_comm:    "Church and Community",
                      voca_min:       "Vocational Ministry",
                      finan_stew:     "Financial Stewardship",
                      miss_int_dev:   "Missions and International Development",
                      trial_dis:      "Trials and Disappointment",
                      career_changes: "Career Changes",
                      marriage:       "Marriage",
                      raise_child:    "Raising Young Children",
                      raise_teen:     "Parenting Teenagers",
                      retirement:     "Retirement" }

      @topic_hash.each_pair do |k, v|
        if params[k]
          @topics.create(content: v)
          flash[:info] = (params[k])
        #else
          # Boolean short-circuit is very OP
          #(@topic = @topics.find_by_content(v)) && @topic.destroy
        end
      end
    end

    def set_user_validations
        @user.should_validate_email = @user.should_validate_name = (should_update_topics || (session[:edit_loc] === 'change_settings'))
        @user.should_validate_password = should_validate_password
    end
end
