class JournalsController < ApplicationController
  def index
    @journals = Journal.all
  end

  def show
    @journal = Journal.find(params[:id])
  end

  def new
    @journal = Journal.new
  end

  def create
    @journal = Journal.new(params[:journal])
    if @journal.save
      redirect_to @journal, :notice => "Successfully created journal."
    else
      render :action => 'new'
    end
  end

  def edit
    @journal = Journal.find(params[:id])
  end

  def update
    @journal = Journal.find(params[:id])
    if @journal.update_attributes(params[:journal])
      redirect_to @journal, :notice  => "Successfully updated journal."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @journal = Journal.find(params[:id])
    @journal.destroy
    redirect_to journals_url, :notice => "Successfully destroyed journal."
  end
end
