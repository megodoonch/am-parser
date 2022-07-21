local ud_prefix = "data/UD/corenlp/";

local MRP_AMR_SUBPATH = "clean_decomp";
local MRP_UCCA_SUBPATH = "very_first";

local SDP_prefix = "data/SemEval/2015/";
local AMR_prefix = "data/AMR/";

{
    # "GLOVE_DIR" : "/local/mlinde/glove/",

    "MRP_AMR_SUBPATH" : MRP_AMR_SUBPATH,
    "MRP_UCCA_SUBPATH" : MRP_UCCA_SUBPATH,
    "SDP_prefix" : SDP_prefix,

    "UD_banks": ["EWT","GUM","LinES","ParTUT"],
    "train_data" : {
        # SDP corpora
        "DM" : SDP_prefix+"DM/train/train.amconll",
        "PAS" : SDP_prefix+"PAS/train/train.amconll",
        "PSD" : SDP_prefix+"PSD/train/train.amconll",
        # AMR corpora
        "AMR-example" : AMR_prefix+"example/output/train/train.amconll",  # toy example
        "LittlePrince" : AMR_prefix+"little-prince/output/train/train.amconll",
        "AMR-2015" : AMR_prefix+"2015/train/train.amconll",
        "AMR-2017" : AMR_prefix+"2017/train/train.amconll",
	"AMR-2017-morphemes" :  AMR_prefix+"AMR2017morphemes/train/train.amconll",
        "AMR-2020" : AMR_prefix+"2020/train/train.amconll",
        "EDS" : "data/EDS/train/train.amconll",
        #UD:
        "EWT": ud_prefix+"EWT/train/train.amconll",
        "GUM": ud_prefix+"GUM/train/train.amconll",
        "LinES": ud_prefix+"LinES/train/train.amconll",
        "ParTUT": ud_prefix+"ParTUT/train/train.amconll",

        # MRP versions
        "MRP-DM" : "data/MRP/DM/train/train.amconll",
        "MRP-PSD" : "data/MRP/PSD/train/train.amconll",
        "MRP-EDS" : "data/MRP/EDS/train/train.amconll",

        "MRP-AMR" : "data/MRP/AMR/"+MRP_AMR_SUBPATH+"/train/train.amconll",

        "MRP-UCCA" : "data/MRP/UCCA/"+MRP_UCCA_SUBPATH+"/train/train.amconll"
    },
    "gold_dev_data" : { #gold AM dependency trees for (a subset of) the dev data
        # SDP corpora
        "DM" : SDP_prefix+"DM/gold-dev/gold-dev.amconll",
        "PAS" : SDP_prefix+"PAS/gold-dev/gold-dev.amconll",
        "PSD" : SDP_prefix+"PSD/gold-dev/gold-dev.amconll",
        # AMR corpora
        "AMR-example" : AMR_prefix+"example/output/gold-dev/gold-dev.amconll",  # toy corpus
        "LittlePrince" : AMR_prefix+"little-prince/output/gold-dev/gold-dev.amconll",
        "AMR-2015" : AMR_prefix+"2015/gold-dev/gold-dev.amconll",
        "AMR-2017" : AMR_prefix+"2017/gold-dev/gold-dev.amconll",
	"AMR-2017" : AMR_prefix+"AMR2017morphemes/gold-dev/gold-dev.amconll",
        "AMR-2020" : AMR_prefix+"2020/gold-dev/gold-dev.amconll",
        "EDS" : "data/EDS/gold-dev/gold-dev.amconll",

        #UD:
        "EWT": ud_prefix+"EWT/dev/dev.amconll",
        "GUM": ud_prefix+"GUM/dev/dev.amconll",
        "LinES": ud_prefix+"LinES/dev/dev.amconll",
        "ParTUT": ud_prefix+"ParTUT/dev/dev.amconll",

        "MRP-DM" : "data/MRP/DM/gold-dev/gold-dev.amconll",
        "MRP-PSD" : "data/MRP/PSD/gold-dev/gold-dev.amconll",
        "MRP-EDS" : "data/MRP/EDS/gold-dev/gold-dev.amconll",

        "MRP-AMR" : "data/MRP/AMR/"+MRP_AMR_SUBPATH+"/gold-dev/gold-dev.amconll",

        "MRP-UCCA" : "data/MRP/UCCA/"+MRP_UCCA_SUBPATH+"/gold-dev/gold-dev.amconll"
    }
}

