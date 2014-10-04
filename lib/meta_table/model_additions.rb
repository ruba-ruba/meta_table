module MetaTable
  module ModelAdditions
    def meta_table(options={})
      MetaTable.render_table(self, options)
    end
  end
end

