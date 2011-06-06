class HangoverVotesController < ApplicationController
  def create
    @hangover = Hangover.find(params[:id])
    @hangover.votes.create(:user => current_user)
    redirect_to :back
  end
end

