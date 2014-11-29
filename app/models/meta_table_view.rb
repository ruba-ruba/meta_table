class MetaTableView < ActiveRecord::Base
  serialize :table_columns, Array

  scope :positioned, -> {order('position')}

  scope :for_user, ->(user=nil) {
    if user.present?
      positioned # TODO: all accessible scopes + all private user scopes 
    else
      positioned # TODO: all accessible scopes
    end
  }
end