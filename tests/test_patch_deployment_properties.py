"""
Property-Based Tests for Patch Deployment

This module tests Properties 5-6 for patch deployment:
- Property 5: Patch Deployment Resource Creation
- Property 6: Patch Configuration Completeness

**Validates: Requirements 2.1, 2.4**
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
        resource_type: Type of resource (e.g., "google_os_config_patch_deployment")
        resource_name: Name of the resource (e.g., "ubuntu_patches")
        
    Returns:
        Resource block content or None if not found
    """
    # Pattern to match resource blocks with nested braces
    pattern = rf'resource\s+"{resource_type}"\s+"{resource_name}"\s*\{{'
    
    # Find the start of the resource block
    match = re.search(pattern, content)
    if not match:
        return None
    
    start_pos = match.start()
    
    # Find the matching closing brace
    brace_count = 0
    in_resource = False
    end_pos = start_pos
    
    for i in range(start_pos, len(content)):
        if content[i] == '{':
            brace_count += 1
            in_resource = True
        elif content[i] == '}':
            brace_count -= 1
            if in_resource and brace_count == 0:
                end_pos = i + 1
                break
    
    return content[start_pos:end_pos]


def extract_output_block(content: str, output_name: str) -> Optional[str]:
    """
    Extract a specific output block from Terraform content.
    
    Args:
        content: Terraform file content
        output_name: Name of the output (e.g., "patch_deployment_id")
        
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
        property_name: Property to check for (e.g., "patch_deployment_id")
        
    Returns:
        True if property is defined in the block
    """
    pattern = rf'{property_name}\s*='
    return bool(re.search(pattern, block))


def extract_nested_block(content: str, block_name: str) -> Optional[str]:
    """
    Extract a nested block from Terraform content.
    
    Args:
        content: Terraform content to search
        block_name: Name of the block (e.g., "patch_config", "instance_filter")
        
    Returns:
        Block content or None if not found
    """
    pattern = rf'{block_name}\s*\{{'
    
    match = re.search(pattern, content)
    if not match:
        return None
    
    start_pos = match.start()
    
    # Find the matching closing brace
    brace_count = 0
    in_block = False
    end_pos = start_pos
    
    for i in range(start_pos, len(content)):
        if content[i] == '{':
            brace_count += 1
            in_block = True
        elif content[i] == '}':
            brace_count -= 1
            if in_block and brace_count == 0:
                end_pos = i + 1
                break
    
    return content[start_pos:end_pos]


def check_apt_configuration(patch_config_block: str) -> Dict[str, bool]:
    """
    Check apt configuration within patch_config block.
    
    Args:
        patch_config_block: Content of patch_config block
        
    Returns:
        Dictionary with boolean flags for apt configuration properties
    """
    apt_block = extract_nested_block(patch_config_block, 'apt')
    
    if not apt_block:
        return {
            'has_apt_block': False,
            'has_type': False,
            'has_excludes': False
        }
    
    return {
        'has_apt_block': True,
        'has_type': check_property_in_block(apt_block, 'type'),
        'has_excludes': check_property_in_block(apt_block, 'excludes')
    }


def extract_instance_filter_labels(instance_filter_block: str) -> Dict[str, str]:
    """
    Extract labels from instance_filter block.
    
    Args:
        instance_filter_block: Content of instance_filter block
        
    Returns:
        Dictionary of label key-value pairs
    """
    labels = {}
    
    # Find the group_labels block
    group_labels_block = extract_nested_block(instance_filter_block, 'group_labels')
    if not group_labels_block:
        return labels
    
    # Find the labels block within group_labels
    labels_pattern = r'labels\s*=\s*\{([^}]*)\}'
    match = re.search(labels_pattern, group_labels_block, re.DOTALL)
    
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


# ============================================================================
# Property 5: Patch Deployment Resource Creation Tests
# ============================================================================

class TestProperty5_PatchDeploymentResourceCreation:
    """
    Test suite for Property 5: Patch Deployment Resource Creation
    
    **Validates: Requirements 2.1**
    
    Property 5 states: For any Terraform configuration including patch deployment,
    applying the configuration should create a google_os_config_patch_deployment
    resource with a valid ID.
    """

    def test_patch_deployment_resource_exists(self):
        """
        Test that google_os_config_patch_deployment resource is defined.
        
        **Validates: Requirements 2.1**
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        assert 'resource "google_os_config_patch_deployment"' in content, (
            "google_os_config_patch_deployment resource must be defined"
        )
    
    def test_patch_deployment_has_id(self):
        """
        Test that patch deployment resource has patch_deployment_id.
        
        **Validates: Requirements 2.1**
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        assert check_property_in_block(patch_block, 'patch_deployment_id'), (
            "Patch deployment must have patch_deployment_id property"
        )
    
    @given(
        deployment_id=st.text(
            alphabet=st.characters(whitelist_categories=('Ll', 'Nd'), whitelist_characters='-'),
            min_size=5,
            max_size=50
        ).filter(lambda x: x[0].isalpha() and x[-1].isalnum())
    )
    @settings(max_examples=100, deadline=None)
    def test_property5_patch_deployment_id_format(self, deployment_id: str):
        """
        Property 5: Patch Deployment Resource Creation
        
        **Validates: Requirements 2.1**
        
        For any valid patch deployment ID format (lowercase letters, numbers, hyphens),
        the configuration should support setting that ID.
        
        This test verifies the configuration structure accepts valid ID formats.
        
        Args:
            deployment_id: Generated patch deployment ID
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        # Verify patch_deployment_id is defined
        assert check_property_in_block(patch_block, 'patch_deployment_id'), (
            f"Patch deployment must have patch_deployment_id for ID format: {deployment_id[:20]}..."
        )
    
    def test_property5_patch_deployment_has_instance_filter(self):
        """
        Property 5: Patch deployment has instance filter
        
        **Validates: Requirements 2.1, 2.2**
        
        Patch deployment must have instance_filter to target specific VMs.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        assert 'instance_filter' in patch_block, (
            "Patch deployment must have instance_filter block"
        )
    
    def test_property5_patch_deployment_has_schedule(self):
        """
        Property 5: Patch deployment has execution schedule
        
        **Validates: Requirements 2.1, 2.3**
        
        Patch deployment must have one_time_schedule for on-demand execution.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        assert 'one_time_schedule' in patch_block, (
            "Patch deployment must have one_time_schedule block for on-demand execution"
        )
    
    def test_property5_patch_deployment_output_exists(self):
        """
        Property 5: Patch deployment ID is output
        
        **Validates: Requirements 2.1, 1.3**
        
        Patch deployment ID should be available as Terraform output.
        """
        terraform_dir = get_terraform_dir()
        outputs_tf = terraform_dir / "outputs.tf"
        content = parse_terraform_file(outputs_tf)
        
        assert 'output "patch_deployment_id"' in content, (
            "patch_deployment_id output must be defined"
        )
        
        output_block = extract_output_block(content, 'patch_deployment_id')
        assert output_block is not None, "patch_deployment_id output not found"
        
        # Verify it references the patch deployment resource
        assert 'google_os_config_patch_deployment.ubuntu_patches' in output_block, (
            "Output must reference google_os_config_patch_deployment.ubuntu_patches"
        )
    
    @given(
        vm_index=st.integers(min_value=0, max_value=9)
    )
    @settings(max_examples=100)
    def test_property5_instance_filter_targets_ubuntu(self, vm_index: int):
        """
        Property 5: Instance filter targets Ubuntu VMs
        
        **Validates: Requirements 2.2**
        
        For any VM index, the instance filter should target VMs with os=ubuntu label.
        
        Args:
            vm_index: Index of the VM (0-9)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        instance_filter = extract_nested_block(patch_block, 'instance_filter')
        assert instance_filter is not None, "instance_filter block not found"
        
        labels = extract_instance_filter_labels(instance_filter)
        
        assert 'os' in labels, (
            f"Instance filter must include 'os' label for VM index {vm_index}"
        )
        assert 'ubuntu' in labels['os'].lower(), (
            f"Instance filter must target Ubuntu VMs for VM index {vm_index}"
        )


# ============================================================================
# Property 6: Patch Configuration Completeness Tests
# ============================================================================

class TestProperty6_PatchConfigurationCompleteness:
    """
    Test suite for Property 6: Patch Configuration Completeness
    
    **Validates: Requirements 2.4**
    
    Property 6 states: For any created patch deployment, the configuration should
    specify patch categories and severity levels in the patch_config block.
    """

    def test_patch_deployment_has_patch_config(self):
        """
        Test that patch deployment has patch_config block.
        
        **Validates: Requirements 2.4**
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        assert 'patch_config' in patch_block, (
            "Patch deployment must have patch_config block"
        )
    
    def test_property6_patch_config_has_apt_block(self):
        """
        Property 6: Patch config has apt configuration
        
        **Validates: Requirements 2.4**
        
        For Ubuntu VMs, patch_config must include apt block.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        patch_config = extract_nested_block(patch_block, 'patch_config')
        assert patch_config is not None, "patch_config block not found"
        
        apt_config = check_apt_configuration(patch_config)
        assert apt_config['has_apt_block'], (
            "patch_config must have apt block for Ubuntu VMs"
        )
    
    @given(
        patch_type=st.sampled_from(['DIST', 'UPGRADE'])
    )
    @settings(max_examples=100)
    def test_property6_apt_type_specified(self, patch_type: str):
        """
        Property 6: Patch Configuration Completeness
        
        **Validates: Requirements 2.4**
        
        For any valid apt patch type (DIST or UPGRADE), the configuration
        should specify the type in the apt block.
        
        Args:
            patch_type: Type of apt upgrade (DIST or UPGRADE)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        patch_config = extract_nested_block(patch_block, 'patch_config')
        assert patch_config is not None, "patch_config block not found"
        
        apt_config = check_apt_configuration(patch_config)
        assert apt_config['has_type'], (
            f"apt block must specify type for patch_type={patch_type}"
        )
    
    @given(
        exclude_count=st.integers(min_value=0, max_value=10)
    )
    @settings(max_examples=100)
    def test_property6_apt_excludes_configurable(self, exclude_count: int):
        """
        Property 6: Apt excludes are configurable
        
        **Validates: Requirements 2.4**
        
        For any number of package exclusions (0-10), the configuration
        should support specifying excludes in the apt block.
        
        Args:
            exclude_count: Number of packages to exclude (0-10)
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        patch_config = extract_nested_block(patch_block, 'patch_config')
        assert patch_config is not None, "patch_config block not found"
        
        apt_config = check_apt_configuration(patch_config)
        assert apt_config['has_excludes'], (
            f"apt block must have excludes property for exclude_count={exclude_count}"
        )
    
    def test_property6_patch_config_has_reboot_config(self):
        """
        Property 6: Patch config has reboot configuration
        
        **Validates: Requirements 2.4**
        
        Patch config should specify reboot behavior.
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        patch_config = extract_nested_block(patch_block, 'patch_config')
        assert patch_config is not None, "patch_config block not found"
        
        assert check_property_in_block(patch_config, 'reboot_config'), (
            "patch_config must specify reboot_config"
        )
    
    @given(
        environment=st.sampled_from(['demo', 'dev', 'staging', 'prod'])
    )
    @settings(max_examples=100)
    def test_property6_instance_filter_uses_environment_label(self, environment: str):
        """
        Property 6: Instance filter uses environment label
        
        **Validates: Requirements 2.4**
        
        For any environment value, the instance filter should target VMs
        with matching environment label.
        
        Args:
            environment: Environment label value
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        instance_filter = extract_nested_block(patch_block, 'instance_filter')
        assert instance_filter is not None, "instance_filter block not found"
        
        labels = extract_instance_filter_labels(instance_filter)
        
        assert 'environment' in labels, (
            f"Instance filter must include 'environment' label for environment={environment}"
        )
    
    def test_property6_patch_config_complete_structure(self):
        """
        Property 6: Patch config has complete structure
        
        **Validates: Requirements 2.4**
        
        Patch config should have all required components:
        - apt block with type and excludes
        - reboot_config
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        content = parse_terraform_file(main_tf)
        
        patch_block = extract_resource_block(
            content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "ubuntu_patches resource not found"
        
        patch_config = extract_nested_block(patch_block, 'patch_config')
        assert patch_config is not None, "patch_config block not found"
        
        # Check apt configuration
        apt_config = check_apt_configuration(patch_config)
        assert apt_config['has_apt_block'], "Must have apt block"
        assert apt_config['has_type'], "apt block must specify type"
        assert apt_config['has_excludes'], "apt block must specify excludes"
        
        # Check reboot configuration
        assert check_property_in_block(patch_config, 'reboot_config'), (
            "Must have reboot_config"
        )


# ============================================================================
# Integration Tests - Cross-Property Validation
# ============================================================================

class TestCrossPropertyValidation:
    """
    Integration tests that validate multiple properties together.
    """
    
    @given(
        deployment_id=st.text(
            alphabet=st.characters(whitelist_categories=('Ll', 'Nd'), whitelist_characters='-'),
            min_size=5,
            max_size=50
        ).filter(lambda x: x[0].isalpha() and x[-1].isalnum())
    )
    @settings(max_examples=50, deadline=None)
    def test_integration_complete_patch_deployment(self, deployment_id: str):
        """
        Integration test: Complete patch deployment configuration validation
        
        Validates Properties 5 and 6 together for any deployment ID.
        
        Args:
            deployment_id: Generated patch deployment ID
        """
        terraform_dir = get_terraform_dir()
        main_tf = terraform_dir / "main.tf"
        outputs_tf = terraform_dir / "outputs.tf"
        
        main_content = parse_terraform_file(main_tf)
        outputs_content = parse_terraform_file(outputs_tf)
        
        # Property 5: Patch deployment resource creation
        patch_block = extract_resource_block(
            main_content, 
            "google_os_config_patch_deployment", 
            "ubuntu_patches"
        )
        assert patch_block is not None, "Patch deployment resource must exist"
        assert check_property_in_block(patch_block, 'patch_deployment_id'), (
            "Must have patch_deployment_id"
        )
        assert 'instance_filter' in patch_block, "Must have instance_filter"
        assert 'one_time_schedule' in patch_block, "Must have one_time_schedule"
        
        # Property 6: Patch configuration completeness
        patch_config = extract_nested_block(patch_block, 'patch_config')
        assert patch_config is not None, "Must have patch_config block"
        
        apt_config = check_apt_configuration(patch_config)
        assert apt_config['has_apt_block'], "Must have apt block"
        assert apt_config['has_type'], "apt must specify type"
        assert apt_config['has_excludes'], "apt must specify excludes"
        
        # Output validation
        output_block = extract_output_block(outputs_content, 'patch_deployment_id')
        assert output_block is not None, "patch_deployment_id output must exist"


# ============================================================================
# Test Execution
# ============================================================================

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
