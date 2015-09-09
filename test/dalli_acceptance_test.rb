require 'test_helper'
require 'mocha/setup'
require 'action_view'
require 'action_view/testing/resolvers'
require 'active_support/cache/dalli_store'
require 'dalli'
require 'jbuilder'
require 'jbuilder/jbuilder_template'
require 'shared_helpers'
require 'jbuilder_cache_multi'

class DalliAcceptanceTest < ActionView::TestCase

  include SharedHelpers

  setup do
    Rails.stubs(:cache).returns(ActiveSupport::Cache::DalliStore.new)
    setup_test_objects
    @context = self
    Rails.cache.clear
  end

  test 'rails cache obj setup correctly' do
    assert_equal Rails.cache.class, ActiveSupport::Cache::DalliStore
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
end
