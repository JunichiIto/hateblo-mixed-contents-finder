require './lib/mixed_contents_finder'
require './lib/hatena_client'
require 'fileutils'

module Tasks
  class << self
    def validate_all(site_url, entire_page, limit, path)
      invalid_contents = MixedContentsFinder.new(entire_page: entire_page).validate_all(site_url, limit: limit)
      if File.exist?(path)
        FileUtils.rm(path)
      end
      File.open(path, 'w') do |file|
        file.puts invalid_contents
      end
      if invalid_contents.empty?
        puts 'OK💚'
      else
        puts "#{invalid_contents.size} errors found. Please open result.txt."
      end
    end

    def validate_page(entry_url, entire_page)
      invalid_contents = MixedContentsFinder.new(entire_page: entire_page).validate_page(entry_url)
      if invalid_contents.empty?
        puts 'OK💚'
      else
        puts invalid_contents
      end
    end

    def update_all(path)
      count = File.read(path).lines.size
      puts "[WARNING] Please backup your entries before update!!"
      print "Do you update #{count} entries? [yes|no]: "
      res = STDIN.gets.chomp
      if res == 'yes'
        client = HatenaClient.new
        File.foreach(path, chomp: true) do |url|
          client.update_entry(url)
          sleep 1
        end
        puts 'Completed.'
      end
    end
  end
end