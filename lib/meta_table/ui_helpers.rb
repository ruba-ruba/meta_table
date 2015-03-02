module UiHelpers
  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods
    def clearfix
      content_tag(:div, "", class: 'clearfix')
    end
  end
end