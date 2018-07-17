require 'mechanize'
require './lib/element_validator'
require './lib/invalid_content'

class MixedContentsFinder
  SLEEP_SEC = 1

  def initialize(entire_page: false)
    @entire_page = entire_page
  end

  def validate_all(site_url, limit: 3)
    puts "Validate #{site_url} / entire_page: #{@entire_page}, limit: #{limit || 'none'}"
    invalid_contents = []
    archive_url = File.join(site_url, 'archive')
    agent = Mechanize.new
    next_page_link = nil
    counter = 0
    catch(:exit_loop) do
      begin
        list_url = next_page_link ? next_page_link['href'] : archive_url
        puts "Search in #{list_url}"
        page = agent.get(list_url)
        links = page.search('.entry-title-link')
        links.each do |link|
          counter += 1
          if limit && counter > limit
            throw :exit_loop
          end
          url = link['href']
          invalid_contents += validate_page(url)
        end
        next_page_link = page.search('.pager-next a')&.first
      end while next_page_link
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
    %w(link href),
  ]

  def validate_page(url)
    puts "[#{Time.now.strftime("%H:%M:%S")}] Validate #{url}"

    agent = Mechanize.new
    page = agent.get(url)
    invalid_contents = VALIDATE_CONDITIONS.flat_map { |tag, attr|
      params = @entire_page ? [tag, attr, ''] : [tag, attr, '.entry-content']
      validator = ElementValidator.new(*params)
      validator.validate(page)
    }

    invalid_contents.tap do
      sleep SLEEP_SEC
    end
  end
end
