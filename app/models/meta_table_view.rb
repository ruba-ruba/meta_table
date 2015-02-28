class MetaTableView < ActiveRecord::Base

  attr_accessor :route_back

  validate :name, :source_class, :table_columns, presence: true
  validate :at_least_one_selected

  serialize :table_columns

  scope :positioned, -> { order(:position) }

  scope :for_user, ->(user=nil) {
    if user.present?
      positioned # TODO: all accessible scopes + all private user scopes
    else
      positioned # TODO: all accessible scopes
    end
  }

  def at_least_one_selected
    unless table_columns && enabled_attributes.any?
      self.errors.add(:table_columns, "At least one column needs to be selected")
    end
  end

  def enabled_attributes
    table_columns.select {|k,v| v == '1'}
  end

end
