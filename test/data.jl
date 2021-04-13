using SBMLBioModelsRepository
using CSV, DataFrames
using Test

datadir = joinpath(@__DIR__, "../data/")
biomd_dir = joinpath(datadir, "biomd/")

# test we get all biomodels sbml files
# biomodels(;limit=200)
# biomodels(;curl_meta=true, limit=200)
# @test ispath(datadir)

# biomd_fns = readdir(biomd_dir; join=true)
# biomd_df = CSV.read(joinpath(datadir, "sbml_biomodels.csv"), DataFrame)
# @show biomd_fns
# display(biomd_df)
# @test length(biomd_fns) == nrow(biomd_df) # 2216

# test suite stuff
sbml_test_suite()
suite_fns = get_sbml_suite_fns()
@test isfile(suite_fns[1])

# fns = vcat(biomd_fns, suite_fns)

