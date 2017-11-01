# encoding: utf-8

control 'Helm client binary' do
  title 'Verify Helm client binary'
  desc 'Ensures Helm client binary is installed with defaults'
  describe file('/usr/bin/helm') do
    it { should exist }
  end
  describe command("/usr/bin/helm version -c") do
    its(:stdout) { should match /SemVer\:"v2.6.2"/ }
  end
end

control 'Helm home' do
  title 'Verify default Helm home'
  desc 'Ensures Helm home has been initialized to expected default directory'
  describe file('/srv/helm/home') do
    it { should exist }
    it { should be_executable }
    it { should be_directory }
  end
end

control 'Helm repos' do
  title 'Verify default Helm repos'
  desc 'Ensures Helm default repos are maintained'
  describe command("/usr/bin/helm repo list --home /srv/helm/home") do
    its(:stdout) { should match /stable/ }
    its(:stdout) { should match /local/ }
  end
end

control 'Kubectl config' do
  title 'Verify Kube config'
  desc 'Ensures kubectl config has been properly generated'
  describe yaml('/srv/helm/.kube/config.yml') do
    its('clusters') { should eq [] }
    its('contexts') { should eq [] }
    its('users') { should eq [] }
    its('current-context') { should eq "" }
  end
end