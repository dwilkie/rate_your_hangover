class HangoverVotesController < ApplicationController
  def create
    @hangover = Hangover.find(params[:id])
    @hangover.votes.create(:user => current_user)
  end
end

