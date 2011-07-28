class HangoversController < ApplicationController
  prepend_before_filter :authenticate_user!, :except => [:index, :show]

  def index
    @hangovers = Hangover.inventory(params[:type])
  end

  def show
    @hangover = Hangover.find(params[:id])
  end

  def new
    @hangover = Hangover.new(params)
    @hangover.delete_upload
    unless @hangover.upload_path_valid?
      flash[:error] = @hangover.errors.full_messages.to_sentence
      redirect_to new_hangover_image_path
    end
  end

  def create
    @hangover = current_user.hangovers.build(params[:hangover])
    if @hangover.save_and_process_image
      flash[:notice] = I18n.t(
        "hangover.being_created",
        :refresh_link => view_context.link_to(
          I18n.t("hangover.refresh"), hangovers_path
        )
      ).html_safe
      redirect_to :action => :index
    else
      render :new
    end
  end
end

