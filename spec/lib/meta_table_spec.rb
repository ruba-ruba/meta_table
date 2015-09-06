require 'rails'
require 'action_controller/railtie'
require 'spec_helper'

 describe PostsController, type: :controller do
  render_views

  it "works" do
    get :index
    expect(response).to be_success
  end
end