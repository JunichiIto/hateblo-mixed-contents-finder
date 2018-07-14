require 'mechanize'
require './lib/element_validator'
require './lib/invalid_content'

class MixedContentsFinder
  SLEEP_SEC = 1

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
      validator = ElementValidator.new(tag, attr)
      validator.validate(page)
    }.compact

    [*invalid_contents, *validate_link(page)].tap do
      sleep SLEEP_SEC
    end
  end

  # rel属性にstylesheetが指定されている<link>要素のhref属性
  def validate_link(page)
    nodes = page.search(".entry-content link")
    nodes.map { |node|
      if node['rel'] == 'stylesheet'
        InvalidContent.new(page.uri, 'link', 'href', node['href'])
      end
    }.compact
  end
end
