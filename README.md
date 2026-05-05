# Snakemake quickstart 

[![CC BY 4.0][cc-by-shield]][cc-by]

This quick intro with sample data allows you to start using [`Snakemake`](https://snakemake.readthedocs.io/en/stable/index.html) workflow management system with some key functions that you might need.

I designed this tutorial for a group meeting, so it implies commentary from a person leading the tutorial, but it should be helpful for self-directed study as well. The materials are aimed at people doing molecular dynamics. However, the contents are quite general, so you might find it useful regardless of your field.

**Data description:** several `gro` frames from WALP peptide simulations in POPC bilayer solvated in 0.15 NaCl. Simulated in Feb 2025 with Martini3 force field and `gromacs2024`. 

**Contantents:**

- [Setup](#sec1) </br>

- [Example 1. Basic start](#sec2) </br>

- [Example 2. Multiple rules, python and shell instructions](#sec3) </br>

- [Example 3. Wildcards, modularisation and configs](#sec4) </br>

- [Further reading](#sec5) </br>

<a name="sec1"></a>

## Setup

```
# clone repository locally 
git clone 

# create a clean environment using any manager, for example:
python3 -m venv venv

# install snakemake and other packages 
pip install -r requirements.txt 
```

<a name="sec2"></a>

## Example 1

Quickstart by testing a workflow consisting of a single rule that will count `W` beads in an input `gro` file.

Inspect the contents of `Snakefile` in `example_1`.

```
cd example_1

# It's always good to start with --dry-run/-n to see what jobs will be executed
snakemake --cores 1 -n
```

Try adding a `print('Hello!')` statement in the begginning of `Snakefile`. Rerun the command above.
You will see that 'Hello!' is printed before all the stdout logs. That's because `Snakefile` is actually executed line-by-line similarly to a `.py` file.

```
# execute the workflow, inspect the information in stdout
snakemake --cores 1
```

Congratulations! You've just executed your first Snakemake workflow.

How does Snakemake actually discover the workflow file? By default, it looks for files in the follwoing order `Snakefile`, `snakefile`, `workflow/Snakefile`, `workflow/snakefile` *(you can try creating all of these options with altered rule names and experiment with dry-run)*. To use a workflow file somewhere else or with a different name, pass it explicitly with `-s/--snakefile` argument:

```
mv Snakefile custom_workflow.smk
snakemake --cores 1 -s custom_workflow.smk -n
```

Also, note that running `Snakemake` creates a `.snakemake` working-state directory. It contains logs and other useful information (per-output-file metadata, marks for outputs from jobs that started but did not finish cleanly, environment info etc).
More about [snakemake reports](https://github.com/snakemake/snakemake/blob/main/docs/snakefiles/reporting.rst).

<a name="sec3"></a>

## Example 2

Let's look at combining multiple rules, and creating them as shell or python commands. 

Inspect the contents of `Snakefile` in `example_2`:

- It has module imports, python function `lipid_z_thickness` and several rules.

- Take a closer look at the rule `all`. It only has `input` definition and it allows to set the target output for the whole workflow. Snakemake will define the first rule of the Snakefile as the target. Hence, it is best practice to have a rule `all` at the top of the workflow which has all of the desired target files as inputs. Alternatively, target rule can be specified with command line argument `snakemake -n target_rule_name`

- Note that rules `analyse_lipids` and `average_z_thickness` define instructions in python code after `run` key word, while `count_water` uses shell commands.

- You can also call shell commands using `shell()` function within `run` script.

```
# see what will jobs will be executed
snakemake --cores 1 --dry-run

# try renaming rule `all` and dry-run again
# nothing changed, first rule is still recongised as target

# try removing one of the files in `all` and dry-run again
# note how the job list changed

# now try changing target from terminal, what's different in stdout?
snakemake --cores 1 -n count_water

# run
snakemake --cores 1

# the workflow failed! That's because I left `raise Exception` in `average_z_thickness`
# delete this line and dry-run, note how Snakemake picks up from where it left before without re-running everything

# finish workflow
snakemake --cores 1
```

<a name="sec4"></a>

## Example 3

Finally, we will have a look at wildcards, configs and modularisation. 

Inspect the contents of `Snakefile` in `example_3`. It's very short. Instead of having all the rules and auxiliary python code in one file you can organise them in logical modules and import/include them. The main `Snakefile` will define all the workflow components and target outputs. 

In this case we move to analysing mutiple files in `simulations` dir. Imagine, that you have a lot of inputs, listing all of them manually in rules would be tedious and it's actually unneccessary. Instead you can define the path pattern(s) for the workflow to discover your inputs and use `wildcards`.

Wilcards use in this example:

- First, we collect all simulation names using `glob_wildcards` builtin snakemake function in `Snakefile` and store them in variable `SIMULATIONS`

- Then, we use `SIMULATIONS` list and `expand` builtin snakemake function in `all` to define all the target outputs for each discovered simulation

- Next, we refer to wildcards in the rules inside `rules/lipid_analysis.smk` and `rules/water_analysis.smk` 

Using wilcards can be tricky and confusing, so I really recommend reading through the corresponding sections in [snakemake documentation](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html).

```
# dry-run
snakemake --cores 1 -n

# add `print(SIMULATIONS)` statement in the `snakefile` and dry-run again
# now you should see a list that is SIMULATIONS

# execute
snakemake --cores 1
```

**Note** how `Snakemake` not only creates new files, but also directory strcutre. Now every `simulations/rep` has an `analysis` directory.

**Note**, how rule `aggregate_water_rdf` in `water_analysis.smk` uses multiple outputs from `water_rdf` and aggregates them. This can be a helpful pattern, when you need to analyse individual samples/simulations and then process all the results together.

The last concept I introduce in this tutorial is the use of parameters:

- It's often helpful to reuse the workflow, but with different parameters for analyses/tools

- In this examle I introduced parametrs in `water_rdf` rule. Comment-out lines 15 and 16 and uncomment the next two lines.

- What is `config`? It's a dictiorary with all the parameters. It can be specified through `configfile` in `yaml` format and passed to the workflow in `Snakefile` (see the top line) or from the command line with `--config-file` argument. 

- [More on non-file parameters in rules](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#snakefiles-params)

```
# remove water rdf outputs
rm water_rdf.csv simulations/*/analysis/*rdf*

# dry-run to check rule execution
snakemake --cores 1 -n

# re-execute with different parameters
snakemake --cores 1
```

Now if you open `water_rdf.csv` you will see that the range of bin values indeed changed. 

<a name="sec5"></a>

## This concludes the tutorial, here are some suggestions for further reading:

- If you want to dive deeper into snakemake, I suggest watching this [playlist on YouTube](https://youtube.com/playlist?list=PLWhvkMKn3k1zefj7ELcxlukO6AbuP8YCL&si=bQTsEF-choRPsRPi) 

- `Snakemake` has a lot of cool functions, so I also recommend inspecting the output of `snakemake --help` and experimenting with the options

- Read [`Snakemake` documentation](https://snakemake.readthedocs.io/en/stable/index.html)

- Another helpful chapter from [ECA's Bioinformatics Handbook](https://eriqande.github.io/eca-bioinf-handbook/snakemake-chap.html). 


This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg
