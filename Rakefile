# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

Rails::TestTask.new('test:features' => 'test:prepare') do |t|
  t.pattern = 'test/features/**/*_test.rb'
end
Rake::Task['test:run'].enhance ['test:features']

require 'anemone'

desc 'Verify that the site is up'
task :smoke_test do
  if Rails.env.development?
    url = 'http://localhost:3000/'
  else
    url = "http://#{"#{Rails.env}." unless Rails.env.production?}jujutsu.no/"
  end
  puts "Crawling #{url}"
  Anemone.crawl(url) do |anemone|
    pages = 0
    not_found = []
    anemone.on_every_page do |page|
      pages += 1
      print case page.code / 100
          when 2
            '.'
          when 3
            '>'
          when 4
            '?'
          else
            'X'
          end
      not_found << {page.referer.to_s => page.url.to_s} if page.code == 404
    end
    anemone.after_crawl do
      puts
      if not_found.any?
        pp not_found
        abort('Site NOT OK!')
      end
      puts "Site OK: #{pages} pages."
    end
  end
end
