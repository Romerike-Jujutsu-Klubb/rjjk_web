# frozen_string_literal: true

desc 'Verify that the site is up'
task :smoke_test do
  url = if Rails.env.development?
          'http://localhost:3000/'
        else
          "http://#{"#{Rails.env}." unless Rails.env.production?}jujutsu.no/"
        end
  puts "Crawling #{url}"
  start = Time.current
  Medusa.crawl(url, threads: 4, discard_page_bodies: true) do |medusa|
    slowest_page = nil
    pages = 0
    not_found = []
    medusa.on_every_page do |page|
      unless page.fetched?
        p page
        next
      end
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
      not_found << { page.referer.to_s => page.url.to_s } if page.code == 404
      slowest_page = page if slowest_page.nil? || page.response_time > slowest_page.response_time
    end
    medusa.after_crawl do
      puts
      if not_found.any?
        pp not_found
        abort('Site NOT OK!')
      end
      duration = Time.current - start
      puts "Slowest page: #{slowest_page.response_time}ms #{slowest_page.url}"
      puts "Site OK: #{pages} pages in #{duration}s:  #{(pages / duration).round(1)} pages/s"
    end
  end
end
