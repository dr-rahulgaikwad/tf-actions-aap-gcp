"""
Property-Based Tests for Minimal Firewall Rules Configuration

Feature: terraform-actions-gcp-patching
Property 18: Minimal Firewall Rules

This module tests that firewall rule configuration is minimal (≤ 2 rules)
and only allows SSH access, following security best practices.

**Validates: Requirements 7.5**
"""

import re
from pathlib import Path
from typing import List, Dict, Set

import pytest
from hypothesis import given, strategies as st, settings


# ============================================================================
# Test Configuration
# ============================================================================

# Terraform project root
TERRAFORM_DIR = Path(__file__).parent.parent / "terraform"

# Maximum allowed custom firewall rules for this prototype
MAX_FIREWALL_RULES = 2

# Allowed protocols and ports for this prototype
ALLOWED_PROTOCOLS = {"tcp"}
ALLOWED_PORTS = {"22"}  # SSH only

# Prohibited overly permissive configurations
PROHIBITED_SOURCE_RANGES = {
    # We allow 0.0.0.0/0 for demo purposes, but document it as a concern
}


# ============================================================================
# Helper Functions
# ============================================================================

def extract_firewall_rules_from_terraform() -> List[Dict]:
    """
    Extract firewall rule resources from Terraform configuration.
    
    Returns:
        List of dictionaries containing firewall rule information
    """
    rules = []
    
    for tf_file in TERRAFORM_DIR.glob("*.tf"):
        content = tf_file.read_text()
        
        # Find google_compute_firewall resources
        firewall_pattern = r'resource\s+"google_compute_firewall"\s+"([^"]+)"\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'
        
        for match in re.finditer(firewall_pattern, content, re.DOTALL):
            resource_name = match.group(1)
            resource_body = match.group(2)
            
            # Extract rule details
            rule_info = {
                "name": resource_name,
                "file": tf_file.name,
                "body": resource_body,
            }
            
            # Extract name attribute
            name_match = re.search(r'name\s*=\s*"([^"]+)"', resource_body)
            if name_match:
                rule_info["rule_name"] = name_match.group(1)
            
            # Extract allow blocks
            allow_blocks = re.findall(
                r'allow\s*\{([^}]+)\}',
                resource_body,
                re.DOTALL
            )
            rule_info["allow_blocks"] = allow_blocks
            
            # Extract protocols and ports
            protocols = set()
            ports = set()
            for allow_block in allow_blocks:
                protocol_match = re.search(r'protocol\s*=\s*"([^"]+)"', allow_block)
                if protocol_match:
                    protocols.add(protocol_match.group(1))
                
                ports_match = re.search(r'ports\s*=\s*\[([^\]]+)\]', allow_block)
                if ports_match:
                    ports_str = ports_match.group(1)
                    # Extract port numbers/strings
                    port_values = re.findall(r'"([^"]+)"', ports_str)
                    ports.update(port_values)
            
            rule_info["protocols"] = protocols
            rule_info["ports"] = ports
            
            # Extract source ranges
            source_ranges_match = re.search(
                r'source_ranges\s*=\s*\[([^\]]+)\]',
                resource_body
            )
            if source_ranges_match:
                ranges_str = source_ranges_match.group(1)
                ranges = re.findall(r'"([^"]+)"', ranges_str)
                rule_info["source_ranges"] = set(ranges)
            else:
                rule_info["source_ranges"] = set()
            
            # Extract target tags
            target_tags_match = re.search(
                r'target_tags\s*=\s*\[([^\]]+)\]',
                resource_body
            )
            if target_tags_match:
                tags_str = target_tags_match.group(1)
                tags = re.findall(r'"([^"]+)"', tags_str)
                rule_info["target_tags"] = set(tags)
            else:
                rule_info["target_tags"] = set()
            
            rules.append(rule_info)
    
    return rules


def count_custom_firewall_rules() -> int:
    """
    Count the number of custom firewall rules defined in Terraform.
    
    Returns:
        Number of google_compute_firewall resources
    """
    return len(extract_firewall_rules_from_terraform())


# ============================================================================
# Property-Based Tests
# ============================================================================

@pytest.mark.property
class TestMinimalFirewallRules:
    """
    Property tests for minimal firewall rules configuration.
    
    Feature: terraform-actions-gcp-patching, Property 18: Minimal Firewall Rules
    **Validates: Requirements 7.5**
    """
    
    def test_firewall_rule_count_is_minimal(self):
        """
        Property: For any firewall rule configuration, the number of custom
        firewall rules should be minimal (≤ 2).
        
        This ensures we maintain a simple, secure network configuration
        for the demo environment.
        
        **Validates: Requirements 7.5**
        """
        rule_count = count_custom_firewall_rules()
        
        assert rule_count <= MAX_FIREWALL_RULES, (
            f"Found {rule_count} custom firewall rules, but maximum allowed is {MAX_FIREWALL_RULES}. "
            f"Keep firewall configuration minimal for this prototype. "
            f"Only SSH access should be required."
        )
    
    def test_firewall_rules_only_allow_ssh(self):
        """
        Property: For any firewall rule in Terraform configuration,
        the rule should only allow SSH access (TCP port 22).
        
        This ensures we don't open unnecessary ports that could
        increase the attack surface.
        
        **Validates: Requirements 7.5**
        """
        rules = extract_firewall_rules_from_terraform()
        
        for rule in rules:
            protocols = rule.get("protocols", set())
            ports = rule.get("ports", set())
            
            # Check protocols
            disallowed_protocols = protocols - ALLOWED_PROTOCOLS
            assert not disallowed_protocols, (
                f"Firewall rule '{rule['name']}' allows disallowed protocols: {disallowed_protocols}. "
                f"Only TCP should be allowed for SSH access."
            )
            
            # Check ports
            disallowed_ports = ports - ALLOWED_PORTS
            assert not disallowed_ports, (
                f"Firewall rule '{rule['name']}' allows disallowed ports: {disallowed_ports}. "
                f"Only port 22 (SSH) should be allowed for this prototype."
            )
    
    def test_firewall_rules_have_target_tags(self):
        """
        Property: For any firewall rule in Terraform configuration,
        the rule should use target tags to limit scope to specific VMs.
        
        This ensures firewall rules don't apply to all VMs in the network,
        following the principle of least privilege.
        
        **Validates: Requirements 7.5**
        """
        rules = extract_firewall_rules_from_terraform()
        
        for rule in rules:
            target_tags = rule.get("target_tags", set())
            
            assert target_tags, (
                f"Firewall rule '{rule['name']}' does not specify target_tags. "
                f"Use target_tags to limit the scope of firewall rules to specific VMs."
            )
    
    def test_firewall_rules_documented_with_security_notes(self):
        """
        Property: For any firewall rule configuration, security considerations
        should be documented in comments.
        
        This ensures operators understand the security implications of
        the firewall configuration.
        
        **Validates: Requirements 7.5**
        """
        main_tf = TERRAFORM_DIR / "main.tf"
        content = main_tf.read_text()
        
        # Check for security-related documentation
        if "google_compute_firewall" in content:
            # Look for security notes near firewall configuration
            firewall_section = content[content.find("google_compute_firewall"):]
            
            security_keywords = ["production", "restrict", "security", "demo"]
            found_keywords = [
                kw for kw in security_keywords
                if kw.lower() in firewall_section[:1000].lower()
            ]
            
            assert found_keywords, (
                "Firewall rules should be documented with security considerations. "
                "Include notes about production restrictions and demo limitations."
            )
    
    @given(
        port=st.integers(min_value=1, max_value=65535).filter(lambda x: x != 22)
    )
    @settings(max_examples=100)
    def test_no_unexpected_ports_allowed(self, port: int):
        """
        Property: For any port number (except 22), the port should NOT be
        allowed in any firewall rule.
        
        This is a comprehensive check that we're not accidentally opening
        ports beyond SSH.
        
        **Validates: Requirements 7.5**
        """
        rules = extract_firewall_rules_from_terraform()
        
        for rule in rules:
            ports = rule.get("ports", set())
            port_str = str(port)
            
            assert port_str not in ports, (
                f"Firewall rule '{rule['name']}' allows unexpected port {port}. "
                f"Only port 22 (SSH) should be allowed for this prototype."
            )
    
    def test_firewall_rules_use_specific_protocols(self):
        """
        Property: For any firewall rule, the protocol should be explicitly
        specified (not 'all' or wildcard).
        
        This ensures we're not accidentally allowing all protocols.
        
        **Validates: Requirements 7.5**
        """
        rules = extract_firewall_rules_from_terraform()
        
        for rule in rules:
            protocols = rule.get("protocols", set())
            
            # Check for overly permissive protocol specifications
            prohibited_protocols = {"all", "ip", "icmp", "udp", "esp", "ah", "sctp"}
            found_prohibited = protocols.intersection(prohibited_protocols)
            
            assert not found_prohibited, (
                f"Firewall rule '{rule['name']}' uses overly permissive protocol: {found_prohibited}. "
                f"Use specific protocols (tcp) for this prototype."
            )


# ============================================================================
# Unit Tests for Specific Scenarios
# ============================================================================

class TestFirewallConfiguration:
    """
    Unit tests for specific firewall configuration scenarios.
    """
    
    def test_ssh_firewall_rule_exists(self):
        """
        Verify that an SSH firewall rule exists in the configuration.
        """
        rules = extract_firewall_rules_from_terraform()
        
        # Should have at least one rule
        assert len(rules) > 0, "No firewall rules found in Terraform configuration"
        
        # At least one rule should allow SSH
        ssh_rules = [
            rule for rule in rules
            if "22" in rule.get("ports", set())
        ]
        
        assert ssh_rules, "No SSH firewall rule found. SSH access is required for Ansible."
    
    def test_ssh_rule_allows_tcp_port_22(self):
        """
        Verify that the SSH rule specifically allows TCP port 22.
        """
        rules = extract_firewall_rules_from_terraform()
        
        ssh_rules = [
            rule for rule in rules
            if "22" in rule.get("ports", set())
        ]
        
        for rule in ssh_rules:
            assert "tcp" in rule.get("protocols", set()), (
                f"SSH rule '{rule['name']}' should use TCP protocol"
            )
    
    def test_firewall_rules_have_descriptions(self):
        """
        Verify that firewall rules have descriptions for documentation.
        """
        rules = extract_firewall_rules_from_terraform()
        
        for rule in rules:
            # Check if description is in the rule body
            assert "description" in rule["body"], (
                f"Firewall rule '{rule['name']}' should have a description"
            )
    
    def test_source_ranges_documented_for_production(self):
        """
        Verify that source ranges are documented with production considerations.
        """
        main_tf = TERRAFORM_DIR / "main.tf"
        content = main_tf.read_text()
        
        if "0.0.0.0/0" in content:
            # If we're using 0.0.0.0/0, it should be documented as demo-only
            assert "demo" in content.lower() or "production" in content.lower(), (
                "Using 0.0.0.0/0 source range should be documented as demo-only "
                "with notes about restricting in production"
            )
    
    def test_firewall_configuration_is_simple(self):
        """
        Verify that the firewall configuration is simple and easy to understand.
        """
        rules = extract_firewall_rules_from_terraform()
        
        # Should have minimal rules
        assert len(rules) <= MAX_FIREWALL_RULES, (
            f"Firewall configuration should be simple with ≤ {MAX_FIREWALL_RULES} rules"
        )
        
        # Each rule should have clear purpose
        for rule in rules:
            # Rule name should be descriptive
            rule_name = rule.get("rule_name", "")
            assert len(rule_name) > 5, (
                f"Firewall rule '{rule['name']}' should have a descriptive name"
            )


# ============================================================================
# Test Execution
# ============================================================================

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
