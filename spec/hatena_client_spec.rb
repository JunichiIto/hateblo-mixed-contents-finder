require 'time'
describe HatenaClient do
  # HACK: avoid false positive detection for git secrets
  let(:entry_id) { '1025784613' + '2601882016' }

  def entry_double(
      title: 'Lorem Ipsum',
      content: 'Hello, world',
      categories: ['foo', 'bar'],
      draft: 'no',
      updated: Time.parse('2018-07-17T12:34:56+09:00'))
    entry = double('entry')
    allow(entry).to receive(:id).and_return(entry_id)
    allow(entry).to receive(:title).and_return(title)
    allow(entry).to receive(:content).and_return(content)
    allow(entry).to receive(:categories).and_return(categories)
    allow(entry).to receive(:draft).and_return(draft)
    allow(entry).to receive(:updated).and_return(updated)
    entry
  end

  let(:update_params) do
    [entry_id, 'Lorem Ipsum', 'Hello, world', ['foo', 'bar'], 'no', '2018-07-17T12:34:56+09:00']
  end

  let(:updated_entry_attributes) do
    {}
  end

  let(:target_url) { 'https://junichiito-test.hatenablog.com/entry/2018/07/17/065606' }

  before do
    posted_entry = entry_double
    allow_any_instance_of(Hatenablog::Client).to receive(:get_entry).with(entry_id).and_return(posted_entry)

    updated_entry = entry_double(updated_entry_attributes)
    allow_any_instance_of(Hatenablog::Client).to receive(:update_entry).with(*update_params).and_return(updated_entry)
  end

  example '正常に更新できる' do
    VCR.use_cassette('hatena_client/blog_response') do
      HatenaClient.new.update_entry(target_url)
    end
  end

  context 'titleが変わった場合' do
    let(:updated_entry_attributes) do
      { title: 'LOREM IPSUM' }
    end
    example '例外が発生する' do
      VCR.use_cassette('hatena_client/blog_response') do
        expect {
          HatenaClient.new.update_entry(target_url)
        }.to raise_error(RuntimeError, /title is changed: Lorem Ipsum => LOREM IPSUM/)
      end
    end
  end

  context 'contentが変わった場合' do
    let(:updated_entry_attributes) do
      { content: 'HELLO, WORLD' }
    end
    example '例外が発生する' do
      VCR.use_cassette('hatena_client/blog_response') do
        expect {
          HatenaClient.new.update_entry(target_url)
        }.to raise_error(RuntimeError, /content is changed: Hello, world => HELLO, WORLD/)
      end
    end
  end

  context 'categoriesが変わった場合' do
    let(:updated_entry_attributes) do
      { categories: ['foo'] }
    end
    example '例外が発生する' do
      VCR.use_cassette('hatena_client/blog_response') do
        expect {
          HatenaClient.new.update_entry(target_url)
        }.to raise_error(RuntimeError, /categories is changed: \["foo", "bar"\] => \["foo"\]/)
      end
    end
  end

  context 'draftが変わった場合' do
    let(:updated_entry_attributes) do
      { draft: 'yes' }
    end
    example '例外が発生する' do
      VCR.use_cassette('hatena_client/blog_response') do
        expect {
          HatenaClient.new.update_entry(target_url)
        }.to raise_error(RuntimeError, /draft is changed: no => yes/)
      end
    end
  end

  context 'updatedが変わった場合' do
    let(:updated_entry_attributes) do
      { updated: Time.parse('2018-07-17T12:34:57+09:00') }
    end
    example '例外が発生する' do
      VCR.use_cassette('hatena_client/blog_response') do
        expect {
          HatenaClient.new.update_entry(target_url)
        }.to raise_error(RuntimeError, /updated is changed: 2018-07-17 12:34:56 \+0900 => 2018-07-17 12:34:57 \+0900/)
      end
    end
  end
end