# PlotIter

API documentation for [PlotIter](https://github.com/tpgillam/PlotIter.jl).

For usage examples, please see the [example notebook](https://github.com/tpgillam/PlotIter.jl/blob/main/examples/example.ipynb).

## Plotting things from an iterable
```@docs
plot_iter
NoDisplay 
DisplayEachRow
DisplayAtEnd
```

## Axis limits
These functions are used internally by [`plot_iter`](@ref), but they can also be useful standalone.

```@docs
xlims_convex_hull!
ylims_convex_hull!
zlims_convex_hull!
clims_convex_hull!
```