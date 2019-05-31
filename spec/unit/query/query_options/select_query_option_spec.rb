# frozen_string_literal: true

require_relative '../../unit_helper'
require_relative '../../../../app/query/query_options/select_query_option'

module Hacienda
  module Test
    describe SelectQueryOption do
      it 'should select only the specified properties' do
        result = SelectQueryOption.new('id').apply([{ id: 'an_id', stuff: 'do not care' }, { id: 'another_id', stuff: 'do not care' }])

        expect(result.size).to eq 2
        expect(result.first).to eq({:id =>'an_id'})
      end
      it 'should select only the specified properties which is not an id field' do
        result = SelectQueryOption.new('stuff').apply([{ id: 'an_id', stuff: 'do not care', other_stuff: 'random data' }, { id: 'another_id', stuff: 'do not care' }])
        expect(result.size).to eq 2
        expect(result.first).to eq({:id =>'an_id', stuff: 'do not care'})
      end
      it 'should select multiple  specified properties ' do
        result = SelectQueryOption.new('id,name').apply([{ id: 'an_id', stuff: 'do not care', name: 'test_name1' }, { id: 'another_id', stuff: 'do not care', name: 'test_name2' }])

        expect(result.size).to eq 2
        expect(result).to eq([{ id: 'an_id', name: 'test_name1' }, { id: 'another_id', name: 'test_name2' }])
      end

      it 'should select nested properties ' do
        result = SelectQueryOption.new('id,data/title').apply([{id: 'an_id', data: {title: 'sample title'}}, {id: 'another_id', data: {title: 'another sample title'}}])

        expect(result.size).to eq 2
        expect(result).to eq([{ id: 'an_id', title: 'sample title' }, { id: 'another_id', title: 'another sample title' }])
      end

      it 'should select nil in case of nested property not available' do
        result = SelectQueryOption.new('id,data/title').apply([{id: 'an_id', data: {}}, {id: 'another_id', data: {}}])

        expect(result.size).to eq 2
        expect(result).to eq([{ id: 'an_id', title: nil }, { id: 'another_id', title: nil }])
      end

      it 'should select nil in case of nested parent property not available' do
        result = SelectQueryOption.new('id,data/title').apply([{id: 'an_id', data1: {}}])

        expect(result.size).to eq 1
        expect(result).to eq([{ id: 'an_id', title: nil }])
      end

      it 'should not fail when select has unknwon fields ' do
        result = SelectQueryOption.new('id,unknown').apply([{ id: 'an_id', stuff: 'do not care', name: 'test_name1' }, { id: 'another_id', stuff: 'do not care', name: 'test_name2' }])

        expect(result.size).to eq 2
        expect(result).to eq([{id: "an_id", unknown: nil}, {id: "another_id", unknown: nil}])
      end
    end
  end
end
