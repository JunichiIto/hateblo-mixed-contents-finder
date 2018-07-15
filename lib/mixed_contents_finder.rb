require 'mechanize'
require './lib/element_validator'
require './lib/invalid_content'

class MixedContentsFinder
  SLEEP_SEC = 1

  def initialize(layout: false)
    @layout = true
  end

  def run(limit = 3)
    invalid_contents = []
    archive_url = 'http://blog.jnito.com/archive'
    agent = Mechanize.new
    page = agent.get(archive_url)

    counter = 0
    loop do
      if limit && counter > limit
        break
      end
      puts page.uri
      links = page.search('.entry-title-link')
      links.each do |link|
        counter += 1
        if limit && counter > limit
          break
        end
        url = link['href']
        invalid_contents += validate_page(url)
      end
      next_page_link = page.search('.pager-next a')&.first
      if next_page_link
        page = agent.get(next_page_link['href'])
      else
        puts 'End.'
        break
      end
    end
    invalid_contents
  end

  VALIDATE_CONDITIONS = [
    %w(img src),
    %w(img srcset),
    %w(source src),
    %w(source srcset),
    %w(script src),
    %w(video src),
    %w(audio src),
    %w(iframe src),
    %w(embed src),
    %w(form action),
    %w(object data),
  ]

  def validate_page(url)
    puts "[#{Time.now.strftime("%H:%M:%S")}] Validate #{url}..."

    agent = Mechanize.new
    page = agent.get(url)
    invalid_contents = VALIDATE_CONDITIONS.flat_map { |tag, attr|
      validator =
        if @layout
          ElementValidator.new(tag, attr, root: '')
        else
          ElementValidator.new(tag, attr)
        end
      validator.validate(page)
    }.compact

    [*invalid_contents, *validate_link(page)].tap do
      sleep SLEEP_SEC
    end
  end

  # rel属性にstylesheetが指定されている<link>要素のhref属性
  def validate_link(page)
    entry_title = find_entry_title(page)
    entry_id = find_entry_id(page)
    nodes =
      if @layout
        page.search("link")
      else
        page.search(".entry-content link")
      end
    nodes.map { |node|
      if node['rel'] == 'stylesheet'
        link_url = node['href']
        if link_url && link_url.match?(/^http:/)
          InvalidContent.new(page.uri, entry_id, entry_title, tag, attr, link_url)
        end
      end
    }.compact
  end

  def find_entry_title(page)
    page.search('.entry-title')[0].text.strip
  end

  def find_entry_id(page)
    page.search('article.entry')[0]['data-uuid']
  end
end
