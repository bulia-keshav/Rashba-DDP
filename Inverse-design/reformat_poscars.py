"""
Reformat POSCARs from nonstandard to standard VASP5 format.

Problem: Our POSCARs have element names on line 1 (comment line) 
instead of line 6 (between lattice vectors and atom counts).
Pymatgen reads line 6 for elements, finds digits, assumes VASP4 format,
and assigns H, He, Li instead of the actual elements.

Fix: Move element names from line 1 to line 6 (standard VASP5 position).

Input:  Inverse-design/rashba/*/ss_2d*POSCAR
Output: Inverse-design/rashba/*/POSCAR_std  (new file, original untouched)

Run from: Keshav-DDP/Inverse-design/
"""

import os
import glob

# =============================================================================
# CONFIG -- change this if you run from a different location
# =============================================================================
RASHBA_DIR = os.path.join(".", "rashba")
OUTPUT_NAME = "POSCAR_std"  # name of the reformatted file

# =============================================================================

folders = sorted(glob.glob(os.path.join(RASHBA_DIR, "*")))
print(f"Found {len(folders)} compound folders in {RASHBA_DIR}")

converted = 0
skipped = 0
errors = 0

for folder in folders:
    if not os.path.isdir(folder):
        continue
    
    # Find the original POSCAR
    matches = glob.glob(os.path.join(folder, "ss_2d*POSCAR"))
    if not matches:
        # Try direct POSCAR
        direct = os.path.join(folder, "POSCAR")
        if os.path.exists(direct):
            matches = [direct]
        else:
            skipped += 1
            continue
    
    poscar_path = matches[0]
    
    try:
        with open(poscar_path, 'r') as f:
            lines = f.readlines()
        
        # Current format:
        # line 0: "As Te Br"        <- element names (comment line)
        # line 1: "1.0"             <- scaling
        # line 2-4: lattice vectors
        # line 5: "1  1  1"         <- atom counts
        # line 6: "Cartesian"       <- coord type
        # line 7+: coordinates
        
        # Check if line 0 has element names (letters, not digits)
        line0_parts = lines[0].strip().split()
        line5_parts = lines[5].strip().split()
        
        # Verify: line 0 should be element names, line 5 should be counts
        line0_is_elements = all(p.isalpha() or p == '_' for p in line0_parts)
        line5_is_counts = all(p.isdigit() for p in line5_parts)
        
        if not (line0_is_elements and line5_is_counts):
            # Maybe it's already in standard format, skip
            skipped += 1
            continue
        
        # Reformat to standard VASP5:
        # line 0: comment (use formula as comment)
        # line 1: scaling
        # line 2-4: lattice vectors
        # line 5: element names  <- MOVED HERE
        # line 6: atom counts
        # line 7: coord type
        # line 8+: coordinates
        
        element_names = lines[0].strip()  # "As Te Br"
        
        new_lines = []
        new_lines.append(f"{element_names}\n")         # line 0: comment (keep elements as comment too)
        new_lines.append(lines[1])                      # line 1: scaling
        new_lines.append(lines[2])                      # line 2: a vector
        new_lines.append(lines[3])                      # line 3: b vector
        new_lines.append(lines[4])                      # line 4: c vector
        new_lines.append(f"   {element_names}\n")       # line 5: element names (NEW)
        new_lines.append(lines[5])                      # line 6: atom counts (was line 5)
        for line in lines[6:]:                          # line 7+: coord type + coordinates
            new_lines.append(line)
        
        # Write to new file in the same folder
        out_path = os.path.join(folder, OUTPUT_NAME)
        with open(out_path, 'w') as f:
            f.writelines(new_lines)
        
        converted += 1
        
    except Exception as e:
        print(f"  ERROR: {os.path.basename(folder)}: {e}")
        errors += 1

print(f"\nDone!")
print(f"  Converted: {converted}")
print(f"  Skipped:   {skipped}")
print(f"  Errors:    {errors}")
print(f"\nOutput: {OUTPUT_NAME} in each compound folder")
print(f"In nb5 Cell 4, change the glob pattern to look for '{OUTPUT_NAME}':")
print(f'  matches = glob.glob(os.path.join(compound_folder, "{OUTPUT_NAME}"))')
