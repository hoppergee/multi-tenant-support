class UsersController < ApplicationController
  def index
  end

  def new
  end

  def edit
  end

  def create
    redirect_to users_path
  end

  def update
    redirect_to users_path
  end

  def destroy
    redirect_to users_path
  end
end