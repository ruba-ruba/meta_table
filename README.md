MetaTable
=========


Example Usage
-------------

```ruby
@table = render_meta_table(Post, attributes: 
                                [
                                 {key: :id, label: 'Number', sortable: true},
                                 {key: :title, sortable: true}, 
                                 {key: :published, label: 'Shown?'}, 
                                 :content, :views_count, :content_type, :tag_list, # title eql attribute name, not sortable 
                                 {key: :user, method: :email, label: "Created By Email"} # support of belogs_to, has_one relations
                                 ], 
                              relations: [{:hubs => [:title, :published]}, {:user => [:email]} ], # hmt, hm, habtm relation will be supported in future or not 
                              actions: [:show, [:edit, :admin], [:destroy, :admin]], # action with namespace
                              table_options: {:scope => 'last_month.active', per_page: 4})
```
and then in 'posts/index.html.erb'

```ruby
<%= @table %>
```

## License

This project rocks and uses MIT-LICENSE.
----------------------------------------