class HangoverVotesController < ApplicationController
  def create
    @hangover = Hangover.find(params[:id])
    if @hangover.votes.create(:user => find_or_create_current_user)
      flash[:notice] = I18n.t("hangover.you_rate_it")
    end
    redirect_to :back
  end
end

