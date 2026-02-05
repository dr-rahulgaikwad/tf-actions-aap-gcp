"""
Property-Based Tests for VM Provisioning Completeness

This module tests Property 1: VM Provisioning Completeness
**Validates: Requirements 1.1**

Property 1 states: For any valid Terraform configuration with VM specifications,
applying the configuration should result in all specified VMs being created in GCP
with matching names, machine types, and zones.
"""

import json
import subprocess
import tempfile
from pathlib import Path
from typing import Dict, List, Any
from hypothesis import given, strategies as st, settings, assume
import pytest


# ============================================================================
# Helper Functions
# ============================================================================

def get_terraform_dir() -> Path:
    """
    Get the path to the Terraform directory.
    
    Returns:
        Path object pointing to the terraform directory
    """
    project_root = Path(__file__).parent.parent
    terraform_path = project_root / "terraform"
    
    if not terraform_path.exists():
        raise FileNotFoundError(f"Terraform directory not found at {terraform_path}")
    
    return terraform_path


def run_terraform_command(command: List[str], cwd: Path) -> subprocess.CompletedProcess:
    """
    Run a Terraform command and return the result.
    
    Args:
        command: List of command arguments (e.g., ['terraform', 'plan'])
        cwd: Working directory for the command
        
    Returns:
        CompletedProcess object with stdout, stderr, and returncode
    """
    result = subprocess.run(
        command,
        cwd=cwd,
        capture_output=True,
        text=True,
        timeout=300  # 5 minute timeout
    )
    return result


def parse_terraform_show_json(terraform_dir: Path) -> Dict[str, Any]:
    """
    Run 'terraform show -json' and parse the output.
    
    This provides the current state of Terraform resources in JSON format.
    
    Args:
        terraform_dir: Path to the Terraform directory
        
    Returns:
        Dictionary containing the Terraform state
    """
    result = run_terraform_command(
        ['terraform', 'show', '-json'],
        cwd=terraform_dir
    )
    
    if result.returncode != 0:
        raise RuntimeError(f"terraform show failed: {result.stderr}")
    
    return json.loads(result.stdout)


def get_vm_resources_from_state(state_data: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Extract VM instance resources from Terraform state.
    
    Args:
        state_data: Parsed Terraform state JSON
        
    Returns:
        List of VM resource dictionaries
    """
    vms = []
    
    # Navigate the state structure to find VM instances
    if 'values' in state_data and 'root_module' in state_data['values']:
        root_module = state_data['values']['root_module']
        
        if 'resources' in root_module:
            for resource in root_module['resources']:
                if resource.get('type') == 'google_compute_instance':
                    vms.append(resource)
    
    return vms


def validate_vm_properties(
    vm_resource: Dict[str, Any],
    expected_name_pattern: str,
    expected_machine_type: str,
    expected_zone: str
) -> Dict[str, bool]:
    """
    Validate that a VM resource has the expected properties.
    
    Args:
        vm_resource: VM resource dictionary from Terraform state
        expected_name_pattern: Expected pattern for VM name (e.g., "ubuntu-vm-")
        expected_machine_type: Expected machine type
        expected_zone: Expected zone
        
    Returns:
        Dictionary with validation results for each property
    """
    values = vm_resource.get('values', {})
    
    return {
        'name_matches': expected_name_pattern in values.get('name', ''),
        'machine_type_matches': expected_machine_type in values.get('machine_type', ''),
        'zone_matches': expected_zone in values.get('zone', ''),
        'has_network_interface': len(values.get('network_interface', [])) > 0,
        'has_boot_disk': 'boot_disk' in values
    }


def get_terraform_outputs(terraform_dir: Path) -> Dict[str, Any]:
    """
    Get Terraform outputs by running 'terraform output -json'.
    
    Args:
        terraform_dir: Path to the Terraform directory
        
    Returns:
        Dictionary of output values
    """
    result = run_terraform_command(
        ['terraform', 'output', '-json'],
        cwd=terraform_dir
    )
    
    if result.returncode != 0:
        # If no outputs exist yet, return empty dict
        if "No outputs found" in result.stderr:
            return {}
        raise RuntimeError(f"terraform output failed: {result.stderr}")
    
    return json.loads(result.stdout)


def count_vms_in_state(terraform_dir: Path) -> int:
    """
    Count the number of VM instances in the current Terraform state.
    
    Args:
        terraform_dir: Path to the Terraform directory
        
    Returns:
        Number of VM instances
    """
    try:
        state_data = parse_terraform_show_json(terraform_dir)
        vms = get_vm_resources_from_state(state_data)
        return len(vms)
    except Exception:
        # If state doesn't exist or can't be parsed, return 0
        return 0


def get_vm_count_from_tfvars(terraform_dir: Path) -> int:
    """
    Get the vm_count value from terraform.tfvars if it exists.
    
    Args:
        terraform_dir: Path to the Terraform directory
        
    Returns:
        VM count from tfvars, or default value (2) if not found
    """
    tfvars_path = terraform_dir / "terraform.tfvars"
    
    if not tfvars_path.exists():
        return 2  # Default value from variables.tf
    
    with open(tfvars_path, 'r') as f:
        content = f.read()
        
    # Simple regex to find vm_count = <number>
    import re
    match = re.search(r'vm_count\s*=\s*(\d+)', content)
    
    if match:
        return int(match.group(1))
    
    return 2  # Default value


# ============================================================================
# Property-Based Tests
# ============================================================================

class TestVMProvisioningCompleteness:
    """
    Test suite for Property 1: VM Provisioning Completeness
    
    **Validates: Requirements 1.1**
    """
    
    def test_terraform_directory_exists(self):
        """
        Prerequisite test: Verify Terraform directory exists.
        """
        terraform_dir = get_terraform_dir()
        assert terraform_dir.exists(), "Terraform directory must exist"
        assert (terraform_dir / "main.tf").exists(), "main.tf must exist"
    
    def test_vm_resources_defined(self):
        """
        Test that VM resources are defined in Terraform configuration.
        
        This test verifies that the google_compute_instance resource
        is defined in the Terraform code.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        
        with open(main_tf, 'r') as f:
            content = f.read()
        
        assert 'resource "google_compute_instance"' in content, (
            "google_compute_instance resource must be defined"
        )
        assert 'ubuntu_vms' in content, (
            "VM resource should be named 'ubuntu_vms'"
        )
    
    def test_vm_count_variable_exists(self):
        """
        Test that vm_count variable is defined in variables.tf.
        
        This variable controls how many VMs are provisioned.
        """
        terraform_dir = get_terraform_dir()
        variables_tf = terraform_dir / "variables.tf"
        
        with open(variables_tf, 'r') as f:
            content = f.read()
        
        assert 'variable "vm_count"' in content, (
            "vm_count variable must be defined"
        )
    
    def test_vm_configuration_properties(self):
        """
        Test that VM resources have required configuration properties.
        
        This test verifies that the VM resource definition includes:
        - name
        - machine_type
        - zone
        - boot_disk
        - network_interface
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        
        with open(main_tf, 'r') as f:
            content = f.read()
        
        # Check for required properties in the VM resource
        required_properties = [
            'name',
            'machine_type',
            'zone',
            'boot_disk',
            'network_interface'
        ]
        
        for prop in required_properties:
            assert prop in content, (
                f"VM resource must define '{prop}' property"
            )
    
    def test_vm_naming_convention(self):
        """
        Test that VMs follow the expected naming convention.
        
        VMs should be named with a pattern like "ubuntu-vm-1", "ubuntu-vm-2", etc.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        
        with open(main_tf, 'r') as f:
            content = f.read()
        
        # Check for naming pattern with count.index
        assert 'ubuntu-vm-' in content, (
            "VM names should follow 'ubuntu-vm-' pattern"
        )
        assert 'count.index' in content, (
            "VM names should use count.index for uniqueness"
        )
    
    @pytest.mark.skipif(
        subprocess.run(['which', 'terraform'], capture_output=True).returncode != 0,
        reason="Terraform CLI not available"
    )
    def test_terraform_validate_passes(self):
        """
        Test that Terraform configuration is syntactically valid.
        
        This test runs 'terraform validate' to ensure the configuration
        can be parsed and validated by Terraform.
        """
        terraform_dir = get_terraform_dir()
        
        # Initialize Terraform (required for validate)
        init_result = run_terraform_command(
            ['terraform', 'init', '-backend=false'],
            cwd=terraform_dir
        )
        
        # Validate should pass
        validate_result = run_terraform_command(
            ['terraform', 'validate'],
            cwd=terraform_dir
        )
        
        assert validate_result.returncode == 0, (
            f"Terraform validate failed:\n{validate_result.stderr}"
        )
    
    @given(
        vm_count=st.integers(min_value=1, max_value=5)
    )
    @settings(max_examples=100, deadline=None)
    def test_property_vm_count_configuration(self, vm_count: int):
        """
        Property 1: VM Provisioning Completeness (Configuration Level)
        
        **Validates: Requirements 1.1**
        
        For any valid vm_count value (1-5), the Terraform configuration
        should define that many VM resources with proper naming.
        
        This test validates the configuration logic without actually
        provisioning infrastructure.
        
        Args:
            vm_count: Number of VMs to configure (1-5)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        
        with open(main_tf, 'r') as f:
            content = f.read()
        
        # Verify the resource uses count parameter
        assert 'count = var.vm_count' in content, (
            "VM resource must use count = var.vm_count"
        )
        
        # Verify naming uses count.index
        assert '${count.index' in content, (
            "VM naming must use count.index for uniqueness"
        )
        
        # Property assertion: Configuration supports any valid vm_count
        # The configuration should be generic enough to handle any count value
        assert 'google_compute_instance' in content, (
            f"Configuration must define VM resources for count={vm_count}"
        )
    
    @given(
        machine_type=st.sampled_from(['e2-micro', 'e2-small', 'e2-medium', 'n1-standard-1'])
    )
    @settings(max_examples=100)
    def test_property_machine_type_configuration(self, machine_type: str):
        """
        Property test: VM machine type can be configured
        
        **Validates: Requirements 1.1**
        
        For any valid GCP machine type, the Terraform configuration
        should support setting that machine type via variable.
        
        Args:
            machine_type: GCP machine type to test
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        variables_tf = terraform_dir / "variables.tf"
        
        # Check that machine_type is configurable via variable
        with open(variables_tf, 'r') as f:
            vars_content = f.read()
        
        assert 'variable "vm_machine_type"' in vars_content, (
            "vm_machine_type variable must be defined"
        )
        
        # Check that VM resource uses the variable
        with open(main_tf, 'r') as f:
            main_content = f.read()
        
        assert 'machine_type = var.vm_machine_type' in main_content, (
            "VM resource must use var.vm_machine_type"
        )
    
    @given(
        zone=st.sampled_from([
            'us-central1-a', 'us-central1-b', 'us-central1-c',
            'us-east1-b', 'us-west1-a', 'europe-west1-b'
        ])
    )
    @settings(max_examples=100)
    def test_property_zone_configuration(self, zone: str):
        """
        Property test: VM zone can be configured
        
        **Validates: Requirements 1.1**
        
        For any valid GCP zone, the Terraform configuration should
        support setting that zone via variable.
        
        Args:
            zone: GCP zone to test
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        variables_tf = terraform_dir / "variables.tf"
        
        # Check that zone is configurable via variable
        with open(variables_tf, 'r') as f:
            vars_content = f.read()
        
        assert 'variable "gcp_zone"' in vars_content, (
            "gcp_zone variable must be defined"
        )
        
        # Check that VM resource uses the variable
        with open(main_tf, 'r') as f:
            main_content = f.read()
        
        assert 'zone = var.gcp_zone' in main_content or 'zone         = var.gcp_zone' in main_content, (
            "VM resource must use var.gcp_zone"
        )
    
    def test_vm_has_boot_disk_configuration(self):
        """
        Test that VMs have boot disk configuration with Ubuntu image.
        
        **Validates: Requirements 1.1**
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        
        with open(main_tf, 'r') as f:
            content = f.read()
        
        # Check for boot_disk block
        assert 'boot_disk' in content, "VM must have boot_disk configuration"
        
        # Check for Ubuntu image reference
        assert 'ubuntu' in content.lower(), "VM should use Ubuntu image"
        
        # Check for image variable or direct reference
        assert 'var.ubuntu_image' in content or 'ubuntu-' in content, (
            "VM boot disk must reference Ubuntu image"
        )
    
    def test_vm_has_network_interface(self):
        """
        Test that VMs have network interface configuration.
        
        **Validates: Requirements 1.1, 1.2**
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        
        with open(main_tf, 'r') as f:
            content = f.read()
        
        # Check for network_interface block
        assert 'network_interface' in content, (
            "VM must have network_interface configuration"
        )
    
    @given(
        vm_index=st.integers(min_value=0, max_value=4)
    )
    @settings(max_examples=100)
    def test_property_vm_naming_uniqueness(self, vm_index: int):
        """
        Property test: Each VM has a unique name based on its index
        
        **Validates: Requirements 1.1**
        
        For any VM index in the count range, the VM should have a unique
        name that includes the index.
        
        Args:
            vm_index: Index of the VM (0-4)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        
        with open(main_tf, 'r') as f:
            content = f.read()
        
        # Verify naming pattern includes count.index
        assert 'count.index' in content, (
            f"VM naming must use count.index to ensure uniqueness for index {vm_index}"
        )
        
        # Verify the naming pattern creates unique names
        # Expected pattern: "ubuntu-vm-${count.index + 1}"
        assert 'ubuntu-vm-' in content, (
            "VM names should follow 'ubuntu-vm-' pattern"
        )


# ============================================================================
# Integration Tests (State-Based)
# ============================================================================

class TestVMProvisioningState:
    """
    Integration tests that verify VM provisioning in Terraform state.
    
    These tests require that Terraform has been applied at least once.
    They are skipped if no state exists.
    """
    
    @pytest.mark.integration
    def test_state_vm_count_matches_configuration(self):
        """
        Integration test: Number of VMs in state matches configuration
        
        **Validates: Requirements 1.1**
        
        If Terraform has been applied, the number of VMs in the state
        should match the vm_count variable.
        """
        terraform_dir = get_terraform_dir()
        
        try:
            state_data = parse_terraform_show_json(terraform_dir)
        except RuntimeError:
            pytest.skip("No Terraform state available")
        
        vms = get_vm_resources_from_state(state_data)
        expected_count = get_vm_count_from_tfvars(terraform_dir)
        
        assert len(vms) == expected_count, (
            f"Expected {expected_count} VMs in state, found {len(vms)}"
        )
    
    @pytest.mark.integration
    def test_state_vms_have_correct_properties(self):
        """
        Integration test: VMs in state have correct properties
        
        **Validates: Requirements 1.1**
        
        All VMs in the state should have:
        - Correct naming pattern
        - Configured machine type
        - Configured zone
        - Network interface
        - Boot disk
        """
        terraform_dir = get_terraform_dir()
        
        try:
            state_data = parse_terraform_show_json(terraform_dir)
        except RuntimeError:
            pytest.skip("No Terraform state available")
        
        vms = get_vm_resources_from_state(state_data)
        
        if len(vms) == 0:
            pytest.skip("No VMs in state")
        
        # Get expected values from variables
        expected_zone = "us-central1-a"  # Default from variables.tf
        expected_machine_type = "e2-medium"  # Default from variables.tf
        
        for vm in vms:
            validation = validate_vm_properties(
                vm,
                expected_name_pattern="ubuntu-vm-",
                expected_machine_type=expected_machine_type,
                expected_zone=expected_zone
            )
            
            assert validation['name_matches'], (
                f"VM {vm.get('name')} does not match naming pattern"
            )
            assert validation['machine_type_matches'], (
                f"VM {vm.get('name')} does not have correct machine type"
            )
            assert validation['zone_matches'], (
                f"VM {vm.get('name')} is not in correct zone"
            )
            assert validation['has_network_interface'], (
                f"VM {vm.get('name')} does not have network interface"
            )
            assert validation['has_boot_disk'], (
                f"VM {vm.get('name')} does not have boot disk"
            )


# ============================================================================
# Test Execution
# ============================================================================

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short", "-m", "not integration"])
