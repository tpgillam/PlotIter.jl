# PlotIter

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tpgillam.github.io/PlotIter.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tpgillam.github.io/PlotIter.jl/dev/)
[![Build Status](https://github.com/tpgillam/PlotIter.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/tpgillam/PlotIter.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/tpgillam/PlotIter.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/tpgillam/PlotIter.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

You're in a Jupyter notebook, and have some `things`.

You would like to make a plot based on each `thing`:
```julia
# Example data
x = 1.0:0.01:4*pi
things = [
    (; title="A", w=1), (; title="B", w=2), (; title="C", w=3), 
    (; title="D", w=4), (; title="E", w=5), 
];

# Make some plots!
plot_iter(things; ylims_convex_hull=true) do thing
    plot!(x, sin.(x) .* thing.w; title=thing.title)
end;
```
![Example](/docs/src/assets/example_sin.png)

For further usage information, please refer to the [documentation](https://tpgillam.github.io/PlotIter.jl/stable/), and the example notebook at `examples/example.ipynb`.