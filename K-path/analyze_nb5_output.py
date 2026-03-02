import pandas as pd
import numpy as np

# Load the data
df = pd.read_csv('nb5_kpath_descriptors-results/rashba_206_all_descriptors.csv')

print(f"=" * 80)
print(f"NB5 OUTPUT ANALYSIS")
print(f"=" * 80)

print(f"\n1. BASIC SHAPE")
print(f"   Rows: {df.shape[0]}")
print(f"   Columns: {df.shape[1]}")

print(f"\n2. COLUMN TYPES")
id_cols = ['Formula', 'uid', 'kpath', 'Rashba_parameter']
feature_cols = [c for c in df.columns if c not in id_cols]
print(f"   ID columns: {len(id_cols)}")
print(f"   Feature columns: {len(feature_cols)}")

print(f"\n3. NaN DISTRIBUTION")
nan_pct = (df.isna().sum() / len(df) * 100).sort_values(ascending=False)
print(f"   Features with >90% NaN: {(nan_pct > 90).sum()}")
print(f"   Features with >80% NaN: {(nan_pct > 80).sum()}")
print(f"   Features with >50% NaN: {(nan_pct > 50).sum()}")
print(f"   Features with >10% NaN: {(nan_pct > 10).sum()}")
print(f"   Features with 0% NaN: {(nan_pct == 0).sum()}")

print(f"\n4. TOP 40 FEATURES BY NaN%")
for i, (col, pct) in enumerate(nan_pct.head(40).items(), 1):
    print(f"   {i:2d}. {col:50s} {pct:5.1f}%")

print(f"\n5. FEATURE TYPE BREAKDOWN")
# Categorize features
rdf_features = [c for c in feature_cols if 'rdf' in c.lower() or 'coord' in c.lower()]
adf_features = [c for c in feature_cols if 'adf' in c.lower()]
kpath_features = [c for c in feature_cols if 'kpath' in c.lower() or 'kvec' in c.lower() or 'kstart' in c.lower() or 'kend' in c.lower() or 'kmid' in c.lower()]
deg_features = [c for c in feature_cols if 'degeneracy' in c.lower() or 'weight' in c.lower()]
elem_features = [c for c in feature_cols if any(x in c.lower() for x in ['radius', 'mass', 'max_z', 'mean_z', 'sum_z', 'x_mean', 'x_diff', 'n_elements'])]
dos_features = [c for c in feature_cols if 'pfrac' in c.lower() or 'e_' in c.lower()]
nearest_features = [c for c in feature_cols if 'nearest' in c.lower()]
other_features = [c for c in feature_cols if c not in rdf_features + adf_features + kpath_features + deg_features + elem_features + dos_features + nearest_features]

print(f"   RDF/Coord: {len(rdf_features)}, Avg NaN: {df[rdf_features].isna().mean().mean()*100:.1f}%")
print(f"   ADF: {len(adf_features)}, Avg NaN: {df[adf_features].isna().mean().mean()*100:.1f}%")
print(f"   K-path geometry: {len(kpath_features)}, Avg NaN: {df[kpath_features].isna().mean().mean()*100:.1f}%")
print(f"   Degeneracy: {len(deg_features)}, Avg NaN: {df[deg_features].isna().mean().mean()*100:.1f}%")
print(f"   Elemental: {len(elem_features)}, Avg NaN: {df[elem_features].isna().mean().mean()*100:.1f}%")
print(f"   DOS: {len(dos_features)}, Avg NaN: {df[dos_features].isna().mean().mean()*100:.1f}%")
print(f"   Nearest: {len(nearest_features)}, Avg NaN: {df[nearest_features].isna().mean().mean()*100:.1f}%")
print(f"   Other: {len(other_features)}, Avg NaN: {df[other_features].isna().mean().mean()*100:.1f}%")

print(f"\n6. CUTOFF DISTANCE ANALYSIS")
cutoff_cols = {}
for col in feature_cols:
    if 'A' in col and any(c.isdigit() for c in col):
        # Extract cutoff value
        parts = col.split('_')
        for part in parts:
            if 'A' in part:
                try:
                    cutoff = float(part.replace('A', ''))
                    if cutoff not in cutoff_cols:
                        cutoff_cols[cutoff] = []
                    cutoff_cols[cutoff].append(col)
                except:
                    pass

if cutoff_cols:
    for cutoff in sorted(cutoff_cols.keys()):
        cols = cutoff_cols[cutoff]
        avg_nan = df[cols].isna().mean().mean() * 100
        print(f"   {cutoff:.1f}A cutoff: {len(cols)} features, Avg NaN: {avg_nan:.1f}%")

print(f"\n7. UNIQUE VALUE COUNTS (for features with few values)")
low_var = []
for col in feature_cols:
    n_unique = df[col].nunique()
    if n_unique <= 5:
        low_var.append((col, n_unique, df[col].isna().sum()))

if low_var:
    print(f"   Features with ≤5 unique values: {len(low_var)}")
    for col, n_unique, n_nan in sorted(low_var, key=lambda x: x[1])[:20]:
        print(f"      {col:50s} unique={n_unique}, NaN={n_nan}")

print(f"\n8. DESCRIPTOR GROUP SUMMARY")
print(f"   start_ prefix: {len([c for c in feature_cols if c.startswith('start_')])}")
print(f"   mid_ prefix: {len([c for c in feature_cols if c.startswith('mid_')])}")
print(f"   end_ prefix: {len([c for c in feature_cols if c.startswith('end_')])}")

print(f"\n" + "=" * 80)
