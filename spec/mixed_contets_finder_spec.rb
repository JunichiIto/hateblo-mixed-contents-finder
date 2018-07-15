describe MixedContentsFinder do
  example 'each entry' do
    finder = MixedContentsFinder.new
    invalid_contents = finder.validate_page('http://blog.jnito.com/entry/2015/10/29/053000')
    unless invalid_contents.empty?
      puts invalid_contents
    end
    expect(invalid_contents).to be_empty
  end

  example 'layout' do
    finder = MixedContentsFinder.new(layout: true)
    invalid_contents = finder.validate_page('http://blog.jnito.com/entry/2015/10/29/053000')
    unless invalid_contents.empty?
      puts invalid_contents
    end
    expect(invalid_contents).to be_empty
  end
end