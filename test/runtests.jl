using PlotIter
using Plots
using Test

gr()

function _test_lims_cover_range(lims::Tuple, range)
    @test first(range) - 1 <= first(lims) <= first(range)
    @test last(range) <= last(lims) <= last(range) + 1
end

function _test_lims_in_range(lims::Tuple, range)
    @test first(range) <= first(lims)
    @test last(lims) <= last(range)
end

_allequal(things) = all(isequal(first(things)), things)

@testset "PlotIter.jl" begin
    @testset "xyzlims_convex_hull!" begin
        range1 = 1:10
        p1 = plot(range1, range1, range1)
        _test_lims_cover_range(xlims(p1), range1)
        _test_lims_cover_range(ylims(p1), range1)

        range2 = 3:15
        p2 = plot(range2, range2, range2)
        _test_lims_cover_range(xlims(p2), range2)
        _test_lims_cover_range(ylims(p2), range2)

        # Modify the plots to share the same x limits.
        xlims_convex_hull!(p1, p2)
        lims1 = xlims(p1)
        lims2 = xlims(p2)
        @test lims1 == lims2
        _test_lims_cover_range(lims1, 1:15)

        # At this point, the y and z limits should not have been touched.
        _test_lims_cover_range(ylims(p1), range1)
        _test_lims_cover_range(ylims(p2), range2)
        _test_lims_cover_range(zlims(p1), range1)
        _test_lims_cover_range(zlims(p2), range2)

        # Modify the plots to share the same y limits.
        ylims_convex_hull!(p1, p2)
        @test xlims(p1) == xlims(p2)
        lims1 = ylims(p1)
        lims2 = ylims(p2)
        @test lims1 == lims2
        _test_lims_cover_range(lims1, 1:15)
        _test_lims_cover_range(zlims(p1), range1)
        _test_lims_cover_range(zlims(p2), range2)

        # And finally to show the same z limits.
        zlims_convex_hull!(p1, p2)
        @test xlims(p1) == xlims(p2)
        @test ylims(p1) == ylims(p2)
        lims1 = zlims(p1)
        lims2 = zlims(p2)
        @test lims1 == lims2
        _test_lims_cover_range(lims1, 1:15)
    end

    @testset "clims_convex_hull!" begin
        hm1 = heatmap(10 .* rand(5, 5))
        hm2 = heatmap(3 .+ 12 .* rand(5, 5))
        plot(hm1, hm2)
        _test_lims_in_range(PlotIter.clims(hm1), (0, 10))
        _test_lims_in_range(PlotIter.clims(hm2), (3, 15))

        clims_convex_hull!(hm1, hm2)
        lims1 = PlotIter.clims(hm1)
        lims2 = PlotIter.clims(hm2)
        @test lims1 == lims2
        _test_lims_in_range(lims1, (0, 15))
    end

    @testset "plot_iter" begin
        x = 1.0:0.01:(4 * pi)
        things = [
            (; title="A", w=1),
            (; title="B", w=2),
            (; title="C", w=3),
            (; title="D", w=4),
            (; title="E", w=5),
        ]

        for (xch, ych, zch, cch) in
            Iterators.product(Iterators.repeated([false, true], 4)...)
            for num_cols in 1:4
                for (row_width, row_height) in [(800, 300), (400, 100)]
                    # Suppress visual output of any plots when calling `show` internally.
                    all_plots = withenv("GKSwstype" => "nul") do
                        plot_iter(
                            things;
                            num_cols=num_cols,
                            row_width=row_width,
                            row_height=row_height,
                            xlims_convex_hull=xch,
                            ylims_convex_hull=ych,
                            zlims_convex_hull=zch,
                            clims_convex_hull=cch,
                        ) do thing
                            plot!(x .+ thing.w, sin.(x) .* thing.w; title=thing.title)
                        end
                    end

                    # We have access to all the plots that were made, so can check those.
                    @test all_plots isa Vector{<:AbstractPlot}
                    @test length(all_plots) == length(things)
                    xch && @test _allequal(xlims.(all_plots))
                    ych && @test _allequal(ylims.(all_plots))
                    zch && @test _allequal(zlims.(all_plots))
                    cch && @test _allequal(PlotIter.clims.(all_plots))

                    # We can also verify some properties about the rows emitted, since the
                    # last row will still be the "current" plot.
                    last_row = Plots.current()
                    @test length(last_row) == num_cols

                    # Test row width and height match expectation.
                    @test last_row.attr[:size] == (row_width, row_height)
                end
            end
        end
    end
end
