class MetaTableView < ActiveRecord::Base

  validate :name, :source_class, :table_columns, presence: true

  serialize :table_columns, Array

  scope :positioned, -> { order(:position) }

  scope :for_user, ->(user=nil) {
    if user.present?
      positioned # TODO: all accessible scopes + all private user scopes 
    else
      positioned # TODO: all accessible scopes
    end
  }
end