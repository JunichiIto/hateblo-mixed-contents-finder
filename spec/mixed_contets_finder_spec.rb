describe MixedContentsFinder do
  describe 'ページング' do
    context 'limitなし' do
      example '最後まで処理すること' do
        finder = MixedContentsFinder.new
        expect(finder).to receive(:validate_page).and_return([]).exactly(31).times
        VCR.use_cassette('mixed_contents_finder/no_limit') do
          finder.run(nil)
        end
      end
    end

    context 'limitあり' do
      context 'デフォルト値' do
        example '3件まで' do
          finder = MixedContentsFinder.new
          expect(finder).to receive(:validate_page).and_return([]).exactly(3).times
          VCR.use_cassette('mixed_contents_finder/default_limit') do
            finder.run
          end
        end
      end
      context '回数を指定' do
        example 'limitに応じて中断されること' do
          finder = MixedContentsFinder.new
          expect(finder).to receive(:validate_page).and_return([]).exactly(5).times
          VCR.use_cassette('mixed_contents_finder/specified_limit') do
            finder.run(5)
          end
        end
      end
    end
  end

  describe 'validate_page' do
    context '本文のみ' do
      example '適切に検出すること' do
        finder = MixedContentsFinder.new
        VCR.use_cassette('mixed_contents_finder/validate_page') do
          invalid_contents = finder.validate_page('https://junichiito-test.hatenablog.com/entry/2018/07/15/084229')
          expect(invalid_contents.size).to eq 11
        end
      end
    end
    context 'ページ全体' do
      example '適切に検出すること' do
        finder = MixedContentsFinder.new(layout: true)
        VCR.use_cassette('mixed_contents_finder/validate_page') do
          invalid_contents = finder.validate_page('https://junichiito-test.hatenablog.com/entry/2018/07/15/084229')
          expect(invalid_contents.size).to eq 12
        end
      end
    end
  end
end