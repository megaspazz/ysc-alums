class UsersController < ApplicationController

  before_filter :signed_in_user, only: [:index, :edit, :update]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy

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
    if ((!should_auth || @user.authenticate(params[:old_password])) && (@user.attributes = params[:user]) && @user.save(validate: should_validate))
      flash[:success] = "You did it chump"
      sign_in(@user)
      redirect_to(@user)
    else
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
      flash[:success] = "You did it!  You haz regist0rd!!!"
      redirect_to(@user)
    else
      render('new')
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to(users_url)
  end
  


  private

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to(login_url, notice: "Pls sign in")
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(edit_user_url(current_user), notice: "dat aint your account... edit your own stuff mang!") unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def save_edit_type
    	session[:edit_loc] = self.action_name
    end

    # Every time an action that changes a user should validate (i.e. requires password check), add a condition to this method!
    def should_validate
      session[:edit_loc] == 'change_password'
    end

    # Every time an action that changes a user should authenticate/authorize (i.e. requires password check), add a condition to this method!
    def should_auth
      session[:edit_loc] == 'change_password'
    end

end
