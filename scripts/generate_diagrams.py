import os
import re
import subprocess
import sys

def extract_mermaid(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    match = re.search(r'```mermaid\n(.*?)\n```', content, re.DOTALL)
    if not match:
        print("Error: No Mermaid diagram found in ARCHITECTURE.md")
        sys.exit(1)
    
    return match.group(1)

def generate_part_mermaid(full_mermaid, part_num):
    # Header - only one of these should exist in the final file
    header = "%%{init: {'themeVariables': { 'fontSize': '16px', 'fontFamily': 'Inter, system-ui, sans-serif' }}}%%\nflowchart TD\n"
    
    # Extract global styles and classes
    class_defs = re.findall(r'^[ \t]*(?:classDef|class|style|linkStyle)[ \t].*$', full_mermaid, re.MULTILINE)
    global_styles = "\n".join(class_defs)
    
    # Extract the part content based on comment markers %% PART 1 %% and %% PART 2 %%
    if part_num == 1:
        # Part 1 starts after the flowchart TD and goes to %% PART 2 %%
        # Use re.DOTALL to match across newlines
        pattern = r'(?:flowchart TD\s*)?(.*?)(?=%% PART 2 %%)'
    else:
        # Part 2 starts at %% PART 2 %% and goes to the class definitions
        pattern = r'%% PART 2 %%\s*(.*?)(?=\n[ \t]*(?:classDef|class|style|linkStyle)[ \t]|$)'
        
    match = re.search(pattern, full_mermaid, re.DOTALL)
    
    if not match:
        print(f"Error: Could not find Part {part_num} content.")
        sys.exit(1)
    
    part_content = match.group(1).strip()
    
    # Clean up any leftover flowchart TD in the content itself (for Part 1)
    part_content = re.sub(r'^flowchart TD\s*', '', part_content, flags=re.MULTILINE)
    
    return f"{header}\n{part_content}\n\n{global_styles}\n"

def export_diagram(mermaid_text, output_path):
    temp_mmd = "temp_diagram.mmd"
    with open(temp_mmd, 'w') as f:
        f.write(mermaid_text)
    
    try:
        print(f"Exporting to {output_path}...")
        subprocess.run(["mmdc", "-i", temp_mmd, "-o", output_path, "-b", "white", "-w", "2000"], check=True)
        print(f"Successfully exported {output_path}!")
    except FileNotFoundError:
        print("\nError: 'mmdc' (Mermaid CLI) not found.")
        print("Please install it globally using: npm install -g @mermaid-js/mermaid-cli")
    except subprocess.CalledProcessError as e:
        print(f"Error exporting diagram: {e}")
    finally:
        if os.path.exists(temp_mmd):
            os.remove(temp_mmd)

def main():
    arch_file = "ARCHITECTURE.md"
    output_dir = "images"
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    full_mermaid = extract_mermaid(arch_file)
    
    # Export Part 1
    print("\nProcessing Part 1...")
    p1_mermaid = generate_part_mermaid(full_mermaid, 1)
    export_diagram(p1_mermaid, os.path.join(output_dir, "part1.png"))
    
    # Export Part 2
    print("\nProcessing Part 2...")
    p2_mermaid = generate_part_mermaid(full_mermaid, 2)
    export_diagram(p2_mermaid, os.path.join(output_dir, "part2.png"))

if __name__ == "__main__":
    main()
