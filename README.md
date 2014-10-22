MetaTable
=========

philosophy: Creating simple and powerful generating table mechanism which allow create and manipulate a lot of tables in a seconds.


Example Usage
-------------

```ruby
# post.rb

  POST_TABLE_OPTS  = { attributes: [{key: :id, label: 'Number', sortable: true}, {key: :title, sortable: true}, {key: :published, label: 'Shown?'}, {key: :content, render_text: 'value.html_safe'}, :views_count, :content_type, :tag_list, {key: :user, method: :email, label: "Created By Email"}], 
                            relations: [{:hubs => [:title, :published]}, {:user => [:email]} ], 
                            actions: [:show, [:edit, :admin], [:destroy, :admin]],
                            table_options: {:scope => nil, per_page: 4}
                      }

# posts_controller 
   def index
     @table = render_meta_table(Post::POST_TABLE_OPTS)
  end

```

and then in 'posts/index.html.erb'

```ruby
<%= @table %>
```

## Basic Explanation

```ruby
OPTIONS = { attributes: [attributes array]
            actions: [actions in table]
            table_options: {:scope => symbol or string as scope chain, per_page: per_page}
          }
```

pass only symbols to get raw data

```ruby
... attributes: [:email, :name, :your_method/column_name] 
```

use hash syntax to specify more details


```ruby
... attributes: [{key: :id, label: 'Number', sortable: true, render_text: 'value.html_safe'}

# key:          is attrubute/method name
# label:        change column name to value you added      ->  i18n will be soon
# sortable :    makes column sortable
# render_text:  execute your code with each record. value is keyword that means record in database     -> no rescue here yet
```





## License

This project rocks and uses MIT-LICENSE.
----------------------------------------