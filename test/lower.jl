using SBMLBioModelsRepository

using Pkg
Pkg.add(url="https://github.com/LCSB-BioCore/SBML.jl#master")
using SBML

function test_sbml(fns)
    good = []
    bad = []
    for fn in fns
        try 
            m = readSBML(fn)
            push!(good, fn => m)
        catch e
            push!(bad, fn => e)
        end
    end
    good, bad
end

println("****SBML TEST SUITE TESTING****")
suite_fns = get_sbml_suite_fns()
good, bad = test_sbml(suite_fns)
@test length(bad) == 1368 # regression test 
@test sum(length.([good, bad])) == 9373

@show bad
@time test_sbml(suite_fns)

# println("BIOMD DATASET TESTING")
# biomd_dir = joinpath(datadir, "biomd/")
# biomd_fns = readdir(biomd_dir; join=true)
# good, bad = test_sbml(biomd_fns[1:20]);
# @show bad
