module MetaTable
  module ControllerAdditions
    def render_meta_table(klass, options)
      MetaTable.render_table(self, klass, options)
    end
  end
end