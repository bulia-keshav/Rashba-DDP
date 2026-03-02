# NB5 K-path Descriptors Output Analysis

**File analyzed**: `K-path/nb5_kpath_descriptors-results/rashba_206_all_descriptors.csv`  
**Analysis date**: 2025

---

## 1. Dataset Dimensions

- **Total rows**: 205 (expected 206 from rashba.csv)
- **Total columns**: 1,263
  - Identifier columns: 4 (Formula, uid, kpath, Rashba_parameter)
  - Feature columns: 1,259

---

## 2. NaN Distribution Summary

| NaN Threshold | Feature Count | % of Total Features |
|--------------|---------------|---------------------|
| >90% NaN | 1,113 | 88.4% |
| >80% NaN | 1,197 | 95.1% |
| >50% NaN | 1,197 | 95.1% |
| >10% NaN | 1,197 | 95.1% |
| 0% NaN | 66 | 5.2% |

**Key observation**: 1,197 out of 1,259 features (95%) have >10% missing values.

---

## 3. Feature Type Breakdown

| Feature Type | Count | Avg NaN % |
|-------------|-------|-----------|
| RDF/Coord | 855 | 96.5% |
| Elemental properties | 527 | 93.9% |
| ADF | 15 | 0.0% |
| K-path geometry | 18 | 0.0% |
| Degeneracy/weight | 4 | 0.0% |
| DOS (pfrac/e_) | 4 | 0.0% |
| Nearest neighbor | 12 | 0.0% |
| Other | 3 | 0.0% |

**Key observation**: RDF and elemental features have high NaN rates. ADF, k-path geometry, degeneracy, DOS, and nearest neighbor features have no missing values.

---

## 4. Descriptor Point Distribution

| Prefix | Count | Description |
|--------|-------|-------------|
| `start_` | 408 | K-path start point descriptors |
| `mid_` | 408 | K-path midpoint descriptors |
| `end_` | 408 | K-path endpoint descriptors |

Each k-path point has 408 features computed.

---

## 5. Cutoff Distance Analysis

**Observed cutoff range**: 3.3Å to 11.6Å  
**Total unique cutoffs**: 56  
**Features per cutoff**: 21

**NaN percentage by cutoff distance** (sample):

| Cutoff | Avg NaN % | Cutoff | Avg NaN % | Cutoff | Avg NaN % |
|--------|-----------|--------|-----------|--------|-----------|
| 3.9Å | 94.1% | 4.1Å | 89.8% | 4.2Å | 89.8% |
| 5.9Å | 94.1% | 6.3Å | 89.8% | 7.1Å | 89.3% |
| 4.6Å | 99.5% | 5.5Å | 99.5% | 5.7Å | 99.5% |
| 6.9Å | 99.5% | 7.8Å | 99.5% | 9.1Å | 99.0% |

**Observation**: All cutoffs show >89% average NaN. No clear pattern between cutoff distance and NaN rate.

---

## 6. Top Features by NaN Percentage

All top 40 features have 99.5% NaN (204 out of 205 rows missing). Sample:

1. `start_coord_4.6A` - 99.5%
2. `start_rdf_sum_4.6A` - 99.5%
3. `start_rdf_Z_4.6A` - 99.5%
4. `mid_coord_5.5A` - 99.5%
5. `end_rdf_mass_5.7A` - 99.5%

Full list contains features from all three k-path points (start/mid/end) and various cutoff distances.

---

## 7. Low Variance Features

**Features with ≤5 unique values**: 920 (73% of all features)

Sample of features with exactly 1 unique value (constant across all non-NaN entries):

- `start_coord_3.3A` - 1 unique, 198 NaN
- `start_coord_4.9A` - 1 unique, 203 NaN
- `mid_coord_3.3A` - 1 unique, 198 NaN
- `end_coord_5.0A` - 1 unique, 198 NaN

**Observation**: Many features have constant values for the few structures where they are not NaN.

---

## 8. Complete Feature List (0% NaN)

The following 66 features have **no missing values**:

**K-path geometry (18)**:
- kvec_x_start, kvec_y_start, kvec_z_start
- kvec_x_end, kvec_y_end, kvec_z_end
- kvec_x_mid, kvec_y_mid, kvec_z_mid
- kstart_x, kstart_y, kstart_z
- kend_x, kend_y, kend_z
- kmid_x, kmid_y, kmid_z

**Degeneracy (4)**:
- degeneracy_start, degeneracy_end
- weight_start, weight_end

**ADF features (15)**:
- start_adf_mean, start_adf_std, start_adf_max, start_adf_min, start_adf_range
- mid_adf_mean, mid_adf_std, mid_adf_max, mid_adf_min, mid_adf_range
- end_adf_mean, end_adf_std, end_adf_max, end_adf_min, end_adf_range

**DOS features (4)**:
- pfrac_VBM, pfrac_VBM_1, e_VBM, e_VBM_1

**Nearest neighbor (12)**:
- start_nearest_dist_1, start_nearest_dist_2, start_nearest_dist_3, start_nearest_dist_4
- mid_nearest_dist_1, mid_nearest_dist_2, mid_nearest_dist_3, mid_nearest_dist_4
- end_nearest_dist_1, end_nearest_dist_2, end_nearest_dist_3, end_nearest_dist_4

**Elemental (3)**:
- n_elements, X_mean, X_diff

**Other (10)**:
- start_min_radius, start_max_radius, start_mean_radius
- mid_min_radius, mid_max_radius, mid_mean_radius
- end_min_radius, end_max_radius, end_mean_radius
- start_total_mass

---

## 9. Expected vs Actual Rows

- **Input (rashba.csv)**: 206 entries
- **Output CSV**: 205 rows
- **Missing**: 1 row

---

## 10. Statistical Summary

| Metric | Value |
|--------|-------|
| Total data points | 258,915 (205 × 1,263) |
| Non-NaN data points | ~38,000 (estimated) |
| Data completeness | ~15% |
| Usable features (0% NaN) | 66 (5.2%) |
| Problematic features (>90% NaN) | 1,113 (88.4%) |

---

## 11. Implemented Changes in NB5

Changes applied to Cell 8 per GRDF methodology:

1. **Z-projection**: `kfrac_to_realspace` projects k-points to mean slab z-coordinate
   ```python
   mean_z_frac = np.mean([site.frac_coords[2] for site in structure])
   frac[2] = mean_z_frac
   ```

2. **Adaptive cutoffs**: `get_cutoffs` function computes cutoffs as 1.0a and 1.5a
   ```python
   a = np.linalg.norm(structure.lattice.matrix[0])
   return [1.0 * a, 1.5 * a]
   ```

3. **RDF descriptor changes**:
   - `compute_point_environment` uses adaptive cutoffs
   - Suffix format changed from `.0f` to `.1f` (e.g., `4A` → `4.6A`)

4. **POSCAR loading**: Cell 4 `load_structure` function replaced with robust element parser

Changes applied to Cell 4:
- Manual POSCAR parsing to extract element symbols correctly
- Element verification (checks if Z ≤ 3)
- Fallback strategies for misread element names

---

## 12. Observed Cutoff Values

The adaptive cutoff system generated 56 unique cutoff distances ranging from 3.3Å to 11.6Å. Each cutoff has 21 associated features computed.

**Sample cutoffs** (in ascending order):
3.3, 3.4, 3.7, 3.8, 3.9, 4.0, 4.1, 4.2, 4.3, 4.4, 4.6, 4.7, 4.9, 5.0, 5.1, 5.5, 5.6, 5.7, 5.8, 5.9, 6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.9, 7.0, 7.1, 7.2, 7.3, 7.4, 7.6, 7.7, 7.8, 9.1, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9, 10.0, 10.1, 10.5, 10.6, 10.7, 10.8, 10.9, 11.0, 11.1, 11.4, 11.5, 11.6

This represents variable lattice parameters across the 99 compounds in the dataset.

---

## 13. Data Quality Indicators

**Features that ran successfully**:
- All k-path geometry features extracted
- All ADF calculations completed
- All degeneracy/weight values extracted
- All DOS features extracted
- All nearest neighbor distances computed
- All global elemental properties computed

**Features with high failure rate**:
- RDF-based features at all cutoff distances
- Elemental property features computed at RDF cutoffs (mean_Z, max_Z, sum_Z per cutoff)
- Coordination number features at all cutoffs

---

**End of report**
