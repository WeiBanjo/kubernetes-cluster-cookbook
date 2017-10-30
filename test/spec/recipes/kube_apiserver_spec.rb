require 'spec_helper'

describe_recipe 'kubernetes-cluster::kube-apiserver' do
  context 'with default node attributes' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['kubernetes_cluster']['etcd']['clienthosts'] = %w(
          dev-kubernetes-master-master-01.dev.local
          dev-kubernetes-master-master-02.dev.local
          dev-kubernetes-master-master-03.dev.local
        )
      end.converge(described_recipe)
    end

    it { expect(chef_run).to enable_service('kube-apiserver') }
    it { expect(chef_run.node['kubernetes_cluster']['master']['fqdn']).to eq('fauxhai.local') }
    it { expect(chef_run).to_not create_template('/etc/kubernetes/etcd.client.conf') }

    it 'should create template "/etc/kubernetes/apiserver"' do
      expect(chef_run).to create_template('/etc/kubernetes/apiserver').with(
        mode: '0640',
        source: 'kube-apiserver.erb',
        variables: {
          etcd_endpoints: 'http://dev-kubernetes-master-master-01.dev.local:2379,http://dev-kubernetes-master-master-02.dev.local:2379,http://dev-kubernetes-master-master-03.dev.local:2379',
          etcd_cert_dir: '/etc/kubernetes/secrets',
          kubelet_port: '10250',
          kubernetes_api_port: '8080',
          kubernetes_api_args: '',
          kubernetes_master: 'fauxhai.local',
          kubernetes_network: '1.90.0.0/16',
          kubernetes_secure_api_port: '8443'
        }
      )
      resource = chef_run.template('/etc/kubernetes/apiserver')
      expect(resource).to notify('service[kube-apiserver]').to(:restart).delayed
    end
  end

  context 'with node[\'kubernetes\'][\'secure\'][\'enabled\'] = true' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['kubernetes_cluster']['secure']['enabled'] = true
        node.normal['kubernetes_cluster']['etcd']['clienthosts'] = %w(
          dev-kubernetes-master-master-01.dev.local
          dev-kubernetes-master-master-02.dev.local
          dev-kubernetes-master-master-03.dev.local
        )
      end.converge(described_recipe)
    end

    it 'should create template "/etc/kubernetes/etcd.client.conf"' do
      expect(chef_run).to create_template('/etc/kubernetes/etcd.client.conf').with(
        mode: '0644',
        source: 'kube-apiserver-etcd.erb',
        variables: {
          etcd_endpoints: "\"https://dev-kubernetes-master-master-01.dev.local:2379\", \"https://dev-kubernetes-master-master-02.dev.local:2379\", \"https://dev-kubernetes-master-master-03.dev.local:2379\"",
          etcd_cert_dir: '/etc/kubernetes/secrets',
          kubernetes_master: 'fauxhai.local'
        }
      )
    end
  end
end
