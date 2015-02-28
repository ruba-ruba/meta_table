module Fetch

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods

    def get_data attributes
      collection.map do |record|
        attributes.map do |attr|
          if attr.is_a?(Symbol)
            record.send attr
          else
            fetch_rely_on_hash(record, attr)
          end
        end
      end
    end

    def fetch_rely_on_hash(record, attribute)
      attr = attribute[:key]
      if attribute[:render_text]
        implicit_render(record, attribute)
      else
        record.deep_send(attr)
      end
    end

  end

end