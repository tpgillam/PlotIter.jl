module PlotIter

export xlims_convex_hull!, ylims_convex_hull!, zlims_convex_hull!
export NoDisplay, DisplayEachRow, DisplayAtEnd
export plot_iter

using Plots

for dim in (:x, :y, :z)
    func! = Symbol(dim, "lims_convex_hull!")
    lims = Symbol(dim, "lims")
    lims! = Symbol(dim, "lims!")
    @eval begin
        """
            $func!(plots)
            $func!(plots...)
        """
        function $func!(
            plots::Union{Tuple{Vararg{<:AbstractPlot}},AbstractVector{<:AbstractPlot}}
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

"""Create a 'blank' plot."""
_blank_plot() = plot(; legend=false, grid=false, foreground_color_subplot=:white)

function _display_row(plots, num_cols::Integer, row_size)
    # Pad with a "blank" subplot for any missing entries.
    plots = vcat(plots, [_blank_plot() for _ in 1:(num_cols - length(plots))])
    p = plot(plots...; layout=(1, length(plots)), size=row_size)
    return display(p)
end

abstract type DisplayMode end
struct NoDisplay <: DisplayMode end
struct DisplayEachRow <: DisplayMode end
struct DisplayAtEnd <: DisplayMode end

@nospecialize
function plot_iter(
    f::Function,
    iterable;
    num_cols=3,
    row_height=300,
    row_width=900,
    display_mode::Type{<:DisplayMode}=DisplayAtEnd,
    xlims_convex_hull::Bool=false,
    ylims_convex_hull::Bool=false,
    zlims_convex_hull::Bool=false,
    kwargs...,
)
    row_size = (row_width, row_height)

    if (xlims_convex_hull || ylims_convex_hull || zlims_convex_hull)
        # If using any arguments that require all plots to have been generated prior to
        # displaying, ensure that our displaymode is correct.
        if !(display_mode <: Union{NoDisplay,DisplayAtEnd})
            throw(
                ArgumentError(
                    "Invalid display mode $display_mode, since we need all plots first."
                ),
            )
        end
    end

    # A list of all subplots that we generate; we will return this.
    all_plots = []

    # A temporary store of plots prior to displaying.
    current_plots = []

    function flush_plots!()
        @assert length(current_plots) <= num_cols

        # Record the generated subplots.
        append!(all_plots, current_plots)

        if display_mode <: DisplayEachRow
            _display_row(current_plots, num_cols, row_size)
        end
        return empty!(current_plots)
    end

    for item in iterable
        if length(current_plots) == num_cols
            # Buffer is full, pack into a single row.
            flush_plots!()
        end

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

    if display_mode <: DisplayAtEnd
        for row_plots in Iterators.partition(all_plots, num_cols)
            _display_row(row_plots, num_cols, row_size)
        end
    end

    return all_plots
end

end
