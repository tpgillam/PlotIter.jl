using PlotIter
using Plots
using Test

gr()

function _test_lims_in_range(lims::Tuple, range)
    @test first(range) - 1 <= first(lims) <= first(range)
    @test last(range) <= last(lims) <= last(range) + 1
end

@testset "PlotIter.jl" begin
    @testset "xyzlims_convex_hull!" begin
        range1 = 1:10
        p1 = plot(range1, range1, range1)
        _test_lims_in_range(xlims(p1), range1)
        _test_lims_in_range(ylims(p1), range1)

        range2 = 3:15
        p2 = plot(range2, range2, range2)
        _test_lims_in_range(xlims(p2), range2)
        _test_lims_in_range(ylims(p2), range2)

        # Modify the plots to share the same x limits.
        xlims_convex_hull!(p1, p2)
        lims1 = xlims(p1)
        lims2 = xlims(p2)
        @test lims1 == lims2
        _test_lims_in_range(lims1, 1:15)

        # At this point, the y and z limits should not have been touched.
        _test_lims_in_range(ylims(p1), range1)
        _test_lims_in_range(ylims(p2), range2)
        _test_lims_in_range(zlims(p1), range1)
        _test_lims_in_range(zlims(p2), range2)

        # Modify the plots to share the same y limits.
        ylims_convex_hull!(p1, p2)
        @test xlims(p1) == xlims(p2)
        lims1 = ylims(p1)
        lims2 = ylims(p2)
        @test lims1 == lims2
        _test_lims_in_range(lims1, 1:15)
        _test_lims_in_range(zlims(p1), range1)
        _test_lims_in_range(zlims(p2), range2)

        # And finally to show the same z limits.
        zlims_convex_hull!(p1, p2)
        @test xlims(p1) == xlims(p2)
        @test ylims(p1) == ylims(p2)
        lims1 = zlims(p1)
        lims2 = zlims(p2)
        @test lims1 == lims2
        _test_lims_in_range(lims1, 1:15)
    end
end
