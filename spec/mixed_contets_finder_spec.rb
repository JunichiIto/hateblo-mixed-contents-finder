describe MixedContentsFinder do
  # HACK: avoid false positive detection for git secrets
  let(:entry_id) { '10257846132' + '601262485' }

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
        invalid_contents = nil
        VCR.use_cassette('mixed_contents_finder/validate_page') do
          invalid_contents = finder.validate_page('https://junichiito-test.hatenablog.com/entry/2018/07/15/084229')
        end
        expect(invalid_contents.size).to eq 11
        expect(invalid_contents[0]).to have_attributes(
                                         page_url: 'https://junichiito-test.hatenablog.com/entry/2018/07/15/084229',
                                         entry_id: entry_id,
                                         entry_title: 'Lorem Ipsum',
                                         tag: 'img',
                                         attr: 'src',
                                         link_url: 'http://ecx.images-amazon.com/images/I/41QcxDH2E2L._SL160_.jpg'
                                       )
        expect(invalid_contents[1]).to have_attributes(
                                         tag: 'img',
                                         attr: 'srcset',
                                         link_url: 'https://images-fe.ssl-images-amazon.com/images/I/51nY-YLt2ZL._AC_AC_SR98,95_.jpg 2x, http://ecx.images-amazon.com/images/I/51nVqFvj7rL._SL160_.jpg 1x'
                                       )
        expect(invalid_contents[2]).to have_attributes(
                                         tag: 'source',
                                         attr: 'src',
                                         link_url: 'http://example.com/horse.mp3'
                                       )
        expect(invalid_contents[3]).to have_attributes(
                                         tag: 'source',
                                         attr: 'srcset',
                                         link_url: 'https://images-fe.ssl-images-amazon.com/images/I/51nY-YLt2ZL._AC_AC_SR98,95_.jpg 1x, http://ecx.images-amazon.com/images/I/51nVqFvj7rL._SL160_.jpg 2x'
                                       )
        expect(invalid_contents[4]).to have_attributes(
                                         tag: 'script',
                                         attr: 'src',
                                         link_url: 'http://example.com/javascript.js'
                                       )
        expect(invalid_contents[5]).to have_attributes(
                                         tag: 'video',
                                         attr: 'src',
                                         link_url: 'http://example.com/sample.mp4'
                                       )
        expect(invalid_contents[6]).to have_attributes(
                                         tag: 'audio',
                                         attr: 'src',
                                         link_url: 'http://soundbible.com/mp3/Tyrannosaurus%20Rex%20Roar-SoundBible.com-807702404.mp3'
                                       )
        expect(invalid_contents[7]).to have_attributes(
                                         tag: 'iframe',
                                         attr: 'src',
                                         link_url: 'http://blog.jnito.com/embed/2016/05/28/113943'
                                       )
        expect(invalid_contents[8]).to have_attributes(
                                         tag: 'embed',
                                         attr: 'src',
                                         link_url: 'http://example.com/helloworld.swf'
                                       )
        expect(invalid_contents[9]).to have_attributes(
                                         tag: 'form',
                                         attr: 'action',
                                         link_url: 'http://example.com/foo'
                                       )
        expect(invalid_contents[10]).to have_attributes(
                                         tag: 'object',
                                         attr: 'data',
                                         link_url: 'http://cdn-ak.f.st-hatena.com/images/fotolife/J/JunichiIto/20150915/20150915092854.gif'
                                       )
      end
    end
    context 'ページ全体' do
      example '適切に検出すること' do
        finder = MixedContentsFinder.new(layout: true)
        invalid_contents = nil
        VCR.use_cassette('mixed_contents_finder/validate_page') do
          invalid_contents = finder.validate_page('https://junichiito-test.hatenablog.com/entry/2018/07/15/084229')
        end
        expect(invalid_contents.size).to eq 12
        expect(invalid_contents[0]).to have_attributes(
                                         page_url: 'https://junichiito-test.hatenablog.com/entry/2018/07/15/084229',
                                         entry_id: entry_id,
                                         entry_title: 'Lorem Ipsum',
                                         tag: 'img',
                                         attr: 'src',
                                         link_url: 'http://ecx.images-amazon.com/images/I/41QcxDH2E2L._SL160_.jpg'
                                       )
        expect(invalid_contents[11]).to have_attributes(
                                          tag: 'link',
                                          attr: 'href',
                                          link_url: 'http://example.com/style.css'
                                        )
      end
    end
  end
end