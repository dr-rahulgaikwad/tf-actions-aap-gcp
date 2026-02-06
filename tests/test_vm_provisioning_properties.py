"""
Property-Based Tests for VM Provisioning

This module tests Properties 1-4 for VM provisioning:
- Property 1: VM Provisioning Completeness
- Property 2: Network Configuration Consistency
- Property 3: Output Data Completeness
- Property 4: Resource Labeling Consistency

**Validates: Requirements 1.1, 1.2, 1.3, 1.5**
"""

import json
import subprocess
import re
from pathlib import Path
from typing import Dict, List, Any, Optional
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


def parse_terraform_file(file_path: Path) -> str:
    """
    Read and return the content of a Terraform file.
    
    Args:
        file_path: Path to the Terraform file
        
    Returns:
        File content as string
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()


def extract_resource_block(content: str, resource_type: str, resource_name: str) -> Optional[str]:
    """
    Extract a specific resource block from Terraform content.
    
    Args:
        content: Terraform file content
        resource_type: Type of resource (e.g., "google_compute_instance")
        resource_name: Name of the resource (e.g., "ubuntu_vms")
        
    Returns:
        Resource block content or None if not found
    """
    pattern = rf'resource\s+"{resource_type}"\s+"{resource_name}"\s*\{{([^}}]*(?:\{{[^}}]*\}}[^}}]*)*)\}}'
    match = re.search(pattern, content, re.DOTALL)
    
    if match:
        return match.group(0)
    return None


def extract_output_block(content: str, output_name: str) -> Optional[str]:
    """
    Extract a specific output block from Terraform content.
    
    Args:
        content: Terraform file content
        output_name: Name of the output (e.g., "vm_instance_ids")
        
    Returns:
        Output block content or None if not found
    """
    pattern = rf'output\s+"{output_name}"\s*\{{([^}}]*)\}}'
    match = re.search(pattern, content, re.DOTALL)
    
    if match:
        return match.group(0)
    return None


def check_property_in_block(block: str, property_name: str) -> bool:
    """
    Check if a property is defined in a Terraform block.
    
    Args:
        block: Terraform block content
        property_name: Property to check for (e.g., "machine_type")
        
    Returns:
        True if property is defined in the block
    """
    pattern = rf'{property_name}\s*='
    return bool(re.search(pattern, block))


def extract_labels_from_block(block: str) -> Dict[str, str]:
    """
    Extract labels from a Terraform resource block.
    
    Args:
        block: Terraform resource block content
        
    Returns:
        Dictionary of label key-value pairs
    """
    labels = {}
    
    # Find the labels block
    labels_pattern = r'labels\s*=\s*\{([^}]*)\}'
    match = re.search(labels_pattern, block, re.DOTALL)
    
    if match:
        labels_content = match.group(1)
        
        # Extract individual label assignments
        label_pattern = r'(\w+)\s*=\s*(?:var\.(\w+)|"([^"]+)")'
        for label_match in re.finditer(label_pattern, labels_content):
            key = label_match.group(1)
            var_ref = label_match.group(2)
            value = label_match.group(3)
            
            if var_ref:
                labels[key] = f"var.{var_ref}"
            elif value:
                labels[key] = value
    
    return labels


def count_network_interfaces_in_block(block: str) -> int:
    """
    Count the number of network_interface blocks in a resource.
    
    Args:
        block: Terraform resource block content
        
    Returns:
        Number of network_interface blocks
    """
    pattern = r'network_interface\s*\{'
    matches = re.findall(pattern, block)
    return len(matches)


def check_network_interface_properties(block: str) -> Dict[str, bool]:
    """
    Check properties of network_interface block.
    
    Args:
        block: Terraform resource block content
        
    Returns:
        Dictionary with boolean flags for various properties
    """
    # Extract network_interface block
    ni_pattern = r'network_interface\s*\{([^}]*(?:\{[^}]*\}[^}]*)*)\}'
    ni_match = re.search(ni_pattern, block, re.DOTALL)
    
    if not ni_match:
        return {
            'has_network_interface': False,
            'has_network': False,
            'has_access_config': False
        }
    
    ni_content = ni_match.group(1)
    
    return {
        'has_network_interface': True,
        'has_network': bool(re.search(r'network\s*=', ni_content)),
        'has_access_config': bool(re.search(r'access_config\s*\{', ni_content))
    }


def extract_output_value_expression(block: str) -> Optional[str]:
    """
    Extract the value expression from an output block.
    
    Args:
        block: Terraform output block content
        
    Returns:
        Value expression or None if not found
    """
    pattern = r'value\s*=\s*(.+?)(?:\n|$)'
    match = re.search(pattern, block)
    
    if match:
        return match.group(1).strip()
    return None


# ============================================================================
# Property 1: VM Provisioning Completeness Tests
# ============================================================================

class TestProperty1_VMProvisioningCompleteness:
    """
    Test suite for Property 1: VM Provisioning Completeness
    
    **Validates: Requirements 1.1**
    
    Property 1 states: For any valid Terraform configuration with VM specifications,
    applying the configuration should result in all specified VMs being created in GCP
    with matching names, machine types, and zones.
    """

    
    def test_vm_resource_exists(self):
        """
        Test that google_compute_instance resource is defined.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        assert 'resource "google_compute_instance"' in content, (
            "google_compute_instance resource must be defined"
        )
    
    def test_vm_uses_count_parameter(self):
        """
        Test that VM resource uses count parameter for multiple instances.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        assert 'count = var.vm_count' in vm_block, (
            "VM resource must use count = var.vm_count"
        )
    
    @given(
        vm_count=st.integers(min_value=1, max_value=10)
    )
    @settings(max_examples=100, deadline=None)
    def test_property1_vm_count_configuration(self, vm_count: int):
        """
        Property 1: VM Provisioning Completeness
        
        **Validates: Requirements 1.1**
        
        For any valid vm_count value (1-10), the Terraform configuration
        should define VM resources with proper count-based naming.
        
        Args:
            vm_count: Number of VMs to configure (1-10)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        # Verify count parameter exists
        assert 'count = var.vm_count' in vm_block, (
            f"VM resource must use count parameter for vm_count={vm_count}"
        )
        
        # Verify naming uses count.index for uniqueness
        assert 'count.index' in vm_block, (
            f"VM naming must use count.index for uniqueness with vm_count={vm_count}"
        )

    
    @given(
        machine_type=st.sampled_from(['e2-micro', 'e2-small', 'e2-medium', 'n1-standard-1', 'n2-standard-2'])
    )
    @settings(max_examples=100)
    def test_property1_machine_type_configurable(self, machine_type: str):
        """
        Property 1: VM machine type is configurable
        
        **Validates: Requirements 1.1**
        
        For any valid GCP machine type, the configuration should support
        setting that machine type via variable.
        
        Args:
            machine_type: GCP machine type to test
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        variables_tf = terraform_dir / "variables.tf"
        
        main_content = parse_terraform_file(main_tf)
        vars_content = parse_terraform_file(variables_tf)
        
        # Verify variable exists
        assert 'variable "vm_machine_type"' in vars_content, (
            "vm_machine_type variable must be defined"
        )
        
        # Verify VM resource uses the variable
        vm_block = extract_resource_block(main_content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        assert 'machine_type = var.vm_machine_type' in vm_block, (
            f"VM resource must use var.vm_machine_type for machine_type={machine_type}"
        )
    
    @given(
        zone=st.sampled_from([
            'us-central1-a', 'us-central1-b', 'us-central1-c',
            'us-east1-b', 'us-west1-a', 'europe-west1-b', 'asia-east1-a'
        ])
    )
    @settings(max_examples=100)
    def test_property1_zone_configurable(self, zone: str):
        """
        Property 1: VM zone is configurable
        
        **Validates: Requirements 1.1**
        
        For any valid GCP zone, the configuration should support
        setting that zone via variable.
        
        Args:
            zone: GCP zone to test
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        variables_tf = terraform_dir / "variables.tf"
        
        main_content = parse_terraform_file(main_tf)
        vars_content = parse_terraform_file(variables_tf)
        
        # Verify variable exists
        assert 'variable "gcp_zone"' in vars_content, (
            "gcp_zone variable must be defined"
        )
        
        # Verify VM resource uses the variable
        vm_block = extract_resource_block(main_content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        assert 'zone = var.gcp_zone' in vm_block or 'zone         = var.gcp_zone' in vm_block, (
            f"VM resource must use var.gcp_zone for zone={zone}"
        )

    
    def test_property1_vm_has_required_properties(self):
        """
        Property 1: VM resource has all required properties
        
        **Validates: Requirements 1.1**
        
        VM resources must have: name, machine_type, zone, boot_disk, network_interface
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        required_properties = ['name', 'machine_type', 'zone', 'boot_disk', 'network_interface']
        
        for prop in required_properties:
            assert check_property_in_block(vm_block, prop), (
                f"VM resource must define '{prop}' property"
            )
    
    def test_property1_vm_boot_disk_has_ubuntu_image(self):
        """
        Property 1: VM boot disk uses Ubuntu image
        
        **Validates: Requirements 1.1**
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        # Check for boot_disk configuration
        assert 'boot_disk' in vm_block, "VM must have boot_disk configuration"
        
        # Check for Ubuntu image reference
        assert 'ubuntu' in vm_block.lower() or 'var.ubuntu_image' in vm_block, (
            "VM boot disk must reference Ubuntu image"
        )


# ============================================================================
# Property 2: Network Configuration Consistency Tests
# ============================================================================

class TestProperty2_NetworkConfigurationConsistency:
    """
    Test suite for Property 2: Network Configuration Consistency
    
    **Validates: Requirements 1.2**
    
    Property 2 states: For any provisioned VM, the VM should have exactly one 
    network interface with a valid internal IP address and network configuration.
    """
    
    def test_vm_has_network_interface(self):
        """
        Test that VM resource has network_interface block.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        assert 'network_interface' in vm_block, (
            "VM must have network_interface configuration"
        )

    
    @given(
        vm_index=st.integers(min_value=0, max_value=9)
    )
    @settings(max_examples=100)
    def test_property2_single_network_interface(self, vm_index: int):
        """
        Property 2: Network Configuration Consistency
        
        **Validates: Requirements 1.2**
        
        For any VM (identified by index), the VM should have exactly one
        network interface configured.
        
        Args:
            vm_index: Index of the VM (0-9)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        # Count network_interface blocks
        ni_count = count_network_interfaces_in_block(vm_block)
        
        assert ni_count == 1, (
            f"VM at index {vm_index} must have exactly 1 network interface, found {ni_count}"
        )
    
    @given(
        vm_index=st.integers(min_value=0, max_value=9)
    )
    @settings(max_examples=100)
    def test_property2_network_interface_has_network(self, vm_index: int):
        """
        Property 2: Network interface has network configuration
        
        **Validates: Requirements 1.2**
        
        For any VM, the network interface must specify a network.
        
        Args:
            vm_index: Index of the VM (0-9)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        ni_props = check_network_interface_properties(vm_block)
        
        assert ni_props['has_network_interface'], (
            f"VM at index {vm_index} must have network_interface block"
        )
        assert ni_props['has_network'], (
            f"VM at index {vm_index} network_interface must specify network"
        )
    
    @given(
        vm_index=st.integers(min_value=0, max_value=9)
    )
    @settings(max_examples=100)
    def test_property2_network_interface_has_access_config(self, vm_index: int):
        """
        Property 2: Network interface has access_config for external IP
        
        **Validates: Requirements 1.2**
        
        For any VM, the network interface should have access_config
        to enable external IP assignment.
        
        Args:
            vm_index: Index of the VM (0-9)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        ni_props = check_network_interface_properties(vm_block)
        
        assert ni_props['has_access_config'], (
            f"VM at index {vm_index} network_interface must have access_config for external IP"
        )

    
    def test_property2_firewall_rule_exists(self):
        """
        Property 2: Firewall rule for SSH access exists
        
        **Validates: Requirements 1.2**
        
        The configuration should include a firewall rule for SSH access.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        assert 'resource "google_compute_firewall"' in content, (
            "Firewall rule resource must be defined"
        )
        
        # Check for SSH port configuration
        assert '"22"' in content or '22' in content, (
            "Firewall rule must allow SSH port 22"
        )


# ============================================================================
# Property 3: Output Data Completeness Tests
# ============================================================================

class TestProperty3_OutputDataCompleteness:
    """
    Test suite for Property 3: Output Data Completeness
    
    **Validates: Requirements 1.3**
    
    Property 3 states: For any successful Terraform apply operation, the outputs 
    should contain lists of instance IDs, internal IPs, and external IPs with 
    lengths matching the number of provisioned VMs.
    """
    
    def test_required_outputs_exist(self):
        """
        Test that all required outputs are defined.
        """
        terraform_dir = get_terraform_dir()
        outputs_tf = terraform_dir / "outputs.tf"
        content = parse_terraform_file(outputs_tf)
        
        required_outputs = [
            'vm_instance_ids',
            'vm_internal_ips',
            'vm_external_ips',
            'vm_names'
        ]
        
        for output_name in required_outputs:
            assert f'output "{output_name}"' in content, (
                f"Output '{output_name}' must be defined"
            )
    
    @given(
        output_name=st.sampled_from(['vm_instance_ids', 'vm_internal_ips', 'vm_external_ips', 'vm_names'])
    )
    @settings(max_examples=100)
    def test_property3_output_uses_splat_syntax(self, output_name: str):
        """
        Property 3: Output Data Completeness
        
        **Validates: Requirements 1.3**
        
        For any output (instance IDs, IPs, names), the output should use
        splat syntax to collect values from all VMs.
        
        Args:
            output_name: Name of the output to test
        """
        terraform_dir = get_terraform_dir()
        outputs_tf = terraform_dir / "outputs.tf"
        content = parse_terraform_file(outputs_tf)
        
        output_block = extract_output_block(content, output_name)
        assert output_block is not None, f"Output '{output_name}' not found"
        
        # Verify output uses splat syntax [*]
        assert '[*]' in output_block, (
            f"Output '{output_name}' must use splat syntax [*] to collect all VM values"
        )

    
    @given(
        vm_count=st.integers(min_value=1, max_value=10)
    )
    @settings(max_examples=100)
    def test_property3_output_length_matches_vm_count(self, vm_count: int):
        """
        Property 3: Output list length matches VM count
        
        **Validates: Requirements 1.3**
        
        For any vm_count value, the output expressions should be structured
        to return lists with length equal to vm_count.
        
        This test verifies the configuration structure, not runtime values.
        
        Args:
            vm_count: Number of VMs (1-10)
        """
        terraform_dir = get_terraform_dir()
        outputs_tf = terraform_dir / "outputs.tf"
        content = parse_terraform_file(outputs_tf)
        
        # All VM-related outputs should reference the ubuntu_vms resource with splat
        required_outputs = ['vm_instance_ids', 'vm_internal_ips', 'vm_external_ips', 'vm_names']
        
        for output_name in required_outputs:
            output_block = extract_output_block(content, output_name)
            assert output_block is not None, f"Output '{output_name}' not found"
            
            # Verify it references ubuntu_vms with splat syntax
            assert 'google_compute_instance.ubuntu_vms[*]' in output_block, (
                f"Output '{output_name}' must reference ubuntu_vms[*] for vm_count={vm_count}"
            )
    
    def test_property3_instance_ids_output_structure(self):
        """
        Property 3: Instance IDs output has correct structure
        
        **Validates: Requirements 1.3**
        """
        terraform_dir = get_terraform_dir()
        outputs_tf = terraform_dir / "outputs.tf"
        content = parse_terraform_file(outputs_tf)
        
        output_block = extract_output_block(content, 'vm_instance_ids')
        assert output_block is not None, "vm_instance_ids output not found"
        
        # Should reference instance_id attribute
        assert 'instance_id' in output_block, (
            "vm_instance_ids must reference instance_id attribute"
        )
    
    def test_property3_internal_ips_output_structure(self):
        """
        Property 3: Internal IPs output has correct structure
        
        **Validates: Requirements 1.3**
        """
        terraform_dir = get_terraform_dir()
        outputs_tf = terraform_dir / "outputs.tf"
        content = parse_terraform_file(outputs_tf)
        
        output_block = extract_output_block(content, 'vm_internal_ips')
        assert output_block is not None, "vm_internal_ips output not found"
        
        # Should reference network_interface[0].network_ip
        assert 'network_interface[0].network_ip' in output_block, (
            "vm_internal_ips must reference network_interface[0].network_ip"
        )
    
    def test_property3_external_ips_output_structure(self):
        """
        Property 3: External IPs output has correct structure
        
        **Validates: Requirements 1.3**
        """
        terraform_dir = get_terraform_dir()
        outputs_tf = terraform_dir / "outputs.tf"
        content = parse_terraform_file(outputs_tf)
        
        output_block = extract_output_block(content, 'vm_external_ips')
        assert output_block is not None, "vm_external_ips output not found"
        
        # Should reference network_interface[0].access_config[0].nat_ip
        assert 'access_config[0].nat_ip' in output_block, (
            "vm_external_ips must reference access_config[0].nat_ip"
        )

    
    def test_property3_vm_names_output_structure(self):
        """
        Property 3: VM names output has correct structure
        
        **Validates: Requirements 1.3**
        """
        terraform_dir = get_terraform_dir()
        outputs_tf = terraform_dir / "outputs.tf"
        content = parse_terraform_file(outputs_tf)
        
        output_block = extract_output_block(content, 'vm_names')
        assert output_block is not None, "vm_names output not found"
        
        # Should reference name attribute
        assert '.name' in output_block, (
            "vm_names must reference name attribute"
        )


# ============================================================================
# Property 4: Resource Labeling Consistency Tests
# ============================================================================

class TestProperty4_ResourceLabelingConsistency:
    """
    Test suite for Property 4: Resource Labeling Consistency
    
    **Validates: Requirements 1.5**
    
    Property 4 states: For any provisioned VM, the VM should have all required 
    labels (environment, managed_by, os) with non-empty values.
    """
    
    def test_vm_has_labels_block(self):
        """
        Test that VM resource has labels block.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        assert 'labels' in vm_block, (
            "VM resource must have labels block"
        )
    
    @given(
        label_name=st.sampled_from(['environment', 'managed_by', 'os'])
    )
    @settings(max_examples=100)
    def test_property4_required_labels_exist(self, label_name: str):
        """
        Property 4: Resource Labeling Consistency
        
        **Validates: Requirements 1.5**
        
        For any required label (environment, managed_by, os), the VM resource
        should define that label with a non-empty value.
        
        Args:
            label_name: Name of the required label
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        labels = extract_labels_from_block(vm_block)
        
        assert label_name in labels, (
            f"VM resource must have '{label_name}' label"
        )
        
        # Verify label has a value (either variable reference or literal)
        label_value = labels[label_name]
        assert label_value, (
            f"Label '{label_name}' must have a non-empty value"
        )

    
    @given(
        vm_index=st.integers(min_value=0, max_value=9)
    )
    @settings(max_examples=100)
    def test_property4_all_labels_present(self, vm_index: int):
        """
        Property 4: All required labels are present
        
        **Validates: Requirements 1.5**
        
        For any VM (identified by index), all three required labels
        (environment, managed_by, os) must be present.
        
        Args:
            vm_index: Index of the VM (0-9)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        labels = extract_labels_from_block(vm_block)
        required_labels = ['environment', 'managed_by', 'os']
        
        for label in required_labels:
            assert label in labels, (
                f"VM at index {vm_index} must have '{label}' label"
            )
    
    def test_property4_environment_label_uses_variable(self):
        """
        Property 4: Environment label uses variable for flexibility
        
        **Validates: Requirements 1.5**
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        variables_tf = terraform_dir / "variables.tf"
        
        main_content = parse_terraform_file(main_tf)
        vars_content = parse_terraform_file(variables_tf)
        
        # Verify environment variable exists
        assert 'variable "environment"' in vars_content, (
            "environment variable must be defined"
        )
        
        # Verify VM labels use the variable
        vm_block = extract_resource_block(main_content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        labels = extract_labels_from_block(vm_block)
        assert 'environment' in labels, "environment label must be present"
        assert 'var.environment' in labels['environment'], (
            "environment label should use var.environment"
        )
    
    def test_property4_managed_by_label_uses_variable(self):
        """
        Property 4: Managed_by label uses variable
        
        **Validates: Requirements 1.5**
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        variables_tf = terraform_dir / "variables.tf"
        
        main_content = parse_terraform_file(main_tf)
        vars_content = parse_terraform_file(variables_tf)
        
        # Verify managed_by variable exists
        assert 'variable "managed_by"' in vars_content, (
            "managed_by variable must be defined"
        )
        
        # Verify VM labels use the variable
        vm_block = extract_resource_block(main_content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        labels = extract_labels_from_block(vm_block)
        assert 'managed_by' in labels, "managed_by label must be present"
        assert 'var.managed_by' in labels['managed_by'], (
            "managed_by label should use var.managed_by"
        )

    
    def test_property4_os_label_value(self):
        """
        Property 4: OS label has correct value for Ubuntu
        
        **Validates: Requirements 1.5**
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        vm_block = extract_resource_block(content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "ubuntu_vms resource not found"
        
        labels = extract_labels_from_block(vm_block)
        assert 'os' in labels, "os label must be present"
        
        # OS label should be "ubuntu" for Ubuntu VMs
        assert 'ubuntu' in labels['os'].lower(), (
            "os label should indicate Ubuntu operating system"
        )


# ============================================================================
# Integration Tests - Cross-Property Validation
# ============================================================================

class TestCrossPropertyValidation:
    """
    Integration tests that validate multiple properties together.
    """
    
    @given(
        vm_count=st.integers(min_value=1, max_value=10)
    )
    @settings(max_examples=50)
    def test_integration_vm_configuration_completeness(self, vm_count: int):
        """
        Integration test: Complete VM configuration validation
        
        Validates Properties 1, 2, 3, and 4 together for any vm_count.
        
        Args:
            vm_count: Number of VMs (1-10)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        outputs_tf = terraform_dir / "outputs.tf"
        
        main_content = parse_terraform_file(main_tf)
        outputs_content = parse_terraform_file(outputs_tf)
        
        # Property 1: VM provisioning completeness
        vm_block = extract_resource_block(main_content, "google_compute_instance", "ubuntu_vms")
        assert vm_block is not None, "VM resource must exist"
        assert 'count = var.vm_count' in vm_block, "Must use count parameter"
        
        # Property 2: Network configuration
        ni_props = check_network_interface_properties(vm_block)
        assert ni_props['has_network_interface'], "Must have network interface"
        assert ni_props['has_network'], "Must specify network"
        
        # Property 3: Output completeness
        for output_name in ['vm_instance_ids', 'vm_internal_ips', 'vm_external_ips']:
            output_block = extract_output_block(outputs_content, output_name)
            assert output_block is not None, f"Output {output_name} must exist"
            assert '[*]' in output_block, f"Output {output_name} must use splat syntax"
        
        # Property 4: Resource labeling
        labels = extract_labels_from_block(vm_block)
        required_labels = ['environment', 'managed_by', 'os']
        for label in required_labels:
            assert label in labels, f"Label {label} must be present"


# ============================================================================
# Test Execution
# ============================================================================

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
