require 'tempfile'

RSpec.describe HatebloMixedContentsFinder::Tasks do
  # HACK: avoid false positive detection for git secrets
  let(:entry_id) { '1025784613' + '2601882016' }

  describe '#validate_all' do
    let(:site_url) { 'http://my-example.hatenablog.com' }
    let(:entire_page) { false }
    let(:limit) { nil }
    let(:path) { Tempfile.open.path }

    before do
      finder = double(HatebloMixedContentsFinder::MixedContentsFinder)
      allow(finder).to receive(:validate_all).with('http://my-example.hatenablog.com', limit: nil).and_return(invalid_contents)
      allow(HatebloMixedContentsFinder::MixedContentsFinder).to receive(:new).with(entire_page: false).and_return(finder)
    end

    context 'エラーがない場合' do
      let(:invalid_contents) { [] }
      example 'OKメッセージを表示する' do
        message = "OK💚\n"
        expect {
          HatebloMixedContentsFinder::Tasks.validate_all(site_url, entire_page, limit, path)
        }.to output(message).to_stdout
        expect(File.read(path)).to eq ''
      end
    end

    context 'エラーがある場合' do
      let(:invalid_contents) do
        content = HatebloMixedContentsFinder::InvalidContent.new(
                                  'http://my-example.hatenablog.com/2018/07/17/075334',
                                  entry_id,
                                  'Lorem Ipsum',
                                  'img',
                                  'src',
                                  'http://example.com/sample.jpg'
        )
        [content]
      end
      example 'ファイルにエラー内容を出力する' do
        message = "1 errors found. Please open result.txt.\n"
        expect {
          HatebloMixedContentsFinder::Tasks.validate_all(site_url, entire_page, limit, path)
        }.to output(message).to_stdout
        expect(File.read(path)).to eq \
          "http://my-example.hatenablog.com/2018/07/17/075334\t10257846132601882016\tLorem Ipsum\timg\tsrc\thttp://example.com/sample.jpg"
      end
    end
  end

  describe '#validate_page' do
    let(:entry_url) { 'http://my-example.hatenablog.com/2018/07/17/075334' }
    let(:entire_page) { false }

    before do
      finder = double(HatebloMixedContentsFinder::MixedContentsFinder)
      allow(finder).to receive(:validate_page).with('http://my-example.hatenablog.com/2018/07/17/075334').and_return(invalid_contents)
      allow(HatebloMixedContentsFinder::MixedContentsFinder).to receive(:new).with(entire_page: false).and_return(finder)
    end

    context 'エラーがない場合' do
      let(:invalid_contents) { [] }
      example 'OKメッセージを表示する' do
        message = "OK💚\n"
        expect {
          HatebloMixedContentsFinder::Tasks.validate_page(entry_url, entire_page)
        }.to output(message).to_stdout
      end
    end

    context 'エラーがある場合' do
      let(:invalid_contents) do
        content = HatebloMixedContentsFinder::InvalidContent.new(
          'http://my-example.hatenablog.com/2018/07/17/075334',
          entry_id,
          'Lorem Ipsum',
          'img',
          'src',
          'http://example.com/sample.jpg'
        )
        [content]
      end
      example 'エラー内容を出力する' do
        message = "http://my-example.hatenablog.com/2018/07/17/075334\t10257846132601882016\tLorem Ipsum\timg\tsrc\thttp://example.com/sample.jpg\n"
        expect {
          HatebloMixedContentsFinder::Tasks.validate_page(entry_url, entire_page)
        }.to output(message).to_stdout
      end
    end
  end

  describe '#update_all' do
    let(:path) do
      Tempfile.open.path.tap do |_path|
        File.open(_path, 'w') do |f|
          f.puts 'http://my-example.hatenablog.com/2018/07/17/075334'
        end
      end
    end
    before do
      client = double(HatebloMixedContentsFinder::HatenaClient)
      allow(client).to receive(:update_entry).with('http://my-example.hatenablog.com/2018/07/17/075334')
      allow(HatebloMixedContentsFinder::HatenaClient).to receive(:new).and_return(client)
    end
    context 'yesを入力した場合' do
      example '更新を実行する' do
        allow(STDIN).to receive(:gets).and_return("yes\n")
        message = <<~TEXT
          [WARNING] Please backup your entries before update!!
          Do you update 1 entries? [yes|no]: Completed.
        TEXT
        expect {
          HatebloMixedContentsFinder::Tasks.update_all(path, sleep_sec: 0)
        }.to output(message).to_stdout
      end
    end
    context 'noを入力した場合' do
      example '処理を中止する' do
        allow(STDIN).to receive(:gets).and_return("no\n")
        message = <<~TEXT.chomp + ' '
          [WARNING] Please backup your entries before update!!
          Do you update 1 entries? [yes|no]:
        TEXT
        expect {
          HatebloMixedContentsFinder::Tasks.update_all(path)
        }.to output(message).to_stdout
      end
    end
  end
end