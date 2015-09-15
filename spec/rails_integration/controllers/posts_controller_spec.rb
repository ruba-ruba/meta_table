require 'rails_helper'

describe PostsController, type: :controller do

  context 'load methods' do
    subject { self.controller }

    it { is_expected.to respond_to(:render_posts_table) }

    it { is_expected.to respond_to(:meta_table) }
  end
  
  context 'render views' do
    render_views
    
    it "has success response" do
      get :index
      expect(response).to be_success
    end
  end
end