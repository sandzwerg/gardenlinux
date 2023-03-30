import pytest
from helper.tests.file_content import file_content
from helper.utils import execute_remote_command


@pytest.mark.parametrize(
    "config_dir",
    [
        "/var/lib/kubelet/config.yaml"
    ]
)

def test_k8s_conformance(client, config_dir, non_chroot):
    cmd = f"sudo ctr run --rm --privileged --net-host \
        --mount type=bind,src=$PWD,dst=/rootfs,options=rbing:rw \
        --mount type=bind,src={config_dir},dst={config_dir},options=rbing:rw \
        registry.k8s.io/node-test:0.2"
    execute_remote_command(client, cmd)
