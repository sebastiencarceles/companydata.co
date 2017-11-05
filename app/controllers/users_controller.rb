# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "TODO"
    else
      render :new
    end
  end

  def show
  end

  private

    def find_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:firstname, :lastname, :email, :password)
    end
end
