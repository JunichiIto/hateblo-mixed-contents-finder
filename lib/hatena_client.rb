require 'mechanize'
require 'hatenablog'

class HatenaClient
  def update_entry(entry_url)
    entry_id = fetch_id(entry_url)
    Hatenablog::Client.create do |blog|
      posted_entry = blog.get_entry(entry_id)
      puts "Updating #{entry_url} #{posted_entry.title}"

      updated_entry = blog.update_entry(
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
