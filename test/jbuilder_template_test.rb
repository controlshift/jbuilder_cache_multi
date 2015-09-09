require 'test_helper'
require 'mocha/setup'
require 'action_view'
require 'action_view/testing/resolvers'
require 'active_support/cache'
require 'jbuilder'
require 'jbuilder/jbuilder_template'
require 'shared_helpers'
require 'jbuilder_cache_multi'

class JbuilderTemplateTest < ActionView::TestCase
  include SharedHelpers

  setup do
    setup_test_objects
    Rails.stubs(:cache).returns(ActiveSupport::Cache::MemoryStore.new)
    @context = self
    Rails.cache.clear
  end

  test 'rails cache obj setup correctly' do
    assert_equal Rails.cache.class, ActiveSupport::Cache::MemoryStore
  end

  test 'renders cached array of block partials' do
    undef_context_methods :fragment_name_with_digest, :cache_fragment_name
  
    json = render_jbuilder <<-JBUILDER
      json.cache_collection! @blog_post_collection do |blog_post|
        json.partial! 'blog_post', :blog_post => blog_post
      end
    JBUILDER
        
    assert_collection_rendered json
  end

  test 'renders cached array with a key specified as a proc' do
    undef_context_methods :fragment_name_with_digest, :cache_fragment_name
    @cache_key_proc.expects(:call).times(10)

    json = render_jbuilder <<-JBUILDER
      json.cache_collection! @blog_post_collection, key: @cache_key_proc do |blog_post|
        json.partial! 'blog_post', :blog_post => blog_post
      end
    JBUILDER

    assert_collection_rendered json
  end
  
  test 'reverts to cache! if cache does not support fetch_multi' do
    undef_context_methods :fragment_name_with_digest, :cache_fragment_name
    ActiveSupport::Cache::Store.send(:undef_method, :fetch_multi) if ActiveSupport::Cache::Store.method_defined?(:fetch_multi)
     
    json = render_jbuilder <<-JBUILDER
      json.cache_collection! @blog_post_collection do |blog_post|
        json.partial! 'blog_post', :blog_post => blog_post
      end
    JBUILDER
    
    assert_collection_rendered json
  end
  
  test 'reverts to array! when controller.perform_caching is false' do
    controller.perform_caching = false
    
    json = render_jbuilder <<-JBUILDER
      json.cache_collection! @blog_post_collection do |blog_post|
        json.partial! 'blog_post', :blog_post => blog_post
      end
    JBUILDER
    
    assert_collection_rendered json
  end

end
