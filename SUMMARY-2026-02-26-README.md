# Spintronics Compounds Analysis - Project Summary
**Date:** February 26, 2026

---

## Project Overview
Analysis of 2D spintronics materials including Rashba effect, Zeeman splitting, and other spin-dependent phenomena. This project contains computational data and analysis tools for investigating electronic and spin properties of various 2D compounds.

---

## Current Work: Orbital & Atomic DOS Contribution Analysis

### Scope
**Analysis completed for a single compound (ZrCl2)** to establish methodology and workflow for future large-scale analysis.

### What Was Done

#### 1. **DOS Parsing & Band Edge Identification**
- Parsed VASP output (`vasprun.xml`) for electronic structure data
- Identified Fermi energy, VBM (Valence Band Maximum), and CBM (Conduction Band Minimum)
- Calculated band gap and energy windows (±0.5 eV) around VBM and CBM

#### 2. **Contribution Analysis**
- Computed element-wise (atomic) contributions to DOS at band edges
- Decomposed orbital contributions (s, p, d) for each element
- Integrated DOS within VBM and CBM windows using trapezoidal integration
- Normalized contributions to percentage weights

#### 3. **Visualization**
- **DOS Plot**: Total and element-projected DOS with highlighted VBM/CBM windows
- **Pie Charts**: Atomic and orbital contributions for VBM and CBM separately
- Generated quantitative breakdown of which elements and orbitals dominate band edges

### Key Results
- Element-wise and orbital-wise percentage contributions to VBM and CBM
- Visual identification of dominant orbitals and atoms at band edges
- Established repeatable workflow for DOS decomposition analysis

---

## Project Structure

```
Keshav-DDP/
│
├── Weight-contribution/
│   └── orbital.ipynb                    # Main analysis notebook (DOS, atomic/orbital contributions)
│
├── Inverse-design/
│   ├── download_nomad.ps1               # Data download script
│   └── [180+ compound directories]/     # VASP calculation outputs for 2D materials
│       ├── ZrCl2-dc09b7c396eb/          # Example: single compound analyzed
│       ├── Ag2Cl2-dd5f0964d63d/
│       ├── BN-4a5edc763604/
│       ├── MoS2-*/
│       └── ...                          # Additional compounds (halides, chalcogenides, etc.)
│           └── ss_2d%2F[compound]%2Fbands_ncl%2Fvasprun.xml  # Electronic structure data
│
├── ss_2d_materials.json                 # Compound metadata
│
└── SUMMARY-2026-02-26-README.md         # This file

```

---

## Long-Term Planning

### Current Status
✅ **Single compound workflow established** - Methodology validated on ZrCl2  
⏳ **Scale-up pending** - 180+ compounds available for systematic analysis

### Next Steps
1. **Automate batch processing** for all compounds in `Inverse-design/`
2. **Comparative analysis** across material families (TMDs, halides, chalcogenides)
3. **Correlation studies** between atomic/orbital contributions and spintronics properties
4. **Database creation** for quick lookup of band edge characteristics

### Methodological Foundation
The notebook workflow provides:
- Reusable functions for DOS integration and normalization
- Standardized visualization templates
- Extensible framework for additional analysis (e.g., spin-texture, symmetry)

---

## Technical Details

### Tools & Libraries
- **Pymatgen**: VASP output parsing, DOS analysis
- **NumPy**: Numerical integration and array operations
- **Matplotlib**: Visualization (DOS plots, pie charts)

### Energy Windows
- **VBM Window**: [VBM - 0.5 eV, VBM]
- **CBM Window**: [CBM, CBM + 0.5 eV]
- Fermi energy shifted to zero for consistency

### Contribution Calculation
1. Extract orbital-projected DOS for each element
2. Integrate DOS over energy window (trapezoidal rule)
3. Normalize to percentage (sum = 100% for VBM/CBM separately)

---

## Notes
- **Material scope**: Not limited to Rashba materials; includes Zeeman-type and other spintronics-relevant compounds
- **SOC treatment**: Correctly handles spin-orbit coupling (both spin channels summed where applicable)
- **Reproducibility**: All analysis parameters clearly defined in notebook cells

---

**Analyst Notes:**  
This foundational work on a single compound establishes confidence in the methodology before scaling to the full dataset. The modular notebook design allows easy adaptation for batch processing and comparative studies across the extensive compound library.
