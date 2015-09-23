require 'anemone'

desc 'Verify that the site is up'
task :smoke_test do
  if Rails.env.development?
    url = 'http://localhost:3000/'
  else
    url = "http://#{"#{Rails.env}." unless Rails.env.production?}jujutsu.no/"
  end
  puts "Crawling #{url}"
  start = Time.now
  Anemone.crawl(url, threads: 4, discard_page_bodies: true) do |anemone|
    slowest_page = nil
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
      slowest_page = page if slowest_page.nil? || page.response_time > slowest_page.response_time
    end
    anemone.after_crawl do
      puts
      if not_found.any?
        pp not_found
        abort('Site NOT OK!')
      end
      duration = Time.now - start
      puts "Slowest page: #{slowest_page.response_time}ms #{slowest_page.url}"
      puts "Site OK: #{pages} pages in #{duration}s:  #{(pages / duration).round(1)} pages/s"
    end
  end
end
