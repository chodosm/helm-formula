# encoding: utf-8

control 'Helm client binary' do
  title 'Verify Helm client binary'
  desc 'Ensures Helm client binary is installed'
  describe file('/usr/local/bin/helm') do
    it { should exist }
  end
  describe command("/usr/local/bin/helm version -c") do
    its(:stdout) { should match /SemVer\:"v2.6.2"/ }
  end
end

control 'Helm home' do
  title 'Verify Helm home'
  desc 'Ensures Helm home has been initialized to expected directory'
  describe file('/root/.helm') do
    it { should exist }
    it { should be_executable }
    it { should be_directory }
  end
end

control 'Helm repos' do
  title 'Verify configured Helm repos'
  desc 'Ensures Helm repos have been properly configured'
  describe command("/usr/local/bin/helm repo list --home /root/.helm") do
    its(:stdout) { should match /incubator/ }
    its(:stdout) { should match /stable/ }
    its(:stdout) { should_not match /local/ }
  end
end

control 'Kubectl config' do
  title 'Verify Kube config'
  desc 'Ensures kubectl config has been properly generated'
  describe yaml('/srv/helm/kubeconfig.yml') do
    config = {
      cluster_name: "kubernetes.example",
      cluster_server: "https://kubernetes.example.com",
      cluster_cert: "base64_of_ca_certificate",
      context_name: "kubernetes-example",
      user_name: "admin",
      user_pass: "uberadminpass"
    }
    its(['clusters', 0, 'name']) { should eq config[:cluster_name] }
    its(['clusters', 0, 'cluster', 'server']) { should eq config[:cluster_server] }
    its(['contexts', 0, 'name']) { should eq config[:context_name] }
    its(['contexts', 0, 'context', 'cluster']) { should eq config[:cluster_name] }
    its(['contexts', 0, 'context', 'user']) { should eq config[:user_name] }
    its('current-context') { should eq config[:context_name] }
    its(['users', 0, 'name']) { should eq config[:user_name] }
    its(['users', 0, 'user', 'password']) { should eq config[:user_pass] }
  end
end