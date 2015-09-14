require 'spec_helper'

describe MetaTable do

  context 'get attributes as keys for current table' do
    let!(:params) { {controller_name: 'PostsController', table_for: 'post'} }

    subject { MetaTable.keys_for_controller(params) }

    it 'raise error when nothing to show' do
      allow(PostsController).to receive('post_columns').and_return([])
      expect{ subject }.to raise_error MetaTable::NoAttributesError 
    end

    it 'return attributes for PostsController' do
      expect(subject).to eq [:id, :title]
    end
  end

  context '#normalized_attributes' do
    let(:attrs) { [:abc, {key: 'key12'}] }

    it 'call normalized_attribute exactly attrs count times' do 
      expect(MetaTable).to receive(:normalized_attribute).exactly(2).times
      MetaTable.normalized_attributes(attrs)
    end

    it 'normalized_attribute' do
      expect(MetaTable.normalized_attribute(attrs[0])).to eq( {key: :abc} )
      expect(MetaTable.normalized_attribute(attrs[1])).to eq( {key: 'key12'} )
    end
  end
end
