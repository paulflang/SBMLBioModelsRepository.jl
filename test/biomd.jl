# test we get all biomodels sbml files
df = biomodels(;curl_meta=true, verbose=false)

biomd_dir = joinpath(datadir, "biomd/")
@show biomd_dir
@test ispath(biomd_dir)

biomd_fns = readdir(biomd_dir; join=true)
# @show biomd_fns
# display(df)
@test length(biomd_fns) == nrow(biomd_df) # 2216 reenable eventually? should be 981 ODEs

println("BIOMD DATASET TESTING")
# biomd_odes = CSV.read("data/SBML_ODEs_biomd.csv", DataFrame) # fix for CI
# ids = biomd_odes.id
# fns = .*("data/biomd/", ids, ".xml")
biomd_fns = readdir("data/biomd/"; join=true)
# size = 0
# sizemap = map(fn->fn=>stat(fn).size, fns) # ~200 MB
# sort!(sizemap, by=x->last.(x), rev=true)

# biomd_dir = joinpath(datadir, "biomd/")
# biomd_fns = readdir(biomd_dir; join=true)

# (good, bad) = goodbad(f, first.(sizemap)[1:100])
(good, bad) = goodbad(f, biomd_fns)
# @test sum(length.([good, bad])) == 2226
@show length(bad)

biomd_df = lower_fns(biomd_fns; write_fn="biomd.csv")
