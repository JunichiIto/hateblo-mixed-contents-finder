require 'open-uri'
require 'nokogiri'
require 'mechanize'
require './lib/element_validator'
require './lib/invalid_content'

class MixedContentsFinder
  SLEEP_SEC = 1

  def run(limit = 3)
    invalid_contents = []
    # archive_url = 'http://blog.jnito.com/archive'
    archive_url = 'http://blog.jnito.com/archive?page=6'
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
    puts "Validate #{url}..."

    agent = Mechanize.new
    page = agent.get(url)
    invalid_contents = VALIDATE_CONDITIONS.flat_map { |tag, attr|
      validator = ElementValidator.new(tag, attr)
      validator.validate(page)
    }.compact

    # validate_image(page)
    # validate_source(page)
    # validate_script(page)
    # validate_video(page)
    # validate_audio(page)
    # validate_iframe(page)
    # validate_embed(page)

    [*invalid_contents, *validate_link(page)].tap do
      sleep SLEEP_SEC
    end
    # validate_form(page)
    # validate_object(page)

  end

  # <img>要素のsrc属性およびsrcset属性
  def validate_image(page)
    nodes = page.search(".entry-content img")
    nodes.each do |node|
      src = node['src']
      if src.match?(/^http:/)
        puts src
      end
      if srcset = node['srcset']
        puts 'srcset'
        puts srcset
      end
    end
  end

  # <source>要素のsrc属性およびsrcset属性
  def validate_source(page)
    nodes = page.search(".entry-content source")
    nodes.each do |node|
      puts 'source'
      puts node['src']
      if srcset = node['srcset']
        puts srcset
      end
    end
  end

  # <script>要素のsrc属性
  def validate_script(page)
    nodes = page.search(".entry-content script")
    nodes.each do |node|
      src = node['src']
      if src && src.match?(/^http:/)
        puts 'script'
        puts src
      end
    end
  end

  # <video>要素のsrc属性
  def validate_video(page)
    nodes = page.search(".entry-content video")
    nodes.each do |node|
      puts 'video'
      puts node['src']
    end
  end

  # <audio>要素のsrc属性
  def validate_audio(page)
    nodes = page.search(".entry-content audio")
    nodes.each do |node|
      puts 'audio'
      puts node['src']
    end
  end

  # <iframe>要素のsrc属性
  def validate_iframe(page)
    nodes = page.search(".entry-content iframe")
    nodes.each do |node|
      src = node['src']
      if src.match?(/^http:/)
        puts 'iframe'
        puts src
      end
    end
  end

  # <embed>要素のsrc属性
  def validate_embed(page)
    nodes = page.search(".entry-content embed")
    nodes.each do |node|
      puts 'embed'
      puts node['src']
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

  # <form>要素のaction属性
  def validate_form(page)
    nodes = page.search(".entry-content form")
    nodes.each do |node|
      puts 'form'
      puts node['action']
    end
  end

  # <object>要素のdata属性
  def validate_object(page)
    nodes = page.search(".entry-content object")
    nodes.each do |node|
      puts 'object'
      puts node['data']
    end
  end
end
