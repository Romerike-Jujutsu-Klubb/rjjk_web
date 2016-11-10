# frozen_string_literal: true
task :smoke_test do
  system "rake --trace smoke_test RAILS_ENV=#{fetch(:rails_env)}"
end
after :deploy, :smoke_test
