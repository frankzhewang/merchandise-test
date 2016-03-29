# merchandise-test
Numerics in the paper "Optimal Merchandise Testing with Limited Inventory", co-authored by Li Chen, Adam J. Mersereau, and Zhe (Frank) Wang.

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

- <a name='clone'></a>Clone this repo 
    ```bash
    git clone https://github.com/frankzhewang/merchandise-test.git
    ```
    The above command can also be used to setup on a personal computer.

## Switch between versions
This repo contains different versions of the numerical analysis.

Currently, there are two versions: `master`, and `testing`. The [`master`](https://github.com/frankzhewang/merchandise-test/tree/master) version, a clean version in which output data are not included , is the default version when the repo is cloned. The [`testing`](https://github.com/frankzhewang/merchandise-test/tree/testing) version also includes output data from a complete testing run of all the numerical analysis.

A `paper-v1` version which includes results in the original paper will be added in the near future.

Under the root directory, you can use the following Git command to switch between versions:
```bash
git checkout <version name>
```

## Run numerical analysis

### <a name='2store'></a>[two-store](two-store): Two-store instances

1. Generate demand sample paths
    ```bash
    cd two-store/bin
    ./run-gen-demand <output path>
    ```
    Due to the sizes of demand files, the `<output path>` should be on the lustre scratch space of KillDevil. Your personal   `/lustre` directory should look like `/lustre/scr/y/o/youronyen`. For details, see   [here](http://help.unc.edu/help/getting-started-on-killdevil/#P63_6342).

    You should always make sure that the submitted jobs have been completed before you proceed to the next step. To check job status, use `bjobs` command.

2. Compute profits with timing information under all possible allocations
    ```bash
    ./run-timing <demand file path>
    ```

3. Generate solution tables for the no-timing case
    ```bash
    ./run-sol-tab
    ```

4. Combine the raw solution tables
    ```bash
    ./run-combine-sol-tab
    ```

5. Compute profits without timing information under all possible allocations
    ```bash
    ./run-no-timing <demand file path>
    ```
    
6. Summarize profits under various allocation policies
    ```bash
    ./run-summarize
    ```

### <a name='3store'></a>[three-store](three-store): Three-store instances

1. Generate demand sample paths
    ```bash
    cd two-store/bin
    ./run-gen-demand <output path>
    ```
    Again, make sure that the output path is in your `/lustre` drive, and that the submitted jobs are completed before moving on.

2. Compute profits with timing information under all possible allocations
    ```bash
    ./run-timing <demand file path>
    ```

3. Generate solution tables for the no-timing case
    ```bash
    ./run-sol-tab
    ```

4. Combine the raw solution tables
    ```bash
    ./run-combine-sol-tab
    ```

5. Compute profits without timing information under all possible allocations
    ```bash
    ./run-no-timing <demand file path>
    ```
    
6. Summarize profits under various allocation policies
    ```bash
    ./run-summarize
    ```

### <a name='q40'></a>[three-store-Q40](three-store-Q40): A three-identical-store example

1. Generate demand sample paths
    ```bash
    cd three-store-Q40/bin
    ./run-gen-demand <output path>
    ```
    
2. Compute profits with and without timing information
    ```bash
    ./run-profit <demand file path>
    ```


## Generate Figures

All the figures are generated in Matlab. To generate figures, first [clone this repo](#clone) to your personal computer. Next, make sure that you have the required data ready for each figure that you want to plot. The easiest way to assure this is to [switch](#switch-between-versions) to the `testing` version which contains results from a testing run of all the numerical analysis.

### Figure 1

- Run [figure/fig-1/gen\_data.m](figure/fig-1/gen_data.m) to generate the required data.
- Run [figure/fig-1/fig\_1\_profit\_q1.m](figure/fig-1/fig_1_profit_q1.m) to generate Figure 1.

### Figure 2

- Requires a complete run of analysis in [three-store-Q40](three-store-Q40) (see [here](#q40)).
- Run [figure/fig-2/]().

### Figure 3

- Requires a complete run of analyis in [two-store](two-store) (see [here](#2store)).
- Run [figure/fig-3/fig\_3\_bubble\_qNT\_qT.m](figure/fig-3/fig_3_bubble_qNT_qT.m).

### Figure 4

- Requires a complete run of analysis in [two-store](two-store) (see [here](#2store)).
- Run [figure/fig-4a/fig\_4a\_bubble\_qopt\_qMS.m](figure/fig-4a/fig_4a_bubble_qopt_qMS.m) to generate Figure 4a.
- Run [figure/fig-4b/fig\_4b\_bubble\_qopt\_qSPS.m](figure/fig-4b/fig_4b_bubble_qopt_qSPS.m) to generate Figure 4b.

### Figure 5

- Requires a complete run of analysis in [two-store](two-store) (see [here](#2store)).
- Run [figure/fig-5/fig\_5\_gap\_r\_SP.m](figure/fig-5/fig_5_gap_r_SP.m).

### Figure 6

- Requires a complete run of analysis in [three-store](three-store) (see [here](#3store)).
- Run [figure/fig-6/fig\_6a\_box\_timing.m](figure/fig-6/fig_6a_box_timing.m) to generate Figure 6a.
- Run [figure/fig-6/fig\_6b\_box\_no\_timing.m](figure/fig-6/fig_6a_box_no_timing.m) to generate Figure 6b.
