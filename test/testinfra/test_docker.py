import pytest

@pytest.mark.docker_images("renatomefi/testinfra:latest")
def test_executables(host):
    assert host.exists("docker")
    assert host.exists("pip")
    assert host.exists("testinfra")

@pytest.mark.docker_images("renatomefi/testinfra:latest")
def test_pip_is_installed(host):
    pip = host.package("py-pip")
    assert pip.is_installed
    assert pip.version.startswith("10")

@pytest.mark.docker_images("renatomefi/testinfra:latest")
def test_pip_packages(host):
    packages = host.pip_package.get_packages()
    assert "docker" in packages
    assert "testinfra" in packages
    assert "paramiko" in packages
