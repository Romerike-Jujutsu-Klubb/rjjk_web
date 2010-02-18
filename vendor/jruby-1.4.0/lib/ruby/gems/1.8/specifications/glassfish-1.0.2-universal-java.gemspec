# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{glassfish}
  s.version = "1.0.2"
  s.platform = %q{universal-java}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vivek Pandey"]
  s.date = %q{2009-12-22}
  s.default_executable = %q{glassfish}
  s.description = %q{GlassFish gem is an embedded GlassFish V3 application server which
                                would help run your Ruby on Rails application}
  s.email = %q{vivek.pandey@sun.com}
  s.executables = ["glassfish", "gfrake"]
  s.extra_rdoc_files = ["README.txt", "History.txt", "LICENSE.txt"]
  s.files = ["bin/gfrake", "bin/glassfish", "lib/asadmin.rb", "lib/command_line_parser.rb", "lib/config.rb", "lib/gfraker.rb", "lib/glassfish.rb", "lib/rdoc_usage.rb", "lib/server.rb", "lib/version.rb", "lib/java/akuma.jar", "lib/java/gf-jruby-connector.jar", "lib/java/glassfish-embedded-nucleus.jar", "lib/java/glassfish-gem.jar", "lib/java/grizzly-jruby-module.jar", "lib/java/grizzly-jruby.jar", "lib/jruby/rails_path.rb", "lib/jruby/rack/grizzly_helper.rb", "lib/jruby/rack/merb.rb", "lib/jruby/rack/rackup.rb", "lib/jruby/rack/rails.rb", "lib/jruby/rack/sinatra.rb", "lib/rack/adapter/merb.rb", "lib/rack/adapter/rails.rb", "lib/rack/handler/glassfish.rb", "lib/rack/handler/grizzly.rb", "generators/gfrake/templates/glassfish.yml", "README.txt", "History.txt", "LICENSE.txt"]
  s.homepage = %q{http://glassfishgem.rubyforge.org/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{glassfishgem}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{GlassFish V3 gem for JRuby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0.4.0"])
    else
      s.add_dependency(%q<rack>, [">= 0.4.0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0.4.0"])
  end
end
