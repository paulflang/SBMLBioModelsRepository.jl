using SBMLBioModelsRepository

using Pkg, Test
Pkg.develop(url="https://github.com/LCSB-BioCore/SBML.jl#paulflang:pl/mk-species-units")
using SBML
using ModelingToolkit, OrdinaryDiffEq, CSV, DataFrames
using Base.Threads
function goodbad(f, xs)
    good = []
    bad = []
    for x in xs
        try
            push!(good, x => f(x))
        catch e
            push!(bad, x => e)
        end
    end
    (good, bad)
end

"""
naive tester to separate the ones that lower and those that dont
"""
function test_suite(logdir=joinpath(@__DIR__, "logs"); write=false)
    !isdir(logdir) && mkdir(logdir)
    models = semantic()
    f = x -> ODESystem(readSBML(x))
    (g, b) = goodbad(f, models)
end

function lower_one(fn, df; verbose=false)
    k = 0
    n_dvs = 0
    n_ps = 0
    err = ""
    try
        ml = readSBML(fn)
        k = 1
        sys = ODESystem(ml)
        n_dvs = length(states(sys))
        n_ps = length(parameters(sys))
        k = 2
        prob  = ODEProblem(ml, (0, 1000.0))
        k = 3
        sol = solve(prob, TRBDF2(), dtmax=0.5)
        k = 4
    catch e
        verbose && @info fn => e
        err = string(e)
    finally
        push!(df, (fn, k, n_dvs, n_ps, err))
        verbose && printstyled("$fn done with a code $k\n"; color=:green)
    end
end

function lower_fns(fns; write=true)
    df = DataFrame(file=String[], retcode=Int[], n_dvs=Int[], n_ps=Int[], error=String[])
    @sync Threads.@threads for fn in fns 
        lower_one(fn, df)
    end
    write && CSV.write("logs/test_suite.csv", df)
    df
end

println("****SBML TEST SUITE TESTING****")
f(x) = ODESystem(readSBML(x))
suite_fns = get_sbml_suite_fns()
fn = suite_fns[1]
@test isfile(fn)
@test readSBML(fn) isa SBML.Model
(good, bad) = goodbad(f, suite_fns)
@test length(bad) == 646 # regression test 
@test sum(length.([good, bad])) == 1664

df = lower_fns(suite_fns)
# @btime lower_fns($suite_fns[1:50]; write=false) # 176.973 s (253344211 allocations: 17.69 GiB)
# @btime serial_lower_fns($suite_fns[1:50]; write=false)
# @show bad
# @time test_sbml(suite_fns)


# println("BIOMD DATASET TESTING")
# biomd_dir = joinpath(datadir, "biomd/")
# biomd_fns = readdir(biomd_dir; join=true)
# good, bad = test_sbml(biomd_fns)
# @test sum(length.([good, bad])) == 2226
# @show length(bad)
# @show bad
# @time test_sbml(biomd_fns) # too



# function serial_lower_fns(fns; write=true)
#     df = DataFrame(file=String[], retcode=Int[], n_dvs=Int[], n_ps=Int[], error=String[])
#     for fn in fns 
#         lower_one(fn, df)
#     end
#     write && CSV.write("logs/test_suite.csv", df)
#     df
# end


"""
writes the good ones to files. works but needs refactor
"""
function process_good()
    outdir = "../SBMLBioModelsRepository/data/sbml-test-suite-mtk/" # write(io, sys) dir
    for p in g 
        fn, sys = first(p), last(p)
        fn = basename(fn)
        fn, ext = splitext(fn)
        
        if write 
            outfn = joinpath(outdir, "$(fn).jl")
            open(outfn, "w") do io 
                write(io, sys)
            end
        end
    end
end
