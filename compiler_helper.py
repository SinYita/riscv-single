#!/usr/bin/env python3
"""
RISC-V Single Cycle CPU Testbench Compiler Helper
Compiles and runs individual or all testbenches with their corresponding modules.

Usage:
    python3 compiler_helper.py [options] [module_names...]
    
Examples:
    python3 compiler_helper.py --all                    # Run all testbenches
    python3 compiler_helper.py ALU PC NPC               # Run specific testbenches
    python3 compiler_helper.py --compile-only ALU       # Only compile, don't run
    python3 compiler_helper.py --clean                  # Clean compiled files
    python3 compiler_helper.py --list                   # List available modules
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
import time

# Define testbench configurations
TESTBENCH_CONFIG = {
    'ALU': {
        'testbench': 'ALU_tb.v',
        'modules': ['ALU.v', 'ALU_Decoder.v'],
        'executable': 'alu_test',
        'description': 'Arithmetic Logic Unit'
    },
    'Controller': {
        'testbench': 'Controller_tb.v',
        'modules': ['Controller.v'],
        'executable': 'controller_test',
        'description': 'Main Controller (Instruction Decoder)'
    },
    'Data_Memory': {
        'testbench': 'Data_Memory_tb.v',
        'modules': ['Data_Memory.v'],
        'executable': 'data_memory_test',
        'description': 'Data Memory Unit'
    },
    'Instruction_Memory': {
        'testbench': 'Instruction_Memory_tb.v',
        'modules': ['Instruction_Memory.v'],
        'executable': 'instruction_memory_test',
        'description': 'Instruction Memory Unit'
    },
    'Mux': {
        'testbench': 'Mux_tb.v',
        'modules': ['Mux.v'],
        'executable': 'mux_test',
        'description': 'Multiplexer'
    },
    'NPC': {
        'testbench': 'NPC_tb.v',
        'modules': ['NPC.v'],
        'executable': 'npc_test',
        'description': 'Next Program Counter'
    },
    'PC': {
        'testbench': 'PC_tb.v',
        'modules': ['PC.v'],
        'executable': 'pc_test',
        'description': 'Program Counter'
    },
    'Register_File': {
        'testbench': 'Register_File_tb.v',
        'modules': ['Register_File.v'],
        'executable': 'register_file_test',
        'description': 'Register File'
    },
    'Sign_Extend': {
        'testbench': 'Sign_Extend_tb.v',
        'modules': ['Sign_Extend.v'],
        'executable': 'sign_extend_test',
        'description': 'Sign Extension Unit'
    },
    'Single_Cycle_Top': {
        'testbench': 'Single_Cycle_Top_tb.v',
        'modules': [],
        'executable': 'single_cycle_top_test',
        'description': 'Complete Single Cycle CPU'
    }
}

class Colors:
    """ANSI color codes for terminal output"""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'

def print_colored(text, color=None):
    """Print colored text to terminal"""
    if color:
        print(f"{color}{text}{Colors.END}")
    else:
        print(text)

def get_project_paths():
    """Get absolute paths for project directories"""
    script_dir = Path(__file__).parent.absolute()
    testbench_dir = script_dir / 'testbench'
    src_dir = script_dir / 'src'
    return script_dir, testbench_dir, src_dir

def compile_testbench(module_name, compile_only=False, verbose=False):
    """Compile and optionally run a specific testbench"""
    if module_name not in TESTBENCH_CONFIG:
        print_colored(f"Error: Module '{module_name}' not found", Colors.FAIL)
        return False
    
    config = TESTBENCH_CONFIG[module_name]
    script_dir, testbench_dir, src_dir = get_project_paths()
    
    print_colored(f"\nCompiling {config['description']} ({module_name})...", Colors.BLUE)
    
    # Change to testbench directory
    os.chdir(testbench_dir)
    
    # Build iverilog command
    testbench_file = config['testbench']
    module_files = [f"../src/{module}" for module in config['modules']]
    executable = config['executable']
    
    # Include define.v if it exists
    include_args = ['-I', '../src']
    
    compile_cmd = ['iverilog'] + include_args + ['-o', executable, testbench_file] + module_files
    
    if verbose:
        print_colored(f"Command: {' '.join(compile_cmd)}", Colors.CYAN)
    
    # Compile
    try:
        result = subprocess.run(compile_cmd, capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            print_colored(f"Compilation failed for {module_name}", Colors.FAIL)
            if result.stderr:
                print_colored(f"Error output:\n{result.stderr}", Colors.WARNING)
            return False
        else:
            print_colored(f"Compilation successful for {module_name}", Colors.GREEN)
            if result.stderr and verbose:  # Show warnings if verbose
                print_colored(f"Warnings:\n{result.stderr}", Colors.WARNING)
    
    except subprocess.TimeoutExpired:
        print_colored(f"Compilation timeout for {module_name}", Colors.FAIL)
        return False
    except Exception as e:
        print_colored(f"Compilation error for {module_name}: {e}", Colors.FAIL)
        return False
    
    # Run simulation if not compile-only
    if not compile_only:
        print_colored(f"Running {module_name} testbench...", Colors.BLUE)
        try:
            run_cmd = ['vvp', executable]
            if verbose:
                print_colored(f"Command: {' '.join(run_cmd)}", Colors.CYAN)
            
            result = subprocess.run(run_cmd, capture_output=True, text=True, timeout=60)
            if result.returncode != 0:
                print_colored(f"Simulation failed for {module_name}", Colors.FAIL)
                if result.stderr:
                    print_colored(f"Error output:\n{result.stderr}", Colors.WARNING)
                return False
            else:
                print_colored(f"Simulation completed for {module_name}", Colors.GREEN)
                if result.stdout:
                    print_colored(f"Simulation Output:", Colors.HEADER)
                    print(result.stdout)
        
        except subprocess.TimeoutExpired:
            print_colored(f"Simulation timeout for {module_name}", Colors.FAIL)
            return False
        except Exception as e:
            print_colored(f"Simulation error for {module_name}: {e}", Colors.FAIL)
            return False
    
    return True

def clean_files():
    """Clean compiled executables and VCD files"""
    script_dir, testbench_dir, src_dir = get_project_paths()
    os.chdir(testbench_dir)
    
    print_colored(f"Cleaning compiled files...", Colors.BLUE)
    
    cleaned_count = 0
    for module_name, config in TESTBENCH_CONFIG.items():
        executable = config['executable']
        vcd_file = f"{module_name}_tb.vcd"
        
        # Remove executable
        if os.path.exists(executable):
            os.remove(executable)
            print_colored(f"  Removed: {executable}", Colors.CYAN)
            cleaned_count += 1
        
        # Remove VCD file
        if os.path.exists(vcd_file):
            os.remove(vcd_file)
            print_colored(f"  Removed: {vcd_file}", Colors.CYAN)
            cleaned_count += 1
    
    print_colored(f"Cleaned {cleaned_count} files", Colors.GREEN)

def list_modules():
    """List all available modules"""
    print_colored(f"\nAvailable Modules:", Colors.HEADER)
    print_colored("=" * 60, Colors.HEADER)
    
    for module_name, config in TESTBENCH_CONFIG.items():
        print_colored(f"{module_name:20} - {config['description']}", Colors.CYAN)
    
    print_colored(f"\nTotal: {len(TESTBENCH_CONFIG)} modules available", Colors.BLUE)

def compiler_helper():
    parser = argparse.ArgumentParser(
        description='RISC-V Single Cycle CPU Testbench Compiler Helper',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --all                    # Run all testbenches
  %(prog)s ALU PC NPC               # Run specific testbenches  
  %(prog)s --compile-only ALU       # Only compile, don't run
  %(prog)s --clean                  # Clean compiled files
  %(prog)s --list                   # List available modules
        """
    )
    
    parser.add_argument('modules', nargs='*', 
                       help='Module names to compile/run (use --list to see available)')
    parser.add_argument('--all', action='store_true',
                       help='Compile and run all testbenches')
    parser.add_argument('--compile-only', action='store_true',
                       help='Only compile, do not run simulations')
    parser.add_argument('--clean', action='store_true',
                       help='Clean compiled executables and VCD files')
    parser.add_argument('--list', action='store_true',
                       help='List all available modules')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose output')
    
    args = parser.parse_args()
    
    # Handle special commands
    if args.clean:
        clean_files()
        return
    
    if args.list:
        list_modules()
        return
    
    # Determine which modules to process
    if args.all:
        modules_to_process = list(TESTBENCH_CONFIG.keys())
        print_colored(f"Running ALL testbenches...", Colors.HEADER)
    elif args.modules:
        modules_to_process = args.modules
    else:
        print_colored(f"Error: No modules specified. Use --all or specify module names.", Colors.FAIL)
        print_colored("Use --list to see available modules.", Colors.WARNING)
        return
    
    # Validate modules
    invalid_modules = [m for m in modules_to_process if m not in TESTBENCH_CONFIG]
    if invalid_modules:
        print_colored(f"Error: Invalid modules: {', '.join(invalid_modules)}", Colors.FAIL)
        print_colored("Use --list to see available modules.", Colors.WARNING)
        return
    
    # Process modules
    print_colored(f"\nProcessing {len(modules_to_process)} module(s)...", Colors.HEADER)
    
    success_count = 0
    start_time = time.time()
    
    for module_name in modules_to_process:
        success = compile_testbench(module_name, args.compile_only, args.verbose)
        if success:
            success_count += 1
    
    # Summary
    elapsed_time = time.time() - start_time
    print_colored("\n" + "=" * 60, Colors.HEADER)
    print_colored(f"Summary: {success_count}/{len(modules_to_process)} modules successful", 
                 Colors.GREEN if success_count == len(modules_to_process) else Colors.WARNING)
    print_colored(f"Total time: {elapsed_time:.2f} seconds", Colors.BLUE)
    
    if success_count == len(modules_to_process):
        print_colored(f"All operations completed successfully!", Colors.GREEN)
    else:
        print_colored(f"Some operations failed. Check the output above.", Colors.WARNING)

if __name__ == '__main__':
    try:
        compiler_helper()
    except KeyboardInterrupt:
        print_colored("\n\nOperation cancelled by user", Colors.WARNING)
        sys.exit(1)
    except Exception as e:
        print_colored(f"\nUnexpected error: {e}", Colors.FAIL)
        sys.exit(1)