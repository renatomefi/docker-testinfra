import pytest

def test_executables(host):
    assert host.exists("docker")
    assert host.exists("pip")

@pytest.mark.v1
def test_executables(host):
    assert host.exists("testinfra")

def test_pip_packages(host):
    packages = host.pip_package.get_packages()
    assert "pip" in packages
    assert "docker" in packages
    assert "testinfra" in packages
    assert "paramiko" in packages
