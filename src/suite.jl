"""
requires git

returns location of all the models (every version), and the

for a particular version just do 

    `filter(x->occursin("l1v2", x), fns)`
"""
function sbml_test_suite(repo_path="$(datadir)/sbml-test-suite/")
    # !ispath(dir) && mkpath(dir)
    p = joinpath(@__DIR__, repo_path)

    run(`git clone "https://github.com/anandijain/sbml-test-suite" $(repo_path)`)
end

function get_sbml_suite_fns(repo_path="$(datadir)/sbml-test-suite/")
    p = joinpath(@__DIR__, repo_path)
    semantic = "$(p)semantic/"
    ds = filter(isdir, readdir(semantic; join=true))
    fns = reduce(vcat, glob.("*.xml", ds))
    fs = map(x -> splitdir(x)[end], fns)
    fns
end