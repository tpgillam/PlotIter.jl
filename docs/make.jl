using PlotIter
using Documenter

DocMeta.setdocmeta!(PlotIter, :DocTestSetup, :(using PlotIter); recursive=true)

makedocs(;
    modules=[PlotIter],
    authors="Tom Gillam <tpgillam@googlemail.com>",
    repo="https://github.com/tpgillam/PlotIter.jl/blob/{commit}{path}#{line}",
    sitename="PlotIter.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://tpgillam.github.io/PlotIter.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/tpgillam/PlotIter.jl",
    devbranch="main",
)
