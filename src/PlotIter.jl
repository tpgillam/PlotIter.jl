module PlotIter

export xlims_convex_hull!, ylims_convex_hull!, zlims_convex_hull!
export NoDisplay, DisplayEachRow, DisplayAtEnd
export plot_iter

using Plots

for dim in (:x, :y, :z)
    dim_str = string(dim)
    func! = Symbol(dim, "lims_convex_hull!")
    lims = Symbol(dim, "lims")
    lims! = Symbol(dim, "lims!")
    @eval begin
        """
            $($func!)(plots)
            $($func!)(plots...)

        Set the $($dim_str)-axis limits for all `plots` to the smallest interval that contains
        all the existing $($dim_str)-axis limits.

        This is useful to ensure that two plots are visually comparable.
        """
        function $func!(
            plots::Union{Tuple{Vararg{AbstractPlot}},AbstractVector{<:AbstractPlot}}
        )
            isempty(plots) && throw(ArgumentError("Need at least one plot."))

            (x_min, x_max) = $lims(first(plots))
            for p in plots[2:end]
                (this_x_min, this_x_max) = $lims(p)
                x_min = min(x_min, this_x_min)
                x_max = max(x_max, this_x_max)
            end

            for p in plots
                $lims!(p, x_min, x_max)
            end

            return nothing
        end
        $func!(plots::AbstractPlot...) = $func!(plots)
    end
end

_blank_plot() = plot(; legend=false, grid=false, foreground_color_subplot=:white)

function _display_row(plots, num_cols::Integer, row_size)
    # Pad with a "blank" subplot for any missing entries.
    plots = vcat(plots, [_blank_plot() for _ in 1:(num_cols - length(plots))])
    p = plot(plots...; layout=(1, length(plots)), size=row_size)
    return display(p)
end

abstract type DisplayMode end

"""
    struct NoDisplay <: DisplayMode

Don't show any plots.
"""
struct NoDisplay <: DisplayMode end

"""
    struct DisplayEachRow <: DisplayMode

Show a row of plots as soon as it is complete.
"""
struct DisplayEachRow <: DisplayMode end

"""
    struct DisplayAtEnd <: DisplayMode

Wait until the iterable is exhausted, and then show all rows of plots.
"""
struct DisplayAtEnd <: DisplayMode end

"""
    plot_iter(f::Function, iterable; kwargs...)

Generate one plot per item of `iterable`.

This function will call `f` for each item in `iterable`, with a new plot set as
`Plots.current()`.

It is optimised for use within a Jupyter notebook. It will let you quickly generate a number
of plots, making use of the available page width. The plots are then close together, so
easier to compare visually.

This function avoids the need to manually construct a layout for this simple case.

# Arguments
- `f::Function`: A function that takes a single argument of type `eltype(iterable)`. Any
    return value is ignored.
- `iterable`: Any iterable object.

# Keyword arguments
- `num_cols::Integer=3`: The number of of plots to put side-by-side.
- `row_height=300`: The vertical extent of each plot.
- `row_width=900`: The width of each row (that is for _all_ plots in the row)
- `display_mode::DisplayMode=DisplayAtEnd()`: An instance of:
    - [`NoDisplay`](@ref): Don't `show` the plots.
    - [`DisplayEachRow`](@ref): Every time a row of plots is complete, `show` it.
    - [`DisplayAtEnd`](@ref): Wait until all plots are generated, and then show all at once.
- `xlims_convex_hull::Bool=false`: Iff true, call [`xlims_convex_hull!`](@ref) on all plots.
    This requires the `display_mode` to be [`NoDisplay`](@ref) or [`DisplayAtEnd`](@ref).
- `ylims_convex_hull::Bool=false`: Iff true, call [`ylims_convex_hull!`](@ref) on all plots.
    This requires the `display_mode` to be [`NoDisplay`](@ref) or [`DisplayAtEnd`](@ref).
- `zlims_convex_hull::Bool=false`: Iff true, call [`zlims_convex_hull!`](@ref) on all plots.
    This requires the `display_mode` to be [`NoDisplay`](@ref) or [`DisplayAtEnd`](@ref).
- `kwargs...`: Any other keyword arguments specified will be forwarded to the

# Returns
A vector of all plots that have been generated.

# Example

Here is the simplest use, with no configuration:
```julia
plot_iter(1:3) do i
    # Note: call to `plot!` rather than `plot` is important, since a new plot object has
    # already been created by `plot_iter`.
    plot!(i .* rand(30))
end;
```

We can also change the sizes, as well as make the y-axis limits match:
```julia
plot_iter(1:3; num_cols=2, row_height=500, ylims_convex_hull=true) do i
    plot!(i .* rand(30))
end;
```
"""
function plot_iter(
    f::Function,
    @nospecialize(iterable);
    num_cols::Integer=3,
    row_height=300,
    row_width=900,
    display_mode::DisplayMode=DisplayAtEnd(),
    xlims_convex_hull::Bool=false,
    ylims_convex_hull::Bool=false,
    zlims_convex_hull::Bool=false,
    kwargs...,
)
    row_size = (row_width, row_height)

    if (xlims_convex_hull || ylims_convex_hull || zlims_convex_hull)
        # If using any arguments that require all plots to have been generated prior to
        # displaying, ensure that our displaymode is correct.
        if !isa(display_mode, Union{NoDisplay,DisplayAtEnd})
            throw(
                ArgumentError(
                    "Invalid display mode $display_mode, since we need all plots first."
                ),
            )
        end
    end

    # A vector of all subplots that we generate; we will return this.
    all_plots = AbstractPlot[]

    # A temporary store of plots prior to displaying.
    current_plots = AbstractPlot[]

    function flush_plots!()
        @assert length(current_plots) <= num_cols

        # Record the generated subplots.
        append!(all_plots, current_plots)

        isa(display_mode, DisplayEachRow) && _display_row(current_plots, num_cols, row_size)
        return empty!(current_plots)
    end

    for item in iterable
        # If buffer is full, pack into a single row.
        (length(current_plots) == num_cols) && flush_plots!()

        # Create a new plot on the stack, and call our function with the item.
        p = plot(; kwargs...)
        f(item)
        push!(current_plots, p)
    end

    # Ensure that we always empty the buffer
    flush_plots!()

    # Now rescale any axes which we need to.
    xlims_convex_hull && xlims_convex_hull!(all_plots)
    ylims_convex_hull && ylims_convex_hull!(all_plots)
    zlims_convex_hull && zlims_convex_hull!(all_plots)

    if isa(display_mode, DisplayAtEnd)
        for row_plots in Iterators.partition(all_plots, num_cols)
            _display_row(row_plots, num_cols, row_size)
        end
    end

    return all_plots
end

end
