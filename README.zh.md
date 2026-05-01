# KCICPT MATLAB

[English](README.md) | **中文文档**

基于**核条件独立聚类置换检验（Kernel Conditional Independence Cluster Permutation Test，KCICPT）**算法及其与 PC 算法集成的 MATLAB 实现，用于从连续型高维生物数据中学习调控网络结构。

本项目源自北京交通大学硕士学位论文研究，在 Gary Doran 等人提出的 KCIPT 算法基础上，通过 K-means 聚类置换、不完全 Cholesky 分解和高斯分布模拟三项关键优化，显著降低了算法在大样本数据上的时间复杂度，使核条件独立性检验真正适用于生物大数据场景。

---

## 算法亮点

- 基于置换与 MMD 统计量的核条件独立性检验框架。
- **K-means 聚类置换**：将置换优化的时间复杂度由 O(N³) 降低至 O(n·m³)，其中 n、m 均远小于 N。
- **不完全 Cholesky 分解**：构建 Gram 矩阵的低秩近似，将 MMD 计算复杂度由 O(N²) 降低至 O(m²N)。
- **高斯分布模拟 P 值**：利用随机扰乱结果建立高斯模型，将 P 值计算复杂度由 O(B·T·N) 降低至 O(B·S)，其中 S 远小于 T 和 N。
- Bootstrap / 经验零分布流程用于估计统计检验显著性。
- 与 PC 算法结合，实现贝叶斯/调控网络结构学习（KCICPT-PC）。
- 提供医学数据和单细胞信号网络数据的示例脚本。

---

## 算法核心逻辑

### 1. 问题背景

贝叶斯网络（Bayesian Network）是概率统计与图论结合的概率图模型，能够清晰表达变量间的因果关系。基于条件独立性检验的结构学习算法（如 PC 算法）以条件独立性检验为核心，通过判断变量间是否条件独立来决定网络中是否保留对应的边。

然而，传统基于核方法的条件独立性检验算法（Gary 等人提出的 KCIPT）在大样本数据上时间复杂度过高，难以实际应用。KCICPT 算法正是为解决这一问题而设计。

### 2. 最大均值差异（MMD）

KCICPT 算法以**最大均值差异（Maximum Mean Discrepancy，MMD）**作为两样本分布相似性的度量。在再生核希尔伯特空间（RKHS）上，MMD 的平方可表示为：

```
MMD²(P, Q) = E[k(x,x')] - 2E[k(x,y)] + E[k(y,y')]
```

其中 k 为高斯核函数，核宽取样本两两距离的中位数。若 MMD 值足够小，则认为两组样本来自相同分布；反之则来自不同分布。

### 3. 置换方法

KCICPT 通过构造置换样本将条件独立性检验转化为两样本检验：

- 给定变量 X、Y 及条件变量集 Z，目标是检验 X⊥Y|Z。
- 构造最优置换矩阵 P，使得置换后的样本 X̃ 满足 X̃⊥Y|Z。
- 通过求解最优化问题（最小化置换后 Z 值的距离之和）来确定置换矩阵。
- 计算原始分布与置换分布的 MMD，若 MMD 较大则拒绝条件独立假设。

### 4. K-means 聚类置换优化

直接在大规模样本上求解置换矩阵的时间复杂度为 O(N³)，无法适应大样本数据。

KCICPT 引入**K-means 聚类分治策略**：

1. 对条件变量 Z 进行 K-means 聚类，将样本分为 k 个类别。
2. 在每个类别内部分别进行置换优化。
3. 合并各类的置换结果，得到整体的近似最优置换。

经过此优化，时间复杂度降低为 O(k·m³)，其中 m 为每类内样本数上限，k·m³ 远小于 N³。实验验证表明，聚类置换与全量置换的网络学习效果相当。

### 5. 不完全 Cholesky 分解优化

KCICPT 需要反复计算大型 Gram 矩阵的 MMD 值，直接计算时间复杂度为 O(N²)。

**不完全 Cholesky 分解**通过将半正定的 Gram 矩阵 K（N×N）分解为低秩矩阵的乘积来近似表示：

```
K ≈ G · Gᵀ，  其中 G 为 N×m 矩阵，m << N
```

分解后，MMD 计算可以利用低秩矩阵完成，复杂度由 O(N²) 降低至 O(m²N)。其中 m 为不完全分解的秩参数，可人为设定以平衡精度与效率。

### 6. 高斯分布模拟 P 值优化

P 值的计算通常需要大量随机扰乱（Monte Carlo 迭代），时间开销为 O(B·T·N)。

KCICPT 利用以下思路优化：

1. 随机扰乱结果近似服从高斯分布。
2. 对每个 Outer Bootstrap 采样，通过有限次（200次）随机扰乱估计均值和方差。
3. 利用已知高斯分布参数直接计算 P 值，无需再进行大量蒙特卡洛迭代。

```
P-value = 1 - Φ((statistic - μ) / σ)
```

此优化将 P 值计算复杂度由 O(B·T·N) 降低至 O(B·S)，其中 S 远小于 T·N。

### 7. KCICPT-PC 结构学习

将 KCICPT 条件独立性检验嵌入 PC 算法框架：

1. 初始化完全无向图。
2. 迭代对每对相邻节点检验条件独立性（调用 KCICPT）。
3. 若检验结果为条件独立（p-value ≥ α），则删除两节点间的边并记录分离集。
4. 逐步提高分离集阶数，直到无法继续删边。
5. 通过方向规则确定剩余边的方向，得到 PDAG（部分有向无环图）。

---

## 仓库结构

```text
.
├── kcipt/              # KCICPT 核心算法实现
├── algorithms/         # 高斯过程与核工具函数
├── experiments/        # 合成/混沌数据实验入口
├── data/               # 示例数据集及数据生成工具
├── docs/               # 研究论文草稿及项目文档
├── bnt/                # Bayesian Network Toolbox 依赖快照
├── gpml-matlab/        # GPML MATLAB 依赖快照
├── run_digoxin_pc.m    # PC 学习示例入口
├── setup_kcicpt.m      # 初始化 MATLAB 路径
└── *.m                 # 核函数、绘图与工具函数
```

---

## 主要入口文件

- `kcipt/kcipt.m`：运行 KCICPT 统计量与经验零分布估计。
- `kcipt/kcipt_pc.m`：将 KCICPT 封装为 PC 结构学习的条件独立性检验接口。
- `kcipt/MyIchol.m`：不完全 Cholesky 近似，用于加速核计算。
- `run_digoxin_pc.m`：Fukumizu 医学数据集（Digoxin）的 PC 结构学习示例。
- `experiments/kcipt_chaotic.m`：合成混沌系统实验驱动脚本。
- `docs/KCICPT-paper-draft.pdf`：原始研究论文草稿。

---

## 环境要求

- MATLAB（原始开发与测试基于 MATLAB 2010 前后版本语法）。
- Statistics and Machine Learning Toolbox（需要 `kmeans`、`normrnd` 等函数）。
- 已打包的 BNT 和 GPML MATLAB 依赖快照，无需额外安装。

---

## 快速开始

在 MATLAB 中执行：

```matlab
cd /path/to/kcicpt-matlab
setup_kcicpt
load digoxin_4.mat
run_digoxin_pc(digoxin, 0.05)
```

若变量名与 `digoxin` 不同，可直接传入数值矩阵：

```matlab
data = load('digoxin_4.mat');
run_digoxin_pc(data.<variable_name>, 0.05)
```

其中第二个参数 `0.05` 为显著性水平 α，常用取值为 0.01、0.05、0.1。

---

## 实验数据集

### Fukumizu 医学数据（digoxin）

- 来源：Fukumizu (2008) 实验数据。
- 包含三个变量：肌酐清除率（creatinine clearance）、地高辛清除率（digoxin clearance）、尿流量（urine flow），共 35 个样本。
- 对应一个三节点调控网络，可学习出包含两条无向边的 PDAG 结构。

### Sachs 单细胞信号网络数据

- 来源：Karen Sachs (2005)，通过流式细胞术测定磷酸化蛋白质和磷脂获得。
- 包含 11 个变量（磷酸化蛋白和磷脂），共 11,672 个样本（本文使用多种 k-means 聚类缩减后的版本）。
- 实验表明，KCICPT-PC 从该数据中恢复的调控网络优于 Grow-Shrink (GS)、IAMB、Fast-IAMB、Inter-IAMB 等传统非核方法。

---

## 性能对比

在 Sachs k-means2000 数据上，各优化策略时间开销对比（秒）：

| 算法配置 | 耗时 (s) |
|---|---|
| 原始 KCIPT | >> 423,009 |
| + Cholesky 分解 | 176,491 |
| + Cholesky + 聚类置换(400) | 111,059 |
| + Cholesky + 聚类置换(400) + 高斯模拟 | 66,695 |

三项优化叠加后，收敛时间缩减至原始 KCIPT 的 15% 以内。

---

## 引用

如果本代码对您的学术研究有帮助，请引用：

> 郭珣. 基于 KCICPT 算法的基因调控网络结构学习研究 [D]. 北京：北京交通大学，2017.

> Xun Guo, Yi Liu, Zhengwei Xie. Regulator network learning algorithm based on Kernel Conditional Independence Cluster Permutation Test (KCICPT) algorithm.

原始论文草稿及参考资料见 [`docs/`](https://github.com/guoxun/kcicpt-matlab/tree/master/docs)。
