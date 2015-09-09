module SharedHelpers
  BlogPost = Struct.new(:id, :body, :author_name)

  def setup_test_objects
    @blog_post_partial = <<-JBUILDER
      json.extract! blog_post, :id, :body
      json.author do
        name = blog_post.author_name.split(nil, 2)
        json.first_name name[0]
        json.last_name  name[1]
      end
    JBUILDER

    @cache_key_proc = Proc.new { |blog_post| blog_post.id }

    @blog_authors = [ 'David Heinemeier Hansson', 'Pavel Pravosud' ].cycle

    @blog_post_collection = 10.times.map{ |i| BlogPost.new(i+1, "post body #{i+1}", @blog_authors.next) }
  end 

  def partials
    {
      '_partial.json.jbuilder'  => 'json.content "hello"',
      '_blog_post.json.jbuilder' => @blog_post_partial
    }
  end

  def render_jbuilder(source)
    @rendered = []
    lookup_context.view_paths = [ActionView::FixtureResolver.new(partials.merge('test.json.jbuilder' => source))]
    ActionView::Template.new(source, 'test', JbuilderHandler, :virtual_path => 'test').render(self, {}).strip
  end

  def undef_context_methods(*names)
    self.class_eval do
      names.each do |name|
        undef_method name.to_sym if self.method_defined?(name.to_sym)
      end
    end
  end
  
  def assert_collection_rendered(json, context = nil)
    result = MultiJson.load(json)
    result = result.fetch(context) if context
    
    assert_equal 10, result.length
    assert_equal Array, result.class
    assert_equal 'post body 5',        result[4]['body']
    assert_equal 'Heinemeier Hansson', result[2]['author']['last_name']
    assert_equal 'Pavel',              result[5]['author']['first_name']
  end
end
