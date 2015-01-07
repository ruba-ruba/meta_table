class MetaTableViewsController < ApplicationController
  layout false

  def new
    @mtw = MetaTableView.new
  end

  def edit
    @mtw = MetaTableView.find params[:id]
    render template: 'meta_table_views/new'
  end

  def create
    @mtw = MetaTableView.new(params[:meta_table_view])
    if @mtw.save
      redirect_to "/meta_table/#{@mtw.id}/edit"
    else
      render :action => :new
    end
  end

  def update
    @mtw = MetaTableView.new(params[:meta_table_view])
    if @mtw.save
      redirect_to "/meta_table/#{@mtw.id}/edit"
    else
      render :action => :new
    end
  end

  protected

  def meta_table_view_params
    params.require(:meta_table_view).permit!
  end
  
end