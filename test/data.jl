using SBMLBioModelsRepository
using CSV, DataFrames
using Test

# test we get all biomodels sbml files
# biomodels()
# datadir = joinpath(@__DIR__, "../data/")
# @test ispath(datadir)

# biomd_fns = readdir(joinpath(datadir, "biomd/"))
# biomd_df = CSV.read(joinpath(datadir, "sbml_biomodels.csv"), DataFrame)

# @test length(biomd_fns) == nrow(biomd_df) # 2216

# test suite stuff
sbml_test_suite()
suite_fns = get_sbml_suite_fns()
@test isfile(suite_fns[1])

# fns = vcat(biomd_fns, suite_fns)

using Pkg
Pkg.add(url="https://github.com/LCSB-BioCore/SBML.jl/")
using SBML

good = []
bad = []
for fn in suite_fns
    try 
        m = readSBML(fn)
        push!(good, fn => m)
    catch e
        push!(bad, fn => e)
    end
end
@show good
@show "-------"
@show bad
