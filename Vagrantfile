# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

VAGRANTFILE_API_VERSION = "2"

IMAGE="jakm/aerospike-server"

nodes_config = (JSON.parse(File.read("nodes.json")))['nodes']

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    nodes_config.each do |node|
        node_name   = node[0] # name of node
        node_config = node[1] # content of node

        config.vm.define node_name do |config|
            config.vm.provider "docker" do |d|
                d.image = if node_config["image"].empty? then IMAGE else node_config["image"] end
                d.name = node_name
                d.has_ssh = true
                d.create_args = ["--hostname=" + node_name, "--memory=" + node_config["memory"]]
                d.cmd = ["/usr/local/sbin/bootstrap.sh", node_config["ip"]]

                if not node_config["data_dir"].empty?
                    d.volumes.push(node_config["data_dir"] + ":/opt/aerospike/data")
                end
            end

            config.vm.synced_folder '.', '/vagrant', disabled: true
        end

    end

    config.trigger.after :up, :vm => ["aero1"]  do
        run "sudo ./setup-network.py"
    end
end
