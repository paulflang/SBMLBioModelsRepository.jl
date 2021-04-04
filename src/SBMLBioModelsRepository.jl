module SBMLBioModelsRepository
# this is used to download the data from biomd
using CSV, DataFrames, JSON3, JSONTables, Glob  #  , InfoZIP i guess zip files stuff is just bad 
using Base.Threads

function curl_biomd_metadata(meta_dir="data/biomd_meta")
    !ispath(meta_dir) && mkpath(meta_dir)
    offsets = 0:100:2200
    urls = "https://www.ebi.ac.uk/biomodels/search?query=sbml&offset=" .* string.(offsets) .* "&numResults=100&format=json"
    @sync Threads.@threads for i in 1:length(urls) 
        run(`curl $(urls[i]) -o "$(meta_dir)/sbml_$(i).json"`)
    end
end

function jsonfn_to_df(fn)
    json = read(fn, String);
    json = JSON3.read(json)
    DataFrame(jsontable(json.models))
end

function biomd_sbml_metadata(meta_dir="data/biomd_meta")
    fns = readdir(meta_dir; join=true)
    dfs = jsonfn_to_df.(fns)
    vcat(dfs...)
end

"uses the BioModels IDs and the download REST API"
function sbml_zip_urls(df)
    base = "https://www.ebi.ac.uk/biomodels/search/download?models="
    ids = df.id
    N = 100 # api limits 100 at a time
    chunks = [ids[i:i + 99] for i in 1:100:2200]
    append!(chunks, [ids[2201:end]])
    qs = join.(chunks, ",") 
    base .* qs  
end

"""
takes the metadata dataframe from `biomd_sbml_metadata()`.

should probably do this async
"""
function curl_sbml_zips(urls, zips_dir="data/biomd_zips/")
    @sync Threads.@threads for i in 1:length(urls)
        run(`curl -X GET "$(urls[i])" -H "accept: application/zip" -o $(zips_dir)$i.zip`)
    end 
    return urls
end

# """
# unzips all the zip files to a dir.

# todo test that this doesn't overwrite it better not i swear to gosh
# """
# function unzip_sbml(zips_dir, unzip_dir)
#     mkpath(unzip_dir)
#     InfoZIP.unzip.(readdir(zips_dir; join=true), unzip_dir)
#     unzip_dir
# end

"dir is where all the models are put. doesn't "
function biomodels(meta_dir="data/biomd_meta", zips_dir="data/biomd_zips/", sbmls_dir="data/biomd/"; curl_meta=false)
    mkpath.([meta_dir,
        zips_dir,
        sbmls_dir])
        
    curl_meta && curl_biomd_metadata(meta_dir)
    df = biomd_sbml_metadata(meta_dir)
    CSV.write("data/sbml_biomodels.csv", df)
    urls = sbml_zip_urls(df)
    curl_sbml_zips(urls, zips_dir)
    # manually extract them 
    # unzip_sbml(zips_dir, sbmls_dir)
    # readdir(sbmls_dir; join=true)
end

"""
requires git.

this is also a fat download: 391.56 MB. 
the total size of the SBML is like 5 MB 
there's got to be a better way to access the test-suite
did anyone even intend for people to use this?
"""
function sbml_test_suite(dir=joinpath("data","sbml_test_suite_models"))
    repo_p = joinpath("data","sbml-test-suite")
    !isdir(dir) && begin mkpath(dir)   
        run(`git clone https://github.com/sbmlteam/sbml-test-suite.git $(repo_p)`)
    end
    p = joinpath("cases","semantic")
    ds = filter(isdir, readdir(joinpath(repo_p,p); join=true))
    fns = reduce(vcat, glob.("*.xml", ds))
    fs = map(x -> splitdir(x)[end], fns)
    dsts = normpath.(dir .* fs)
    cp.(fns, dsts, force=true)
    rm(repo_p; recursive=true)
    readdir(dir; join=true)
end


export sbml_test_suite, biomodels

export biomd_sbml_metadata, curl_sbml_zips, sbml_zip_urls

end