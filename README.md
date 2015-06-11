MetaTable
=========


philosophy: Creating simple and powerful generating table mechanism which allow create and manipulate a lot of tables in a seconds.


## setup
-----

#### Gemfile
```ruby 
  gem 'meta_table', :require => true
```

#### application.js
```//= require meta_table```
#### application.css
```*= require meta_table```

#### generate
```ruby 
  rails g mtw
  rake db:migrate
```  

Example Usage
-------------

```ruby

# posts_controller

  class PostsController < ApplicationController

    meta_table :post,
         [
          {key: :id, label: 'Number'},
          {key: :logo, label: 'Preview', render_text: "<%= image_tag(record.logo, style:'height: 100px;width:100px;') %>"},
          {key: :title, searchable: true},
          {key: :published, label: 'Shown?'},
          {key: :content, render_text: "<%= record.content %>", searchable: true},
          {key: :content_type, render_text: "record.content_type"},
          :views_count,
          :tag_list,
          {key: :user, method: :email, label: "Created By Email"},
          {key: :actions, label: 'Actions From Attrs', render_text: [:show, [:edit, :admin],[:destroy, :admin], "<%= link_to 'Edit', edit_admin_post_path(record), class: 'button small' %>"]}
         ],
         {:scope => 'desc.articles', per_page_choises: [4, 12, 24], includes: [:categories]}

    def index
      @table = render_posts_table
    end

```

and then in 'posts/index.html.erb'

```ruby
<%= @table %>
```

## Basic Explanation

```ruby

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
... [:email, :name, :your_method/column_name]

```

use hash syntax to specify more details


```ruby
... :table_name, [{key: :id, label: 'Number', render_text: 'value.html_safe'}, {...}]


# key:          is attrubute/method name
# label:        change column name to record you added      ->  i18n will be soon
# searchable:   makes column searchable in basic sql like search
# render_text:  execute your code with each record. record is keyword that means record in database    -> no rescue here yet
# render_text:  when key is :actions   you can pass array here and put list of actions, anyway you still can put all actions in erb string
```


### Current = "0.0.3"

### Next = "0.0.4"
  - Add I18n support for labels

### License

#### This project rocks and uses MIT-LICENSE.
