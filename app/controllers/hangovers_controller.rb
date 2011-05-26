class HangoversController < ApplicationController
  def index
    @hangovers = Hangover.summary
  end

  def show
    @hangover = Hangover.find(params[:id])
  end

  def new
    @hangover = Hangover.new
  end

  def create
    @hangover = Hangover.new(params[:hangover])
    @hangover.owner = request.remote_ip
    if @hangover.save
      redirect_to @hangover, :notice => "Successfully created hangover."
    else
      render :action => 'new'
    end
  end

  def edit
    @hangover = Hangover.find(params[:id])
  end

  def update
    @hangover = Hangover.find(params[:id])
    if @hangover.update_attributes(params[:hangover])
      redirect_to @hangover, :notice  => "Successfully updated hangover."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @hangover = Hangover.find(params[:id])
    @hangover.destroy
    redirect_to hangovers_url, :notice => "Successfully destroyed hangover."
  end
end
