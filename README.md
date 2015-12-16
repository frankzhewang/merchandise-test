# merchandise-test
Numerics in the paper "Optimal Merchandise Testing with Limited Inventory"

## Setup UNC KillDevil

- Connect to UNC KillDevil
```bash
ssh youronyen@killdevil.unc.edu
```
Use your Onyen password to log in.

- Load Git, Matlab and Mathematica every time you log in.
```bash
module initadd git
module initadd matlab
module initadd mathematica 
```
Please refer to http://help.unc.edu/help/getting-started-on-killdevil/ for detailed instructions.

- Clone this repo
```bash
git clone https://github.com/frankzhewang/merchandise-test.git
```
The above command can also be used to setup on a personal computer.

## Switch between versions
This repo contains different versions of the numerical analysis

Currently, there are two versions: `master`, and `testing`. The `master` version

You can use the following Git command under the root directory to switch between versions:
```bash
git checkout <version name>
```
## Run numerical analysis

### Generate demand paths

## Generate Figures

Before generating a figures, make sure that you have the relevant data ready.

### Figure 1

- Run figure/fig-1/gen\_data.m to generate the required data.
- Run ```figure/fig-1/fig_1_profit_q1.m``` to generate Figure 1.

### Figure 2

### Figure 3

- Run ```figure/fig-3/fig_3_bubble_qNT_qT.m```.

### Figure 4

- Run ```figure/fig-4a/fig_4a_bubble_qopt_qMS.m``` to generate Figure 4a
- Run ```figure/fig-4b/fig_4b_bubble_qopt_qSPS.m``` to generate Figure 4b.

### Figure 5

- Run ```figure/fig-5/fig_5_gap_r_SP.m```.

### Figure 6
