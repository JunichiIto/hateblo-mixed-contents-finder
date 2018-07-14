describe MixedContentsFinder do
  example do
    finder = MixedContentsFinder.new
    invalid_contents = finder.validate_page('http://blog.jnito.com/entry/2015/10/25/062535')
    puts invalid_contents
    expect(true).to be true
  end
end