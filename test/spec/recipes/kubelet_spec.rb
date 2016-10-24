require 'spec_helper'

describe_recipe 'kubernetes-cluster::kubelet' do
  context 'with default node attributes' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    it { expect(chef_run).to enable_service('kubelet') }

    it 'should create template "/etc/kubernetes/kubelet"' do
      expect(chef_run).to create_template('/etc/kubernetes/kubelet').with(
        mode: '0640',
        source: 'kube-kubelet.erb',
        variables: {
          kubelet_args: '--config=/etc/kubernetes/manifests --register-node=true --register-schedulable=false',
          kubelet_hostname: 'fauxhai.local'
        }
      )
      resource = chef_run.template('/etc/kubernetes/kubelet')
      expect(resource).to notify('service[kubelet]').to(:restart).delayed
    end
  end

  context 'with node[\'kubernetes\'][\'secure\'][\'enabled\'] = true' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['kubernetes_cluster']['secure']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'should create template "/etc/kubernetes/secrets/kube.config"' do
      expect(chef_run).to create_template('/etc/kubernetes/secrets/kube.config').with(
        mode: '770',
        group: 'kube-services',
        source: 'kube-kubelet-kube-config.erb',
        variables: {
          etcd_cert_dir: '/etc/kubernetes/secrets',
          kubernetes_admin_token: nil,
          kubernetes_api_host: '127.0.0.1',
          kubernetes_api_port: '8443'
        }
      )
    end
  end
end
