class HangoversController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def index
    @hangovers = Hangover.inventory(params[:type])
  end

  def show
    @hangover = Hangover.find(params[:id])
  end

  def new
    @hangover = Hangover.new(params)
  end

  def create
    @hangover = current_user.hangovers.build(params[:hangover])
    if @hangover.save_and_process_image
      flash[:notice] = I18n.t("hangover.being_created")
      redirect_to :action => :index
    else
      render :new
    end
  end

#  def edit
#    @hangover = Hangover.find(params[:id])
#  end

#  def update
#    @hangover = Hangover.find(params[:id])
#    if @hangover.update_attributes(params[:hangover])
#      redirect_to @hangover, :notice  => "Successfully updated hangover."
#    else
#      render :action => 'edit'
#    end
#  end

#  def destroy
#    @hangover = Hangover.find(params[:id])
#    @hangover.destroy
#    redirect_to hangovers_url, :notice => "Successfully destroyed hangover."
#  end
end

