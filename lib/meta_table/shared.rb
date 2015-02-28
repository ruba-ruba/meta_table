module Shared
  module ClassMethods
    def deep_send_with_object(object, route)
      route.to_s.split('.').inject(object){|memo,obj| memo ? memo.send(obj) : nil }
    end
  end

  module InstanceMethods
    def deep_send(route)
      route.to_s.split('.').inject(self) { |memo, obj| memo ? memo.send(obj) : nil }
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end