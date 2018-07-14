describe MixedContentsFinder do
  example do
    finder = MixedContentsFinder.new
    invalid_contents = finder.validate_page('http://blog.jnito.com/entry/20110617/1308261583')
    puts invalid_contents
  end
end