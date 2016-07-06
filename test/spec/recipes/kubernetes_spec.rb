require 'spec_helper'

describe_recipe 'kubernetes-cluster::kubernetes' do
  context 'with default node attributes' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    it 'should create template "/etc/kubernetes/config"' do
      expect(chef_run).to create_template('/etc/kubernetes/config').with(
        mode: '0640',
        source: 'kube-config.erb',
        variables: {
          allow_privileged: false,
          etcd_cert_dir: '/etc/kubernetes/secrets',
          kubernetes_api_host: '127.0.0.1',
          kubernetes_api_port: '8080',
          kubernetes_log_level: '5',
          kubernetes_master: 'fauxhai.local',
          kubernetes_secure_api_host: '127.0.0.1',
          kubernetes_secure_api_port: '8443'
        }
      )
    end
  end
end
