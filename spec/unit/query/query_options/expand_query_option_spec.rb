# frozen_string_literal: true

require_relative '../../unit_helper'
require_relative '../../../../app/query/query_options/expand_query_option'

module Hacienda
  module Test
    describe ExpandQueryOption do
      it 'should expand the specified properties with no selector' do
        result = ExpandQueryOption.new('id(),modules()').apply([{id: 'an_id', modules: [{title: 'title'}, {title: 'title'}]}])

        expect(result.size).to eq 1
        expect(result.first).to eq({:id => 'an_id', :modules => [{:title => "title"}, {:title => "title"}]})
      end

      it 'should should raise exception if no selectors specified' do
        query_option = ExpandQueryOption.new('id')
        expect { query_option.apply([{id: 'an_id'}]) }.to raise_exception RuntimeError, 'No selectors available for field id. Use empty parenthesis if no selectors intended.'
      end

      it 'should expand the specified properties with filter and select' do
        result = ExpandQueryOption.new("id(),modules($filter=type eq 'type 1'&$select=data/title)").apply([{id: 'an_id', modules: [{type: 'type 1', data: {title: 'title 1'}}, {type: 'type 2', data: {title: 'title 2'}}]}])

        expect(result.size).to eq 1
        expect(result.first).to eq({:id => 'an_id', :modules => [{:title => "title 1", :id => nil}]})
      end

      it 'should return all expanded values if junk selector provided' do
        result = ExpandQueryOption.new("id(),modules(some junk value...)").apply([{id: 'an_id', modules: [{type: 'type 1', data: {title: 'title 1'}}, {type: 'type 2', data: {title: 'title 2'}}]}])

        expect(result.size).to eq 1
        expect(result.first).to eq({:id => 'an_id', :modules => [{:type=>"type 1", :data=>{:title=>"title 1"}}, {:type=>"type 2", :data=>{:title=>"title 2"}}]})
      end

    end
  end
end
