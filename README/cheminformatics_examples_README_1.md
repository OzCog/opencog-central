# Examples

This directory contains examples of defining atoms, bonds, molecules and reactions in
OpenCog using different languages: 1) Scheme, 2) Python, 3) Python within Jupyter notebooks.

The following is a short description how to run the examples.

## Scheme

Change to the `scheme` directory and use the Guile interpreter to load a script:

```
> guile -s example.scm
```
Alternately, to work at the command prompts:
```
> guile
(use-modules (opencog) (opencog cheminformatics))
(load "example.scm")
```
The current examples are:
* [reaction.scm](scheme/reaction.scm) - an esterification reaction.

## Python

Change to the `python` directory and use the Python 3 interpreter to run a script:

```
> python example.py
```

## Jupyter notebooks

Change to the `jupyter` directory, start a Jupyter server and use the automatically opened web GUI to inspect and run a notebook:

```
> jupyter-notebook
```
