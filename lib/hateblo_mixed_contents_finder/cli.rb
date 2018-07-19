require 'fileutils'
require 'thor'

module HatebloMixedContentsFinder
  class CLI < Thor
    desc "validate_all SITE_URL", "Find http contents in all entries."
    option :entire_page, type: :boolean, default: false, desc: "Validate entire page or content part only."
    option :limit, type: :numeric, default: nil, desc: "Specify upper limit of entry validation."
    option :path, type: :string, default: './result.txt', hide: true
    def validate_all(site_url)
      entire_page = options[:entire_page]
      limit = options[:limit]
      path = options[:path]

      invalid_contents = MixedContentsFinder.new(entire_page: entire_page).validate_all(site_url, limit: limit)
      FileUtils.rm(path) if File.exist?(path)
      File.write(path, invalid_contents.join("\n"))
      if invalid_contents.empty?
        puts 'OK💚'
      else
        puts "#{invalid_contents.size} errors found. Please open result.txt."
      end
    end

    desc "validate_entry ENTRY_URL", "Find http contents in a specified entry."
    option :entire_page, type: :boolean, default: false, desc: "Validate entire page or content part only."
    def validate_entry(entry_url)
      entire_page = options[:entire_page]

      invalid_contents = MixedContentsFinder.new(entire_page: entire_page).validate_entry(entry_url)
      if invalid_contents.empty?
        puts 'OK💚'
      else
        puts invalid_contents
      end
    end

    desc "update_all", "Update entries specified in invalid_entries.txt."
    option :path, type: :string, default: './invalid_entries.txt', hide: true
    option :sleep_sec, type: :numeric, default: 1, hide: true
    def update_all
      sleep_sec = options[:sleep_sec]
      path = options[:path]

      count = File.read(path).lines.size
      puts "[WARNING] Please backup your entries before update!!"
      print "Do you update #{count} entries? [yes|no]: "
      res = STDIN.gets.chomp.downcase
      return unless res == 'yes'

      client = HatenaClient.new
      File.foreach(path, chomp: true) do |url|
        client.update_entry(url)
        sleep sleep_sec
      end
      puts 'Completed.'
    end
  end
end
