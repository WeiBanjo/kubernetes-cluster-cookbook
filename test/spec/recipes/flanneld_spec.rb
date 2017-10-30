require 'spec_helper'

describe_recipe 'kubernetes-cluster::flanneld' do
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

    it { expect(chef_run).to enable_service('flanneld') }
    it { expect(chef_run).to_not enable_service('docker') }
    it { expect(chef_run).to_not start_service('docker') }
    it { expect(chef_run).to_not enable_service('kubelet') }
    it { expect(chef_run).to_not start_service('kubelet') }
    it { expect(chef_run).to_not run_execute('redo-docker-bridge') }

    it 'should not run execute "redo-docker-bridge"' do
      expect(chef_run).to_not run_execute('redo-docker-bridge').with(
        command: 'ifconfig docker0 down; brctl delbr docker0 adsf'
      )
      # resource = chef_run.execute('redo-docker-bridg')
      # expect(resource).to notify('service[docker]').to(:restart).immediately
    end

    it 'should create template "/etc/sysconfig/flanneld"' do
      expect(chef_run).to create_template('/etc/sysconfig/flanneld').with(
        mode: '0640',
        source: 'flannel-flanneld.erb',
        variables: {
          etcd_endpoints: 'http://dev-kubernetes-master-master-01.dev.local:2379,http://dev-kubernetes-master-master-02.dev.local:2379,http://dev-kubernetes-master-master-03.dev.local:2379',
          etcd_cert_dir: '/etc/kubernetes/secrets'
        }
      )
      resource = chef_run.template('/etc/sysconfig/flanneld')
      expect(resource).to notify('service[flanneld]').to(:restart).immediately
      expect(resource).to notify('execute[redo-docker-bridge]').to(:run).delayed
      expect(resource).to notify('service[kubelet]').to(:restart).delayed
    end
  end
end
