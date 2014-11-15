MetaTable
=========

philosophy: Creating simple and powerful generating table mechanism which allow create and manipulate a lot of tables in a seconds.


Example Usage
-------------

```ruby
# post.rb

      POST_TABLE_OPTS  = 
        { attributes: [{key: :id, label: 'Number', sortable: true},
                      {key: :logo, label: 'Preview', render_text: "<%= image_tag(value.logo, style:'height: 100px;width:100px;') %>"}, 
                      {key: :title, sortable: true, searchable: true}, 
                      {key: :published, label: 'Shown?'}, 
                      {key: :content, render_text: "<%= record.content %>", searchable: true}, 
                      {key: :content_type, render_text: "record.content_type"}, 
                      :views_count, 
                      :tag_list, 
                      {key: :user, method: :email, label: "Created By Email"}],
          actions: [:show, [:edit, :admin], [:destroy, :admin], "<%= link_to record.title, your_path(record) %>"],
          table_options: {:scope => 'desc.articles', per_page: 4}
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

actions detailed:

```ruby
actions: [:show, [:destroy, :admin], "<%= link_to record.title, your_path(record) %>"]

# :show               generates record show path
# [:edit, :namespace] generates record edit path with namespace
# "<%= your code here  %>" anything which works inside your app
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
# searchable:   makes column searchable in basic sql like search
# render_text:  execute your code with each record. value is keyword that means record in database    -> no rescue here yet
```



## License

This project rocks and uses MIT-LICENSE.
----------------------------------------