
run "rm -r test"
run "rm Gemfile"

generate :scaffold, "post title:string content:text user_id:integer category_id:integer published:boolean"

inject_into_file 'app/controllers/posts_controller.rb', "
  meta_table(:post, [ {key: :id, label: 'Number'},
                      {key: :title, searchable: true}],
                      {:scope => 'published', per_page_choises: [5, 10, 15], includes: [:hubs, :user]}
                      )", 
after: 'class PostsController < ApplicationController'



rake "db:migrate db:test:prepare"

