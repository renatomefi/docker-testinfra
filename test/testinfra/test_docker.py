import pytest

def test_executables(host):
    assert host.exists("docker")
    assert host.exists("pip")

@pytest.mark.v1
def test_executables(host):
    assert host.exists("testinfra")

def test_pip_is_installed(host):
    pip = host.package("py-pip")
    assert pip.is_installed
    assert pip.version.startswith("10")

def test_pip_packages(host):
    packages = host.pip_package.get_packages()
    assert "docker" in packages
    assert "testinfra" in packages
    assert "paramiko" in packages
