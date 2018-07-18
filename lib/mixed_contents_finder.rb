require 'mechanize'
require './lib/element_validator'
require './lib/invalid_content'

class MixedContentsFinder
  def initialize(entire_page: false)
    @entire_page = entire_page
  end

  def validate_all(site_url, limit: 3, sleep_sec: 1)
    puts "Validate #{site_url} / entire_page: #{@entire_page}, limit: #{limit || 'none'}"
    invalid_contents = []
    archive_url = File.join(site_url, 'archive')
    agent = Mechanize.new
    next_page_link = nil
    counter = 0
    catch(:exit_loop) do
      begin
        list_url = next_page_link ? next_page_link['href'] : archive_url
        puts "Validating #{list_url}"
        page = agent.get(list_url)
        links = page.search('.entry-title-link')
        links.each do |link|
          over_limit = limit && (counter += 1) > limit
          throw :exit_loop if over_limit

          url = link['href']
          invalid_contents += validate_page(url)
          sleep sleep_sec
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
    root = @entire_page ? '' : '.entry-content'
    VALIDATE_CONDITIONS.flat_map do |tag, attr|
      validator = ElementValidator.new(tag, attr, root)
      validator.validate(page)
    end
  end
end
