"""
Property-Based Tests for No Plaintext Credentials

This module tests Property 15: No Plaintext Credentials
**Validates: Requirements 8.2**

Property 15 states: For any Terraform file in the codebase, scanning the file 
content should not reveal any plaintext credentials (API keys, passwords, 
private keys, tokens).
"""

import os
import re
from pathlib import Path
from typing import List, Dict, Tuple
from hypothesis import given, strategies as st, settings
import pytest


# ============================================================================
# Credential Pattern Definitions
# ============================================================================

# Patterns that indicate plaintext credentials
CREDENTIAL_PATTERNS = {
    'private_key_pem': {
        'pattern': r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
        'description': 'PEM-encoded private key'
    },
    'gcp_service_account_json': {
        'pattern': r'"type"\s*:\s*"service_account".*"private_key"',
        'description': 'GCP service account JSON key',
        'flags': re.DOTALL
    },
    'aws_access_key': {
        'pattern': r'(?:AKIA|A3T|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}',
        'description': 'AWS access key ID'
    },
    'generic_api_key': {
        'pattern': r'(?:api[_-]?key|apikey)\s*[=:]\s*["\']([A-Za-z0-9_\-]{20,})["\']',
        'description': 'Generic API key assignment',
        'flags': re.IGNORECASE
    },
    'password_assignment': {
        'pattern': r'(?:password|passwd|pwd)\s*[=:]\s*["\']([^"\']{8,})["\']',
        'description': 'Password assignment',
        'flags': re.IGNORECASE
    },
    'bearer_token': {
        'pattern': r'Bearer\s+[A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+\.?[A-Za-z0-9\-_=]*',
        'description': 'Bearer token (JWT format)'
    },
    'generic_token': {
        'pattern': r'(?:token|auth[_-]?token)\s*[=:]\s*["\']([A-Za-z0-9_\-]{20,})["\']',
        'description': 'Generic token assignment',
        'flags': re.IGNORECASE
    },
    'ssh_private_key': {
        'pattern': r'ssh-rsa\s+[A-Za-z0-9+/]{200,}={0,3}',
        'description': 'SSH public key (long format)'
    },
    'base64_credentials': {
        'pattern': r'(?:credentials|secret)\s*[=:]\s*["\']([A-Za-z0-9+/]{40,}={0,3})["\']',
        'description': 'Base64-encoded credentials',
        'flags': re.IGNORECASE
    }
}

# Patterns that are ALLOWED (false positives to exclude)
ALLOWED_PATTERNS = [
    r'var\.',  # Terraform variable references
    r'data\.vault_generic_secret',  # Vault data source references
    r'vault_generic_secret\..*\.data',  # Vault secret data access
    r'REPLACE_WITH',  # Placeholder text
    r'your-.*',  # Example placeholder values
    r'example\.com',  # Example domains
    r'AKIA.*EXAMPLE',  # Example AWS keys
    r'xxx+',  # Redacted values
    r'\*\*\*+',  # Redacted values
    r'<.*>',  # Placeholder brackets
    r'\$\{.*\}',  # Variable interpolation
    r'VAULT_TOKEN',  # Environment variable reference
]


# ============================================================================
# Helper Functions
# ============================================================================

def get_terraform_files(terraform_dir: str = "terraform") -> List[Path]:
    """
    Get all Terraform files in the specified directory.
    
    Args:
        terraform_dir: Path to the Terraform directory
        
    Returns:
        List of Path objects for .tf and .tfvars files
    """
    project_root = Path(__file__).parent.parent
    terraform_path = project_root / terraform_dir
    
    if not terraform_path.exists():
        return []
    
    # Include .tf files and .tfvars.example files
    tf_files = list(terraform_path.glob("*.tf"))
    tfvars_files = list(terraform_path.glob("*.tfvars.example"))
    
    return tf_files + tfvars_files


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


def is_allowed_pattern(text: str, context: str) -> bool:
    """
    Check if the matched text is an allowed pattern (false positive).
    
    Args:
        text: The matched credential text
        context: Surrounding context (line containing the match)
        
    Returns:
        True if this is an allowed pattern (not a real credential)
    """
    # Check if the match or its context contains allowed patterns
    for allowed in ALLOWED_PATTERNS:
        if re.search(allowed, context, re.IGNORECASE):
            return True
        if re.search(allowed, text, re.IGNORECASE):
            return True
    
    return False


def scan_for_credentials(content: str, file_name: str) -> List[Dict[str, str]]:
    """
    Scan file content for plaintext credential patterns.
    
    Args:
        content: File content to scan
        file_name: Name of the file being scanned
        
    Returns:
        List of findings with type, description, line number, and context
    """
    findings = []
    lines = content.split('\n')
    
    for pattern_name, pattern_info in CREDENTIAL_PATTERNS.items():
        pattern = pattern_info['pattern']
        description = pattern_info['description']
        flags = pattern_info.get('flags', 0)
        
        # Search for pattern in content
        for match in re.finditer(pattern, content, flags):
            matched_text = match.group(0)
            
            # Find the line number
            line_num = content[:match.start()].count('\n') + 1
            
            # Get the line context
            if line_num <= len(lines):
                line_context = lines[line_num - 1].strip()
            else:
                line_context = matched_text[:100]
            
            # Check if this is an allowed pattern (false positive)
            if is_allowed_pattern(matched_text, line_context):
                continue
            
            # Truncate matched text for safety
            display_text = matched_text[:50]
            if len(matched_text) > 50:
                display_text += "..."
            
            findings.append({
                'file': file_name,
                'type': pattern_name,
                'description': description,
                'line': line_num,
                'context': line_context[:100],
                'matched': display_text
            })
    
    return findings


def scan_all_terraform_files() -> Dict[str, List[Dict[str, str]]]:
    """
    Scan all Terraform files for plaintext credentials.
    
    Returns:
        Dictionary mapping file names to lists of findings
    """
    terraform_files = get_terraform_files()
    all_findings = {}
    
    for tf_file in terraform_files:
        content = parse_terraform_file(tf_file)
        findings = scan_for_credentials(content, tf_file.name)
        
        if findings:
            all_findings[tf_file.name] = findings
    
    return all_findings


def format_findings(findings: Dict[str, List[Dict[str, str]]]) -> str:
    """
    Format findings into a readable error message.
    
    Args:
        findings: Dictionary of findings by file
        
    Returns:
        Formatted error message string
    """
    if not findings:
        return ""
    
    lines = ["Found plaintext credentials in Terraform files:"]
    
    for file_name, file_findings in findings.items():
        lines.append(f"\n{file_name}:")
        for finding in file_findings:
            lines.append(
                f"  Line {finding['line']}: {finding['description']}\n"
                f"    Type: {finding['type']}\n"
                f"    Context: {finding['context']}\n"
                f"    Matched: {finding['matched']}"
            )
    
    return "\n".join(lines)


# ============================================================================
# Property-Based Tests
# ============================================================================

class TestNoPlaintextCredentials:
    """
    Test suite for Property 15: No Plaintext Credentials
    
    **Validates: Requirements 8.2**
    """
    
    def test_no_private_keys_in_files(self):
        """
        Test that no PEM-encoded private keys exist in Terraform files.
        
        This test specifically checks for private key headers that would
        indicate a plaintext private key in the codebase.
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        findings = []
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            
            # Check for private key patterns
            if re.search(CREDENTIAL_PATTERNS['private_key_pem']['pattern'], content):
                # Verify it's not in a comment or example
                lines = content.split('\n')
                for i, line in enumerate(lines, 1):
                    if re.search(CREDENTIAL_PATTERNS['private_key_pem']['pattern'], line):
                        if not is_allowed_pattern(line, line):
                            findings.append(f"{tf_file.name}:Line {i}")
        
        assert len(findings) == 0, (
            f"Found private keys in Terraform files: {findings}"
        )
    
    def test_no_service_account_json_in_files(self):
        """
        Test that no GCP service account JSON keys exist in Terraform files.
        
        Service account keys should be retrieved from Vault, not embedded
        in the Terraform code.
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        findings = []
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            
            # Check for service account JSON pattern
            pattern = CREDENTIAL_PATTERNS['gcp_service_account_json']
            if re.search(pattern['pattern'], content, pattern.get('flags', 0)):
                # Verify it's not in a comment or documentation
                if not is_allowed_pattern(content, content):
                    findings.append(tf_file.name)
        
        assert len(findings) == 0, (
            f"Found GCP service account JSON in files: {findings}"
        )
    
    def test_no_api_keys_in_files(self):
        """
        Test that no API keys exist in Terraform files.
        
        API keys should be retrieved from Vault or passed as variables,
        not hardcoded in the Terraform code.
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        findings = []
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            
            # Check for API key patterns
            for pattern_name in ['generic_api_key', 'aws_access_key']:
                pattern = CREDENTIAL_PATTERNS[pattern_name]
                for match in re.finditer(pattern['pattern'], content, 
                                        pattern.get('flags', 0)):
                    matched_text = match.group(0)
                    line_num = content[:match.start()].count('\n') + 1
                    lines = content.split('\n')
                    context = lines[line_num - 1] if line_num <= len(lines) else ""
                    
                    if not is_allowed_pattern(matched_text, context):
                        findings.append(f"{tf_file.name}:Line {line_num}")
        
        assert len(findings) == 0, (
            f"Found API keys in Terraform files: {findings}"
        )
    
    def test_no_passwords_in_files(self):
        """
        Test that no passwords exist in Terraform files.
        
        Passwords should never be hardcoded in infrastructure code.
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        findings = []
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            
            # Check for password patterns
            pattern = CREDENTIAL_PATTERNS['password_assignment']
            for match in re.finditer(pattern['pattern'], content, 
                                    pattern.get('flags', 0)):
                matched_text = match.group(0)
                line_num = content[:match.start()].count('\n') + 1
                lines = content.split('\n')
                context = lines[line_num - 1] if line_num <= len(lines) else ""
                
                if not is_allowed_pattern(matched_text, context):
                    findings.append(f"{tf_file.name}:Line {line_num}")
        
        assert len(findings) == 0, (
            f"Found passwords in Terraform files: {findings}"
        )
    
    def test_no_tokens_in_files(self):
        """
        Test that no authentication tokens exist in Terraform files.
        
        Tokens should be retrieved from Vault, not hardcoded.
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        findings = []
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            
            # Check for token patterns
            for pattern_name in ['bearer_token', 'generic_token']:
                pattern = CREDENTIAL_PATTERNS[pattern_name]
                for match in re.finditer(pattern['pattern'], content, 
                                        pattern.get('flags', 0)):
                    matched_text = match.group(0)
                    line_num = content[:match.start()].count('\n') + 1
                    lines = content.split('\n')
                    context = lines[line_num - 1] if line_num <= len(lines) else ""
                    
                    if not is_allowed_pattern(matched_text, context):
                        findings.append(f"{tf_file.name}:Line {line_num}")
        
        assert len(findings) == 0, (
            f"Found tokens in Terraform files: {findings}"
        )
    
    @given(
        file_index=st.integers(min_value=0, max_value=20)
    )
    @settings(max_examples=100)
    def test_property_no_plaintext_credentials(self, file_index: int):
        """
        Property 15: No Plaintext Credentials
        
        **Validates: Requirements 8.2**
        
        For any Terraform file in the codebase, scanning the file content 
        should not reveal any plaintext credentials (API keys, passwords, 
        private keys, tokens).
        
        This property test randomly samples Terraform files and scans them
        for various credential patterns. All credentials should be retrieved
        from Vault or passed as variables, never hardcoded.
        
        Args:
            file_index: Random index to select a Terraform file
        """
        terraform_files = get_terraform_files()
        
        if len(terraform_files) == 0:
            pytest.skip("No Terraform files found")
        
        # Use modulo to wrap around if index exceeds file count
        selected_file = terraform_files[file_index % len(terraform_files)]
        
        content = parse_terraform_file(selected_file)
        findings = scan_for_credentials(content, selected_file.name)
        
        # Property assertion: No plaintext credentials should be found
        assert len(findings) == 0, (
            f"File {selected_file.name} contains plaintext credentials:\n" +
            "\n".join([
                f"  Line {f['line']}: {f['description']} - {f['matched']}"
                for f in findings
            ])
        )
    
    @given(
        pattern_name=st.sampled_from(list(CREDENTIAL_PATTERNS.keys()))
    )
    @settings(max_examples=100)
    def test_property_no_credential_pattern(self, pattern_name: str):
        """
        Property test: No specific credential pattern in any file
        
        **Validates: Requirements 8.2**
        
        For any credential pattern type (private keys, API keys, passwords, etc.),
        no Terraform file should contain that pattern.
        
        This test systematically checks each credential pattern type across
        all Terraform files.
        
        Args:
            pattern_name: Type of credential pattern to check
        """
        terraform_files = get_terraform_files()
        
        if len(terraform_files) == 0:
            pytest.skip("No Terraform files found")
        
        pattern_info = CREDENTIAL_PATTERNS[pattern_name]
        pattern = pattern_info['pattern']
        description = pattern_info['description']
        flags = pattern_info.get('flags', 0)
        
        findings = []
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            
            for match in re.finditer(pattern, content, flags):
                matched_text = match.group(0)
                line_num = content[:match.start()].count('\n') + 1
                lines = content.split('\n')
                context = lines[line_num - 1] if line_num <= len(lines) else ""
                
                if not is_allowed_pattern(matched_text, context):
                    findings.append(f"{tf_file.name}:Line {line_num}")
        
        # Property assertion: No instances of this credential pattern
        assert len(findings) == 0, (
            f"Found {description} ({pattern_name}) in files: {findings}"
        )
    
    def test_comprehensive_credential_scan(self):
        """
        Comprehensive test: Scan all files for all credential patterns
        
        This test provides a complete security scan of all Terraform files
        for any type of plaintext credential.
        """
        all_findings = scan_all_terraform_files()
        
        # Format findings for readable error message
        error_message = format_findings(all_findings)
        
        # Property assertion: No credentials found in any file
        assert len(all_findings) == 0, error_message
    
    def test_vault_references_only(self):
        """
        Test that credential references use Vault data sources
        
        This test verifies that when credentials are referenced in the code,
        they come from Vault data sources, not from direct assignments.
        """
        terraform_files = get_terraform_files()
        assert len(terraform_files) > 0, "No Terraform files found"
        
        violations = []
        
        for tf_file in terraform_files:
            content = parse_terraform_file(tf_file)
            lines = content.split('\n')
            
            # Look for credential-related assignments
            credential_keywords = ['credentials', 'token', 'api_key', 'private_key']
            
            for i, line in enumerate(lines, 1):
                for keyword in credential_keywords:
                    # Check if line contains credential assignment
                    if re.search(rf'{keyword}\s*=', line, re.IGNORECASE):
                        # Verify it references Vault or a variable
                        if 'vault_generic_secret' not in line and 'var.' not in line:
                            # Check if it's a direct string assignment
                            if re.search(r'=\s*["\']', line):
                                violations.append(
                                    f"{tf_file.name}:Line {i}: {line.strip()}"
                                )
        
        assert len(violations) == 0, (
            f"Found credential assignments not using Vault:\n" +
            "\n".join(violations)
        )


# ============================================================================
# Test Execution
# ============================================================================

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
