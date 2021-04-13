function curl_biomd_metadata(meta_dir="$(datadir)/biomd_meta")
    !ispath(meta_dir) && mkpath(meta_dir)
    offsets = 0:100:2200
    urls = "https://www.ebi.ac.uk/biomodels/search?query=sbml&offset=" .* string.(offsets) .* "&numResults=100&format=json"
    @sync Threads.@threads for i in 1:length(urls) 
        Downloads.download(urls[i], "$(meta_dir)/sbml_$(i).json")
        # run(`curl $(urls[i]) -o "$(meta_dir)/sbml_$(i).json"`)
    end
end

function jsonfn_to_df(fn)
    json = read(fn, String);
    json = JSON3.read(json)
    haskey(json, :models) ? DataFrame(jsontable(json.models)) : missing
end

function biomd_metadata(meta_dir="$(datadir)/biomd_meta")
    fns = readdir(meta_dir; join=true)
    dfs = filter(!ismissing, jsonfn_to_df.(fns))
    vcat(dfs...)
end

"uses the BioModels IDs and the download REST API"
function biomd_zip_urls(ids)
    base = "https://www.ebi.ac.uk/biomodels/search/download?models="
    N = 100 # api limits 100 at a time
    chunks = Iterators.partition(ids, N)
    qs = join.(chunks, ",") 
    base .* qs  
end

"""
takes the metadata dataframe from `biomd_metadata()`.

should probably do this async
"""
function curl_biomd_zips(urls, zips_dir="$(datadir)/biomd_zips/")
    for i in 1:length(urls) # @threads seems to not work
        run(`curl -X GET "$(urls[i])" -H "accept: application/zip" -o $(zips_dir)$i.zip`)
    end 
    return urls
end

"this downloads the xmls directly, without needing zip "
function curl_biomd_xmls(ids; verbose=false)
    base = "https://www.ebi.ac.uk/biomodels/model/download/"
    @sync Threads.@threads for id in ids
        verbose && @info("downloading $id")
        url = "$(base)$(id)?filename=$(id)_url.xml"
        fn = "$(datadir)/biomd/$(id).xml"
        Downloads.download(url, fn)
    end
end

"needs unzip in shell path"
function unzip_biomd(zips_dir, unzip_dir)
    mkpath(unzip_dir)
    zips = readdir(zips_dir; join=true)
    for fn in zips
        run(`unzip $fn -d $(unzip_dir)`) 
    end
    unzip_dir
end

"dir is where all the models are put"
function biomodels(
    meta_dir="$(datadir)/biomd_meta",
    zips_dir="$(datadir)/biomd_zips/",
    unzip_dir="$(datadir)/biomd/";
    curl_meta=false,
    limit=nothing, # still gets all the metadata, just limits for curling zips
    verbose=true
    )

    mkpath.([meta_dir,
        zips_dir,
        unzip_dir])
        
    curl_meta && curl_biomd_metadata(meta_dir)
    df = biomd_metadata(meta_dir)
    verbose && display(df)
    CSV.write("$(datadir)sbml_biomodels.csv", df)
    limit === nothing ? curl_biomd_xmls(df.id; verbose=verbose) : curl_biomd_xmls(df.id[1:limit]; verbose=verbose)
end

# "to delete i guess"
# function grab_extract_biomd_zips()
#     urls = limit === nothing ? biomd_zip_urls(df.id) : biomd_zip_urls(df.id[1:limit])
#     curl_biomd_zips(urls, zips_dir)
#     unzip_biomd(zips_dir, unzip_dir)
# end

"""
requires git

returns location of all the models (every version), and the

for a particular version just do 

    `filter(x->occursin("l1v2", x), fns)`
"""
function sbml_test_suite(repo_path="$(datadir)/sbml-test-suite/")
    # !ispath(dir) && mkpath(dir)
    p = joinpath(@__DIR__, repo_path)

    run(`git clone "https://github.com/anandijain/sbml-test-suite" $(repo_path)`)
end

function get_sbml_suite_fns(repo_path="$(datadir)/sbml-test-suite/")
    p = joinpath(@__DIR__, repo_path)
    semantic = "$(p)semantic/"
    ds = filter(isdir, readdir(semantic; join=true))
    fns = reduce(vcat, glob.("*.xml", ds))
    fs = map(x -> splitdir(x)[end], fns)
    fns
end