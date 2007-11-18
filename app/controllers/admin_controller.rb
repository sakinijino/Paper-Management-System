class AdminController < ApplicationController
  layout 'admin'  
  include AuthenticatedSystem
  before_filter :login_required
  before_filter :admin_required

 def index
    render :action => 'list_user'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #~ verify :method => :post, :only => [ :destroy, :create, :update ],
          #~ :redirect_to => { :action => :list }

  def list_user
    @user_pages, @users = paginate :users, :per_page => 10
    @users.sort! {|u1, u2| Iconv.conv("GBK", "UTF-8", u1.realname)<=>Iconv.conv("GBK", "UTF-8", u2.realname)}
  end

  def new_user
    @user = User.new
    @roles = User.role_list
  end

  def create_user
    @user = User.new(params[:user])
    @user.realname = @user.login if @user.realname == ""
    @user.password = @user.login if @user.password == ""
    @user.password_confirmation = @user.login if @user.password_confirmation == ""
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list_user'
    else
      @roles = User.role_list
      @user.password = ""
      @user.password_confirmation = ""
      render :action => 'new_user'
    end
  end

  def edit_user
    @user = User.find(params[:id])
    @roles = User.role_list
  end

  def update_user
    @user = User.find(params[:id])
    @user.realname = @user.login if @user.realname == ""
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'list_user', :id => @user
    else
      @roles = User.role_list
      @user.password = ""
      @user.password_confirmation = ""
      render :action => 'edit'
    end
  end

  def destroy_user
    User.find(params[:id]).destroy
    redirect_to :action => 'list_user'
  end
end
