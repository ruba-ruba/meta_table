class MetaTableViewsController < ApplicationController
  # layout false

  before_action :set_mtw, only: [:edit, :update]

  def new
    # binding.pry
    @mtw = MetaTableView.new
  end

  def edit
    render template: 'meta_table_views/new'
  end

  def create
    @mtw = MetaTableView.new(params[:meta_table_view])
    if @mtw.save
      redirect_to route_back
    else
      render :action => :new
    end
  end

  def update
    @mtw.attributes = params[:meta_table_view]
    if @mtw.save
      redirect_to params[:meta_table_view][:route_back]
    else
      render :action => :new
    end
  end

  protected

  def meta_table_view_params
    params.require(:meta_table_view).permit!
  end

  def route_back
    str = params[:meta_table_view][:route_back]
    if str.match /table_view=/
      str.gsub(/table_view=(\d|-1)/, "table_view=#{@mtw.id}")
    else
      str + "?table_view=#{@mtw.id}"
    end
  end

  def set_mtw
    @mtw = MetaTableView.find params[:id]
  end
  
end