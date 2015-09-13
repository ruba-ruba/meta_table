
run "rm Gemfile"

generate :scaffold, "post title:string content:text user_id:integer category_id:integer published:boolean"
# generate :scaffold, "category title:string user_id:integer"
# generate :scaffold, "user name:string email:string"


#controller staff
inject_into_file  "app/controllers/posts_controller.rb", 
                  "\n meta_table(:post,[ 
                                         {key: :id, label: 'Number'},
                                         {key: :title, searchable: true}
                                       ],
                                       {scope: 'published', 
                                        per_page_choises: [5, 10, 15],
                                        includes: [:hubs, :user]}
                                      )\n", 
                  after: 'class PostsController < ApplicationController'

inject_into_file  "app/controllers/posts_controller.rb",
                  "\n render_posts_table \n",
                  after: "def index"
#controller staff

#models
inject_into_file  "app/models/post.rb",
                  "\n scope :published, -> { where(published: true) } \n",
                  after: "class Post < ActiveRecord::Base"




generate 'mtw'
rake "db:migrate"
rake "db:test:prepare"

