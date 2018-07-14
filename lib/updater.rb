require './lib/hatena_client'
client = HatenaClient.new
path = './invalid_entries.txt'
File.foreach(path, chomp: true) do |url|
  client.update_entry(url)
  sleep 1
end
puts 'End.'