require './lib/tasks'

desc "Find http contents in all entries. ex) bundle exec rake 'validate_all[http://my-example.hatenablog.com]'"
task :validate_all, [:site_url, :entire_page, :limit] do |t, args|
  entire_page = args.entire_page.to_i == 1
  limit = args.limit ? args.limit.to_i : nil
  path = './result.txt'
  Tasks.validate_all(args.site_url, entire_page, limit, path)
end

desc "Find http contents in a specified entry. ex) bundle exec rake 'validate_page[http://my-example.hatenablog.com/entry/2018/07/17/075334]'"
task :validate_page, [:entry_url, :entire_page] do |t, args|
  entire_page = args.entire_page.to_i == 1
  Tasks.validate_page(args.entry_url, entire_page)
end

desc 'Update entries specified in invalid_entries.txt ex) bundle exec rake update_all'
task :update_all do
  path = './invalid_entries.txt'
  Tasks.update_all(path)
end