# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{glassfish}
  s.version = "0.9.5"
  s.platform = %q{universal-java}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vivek Pandey, Jerome Dochez"]
  s.date = %q{2009-06-01}
  s.default_executable = %q{glassfish}
  s.description = %q{GlassFish gem is an embedded GlassFish V3 application server which would help run your Ruby on Rails application}
  s.email = %q{vivek.pandey@sun.com, jerome.dochez@sun.com}
  s.executables = ["glassfish", "glassfish_rails", "gfrake"]
  s.files = ["bin/gfrake", "bin/glassfish", "bin/glassfish_rails", "lib/appclient", "lib/asadmin.rb", "lib/command_line_parser.rb", "lib/config.rb", "lib/gfraker.rb", "lib/glassfish.rb", "lib/rdoc_usage.rb", "lib/registration", "lib/templates", "lib/version.rb", "lib/appclient/appclientlogin.conf", "lib/appclient/client.policy", "lib/appclient/wss-client-config-1.0.xml", "lib/appclient/wss-client-config-2.0.xml", "lib/registration/servicetag-registry.xml", "lib/templates/cacerts.jks", "lib/templates/default-web.xml", "lib/templates/docroot", "lib/templates/domain.xml", "lib/templates/domain.xml.xsl", "lib/templates/keyfile", "lib/templates/keystore.jks", "lib/templates/logging.properties", "lib/templates/login.conf", "lib/templates/profile.properties", "lib/templates/server.policy", "lib/templates/sun-acc.xml", "lib/templates/docroot/index.html", "generators/gfrake", "generators/gfrake/templates", "generators/gfrake/templates/glassfish.yml", "modules/admin-cli.jar", "modules/akuma.jar", "modules/api-exporter.jar", "modules/asm-all-repackaged.jar", "modules/auto-depends.jar", "modules/bean-validator.jar", "modules/branding.jar", "modules/cli-framework.jar", "modules/common-util.jar", "modules/config-api.jar", "modules/config.jar", "modules/deployment-admin.jar", "modules/deployment-autodeploy.jar", "modules/deployment-common.jar", "modules/flashlight-agent.jar", "modules/flashlight-framework.jar", "modules/gf-jruby-connector.jar", "modules/gfprobe-provider-client.jar", "modules/glassfish-api.jar", "modules/glassfish-ee-api.jar", "modules/glassfish-extra-jre-packages.jar", "modules/glassfish-gem.jar", "modules/glassfish.jar", "modules/grizzly-comet.jar", "modules/grizzly-cometd.jar", "modules/grizzly-compat.jar", "modules/grizzly-config.jar", "modules/grizzly-framework.jar", "modules/grizzly-http.jar", "modules/grizzly-jruby-module.jar", "modules/grizzly-jruby.jar", "modules/grizzly-messagesbus.jar", "modules/grizzly-portunif.jar", "modules/grizzly-rcm.jar", "modules/grizzly-utils.jar", "modules/hk2-core.jar", "modules/hk2.jar", "modules/internal-api.jar", "modules/kernel.jar", "modules/launcher.jar", "modules/org.apache.felix.configadmin.jar", "modules/org.apache.felix.fileinstall.jar", "modules/org.apache.felix.shell.jar", "modules/org.apache.felix.shell.remote.jar", "modules/org.apache.felix.shell.tui.jar", "modules/osgi-main.jar", "modules/pkg-client.jar", "modules/tiger-types-osgi.jar", "config/asadminenv.conf", "config/asenv.bat", "config/asenv.conf", "config/glassfish.container", "domains/domain1", "domains/domain1/config", "domains/domain1/docroot", "domains/domain1/master-password", "domains/domain1/config/admin-keyfile", "domains/domain1/config/cacerts.jks", "domains/domain1/config/default-web.xml", "domains/domain1/config/domain-passwords", "domains/domain1/config/domain.xml", "domains/domain1/config/glassfish_gem_version.yml", "domains/domain1/config/keyfile", "domains/domain1/config/keystore.jks", "domains/domain1/config/logging.properties", "domains/domain1/config/login.conf", "domains/domain1/config/server.policy", "domains/domain1/config/sun-acc.xml", "domains/domain1/docroot/index.html"]
  s.homepage = %q{http://glassfishgem.rubyforge.org/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{glassfishgem}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{GlassFish V3 Application Server for JRuby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0.4.0"])
    else
      s.add_dependency(%q<rack>, [">= 0.4.0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0.4.0"])
  end
end
