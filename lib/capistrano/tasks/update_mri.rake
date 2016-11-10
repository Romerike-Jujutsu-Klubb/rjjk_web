# frozen_string_literal: true
desc 'Update the MRI bundle'

def rvm_cmd(cmd1)
  execute "#{fetch :rvm_path}/bin/rvm", fetch(:mri_ruby_version), 'do', cmd1
end

task :bundle_mri do
  on roles :all do
    within(current_path) do
      with BUNDLE_GEMFILE: "#{current_path}/Gemfile" do
        rvm_cmd('gem install --no-doc bundler')
        rvm_cmd('bundle check || bundle install --without development,test')
      end
    end
  end
end
after :deploy, :bundle_mri
