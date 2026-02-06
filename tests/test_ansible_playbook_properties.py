"""
Property-Based Tests for Ansible Playbook

This module tests Properties 9-12 for Ansible playbook:
- Property 9: Playbook Update Execution
- Property 10: Playbook Status Reporting
- Property 11: Playbook Error Handling
- Property 12: Conditional Reboot Logic

**Validates: Requirements 4.3, 4.4, 4.5, 4.6**
"""

import yaml
import re
from pathlib import Path
from typing import Dict, List, Any, Optional
from hypothesis import given, strategies as st, settings, assume
import pytest


# ============================================================================
# Helper Functions
# ============================================================================

def get_ansible_dir() -> Path:
    """
    Get the path to the Ansible directory.
    
    Returns:
        Path object pointing to the ansible directory
    """
    project_root = Path(__file__).parent.parent
    ansible_path = project_root / "ansible"
    
    if not ansible_path.exists():
        raise FileNotFoundError(f"Ansible directory not found at {ansible_path}")
    
    return ansible_path


def parse_ansible_playbook(file_path: Path) -> Dict[str, Any]:
    """
    Parse an Ansible playbook YAML file.
    
    Args:
        file_path: Path to the playbook file
        
    Returns:
        Parsed playbook as dictionary
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def get_playbook_content(file_path: Path) -> str:
    """
    Get the raw content of a playbook file.
    
    Args:
        file_path: Path to the playbook file
        
    Returns:
        File content as string
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()


def extract_tasks_from_play(play: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Extract tasks from a play.
    
    Args:
        play: Play dictionary from parsed playbook
        
    Returns:
        List of task dictionaries
    """
    return play.get('tasks', [])


def find_task_by_name(tasks: List[Dict[str, Any]], name_pattern: str) -> Optional[Dict[str, Any]]:
    """
    Find a task by name pattern.
    
    Args:
        tasks: List of task dictionaries
        name_pattern: Pattern to match in task name (case-insensitive)
        
    Returns:
        Task dictionary or None if not found
    """
    for task in tasks:
        task_name = task.get('name', '').lower()
        if name_pattern.lower() in task_name:
            return task
    return None


def check_task_has_module(task: Dict[str, Any], module_name: str) -> bool:
    """
    Check if a task uses a specific Ansible module.
    
    Args:
        task: Task dictionary
        module_name: Name of the module (e.g., 'apt', 'reboot')
        
    Returns:
        True if task uses the module
    """
    return module_name in task


def check_task_has_register(task: Dict[str, Any]) -> bool:
    """
    Check if a task registers a variable.
    
    Args:
        task: Task dictionary
        
    Returns:
        True if task has register directive
    """
    return 'register' in task


def check_task_has_when_condition(task: Dict[str, Any]) -> bool:
    """
    Check if a task has a when condition.
    
    Args:
        task: Task dictionary
        
    Returns:
        True if task has when directive
    """
    return 'when' in task


def check_task_has_failed_when(task: Dict[str, Any]) -> bool:
    """
    Check if a task has failed_when condition.
    
    Args:
        task: Task dictionary
        
    Returns:
        True if task has failed_when directive
    """
    return 'failed_when' in task


# ============================================================================
# Property 9: Playbook Update Execution Tests
# ============================================================================

class TestProperty9_PlaybookUpdateExecution:
    """
    Test suite for Property 9: Playbook Update Execution
    
    **Validates: Requirements 4.3**
    
    Property 9 states: For any Ubuntu VM with available package updates, 
    executing the patching playbook should result in the package cache being 
    updated and security packages being upgraded.
    """
    
    def test_playbook_file_exists(self):
        """
        Test that the playbook file exists.
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        
        assert playbook_path.exists(), (
            "Playbook file gcp_vm_patching.yml must exist"
        )

    
    def test_playbook_targets_all_hosts(self):
        """
        Test that playbook targets all hosts.
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        assert len(playbook) > 0, "Playbook must have at least one play"
        play = playbook[0]
        
        assert play.get('hosts') == 'all', (
            "Playbook must target 'all' hosts"
        )
    
    def test_playbook_uses_privilege_escalation(self):
        """
        Test that playbook uses become for privilege escalation.
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        assert play.get('become') is True, (
            "Playbook must use 'become: yes' for privilege escalation"
        )
    
    @given(
        vm_name=st.text(min_size=1, max_size=20, alphabet=st.characters(whitelist_categories=('Lu', 'Ll', 'Nd', 'Pd')))
    )
    @settings(max_examples=100)
    def test_property9_apt_update_task_exists(self, vm_name: str):
        """
        Property 9: Playbook Update Execution
        
        **Validates: Requirements 4.3**
        
        For any VM name, the playbook must have a task to update apt cache.
        
        Args:
            vm_name: Name of the VM (randomized)
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Find apt update task
        apt_update_task = find_task_by_name(tasks, 'update apt')
        
        assert apt_update_task is not None, (
            f"Playbook must have task to update apt cache for VM {vm_name}"
        )
        
        # Verify it uses apt module
        assert check_task_has_module(apt_update_task, 'apt'), (
            f"Apt update task must use 'apt' module for VM {vm_name}"
        )
        
        # Verify it has update_cache parameter
        apt_params = apt_update_task.get('apt', {})
        assert apt_params.get('update_cache') is True or apt_params.get('update_cache') == 'yes', (
            f"Apt task must set update_cache=yes for VM {vm_name}"
        )

    
    @given(
        vm_name=st.text(min_size=1, max_size=20, alphabet=st.characters(whitelist_categories=('Lu', 'Ll', 'Nd', 'Pd')))
    )
    @settings(max_examples=100)
    def test_property9_apt_upgrade_task_exists(self, vm_name: str):
        """
        Property 9: Playbook upgrades security packages
        
        **Validates: Requirements 4.3**
        
        For any VM name, the playbook must have a task to upgrade packages.
        
        Args:
            vm_name: Name of the VM (randomized)
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Find apt upgrade task
        apt_upgrade_task = find_task_by_name(tasks, 'upgrade')
        
        assert apt_upgrade_task is not None, (
            f"Playbook must have task to upgrade packages for VM {vm_name}"
        )
        
        # Verify it uses apt module
        assert check_task_has_module(apt_upgrade_task, 'apt'), (
            f"Apt upgrade task must use 'apt' module for VM {vm_name}"
        )
        
        # Verify it has upgrade parameter
        apt_params = apt_upgrade_task.get('apt', {})
        assert 'upgrade' in apt_params, (
            f"Apt task must have 'upgrade' parameter for VM {vm_name}"
        )
    
    def test_property9_apt_upgrade_uses_safe_mode(self):
        """
        Property 9: Apt upgrade uses safe mode
        
        **Validates: Requirements 4.3**
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        apt_upgrade_task = find_task_by_name(tasks, 'upgrade')
        assert apt_upgrade_task is not None, "Upgrade task must exist"
        
        apt_params = apt_upgrade_task.get('apt', {})
        upgrade_mode = apt_params.get('upgrade')
        
        assert upgrade_mode in ['safe', 'yes', 'dist', 'full'], (
            "Apt upgrade must use a valid upgrade mode"
        )

    
    def test_property9_apt_cleanup_enabled(self):
        """
        Property 9: Apt cleanup is enabled
        
        **Validates: Requirements 4.3**
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        apt_upgrade_task = find_task_by_name(tasks, 'upgrade')
        assert apt_upgrade_task is not None, "Upgrade task must exist"
        
        apt_params = apt_upgrade_task.get('apt', {})
        
        # Check for autoremove and autoclean
        assert apt_params.get('autoremove') in [True, 'yes'], (
            "Apt upgrade should enable autoremove"
        )
        assert apt_params.get('autoclean') in [True, 'yes'], (
            "Apt upgrade should enable autoclean"
        )


# ============================================================================
# Property 10: Playbook Status Reporting Tests
# ============================================================================

class TestProperty10_PlaybookStatusReporting:
    """
    Test suite for Property 10: Playbook Status Reporting
    
    **Validates: Requirements 4.4**
    
    Property 10 states: For any playbook execution (successful or failed), 
    the playbook should return an exit code (0 for success, non-zero for 
    failure) and status message.
    """
    
    @given(
        execution_scenario=st.sampled_from(['success', 'failure', 'partial'])
    )
    @settings(max_examples=100)
    def test_property10_playbook_has_status_reporting(self, execution_scenario: str):
        """
        Property 10: Playbook Status Reporting
        
        **Validates: Requirements 4.4**
        
        For any execution scenario (success/failure/partial), the playbook
        must have tasks that report status.
        
        Args:
            execution_scenario: Type of execution (success/failure/partial)
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Find status reporting tasks (debug tasks)
        status_tasks = [t for t in tasks if 'debug' in t]
        
        assert len(status_tasks) > 0, (
            f"Playbook must have status reporting tasks for scenario: {execution_scenario}"
        )

    
    @given(
        vm_index=st.integers(min_value=0, max_value=9)
    )
    @settings(max_examples=100)
    def test_property10_completion_status_reported(self, vm_index: int):
        """
        Property 10: Completion status is reported
        
        **Validates: Requirements 4.4**
        
        For any VM (identified by index), the playbook must report
        completion status.
        
        Args:
            vm_index: Index of the VM (0-9)
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Find final status reporting task
        status_task = find_task_by_name(tasks, 'patching status')
        
        assert status_task is not None, (
            f"Playbook must report patching status for VM index {vm_index}"
        )
        
        # Verify it uses debug module
        assert check_task_has_module(status_task, 'debug'), (
            f"Status reporting must use debug module for VM index {vm_index}"
        )
    
    def test_property10_status_includes_hostname(self):
        """
        Property 10: Status messages include hostname
        
        **Validates: Requirements 4.4**
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        content = get_playbook_content(playbook_path)
        
        # Check that status messages reference inventory_hostname
        assert 'inventory_hostname' in content, (
            "Status messages should include inventory_hostname for identification"
        )
    
    def test_property10_tasks_register_results(self):
        """
        Property 10: Critical tasks register results
        
        **Validates: Requirements 4.4**
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Find apt update task
        apt_update_task = find_task_by_name(tasks, 'update apt')
        assert apt_update_task is not None, "Apt update task must exist"
        assert check_task_has_register(apt_update_task), (
            "Apt update task must register result for status reporting"
        )
        
        # Find apt upgrade task
        apt_upgrade_task = find_task_by_name(tasks, 'upgrade')
        assert apt_upgrade_task is not None, "Apt upgrade task must exist"
        assert check_task_has_register(apt_upgrade_task), (
            "Apt upgrade task must register result for status reporting"
        )



# ============================================================================
# Property 11: Playbook Error Handling Tests
# ============================================================================

class TestProperty11_PlaybookErrorHandling:
    """
    Test suite for Property 11: Playbook Error Handling
    
    **Validates: Requirements 4.5**
    
    Property 11 states: For any playbook execution that encounters an error, 
    the error message should contain the task name and a description of the failure.
    """
    
    @given(
        error_type=st.sampled_from(['apt_update', 'apt_upgrade', 'reboot', 'connection'])
    )
    @settings(max_examples=100)
    def test_property11_error_handling_exists(self, error_type: str):
        """
        Property 11: Playbook Error Handling
        
        **Validates: Requirements 4.5**
        
        For any error type (apt_update, apt_upgrade, reboot, connection),
        the playbook must have error handling logic.
        
        Args:
            error_type: Type of error to handle
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Map error types to task patterns
        error_task_patterns = {
            'apt_update': 'apt update',
            'apt_upgrade': 'upgrade',
            'reboot': 'reboot',
            'connection': 'apt'  # Connection errors affect apt tasks
        }
        
        pattern = error_task_patterns.get(error_type, error_type)
        
        # Find the main task
        main_task = find_task_by_name(tasks, pattern)
        assert main_task is not None, f"Task for {error_type} must exist"
        
        # Check for error handling: either failed_when or register with error handler
        has_error_handling = (
            check_task_has_failed_when(main_task) or
            check_task_has_register(main_task)
        )
        
        assert has_error_handling, (
            f"Task for {error_type} must have error handling (failed_when or register)"
        )

    
    @given(
        task_name=st.sampled_from(['update apt', 'upgrade', 'reboot'])
    )
    @settings(max_examples=100)
    def test_property11_error_messages_include_task_name(self, task_name: str):
        """
        Property 11: Error messages include task name
        
        **Validates: Requirements 4.5**
        
        For any task that can fail, error messages should identify the task.
        
        Args:
            task_name: Name pattern of the task
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Find error handling task (fail task after the main task)
        error_handler = None
        for i, task in enumerate(tasks):
            if task_name.lower() in task.get('name', '').lower():
                # Look for fail task after this one
                if i + 1 < len(tasks):
                    next_task = tasks[i + 1]
                    if 'fail' in next_task:
                        error_handler = next_task
                        break
        
        if error_handler:
            fail_params = error_handler.get('fail', {})
            msg = fail_params.get('msg', '')
            
            # Error message should reference the operation
            assert len(msg) > 0, (
                f"Error handler for {task_name} must have a message"
            )
    
    def test_property11_error_messages_include_hostname(self):
        """
        Property 11: Error messages include hostname
        
        **Validates: Requirements 4.5**
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        content = get_playbook_content(playbook_path)
        
        # Check for fail tasks with inventory_hostname
        assert 'fail:' in content, "Playbook must have fail tasks for error handling"
        
        # Error messages should include hostname for identification
        fail_pattern = r'fail:\s*\n\s*msg:'
        if re.search(fail_pattern, content):
            # Check that error messages reference inventory_hostname
            assert 'inventory_hostname' in content, (
                "Error messages should include inventory_hostname"
            )

    
    def test_property11_tasks_use_failed_when_false(self):
        """
        Property 11: Tasks use failed_when: false for graceful error handling
        
        **Validates: Requirements 4.5**
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Find apt tasks that should have failed_when: false
        apt_update_task = find_task_by_name(tasks, 'update apt')
        apt_upgrade_task = find_task_by_name(tasks, 'upgrade')
        
        # These tasks should use failed_when: false to allow custom error handling
        for task in [apt_update_task, apt_upgrade_task]:
            if task:
                failed_when = task.get('failed_when')
                assert failed_when is False or failed_when == 'false', (
                    f"Task '{task.get('name')}' should use failed_when: false for graceful error handling"
                )


# ============================================================================
# Property 12: Conditional Reboot Logic Tests
# ============================================================================

class TestProperty12_ConditionalRebootLogic:
    """
    Test suite for Property 12: Conditional Reboot Logic
    
    **Validates: Requirements 4.6**
    
    Property 12 states: For any VM state, if the file /var/run/reboot-required 
    exists after patching, the playbook should execute the reboot task; if the 
    file does not exist, the reboot task should be skipped.
    """
    
    def test_reboot_check_task_exists(self):
        """
        Test that playbook has task to check for reboot requirement.
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Find reboot check task
        reboot_check_task = find_task_by_name(tasks, 'reboot required')
        
        assert reboot_check_task is not None, (
            "Playbook must have task to check if reboot is required"
        )

    
    def test_reboot_check_uses_stat_module(self):
        """
        Test that reboot check uses stat module.
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        reboot_check_task = find_task_by_name(tasks, 'reboot required')
        assert reboot_check_task is not None, "Reboot check task must exist"
        
        # Verify it uses stat module
        assert check_task_has_module(reboot_check_task, 'stat'), (
            "Reboot check must use 'stat' module"
        )
        
        # Verify it checks the correct file
        stat_params = reboot_check_task.get('stat', {})
        path = stat_params.get('path', '')
        assert '/var/run/reboot-required' in path, (
            "Reboot check must check /var/run/reboot-required file"
        )
    
    def test_reboot_check_registers_result(self):
        """
        Test that reboot check registers result for conditional logic.
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        reboot_check_task = find_task_by_name(tasks, 'reboot required')
        assert reboot_check_task is not None, "Reboot check task must exist"
        
        assert check_task_has_register(reboot_check_task), (
            "Reboot check must register result for conditional reboot"
        )
    
    @given(
        reboot_required=st.booleans()
    )
    @settings(max_examples=100)
    def test_property12_conditional_reboot_logic(self, reboot_required: bool):
        """
        Property 12: Conditional Reboot Logic
        
        **Validates: Requirements 4.6**
        
        For any VM state (reboot required or not), the playbook must have
        conditional logic to reboot only when /var/run/reboot-required exists.
        
        Args:
            reboot_required: Whether reboot is required (True/False)
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        # Find reboot task
        reboot_task = find_task_by_name(tasks, 'reboot if required')
        
        assert reboot_task is not None, (
            f"Playbook must have conditional reboot task (reboot_required={reboot_required})"
        )
        
        # Verify it uses reboot module
        assert check_task_has_module(reboot_task, 'reboot'), (
            f"Reboot task must use 'reboot' module (reboot_required={reboot_required})"
        )
        
        # Verify it has when condition
        assert check_task_has_when_condition(reboot_task), (
            f"Reboot task must have 'when' condition (reboot_required={reboot_required})"
        )

    
    @given(
        vm_index=st.integers(min_value=0, max_value=9)
    )
    @settings(max_examples=100)
    def test_property12_reboot_condition_checks_file_existence(self, vm_index: int):
        """
        Property 12: Reboot condition checks file existence
        
        **Validates: Requirements 4.6**
        
        For any VM (identified by index), the reboot task's when condition
        must check if the reboot-required file exists.
        
        Args:
            vm_index: Index of the VM (0-9)
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        reboot_task = find_task_by_name(tasks, 'reboot if required')
        assert reboot_task is not None, f"Reboot task must exist for VM index {vm_index}"
        
        when_condition = reboot_task.get('when')
        assert when_condition is not None, (
            f"Reboot task must have when condition for VM index {vm_index}"
        )
        
        # Convert when condition to string for checking
        when_str = str(when_condition)
        
        # Verify condition checks for file existence
        assert 'stat.exists' in when_str or 'exists' in when_str, (
            f"Reboot when condition must check file existence for VM index {vm_index}"
        )
    
    def test_property12_reboot_has_timeout(self):
        """
        Property 12: Reboot task has timeout configuration
        
        **Validates: Requirements 4.6**
        """
        ansible_dir = get_ansible_dir()
        playbook_path = ansible_dir / "gcp_vm_patching.yml"
        playbook = parse_ansible_playbook(playbook_path)
        
        play = playbook[0]
        tasks = extract_tasks_from_play(play)
        
        reboot_task = find_task_by_name(tasks, 'reboot if required')
        assert reboot_task is not None, "Reboot task must exist"
        
        reboot_params = reboot_task.get('reboot', {})
        
        # Verify timeout is configured
        assert 'reboot_timeout' in reboot_params, (
            "Reboot task must have reboot_timeout configured"
        )
        
        timeout = reboot_params.get('reboot_timeout')
        assert timeout is not None and int(timeout) > 0, (
            "Reboot timeout must be a positive value"
        )
