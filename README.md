# KCICPT MATLAB

MATLAB implementation of **Kernel Conditional Independence Cluster Permutation Test (KCICPT)** and its integration with the PC algorithm for learning regulatory networks from continuous, high-dimensional biological data.

This project was developed from a graduate research project on regulator network learning. It extends kernel conditional independence permutation testing with clustering, incomplete Cholesky decomposition, and Gaussian sampling to make conditional-independence-based structure learning more tractable on biological datasets.

## Highlights

- Kernel conditional independence testing based on permutation and MMD statistics.
- Clustered permutation strategy to reduce the cost of conditional permutations.
- Incomplete Cholesky approximation for accelerating kernel MMD computation.
- Bootstrap / empirical-null workflow for estimating test significance.
- PC algorithm integration for Bayesian/regulatory network structure learning.
- Example datasets and scripts for medical data and single-cell signaling network experiments.

## Repository layout

```text
.
├── kcipt/              # Core KCICPT implementation
├── algorithms/         # Gaussian process and kernel utility routines
├── experiments/        # Experiment entry points for synthetic/chaotic data
├── data/               # Small example datasets and data-generation helpers
├── docs/               # Research paper draft and project documentation
├── bnt/                # Bayesian Network Toolbox dependency snapshot
├── gpml-matlab/        # GPML MATLAB dependency snapshot
├── run_digoxin_pc.m    # Example PC learning entry point
├── setup_kcicpt.m      # Adds project paths for MATLAB sessions
└── *.m                 # Kernel, plotting, and utility helpers
```

## Main entry points

- `kcipt/kcipt.m`: runs the KCICPT statistic and empirical null estimation.
- `kcipt/kcipt_pc.m`: wraps KCICPT as a conditional independence test for PC learning.
- `kcipt/MyIchol.m`: incomplete Cholesky approximation used to accelerate kernel computation.
- `run_digoxin_pc.m`: example workflow for running PC structure learning on a matrix dataset.
- `experiments/kcipt_chaotic.m`: synthetic chaotic-system experiment driver.
- `docs/KCICPT-paper-draft.docx`: original research manuscript draft for the KCICPT project.

## Requirements

- MATLAB, originally developed and tested around MATLAB 2010-era syntax.
- Statistics and Machine Learning Toolbox for routines such as `kmeans` and `normrnd`.
- The bundled BNT and GPML MATLAB dependency snapshots are included for reproducibility.

## Quick start

From MATLAB, run:

```matlab
cd /path/to/kcicpt-matlab
setup_kcicpt
load digoxin_4.mat
run_digoxin_pc(digoxin, 0.05)
```

If your workspace variable name differs from `digoxin`, pass the loaded numeric matrix directly:

```matlab
data = load('digoxin_4.mat');
run_digoxin_pc(data.<variable_name>, 0.05)
```

## Algorithm summary

KCICPT tests whether `X` and `Y` are conditionally independent given `Z` by comparing original samples with conditionally permuted samples. It uses an RBF-kernel MMD statistic, clusters conditioning variables to limit permutation cost, and applies incomplete Cholesky decomposition to avoid constructing full dense Gram matrices for repeated MMD computations.

When integrated with the PC algorithm, KCICPT acts as the conditional independence oracle used to remove edges and recover a Markov-equivalence class for regulatory network structure learning.

## Notes

- Several scripts were preserved from the original research workspace, including experiment outputs and intermediate data files.
- Generated profiling reports, compiled binaries, and large temporary experiment artifacts are ignored by `.gitignore` for future commits.
- Third-party dependency snapshots keep their original license/readme files inside their directories.

## Citation

If this code is useful for academic work, please cite the project as:

> Xun Guo, Yi Liu, Zhengwei Xie. Regulator network learning algorithm based on Kernel Conditional Independence Cluster Permutation Test (KCICPT) algorithm.

Reference materials and the original manuscript draft are available in [`docs/`](https://github.com/guoxun/kcicpt-matlab/tree/master/docs).
