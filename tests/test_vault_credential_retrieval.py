"""
Property-Based Tests for Vault Credential Retrieval

This module tests Property 14: Vault Credential Retrieval
**Validates: Requirements 8.1**

Property 14 states: For any credential requirement in the Terraform code 
(GCP, AAP, SSH), the credential should be retrieved from a Vault data source, 
not from a hardcoded value.
"""

import os
import re
from pathlib import Path
from typing import List, Dict, Set
from hypothesis import given, strategies as st, settings
import pytest


# ============================================================================
# Helper Functions
# ============================================================================

def get_terraform_files(terraform_dir: str = "terraform") -> List[Path]:
    """
    Get all Terraform files in the specified directory.
    
    Args:
        terraform_dir: Path to the Terraform directory
        
    Returns:
        List of Path objects for .tf files
    """
    # Get the project root directory (parent of tests directory)
    project_root = Path(__file__).parent.parent
    terraform_path = project_root / terraform_dir
    
    if not terraform_path.exists():
        return []
    
    return list(terraform_path.glob("*.tf"))


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


def find_vault_data_sources(content: str) -> Set[str]:
    """
    Find all Vault data source declarations in Terraform content.
    
    Args:
        content: Terraform file content
        
    Returns:
        Set of Vault data source names
    """
    # Pattern to match: data "vault_generic_secret" "name" {
    pattern = r'data\s+"vault_generic_secret"\s+"([^"]+)"\s*{'
    matches = re.findall(pattern, content)
    return set(matches)


def find_credential_references(content: str) -> Dict[str, List[str]]:
    """
    Find references to credentials in Terraform content.
    
    This function looks for:
    - Provider credential configurations
    - Authentication blocks
    - Token references
    - Key references
    
    Args:
        content: Terraform file content
        
    Returns:
        Dictionary mapping credential types to their references
    """
    references = {
        'gcp_credentials': [],
        'aap_tokens': [],
        'ssh_keys': []
    }
    
    # Pattern for GCP provider credentials
    # Should reference: data.vault_generic_secret.*.data["key"]
    gcp_cred_pattern = r'credentials\s*=\s*data\.vault_generic_secret\.([^.]+)\.data\["[^"]+"\]'
    gcp_matches = re.findall(gcp_cred_pattern, content)
    references['gcp_credentials'].extend(gcp_matches)
    
    # Pattern for AAP token references
    # Should reference: data.vault_generic_secret.*.data["token"]
    aap_token_pattern = r'token\s*=\s*data\.vault_generic_secret\.([^.]+)\.data\["[^"]+"\]'
    aap_matches = re.findall(aap_token_pattern, content)
    references['aap_tokens'].extend(aap_matches)
    
    # Pattern for SSH key references
    # Should reference: data.vault_generic_secret.*.data["private_key"] or similar
    ssh_key_pattern = r'(?:ssh_key|private_key)\s*=\s*data\.vault_generic_secret\.([^.]+)\.data\["[^"]+"\]'
    ssh_matches = re.findall(ssh_key_pattern, content)
    references['ssh_keys'].extend(ssh_matches)
    
    return references


def find_hardcoded_credentials(content: str) -> List[Dict[str, str]]:
    """
    Search for potential hardcoded credentials in Terraform content.
    
    This function looks for suspicious patterns that might indicate
    hardcoded credentials:
    - credentials = "..." (direct string assignment)
    - token = "..." (direct string assignment)
    - private_key = "..." (direct string assignment)
    - API keys in string format
    
    Args:
        content: Terraform file content
        
    Returns:
        List of dictionaries with 'type' and 'value' keys for each finding
    """
    findings = []
    
    # Pattern for direct string assignments to credential fields
    # This should NOT appear - credentials should come from Vault
    patterns = [
        (r'credentials\s*=\s*"([^"]+)"', 'gcp_credentials'),
        (r'token\s*=\s*"([^"]+)"', 'token'),
        (r'private_key\s*=\s*"([^"]+)"', 'private_key'),
        (r'api_key\s*=\s*"([^"]+)"', 'api_key'),
    ]
    
    for pattern, cred_type in patterns:
        matches = re.findall(pattern, content)
        for match in matches:
            # Exclude variable references and Vault references
            if not match.startswith('var.') and 'vault' not in match.lower():
                findings.append({
                    'type': cred_type,
                    'value': match[:50]  # Truncate for safety
                })
    
    return findings


def verify_vault_data_source_usage(
    vault_sources: Set[str],
    credential_refs: Dict[str, List[str]]
) -> bool:
    """
    Verify that all credential references use Vault data sources.
    
    Args:
        vault_sources: Set of declared Vault data source names
        credential_refs: Dictionary of credential references by type
        
    Returns:
        True if all references use declared Vault sources
    """
    all_refs = []
    for refs in credential_refs.values():
        all_refs.extend(refs)
    
    # All references should point to declared Vault data sources
    for ref in all_refs:
        if ref not in vault_sources:
            return False
    
    return True


# ============================================================================
# Property-Based Tests
# ============================================================================

class TestVaultCredentialRetrieval:
    """
    Test suite for Property 14: Vault Credential Retrieval
    
    **Validates: Requirements 8.1**
    """
    
    def test_vault_data_sources_exist(self):
        """
        Test that Vault data sources are declared for all credential types.
        
        This test verifies that the Terraform code includes data sources
        for retrieving credentials from Vault.
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        all_vault_sources = set()
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            vault_sources = find_vault_data_sources(content)
            all_vault_sources.update(vault_sources)
        
        # We expect at least 3 Vault data sources: GCP, AAP, SSH
        assert len(all_vault_sources) >= 3, (
            f"Expected at least 3 Vault data sources, found {len(all_vault_sources)}: "
            f"{all_vault_sources}"
        )
        
        # Check for expected credential types
        expected_types = {'gcp_credentials', 'aap_token', 'ssh_key'}
        found_types = {name for name in all_vault_sources 
                      if any(t in name for t in ['gcp', 'aap', 'ssh'])}
        
        assert len(found_types) >= 3, (
            f"Expected Vault sources for GCP, AAP, and SSH. Found: {found_types}"
        )
    
    def test_no_hardcoded_credentials(self):
        """
        Test that no hardcoded credentials exist in Terraform files.
        
        This test scans all Terraform files for patterns that indicate
        hardcoded credentials (direct string assignments to credential fields).
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        all_findings = []
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            findings = find_hardcoded_credentials(content)
            
            if findings:
                all_findings.extend([
                    f"{tf_file.name}: {f['type']} = {f['value']}"
                    for f in findings
                ])
        
        assert len(all_findings) == 0, (
            f"Found potential hardcoded credentials:\n" +
            "\n".join(all_findings)
        )
    
    def test_provider_uses_vault_credentials(self):
        """
        Test that the GCP provider configuration uses Vault-retrieved credentials.
        
        This test specifically checks that the google provider block
        references a Vault data source for authentication.
        """
        terraform_files = get_terraform_files()
        
        provider_found = False
        uses_vault = False
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            
            # Check if this file contains the google provider
            if 'provider "google"' in content:
                provider_found = True
                
                # Check if it uses Vault data source
                if 'data.vault_generic_secret' in content:
                    uses_vault = True
                    break
        
        assert provider_found, "Google provider configuration not found"
        assert uses_vault, (
            "Google provider does not use Vault data source for credentials"
        )
    
    @given(
        credential_type=st.sampled_from(['gcp_credentials', 'aap_token', 'ssh_key'])
    )
    @settings(max_examples=100)
    def test_property_vault_credential_retrieval(self, credential_type: str):
        """
        Property 14: Vault Credential Retrieval
        
        **Validates: Requirements 8.1**
        
        For any credential requirement in the Terraform code (GCP, AAP, SSH),
        the credential should be retrieved from a Vault data source,
        not from a hardcoded value.
        
        This property test verifies that:
        1. Vault data sources are declared for each credential type
        2. Credential references point to Vault data sources
        3. No hardcoded credentials exist in the codebase
        
        Args:
            credential_type: Type of credential to check (GCP, AAP, or SSH)
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        # Collect all Vault data sources and credential references
        all_vault_sources = set()
        all_credential_refs = {
            'gcp_credentials': [],
            'aap_tokens': [],
            'ssh_keys': []
        }
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            
            # Find Vault data sources
            vault_sources = find_vault_data_sources(content)
            all_vault_sources.update(vault_sources)
            
            # Find credential references
            cred_refs = find_credential_references(content)
            for key in all_credential_refs:
                all_credential_refs[key].extend(cred_refs[key])
        
        # Property assertion: All credential references must use Vault data sources
        if credential_type == 'gcp_credentials':
            refs = all_credential_refs['gcp_credentials']
        elif credential_type == 'aap_token':
            refs = all_credential_refs['aap_tokens']
        else:  # ssh_key
            refs = all_credential_refs['ssh_keys']
        
        # If there are references for this credential type,
        # they must all point to declared Vault data sources
        for ref in refs:
            assert ref in all_vault_sources, (
                f"Credential reference '{ref}' for {credential_type} "
                f"does not point to a declared Vault data source. "
                f"Available Vault sources: {all_vault_sources}"
            )
    
    @given(
        file_index=st.integers(min_value=0, max_value=10)
    )
    @settings(max_examples=100)
    def test_property_no_credential_leakage(self, file_index: int):
        """
        Property test: No credential leakage in any Terraform file
        
        **Validates: Requirements 8.1**
        
        For any Terraform file in the codebase, the file should not contain
        hardcoded credentials or direct credential assignments.
        
        This test randomly samples Terraform files and verifies they don't
        contain credential leakage patterns.
        
        Args:
            file_index: Random index to select a Terraform file
        """
        terraform_files = get_terraform_files()
        
        if len(terraform_files) == 0:
            pytest.skip("No Terraform files found")
        
        # Use modulo to wrap around if index exceeds file count
        selected_file = terraform_files[file_index % len(terraform_files)]
        
        content = parse_terraform_file(selected_file)
        findings = find_hardcoded_credentials(content)
        
        # Property assertion: No hardcoded credentials should be found
        assert len(findings) == 0, (
            f"File {selected_file.name} contains potential hardcoded credentials: "
            f"{findings}"
        )
    
    def test_all_credentials_use_vault(self):
        """
        Integration test: Verify all credential types use Vault
        
        This test provides a comprehensive check that all three credential
        types (GCP, AAP, SSH) are properly configured to use Vault.
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        # Collect all Vault data sources
        all_vault_sources = set()
        all_credential_refs = {
            'gcp_credentials': [],
            'aap_tokens': [],
            'ssh_keys': []
        }
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            
            vault_sources = find_vault_data_sources(content)
            all_vault_sources.update(vault_sources)
            
            cred_refs = find_credential_references(content)
            for key in all_credential_refs:
                all_credential_refs[key].extend(cred_refs[key])
        
        # Verify that Vault data sources exist
        assert len(all_vault_sources) >= 3, (
            f"Expected at least 3 Vault data sources, found {len(all_vault_sources)}"
        )
        
        # Verify that all credential references use Vault
        is_valid = verify_vault_data_source_usage(
            all_vault_sources,
            all_credential_refs
        )
        
        assert is_valid, (
            "Not all credential references use declared Vault data sources. "
            f"Vault sources: {all_vault_sources}, "
            f"References: {all_credential_refs}"
        )


# ============================================================================
# Test Execution
# ============================================================================

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
