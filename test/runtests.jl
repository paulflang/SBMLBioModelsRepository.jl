using SBMLBioModelsRepository
using CSV, DataFrames, Glob
using Test

@testset "SBMLBioModelsRepository.jl" begin
    @testset "data" begin include("data.jl") end
    @testset "lower" begin include("lower.jl") end
end
