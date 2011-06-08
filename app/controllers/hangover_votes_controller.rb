class HangoverVotesController < ApplicationController
  def create
    user = find_or_create_current_user
    if user
      hangover_vote = Hangover.find(params[:id]).votes.build(:user => user)

      hangover_vote.save ?
        flash[:notice] = I18n.t("hangover.you_rate_it") :
        flash[:error] = hangover_vote.errors.full_messages.to_sentence

    else
      flash[:error] = I18n.t(
        "hangover.sign_in_to_rate_it",
        :sign_in_link => view_context.link_to(I18n.t(:sign_in), new_user_session_path)
      ).html_safe
    end
    redirect_to :back
  end
end

