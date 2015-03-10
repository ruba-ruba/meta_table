Rails.application.routes.draw do
  get 'meta_table/new' => 'meta_table_views#new', as: :meta_table_views_new
  get 'meta_table/:id/edit' => 'meta_table_views#edit'
  patch  'meta_table/:id'  => 'meta_table_views#update', as: :meta_table_view
  post 'meta_table' => 'meta_table_views#create', as: :meta_table_views
end