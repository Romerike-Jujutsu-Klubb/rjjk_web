task :smoke_test do
  system "rake smoke_test RAILS_ENV=#{fetch(:rails_env)}"
end
after :deploy, :smoke_test
