desc 'Update the MRI bundle'
task :bundle_mri do
  on roles :all do
    within(current_path) do
      execute "#{fetch :rvm_path}/bin/rvm", fetch(:mri_ruby_version), 'do gem install --no-doc bundler'
      execute "#{fetch :rvm_path}/bin/rvm", fetch(:mri_ruby_version), "do bundle --gemfile=#{current_path}/Gemfile"
    end
  end
end
after :deploy, :bundle_mri
