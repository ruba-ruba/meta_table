MetaTable
=========


Example Usage
-------------

@table = Post.meta_table(
        attributes: [:title, {key: :published, label: 'Shown?'}, :content, :views_count, :content_type, :tag_list, :type, {key: :user, method: :email}], 
        relations: [{:hubs => [:title, :published]}, {:user => [:email]} ], 
        actions: [:show, [:edit, :admin]])

and then in 'posts/index'
<%= @table %>

note: Relation is not implemented yet


This project rocks and uses MIT-LICENSE.
========================================