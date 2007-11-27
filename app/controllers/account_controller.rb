class AccountController < ApplicationController
  layout 'frame_no_search'
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => 'admin', :action => 'index') if current_user.role == 'Administrator'
      redirect_back_or_default(:controller => 'public', :action => 'index') if current_user.role != 'Administrator'
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    @no_admin = (User.find_by_role('Administator') == nil)
    redirect_to(:action => 'login') unless @no_admin
    @user = User.new(params[:user])
    @user.role = 'Administrator'
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => 'admin', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:action => 'login')
  end
  
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      @user.password = '';
      @user.password_confirmation = '';
      redirect_to :controller=>'personal', :action => 'list_collection', :id=>@user.id
    else
      @user.password = '';
      @user.password_confirmation = '';
      render :action => 'edit'
    end
  end
end
