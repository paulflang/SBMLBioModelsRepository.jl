using SBMLBioModelsRepository
using CSV, DataFrames
using Test

# test we get all biomodels sbml files
# df = biomodels(;curl_meta=true, verbose=false)

# biomd_dir = joinpath(datadir, "biomd/")
# @show biomd_dir
# @test ispath(biomd_dir)

# biomd_fns = readdir(biomd_dir; join=true)
# @show biomd_fns
# display(df)
# @test length(biomd_fns) == nrow(biomd_df) # 2216 reenable eventually?

# test suite stuff
sbml_test_suite()
suite_fns = get_sbml_suite_fns()
@test isfile(suite_fns[1])
