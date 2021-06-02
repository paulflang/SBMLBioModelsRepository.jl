"""this is used to download the data from biomd and the sbml-test-suite"""
module SBMLBioModelsRepository

const datadir = joinpath(@__DIR__, "../data")

using CSV, DataFrames, JSON3, JSONTables, Glob
using Base.Threads, Base.Iterators, Downloads

include("biomd.jl")
include("suite.jl")

# "do it for me" functions
export sbml_test_suite, biomodels

export curl_biomd_xmls
export curl_biomd_metadata, biomd_metadata, curl_biomd_zips, biomd_zip_urls, unzip_biomd
export get_sbml_suite_fns, jsonfn_to_df
export datadir

end
