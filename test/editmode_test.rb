require 'bundler/setup'
require 'active_record'
require 'minitest/autorun'
require 'editmode'
require 'rails/all'
require 'pry-rails'

test_framework = defined?(MiniTest::Test) ? MiniTest::Test : MiniTest::Unit::TestCase

module Rails
  def self.cache
    require 'active_support'
    require 'active_support/cache'
    require 'active_support/cache/file_store'
    ::ActiveSupport::Cache::FileStore.new '/Users/jenvillaganas/work/edit_mode/editmode-rails/test/cache'
  end
end

# Monkey Patch params for View Helper Methods
module Editmode
  module ActionViewExtensions
    module EditmodeHelper
      def params
        {}
      end
    end
  end
end


def setup!
  Editmode.project_id = 'prj_5o66RFmQtg65'
end

setup!

class TestEditmodeCache < Minitest::Test
  def setup
    @chunk_id = 'cnk_9e3ec5e79344023912f5'
  end

  def test_that_chunk_is_not_cached
    Rails.cache.clear
    cache_id = "chunk_#{Editmode.project_id}#{@chunk_id}"
    assert_equal false, Rails.cache.exist?(cache_id)
  end

  def test_that_chunk_will_be_cached
    # This will send a request to api and cache the response
    chunk = Editmode.e @chunk_id
    cache_id = "chunk_#{Editmode.project_id}#{@chunk_id}"
    assert_equal true, Rails.cache.exist?(cache_id)
  end
end

class TestEditmodeHelper < Minitest::Test
  def setup
    @chunk_id = 'cnk_9e3ec5e79344023912f5'
    @cache_id = "chunk_#{Editmode.project_id}#{@chunk_id}"
  end

  def test_lower_case_e
    non_editable_chunk = Editmode.e @chunk_id

    assert_equal true, non_editable_chunk.is_a?(String)
    assert_equal false, non_editable_chunk.include?('em-span')
  end

  def test_lower_case_e_with_collection_field
    non_editable_chunk = Editmode.e 'cnk_ac445023d4be6fb6671a', 'Title'

    assert_equal true, non_editable_chunk.is_a?(String)
    assert_equal false, non_editable_chunk.include?('em-span')
  end

  def test_upper_case_e
    editable_chunk = Editmode.E @chunk_id
    
    assert_equal true, editable_chunk.is_a?(String)
    assert_equal true, editable_chunk.include?('em-span')
    assert_equal true, editable_chunk.include?('data-chunk-editable')
  end

  def test_upper_case_e_with_class_names
    classnames = 'sample class here'
    editable_chunk = Editmode.E @chunk_id, class: classnames
    
    assert_equal true, editable_chunk.include?(classnames)
  end

  def test_upper_case_e_with_unassigned_variable
    editable_chunk = Editmode.E @chunk_id, variables: {}
    
    # Content should not include {{}} token wrapper since they should be converted to empty string ""
    assert_equal false, editable_chunk.include?('{{')
    assert_equal false, editable_chunk.include?('}}')
  end

  def test_upper_case_e_with_assigned_variable
    variable_value = 'Test variable value'
    editable_chunk = Editmode.E @chunk_id, variables: {sample_variable: variable_value}

    assert_equal true, editable_chunk.include?(variable_value)
  end

  def test_upper_case_e_with_collection_field
    editable_chunk = Editmode.E 'cnk_ac445023d4be6fb6671a', 'Title'
    
    assert_equal true, editable_chunk.is_a?(String)
    assert_equal true, editable_chunk.include?('em-span')
    assert_equal true, editable_chunk.include?('data-chunk-editable')
    assert_equal true, editable_chunk.include?('data-chunk-collection-identifier')
  end

  def test_skip_cache
    # Asign a value to Rails cache to make sure that it has existing value
    # The assign value should not match the response we're expecting  
    cache_dummy_content = "Dummy Content"
    cache_dummy_value = {
      identifier: "cnk_9e3ec5e79344023912f5",
      chunk_type: "single_line_text",
      project_id: "prj_5o66RFmQtg65",
      branch_id: "",
      master_branch: true,
      content_key: nil,
      variable_fallbacks: {},
      content: cache_dummy_content
    }.to_json
    Rails.cache.write(@cache_id, cache_dummy_value)

    # without skipping cache
    assert_equal true, Editmode.e(@chunk_id) == cache_dummy_content

    # with skip cache
    assert_equal false, Editmode.e(@chunk_id, skip_cache: true) == cache_dummy_content
    
    # Clean dummy cache
    Rails.cache.clear
  end

  def test_editable_img_chunk
    editable_chunk = Editmode.E('cnk_5278198a030418be2659')

    assert_equal true, editable_chunk.include?('img')
    assert_equal true, editable_chunk.include?('data-chunk-type="image"')
    assert_equal true, editable_chunk.include?('data-chunk-editable')
  end

  def test_non_editable_img_chunk
    editable_chunk = Editmode.e('cnk_5278198a030418be2659')

    assert_equal false, editable_chunk.include?('img')
    assert_equal false, editable_chunk.include?('data-chunk-type="image"')
    assert_equal false, editable_chunk.include?('data-chunk-editable')
  end

  def test_collection
    collection_id = 'col_mXYgqmmXlyC4'

    collection_with_non_editable_fields = Editmode.c(collection_id) do 
      Editmode.f('Title')
    end
    
    assert_equal false, collection_with_non_editable_fields.include?('em-span')
    assert_equal true, collection_with_non_editable_fields.include?("data-chunk-collection-identifier=\"#{collection_id}\"")

    collection_with_editable_fields = Editmode.c(collection_id) do 
      Editmode.F('Title')
    end

    assert_equal true, collection_with_editable_fields.include?('em-span')
    assert_equal true, collection_with_editable_fields.include?("data-chunk-collection-identifier=\"#{collection_id}\"")
  end
end