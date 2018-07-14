require 'open-uri'
require 'nokogiri'
require 'mechanize'

class MixedContentsFinder
  def run
    url = 'http://blog.jnito.com/entry/2018/07/12/075334'
    agent = Mechanize.new
    page = agent.get(url)
    validate_image(page)
    validate_source(page)
    validate_script(page)
    validate_video(page)
    validate_audio(page)
    validate_iframe(page)
    validate_embed(page)
    validate_link(page)
    validate_form(page)
    validate_object(page)
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
      puts 'script'
      puts node['src']
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
    nodes.each do |node|
      if node['rel'] == 'stylesheet'
        puts 'link'
        puts node['href']
      end
    end
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
