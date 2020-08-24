require 'serverspec'

# Required by serverspec
set :backend, :exec

ENV['HOME'] = '/tmp/kitchen/data'
require ENV['HOME'] + '/test/dynatrace/defaults.rb'
require ENV['HOME'] + '/test/dynatrace/oneagent.rb'
require ENV['HOME'] + '/test/util/docker.rb'
require ENV['HOME'] + '/test/util/s2i.rb'

ENV['S2I_HOME']     = '/opt/s2i-wildfly'
ENV['S2I_101_HOME'] = ENV['S2I_HOME'] + '/10.1'

describe "Integrate Dynatrace OneAgent for PaaS into openshift/wildfly-101-centos7" do
  describe command(Dynatrace::OneAgent::S2I::integrate(ENV['S2I_101_HOME'] + '/s2i/bin', 'java')) do
    its(:exit_status) { should eq 0 }
  end

  describe command(Util::Docker::build(ENV['S2I_101_HOME'], 'openshift/wildfly-101-centos7')) do
    its(:exit_status) { should eq 0 }
  end

  describe "Assert dynatrace-monitoring-incl.sh is available in the resulting image's s2i scripts path" do
    describe command(Util::Docker::run('openshift/wildfly-101-centos7', '', "ls -la #{Util::S2I::SCRIPTS_PATH}")) do
      its(:stdout) { should contain 'dynatrace-monitoring-incl.sh' }
      its(:exit_status) { should eq 0 }
    end
  end
end

describe "Build openshift/wildfly-101-centos7 application with OneAgent integrated at build time" do
  describe "Set ENABLE_DYNATRACE, but omit required DT_TENANT and DT_API_TOKEN" do
    describe command(Util::S2I::build('openshift/wildfly-101-centos7', 'git://github.com/bparees/openshift-jee-sample', 'wildflytest', '--env=ENABLE_DYNATRACE=true')) do
      its(:stderr) { should contain '---> Warning: ENABLE_DYNATRACE=true, but DT_TENANT and DT_API_TOKEN have not been defined.' }
      its(:stderr) { should_not contain '---> Installing Dynatrace OneAgent...' }
      its(:exit_status) { should eq 0 }
    end
  end

  describe "Set ENABLE_DYNATRACE with required DT_TENANT and DT_API_TOKEN" do
    describe command(Util::S2I::build('openshift/wildfly-101-centos7', 'git://github.com/bparees/openshift-jee-sample', 'wildflytest', "--env=ENABLE_DYNATRACE=true --env=DT_CLUSTER_HOST=#{Dynatrace::Defaults::DT_CLUSTER_HOST} --env=DT_TENANT=#{Dynatrace::Defaults::DT_TENANT} --env=DT_API_TOKEN=#{Dynatrace::Defaults::DT_API_TOKEN}")) do
      its(:stderr) { should contain '---> Installing Dynatrace OneAgent...' }
      its(:stderr) { should_not contain '---> Warning: ENABLE_DYNATRACE=true, but DT_TENANT and DT_API_TOKEN have not been defined.' }
      its(:stderr) { should contain "Connecting to https://#{Dynatrace::Defaults::DT_CLUSTER_HOST}" }
      its(:stderr) { should match /Installing to \/tmp.*Unpacking complete./m }
      its(:exit_status) { should eq 0 }
    end

    describe "Assert Dynatrace OneAgent has been installed into /tmp/dynatrace/oneagent" do
      describe command(Util::Docker::run('wildflytest', '', 'stat /tmp/dynatrace/oneagent')) do
        its(:exit_status) { should eq 0 }
      end
    end

    describe "Assert Dynatrace OneAgent has been injected into /usr/libexec/s2i/assemble" do
      describe command(Util::Docker::run('wildflytest', '', 'cat /usr/libexec/s2i/assemble')) do
        its(:stdout) { should match /^export DT_ONEAGENT_FOR=java\n. \/usr\/libexec\/s2i\/dynatrace-monitoring-incl.sh/m }
      end
    end

    describe "Assert Dynatrace OneAgent has been injected into /usr/libexec/s2i/run" do
      describe command(Util::Docker::run('wildflytest', '', 'cat /usr/libexec/s2i/run')) do
        its(:stdout) { should match /^export DT_ONEAGENT_FOR=java\n. \/usr\/libexec\/s2i\/dynatrace-monitoring-incl.sh\nexec \$EXEC_CMD_PREFIX \/wildfly\/bin\/standalone.sh/m }
      end
    end

    describe "Assert ENABLE_DYNATRACE remains set to true at container runtime" do
      describe command(Util::Docker::run('wildflytest', '', 'env')) do
        its(:stdout) { should contain 'ENABLE_DYNATRACE=true' }
        its(:exit_status) { should eq 0 }
      end
    end

    describe "Assert Dynatrace OneAgent does not get injected again at runtime" do
      describe command(Util::Docker::run('wildflytest')) do
        its(:stdout) { should contain '---> ENABLE_DYNATRACE=true, but Dynarace OneAgent already exists in /tmp/dynatrace/oneagent. Skipping installation.' }
        its(:stdout) { should_not contain '---> Installing Dynatrace OneAgent...' }
        its(:exit_status) { should eq 0 }
      end
    end
  end
end

describe "Build openshift/wildfly-101-centos7 application with OneAgent integrated at runtime" do
  describe command(Util::S2I::build('openshift/wildfly-101-centos7', 'git://github.com/bparees/openshift-jee-sample', 'wildflytest')) do
    its(:exit_status) { should eq 0 }
  end

  describe "Set ENABLE_DYNATRACE, but omit required DT_TENANT and DT_API_TOKEN" do
    describe command(Util::Docker::run('wildflytest', '--env ENABLE_DYNATRACE=true')) do
      its(:stdout) { should contain '---> Warning: ENABLE_DYNATRACE=true, but DT_TENANT and DT_API_TOKEN have not been defined.' }
      its(:stdout) { should_not contain '---> Installing Dynatrace OneAgent...' }
      its(:exit_status) { should eq 0 }
    end
  end

  describe "Set ENABLE_DYNATRACE with required DT_TENANT and DT_API_TOKEN" do
    describe command(Util::Docker::run('wildflytest', "--env ENABLE_DYNATRACE=true --env DT_CLUSTER_HOST=#{Dynatrace::Defaults::DT_CLUSTER_HOST} --env DT_TENANT=#{Dynatrace::Defaults::DT_TENANT} --env DT_API_TOKEN=#{Dynatrace::Defaults::DT_API_TOKEN}", nil, 'wildflytest')) do
      its(:stdout) { should contain '---> Installing Dynatrace OneAgent...' }
      its(:stdout) { should match Regexp.new("Connecting to https://#{Dynatrace::Defaults::DT_CLUSTER_HOST}") }
      its(:stdout) { should match /Installing to \/tmp.*Unpacking complete./m }
      its(:exit_status) { should eq 0 }
    end

    describe "Assert Dynatrace OneAgent has been installed into /tmp/dynatrace/oneagent" do
      describe command(Util::Docker::exec('wildflytest', 'stat /tmp/dynatrace/oneagent')) do
        its(:exit_status) { should eq 0 }
      end
    end

    describe "Assert Dynatrace OneAgent has been injected into /usr/libexec/s2i/assemble" do
      describe command(Util::Docker::exec('wildflytest', 'cat /usr/libexec/s2i/assemble')) do
        its(:stdout) { should match /^export DT_ONEAGENT_FOR=java\n. \/usr\/libexec\/s2i\/dynatrace-monitoring-incl.sh/m }
      end
    end

    describe "Assert Dynatrace OneAgent has been injected into /usr/libexec/s2i/run" do
      describe command(Util::Docker::exec('wildflytest', 'cat /usr/libexec/s2i/run')) do
        its(:stdout) { should match /^export DT_ONEAGENT_FOR=java\n. \/usr\/libexec\/s2i\/dynatrace-monitoring-incl.sh\nexec \$EXEC_CMD_PREFIX \/wildfly\/bin\/standalone.sh/m }
      end
    end
  end
end