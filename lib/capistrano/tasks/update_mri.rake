desc 'Update the MRI bundle'
task :bundle_mri do
  on roles :all do
    within(current_path) do
      execute "#{fetch :rvm_path}/bin/rvm `cat .ruby-version` do bundle --gemfile=#{current_path}/Gemfile"
    end
  end
end
after :deploy, :bundle_mri
