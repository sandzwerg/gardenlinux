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
    cmd = f"sudo docker run -it --rm --privileged --net=host \
        -v /:/rootfs -v {config_dir}:{config_dir} \
        registry.k8s.io/node-test:0.2"
    execute_remote_command(client, cmd)
