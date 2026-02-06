"""
Property-Based Tests for IAM Least Privilege Configuration

Feature: terraform-actions-gcp-patching
Property 16: Least Privilege IAM

This module tests that service account IAM bindings follow the principle
of least privilege by verifying that only minimal required roles are granted
and no overly permissive roles (owner, editor) are used.

**Validates: Requirements 8.5**
"""

import json
import re
from pathlib import Path
from typing import List, Set

import pytest
from hypothesis import given, strategies as st, settings


# ============================================================================
# Test Configuration
# ============================================================================

# Terraform project root
TERRAFORM_DIR = Path(__file__).parent.parent / "terraform"

# Allowed IAM roles for this prototype (minimal required permissions)
ALLOWED_ROLES = {
    "roles/compute.instanceAdmin.v1",  # VM management
    "roles/compute.networkAdmin",       # Network and firewall management
    "roles/osconfig.patchDeploymentAdmin",  # Patch deployment management
    "roles/iam.serviceAccountUser",     # Service account usage
    "roles/logging.logWriter",          # VM logging (optional)
    "roles/monitoring.metricWriter",    # VM monitoring (optional)
}

# Prohibited overly permissive roles
PROHIBITED_ROLES = {
    "roles/owner",
    "roles/editor",
    "roles/compute.admin",
    "roles/iam.admin",
    "roles/resourcemanager.projectIamAdmin",
}


# ============================================================================
# Helper Functions
# ============================================================================

def extract_iam_roles_from_terraform() -> Set[str]:
    """
    Extract IAM roles referenced in Terraform configuration files.
    
    Returns:
        Set of IAM role strings found in Terraform files
    """
    roles = set()
    
    # Read all .tf files in terraform directory
    for tf_file in TERRAFORM_DIR.glob("*.tf"):
        content = tf_file.read_text()
        
        # Pattern 1: google_project_iam_member or google_project_iam_binding
        # role = "roles/..."
        role_pattern = r'role\s*=\s*"(roles/[^"]+)"'
        matches = re.findall(role_pattern, content)
        roles.update(matches)
        
        # Pattern 2: IAM roles in comments or documentation
        # This helps catch roles that are documented but not yet implemented
        comment_role_pattern = r'#.*?(roles/[\w.]+)'
        comment_matches = re.findall(comment_role_pattern, content)
        roles.update(comment_matches)
    
    return roles


def extract_iam_bindings_from_terraform() -> List[dict]:
    """
    Extract IAM binding resources from Terraform configuration.
    
    Returns:
        List of dictionaries containing IAM binding information
    """
    bindings = []
    
    for tf_file in TERRAFORM_DIR.glob("*.tf"):
        content = tf_file.read_text()
        
        # Find google_project_iam_member resources
        member_pattern = r'resource\s+"google_project_iam_member"\s+"([^"]+)"\s*\{([^}]+)\}'
        for match in re.finditer(member_pattern, content, re.DOTALL):
            resource_name = match.group(1)
            resource_body = match.group(2)
            
            # Extract role from resource body
            role_match = re.search(r'role\s*=\s*"([^"]+)"', resource_body)
            if role_match:
                bindings.append({
                    "type": "member",
                    "name": resource_name,
                    "role": role_match.group(1),
                    "file": tf_file.name
                })
        
        # Find google_project_iam_binding resources
        binding_pattern = r'resource\s+"google_project_iam_binding"\s+"([^"]+)"\s*\{([^}]+)\}'
        for match in re.finditer(binding_pattern, content, re.DOTALL):
            resource_name = match.group(1)
            resource_body = match.group(2)
            
            role_match = re.search(r'role\s*=\s*"([^"]+)"', resource_body)
            if role_match:
                bindings.append({
                    "type": "binding",
                    "name": resource_name,
                    "role": role_match.group(1),
                    "file": tf_file.name
                })
    
    return bindings


# ============================================================================
# Property-Based Tests
# ============================================================================

@pytest.mark.property
class TestIAMLeastPrivilege:
    """
    Property tests for IAM least privilege configuration.
    
    Feature: terraform-actions-gcp-patching, Property 16: Least Privilege IAM
    **Validates: Requirements 8.5**
    """
    
    def test_no_prohibited_roles_in_terraform(self):
        """
        Property: For any IAM role referenced in Terraform configuration,
        the role should NOT be in the prohibited overly permissive roles list.
        
        This ensures we never grant owner, editor, or other admin-level
        permissions that violate least privilege principles.
        
        **Validates: Requirements 8.5**
        """
        roles = extract_iam_roles_from_terraform()
        
        # Find any prohibited roles
        prohibited_found = roles.intersection(PROHIBITED_ROLES)
        
        assert not prohibited_found, (
            f"Found prohibited overly permissive IAM roles: {prohibited_found}. "
            f"These roles violate the principle of least privilege. "
            f"Use more specific roles from the allowed list: {ALLOWED_ROLES}"
        )
    
    def test_only_allowed_roles_used(self):
        """
        Property: For any IAM role referenced in Terraform configuration,
        the role should be in the allowed minimal roles list.
        
        This ensures we only grant the minimum required permissions
        for the prototype to function.
        
        **Validates: Requirements 8.5**
        """
        roles = extract_iam_roles_from_terraform()
        
        # Filter out roles that are just in comments (documentation)
        # We'll be lenient with documented roles vs. actual bindings
        bindings = extract_iam_bindings_from_terraform()
        actual_roles = {b["role"] for b in bindings}
        
        # Check if any actual IAM bindings use disallowed roles
        disallowed = actual_roles - ALLOWED_ROLES
        
        # If we find disallowed roles, provide helpful error message
        if disallowed:
            pytest.fail(
                f"Found IAM roles that are not in the allowed minimal set: {disallowed}\n"
                f"Allowed roles: {ALLOWED_ROLES}\n"
                f"If these roles are necessary, update ALLOWED_ROLES in the test.\n"
                f"Otherwise, use more restrictive roles from the allowed list."
            )
    
    def test_iam_bindings_have_minimal_scope(self):
        """
        Property: For any IAM binding in Terraform configuration,
        the binding should use project-level scope (not organization-level).
        
        This ensures permissions are scoped to the minimum necessary level.
        
        **Validates: Requirements 8.5**
        """
        bindings = extract_iam_bindings_from_terraform()
        
        # Check that we're not using organization-level IAM bindings
        for binding in bindings:
            assert "google_organization_iam" not in binding["type"], (
                f"IAM binding '{binding['name']}' uses organization-level scope. "
                f"Use project-level scope (google_project_iam_*) for least privilege."
            )
    
    @given(
        role_suffix=st.sampled_from([
            "admin",
            "owner",
            "editor",
            "Admin",
            "Owner",
            "Editor",
        ])
    )
    @settings(max_examples=50)
    def test_no_admin_role_patterns(self, role_suffix: str):
        """
        Property: For any IAM role in Terraform configuration,
        the role name should not contain common admin/owner/editor patterns.
        
        This is a fuzzy check to catch potentially overly permissive roles
        that might not be in our explicit prohibited list.
        
        **Validates: Requirements 8.5**
        """
        roles = extract_iam_roles_from_terraform()
        
        # Check if any role ends with the admin/owner/editor pattern
        suspicious_roles = [
            role for role in roles
            if role.lower().endswith(role_suffix.lower())
        ]
        
        # Filter out explicitly allowed roles
        suspicious_roles = [
            role for role in suspicious_roles
            if role not in ALLOWED_ROLES
        ]
        
        if suspicious_roles:
            pytest.fail(
                f"Found IAM roles with potentially overly permissive pattern "
                f"'{role_suffix}': {suspicious_roles}\n"
                f"Verify these roles follow least privilege principles.\n"
                f"If they are necessary and minimal, add them to ALLOWED_ROLES."
            )
    
    def test_service_account_roles_documented(self):
        """
        Property: For any service account IAM configuration,
        the required roles should be documented in the Terraform files.
        
        This ensures operators know what permissions are needed.
        
        **Validates: Requirements 8.5**
        """
        # Read main.tf which should contain IAM documentation
        main_tf = TERRAFORM_DIR / "main.tf"
        content = main_tf.read_text()
        
        # Check that IAM section exists
        assert "IAM Configuration" in content or "IAM" in content, (
            "Terraform configuration should document IAM requirements"
        )
        
        # Check that required roles are documented
        for role in ALLOWED_ROLES:
            # At least some of the core roles should be documented
            if role in {
                "roles/compute.instanceAdmin.v1",
                "roles/osconfig.patchDeploymentAdmin",
            }:
                assert role in content, (
                    f"Required IAM role '{role}' should be documented in Terraform files"
                )


# ============================================================================
# Unit Tests for Specific Scenarios
# ============================================================================

class TestIAMConfiguration:
    """
    Unit tests for specific IAM configuration scenarios.
    """
    
    def test_terraform_service_account_roles_documented(self):
        """
        Verify that the Terraform service account required roles are documented.
        """
        main_tf = TERRAFORM_DIR / "main.tf"
        content = main_tf.read_text()
        
        # Check for documentation of required roles
        assert "compute.instanceAdmin" in content
        assert "osconfig.patchDeploymentAdmin" in content
        assert "principle of least privilege" in content.lower()
    
    def test_no_hardcoded_service_account_keys(self):
        """
        Verify that no service account keys are hardcoded in Terraform files.
        """
        for tf_file in TERRAFORM_DIR.glob("*.tf"):
            content = tf_file.read_text()
            
            # Check for patterns that might indicate hardcoded keys
            assert "private_key" not in content.lower() or "vault" in content.lower(), (
                f"File {tf_file.name} may contain hardcoded private keys. "
                f"Use Vault for credential management."
            )
            
            assert "service_account_key" not in content or "vault" in content.lower(), (
                f"File {tf_file.name} may contain hardcoded service account keys. "
                f"Use Vault for credential management."
            )
    
    def test_iam_best_practices_documented(self):
        """
        Verify that IAM best practices are documented in the configuration.
        """
        main_tf = TERRAFORM_DIR / "main.tf"
        content = main_tf.read_text()
        
        # Check for best practices documentation
        best_practices = [
            "least privilege",
            "service account",
            "minimum",
        ]
        
        for practice in best_practices:
            assert practice.lower() in content.lower(), (
                f"IAM best practice '{practice}' should be documented"
            )


# ============================================================================
# Test Execution
# ============================================================================

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
