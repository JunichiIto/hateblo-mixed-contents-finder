require 'mechanize'
require 'hatenablog'

module HatebloMixedContentsFinder
  class HatenaClient
    def update_entry(entry_url, config_file: nil)
      entry_id = fetch_id(entry_url)
      params = config_file ? [config_file] : []
      Hatenablog::Client.create(*params) do |blog_client|
        posted_entry = blog_client.get_entry(entry_id)
        puts "[#{Time.now.strftime("%H:%M:%S")}] Updating #{entry_url} #{posted_entry.title}"

        updated_entry = blog_client.update_entry(
          posted_entry.id,
          posted_entry.title,
          posted_entry.content,
          posted_entry.categories,
          posted_entry.draft,
          posted_entry.updated.strftime('%Y-%m-%dT%T%:z')
        )

        assert_same(posted_entry, updated_entry)
      end
    end

    private

    def assert_same(posted_entry, updated_entry)
      %w(title content categories updated draft).each do |attr|
        original = posted_entry.send(attr)
        updated = updated_entry.send(attr)
        if original != updated
          raise "#{attr} is changed: #{original} => #{updated} / #{posted_entry.id} / #{posted_entry.title}"
        end
      end
    end

    def fetch_id(url)
      agent = Mechanize.new
      page = agent.get(url)
      page.search('article.entry')[0]['data-uuid']
    end
  end
end
