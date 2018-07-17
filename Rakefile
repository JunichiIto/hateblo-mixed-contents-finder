require './lib/mixed_contents_finder'
require './lib/hatena_client'
require 'fileutils'

desc "Find http contents in all entries. ex) bundle exec rake 'validate_all[http://my-example.hatenablog.com]'"
task :validate_all, [:site_url, :entire_page, :limit] do |t, args|
  entire_page = args.entire_page.to_i == 1
  limit = args.limit ? args.limit.to_i : nil

  invalid_contents = MixedContentsFinder.new(entire_page: entire_page).validate_all(args.site_url, limit: limit)
  path = './result.txt'
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

desc "Find http contents in a specified entry. ex) bundle exec rake 'validate_page[http://my-example.hatenablog.com/entry/2018/07/17/075334]'"
task :validate_page, [:entry_url, :entire_page] do |t, args|
  entire_page = args.entire_page.to_i == 1

  invalid_contents = MixedContentsFinder.new(entire_page: entire_page).validate_page(args.entry_url)
  if invalid_contents.empty?
    puts 'OK💚'
  else
    puts invalid_contents
  end
end

desc 'Update entries specified in invalid_entries.txt ex) bundle exec rake update_all'
task :update_all do
  path = './invalid_entries.txt'
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