require './lib/mixed_contents_finder'
require 'fileutils'
invalid_contents = MixedContentsFinder.new.run(10)
path = './result.txt'
if File.exist?(path)
  FileUtils.rm(path)
end
File.open(path, 'w') do |file|
  file.puts invalid_contents
end
