class Api::V1::UsersController < ApplicationController

  def new
    @user = User.create(name: "ゲスト")
    @user.name = "ゲスト#{@user.id}"
    @user.save
    render json: @user
  end

  def create
  end

  def edit
  end

  def update
  end

end