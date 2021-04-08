using SBMLBioModelsRepository
using CSV, DataFrames, Glob
using Test

@testset "SBMLBioModelsRepository.jl" begin
    @testset "data" begin include("data.jl") end
    @testset "sciml" begin include("sciml.jl") end
end
