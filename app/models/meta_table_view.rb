class MetaTableView < ActiveRecord::Base
  serialize :table_columns, Array

  scope :positioned, -> {order('position')}
end