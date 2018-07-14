describe MixedContentsFinder do
  example do
    finder = MixedContentsFinder.new
    VCR.use_cassette("finder_sample") do
      finder.run
    end
    expect(true).to be true
  end
end