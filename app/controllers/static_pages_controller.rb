class StaticPagesController < ApplicationController
  def home
    if logged_in?
      log_out
    end
  end
end
