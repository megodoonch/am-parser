local k = 6;
local eval_commands = import 'eval_commands.libsonnet';
local give_up = 15; #15 seconds

local data_paths = import 'data_paths.libsonnet';
local MRP_AMR_SUBPATH = data_paths["MRP_AMR_SUBPATH"];
local MRP_UCCA_SUBPATH = data_paths["MRP_UCCA_SUBPATH"];
local SDP_prefix = data_paths["SDP_prefix"];

local sdp_evaluator(dataset_reader, data_iterator, name, threads, from_epoch) = {
        "type": "standard_evaluator",
        "formalism" : name,
        "system_input" : SDP_prefix+name+"/dev/dev.amconll",
        "gold_file": SDP_prefix+name+"/dev/dev.sdp",
        "use_from_epoch" : from_epoch,
        "predictor" : {
                "type" : "amconll_predictor",
                "dataset_reader" : dataset_reader, #same dataset_reader as above.
                "data_iterator" : data_iterator, #same bucket iterator also for validation.
                "k" : k,
                "threads" : threads,
                "give_up": give_up,
                "evaluation_command" : eval_commands['commands'][name]
        }

};

local mrp_evaluator(dataset_reader, data_iterator, name) = {
        "type": "standard_evaluator",
        "formalism" : "MRP-"+name,
        "system_input" : "data/MRP/"+name+"/dev/dev.amconll",
        "gold_file": "data/MRP/"+name+"/dev/dev.mrp",
        "use_from_epoch" : 1,
        "predictor" : {
                "type" : "amconll_predictor",
                "dataset_reader" : dataset_reader, #same dataset_reader as above.
                "data_iterator" : data_iterator, #same bucket iterator also for validation.
                "k" : k,
                "threads" : 4,
                "give_up": give_up, #try parsing only for 1 second, then retry with smaller k
                "evaluation_command" : eval_commands['commands']['MRP-'+name]
        }
};


#Defines validation evaluators for the formalisms
function (dataset_reader, data_iterator) {
  "AMR-2015" :  {
        "type": "standard_evaluator",
        "formalism" : "AMR-2015",
        "system_input" : "data/AMR/2015/dev/dev.amconll",
        "gold_file": "data/AMR/2015/dev/goldAMR.txt",
        "use_from_epoch" : 10,
        "predictor" : {
                "type" : "amconll_predictor",
                "dataset_reader" : dataset_reader, #same dataset_reader as above.
                "data_iterator" : data_iterator, #same bucket iterator also for validation.
                "k" : k,
                "threads" : 4,
                "give_up": give_up, #try parsing only for 1 second, then retry with smaller k
                "evaluation_command" : eval_commands['commands']['AMR-2015']
        }

  },

    "AMR-2017" :  {
        "type": "standard_evaluator",
        "formalism" : "AMR-2017",
        "system_input" : "data/AMR/2017/dev/dev.amconll",
        "gold_file": "data/AMR/2017/dev/goldAMR.txt",
        "use_from_epoch" : 10,
        "predictor" : {
                "type" : "amconll_predictor",
                "dataset_reader" : dataset_reader, #same dataset_reader as above.
                "data_iterator" : data_iterator, #same bucket iterator also for validation.
                "k" : k,
                "threads" : 4,
                "give_up": give_up, #retry with smaller k
                "evaluation_command" : eval_commands['commands']['AMR-2017']
        }

  },


    "AMR-2017-morphemes" :  {
        "type": "standard_evaluator",
        "formalism" : "AMR-2017-morphemes",
        "system_input" : "data/AMR/AMR2017morphemes/dev/dev.amconll",
        "gold_file": "data/AMR/AMR2017morphemes/dev/goldAMR.txt",
        "use_from_epoch" : 10,
        "predictor" : {
                "type" : "amconll_predictor",
                "dataset_reader" : dataset_reader, #same dataset_reader as above.
                "data_iterator" : data_iterator, #same bucket iterator also for validation.
                "k" : k,
                "threads" : 4,
                "give_up": give_up, #retry with smaller k
                "evaluation_command" : eval_commands['commands']['AMR-2017']
        }

  },

    "AMR-example" :  {
        "type": "standard_evaluator",
        "formalism" : "AMR-example",
        "system_input" : "data/AMR/example/output/dev/dev.amconll",
        "gold_file": "data/AMR/example/output/dev/goldAMR.txt",
        "use_from_epoch" : 10,
        "predictor" : {
                "type" : "amconll_predictor",
                "dataset_reader" : dataset_reader, #same dataset_reader as above.
                "data_iterator" : data_iterator, #same bucket iterator also for validation.
                "k" : k,
                "threads" : 4,
                "give_up": give_up, #retry with smaller k
                "evaluation_command" : eval_commands['commands']['AMR-example']
        }

  },

    "LittlePrince" :  {
        "type": "standard_evaluator",
        "formalism" : "LittlePrince",
        "system_input" : "data/AMR/little-prince/output/dev/dev.amconll",
        "gold_file": "data/AMR/little-prince/output/dev/goldAMR.txt",
        "use_from_epoch" : 10,
        "predictor" : {
                "type" : "amconll_predictor",
                "dataset_reader" : dataset_reader, #same dataset_reader as above.
                "data_iterator" : data_iterator, #same bucket iterator also for validation.
                "k" : k,
                "threads" : 4,
                "give_up": give_up, #retry with smaller k
                "evaluation_command" : eval_commands['commands']['LittlePrince']
        }

  },


      "AMR-2020" :  {
          "type": "standard_evaluator",
          "formalism" : "AMR-2020",
          "system_input" : "data/AMR/2020/dev/dev.amconll",
          "gold_file": "data/AMR/2020/dev/goldAMR.txt",
          "use_from_epoch" : 10,
          "predictor" : {
                  "type" : "amconll_predictor",
                  "dataset_reader" : dataset_reader, #same dataset_reader as above.
                  "data_iterator" : data_iterator, #same bucket iterator also for validation.
                  "k" : k,
                  "threads" : 4,
                  "give_up": give_up, #retry with smaller k
                  "evaluation_command" : eval_commands['commands']['AMR-2020']
          }

    },

    "DM" : sdp_evaluator(dataset_reader, data_iterator, "DM",2,10),

    "PAS" :  sdp_evaluator(dataset_reader, data_iterator, "PAS",4,10),

    "PSD" :  sdp_evaluator(dataset_reader, data_iterator, "PSD",2,10),

    "EDS" :  {
        "type": "standard_evaluator",
        "formalism" : "EDS",
        "system_input" : "data/EDS/dev/dev.amconll",
        "gold_file": "data/EDS/dev/dev-gold",
        "use_from_epoch" : 10,
        "predictor" : {
                "type" : "amconll_predictor",
                "dataset_reader" : dataset_reader, #same dataset_reader as above.
                "data_iterator" : data_iterator, #same bucket iterator also for validation.
                "k" : k,
                "threads" : 2,
                "give_up": give_up, #try parsing only for 1 second, then retry with smaller k
                "evaluation_command" : eval_commands['commands']['EDS']
        }
    },
     #UD doesn't need special evaluators.
     "EWT" : { "type" :  "dummy_evaluator" },
     "GUM" : { "type" :  "dummy_evaluator" },
     "LinES" : { "type" :  "dummy_evaluator" },
     "ParTUT" : { "type" :  "dummy_evaluator" },

     #MRP

      "MRP-DM" :  mrp_evaluator(dataset_reader, data_iterator, "DM"),
      "MRP-PSD" :  mrp_evaluator(dataset_reader, data_iterator, "PSD"),

      "MRP-EDS" :  mrp_evaluator(dataset_reader, data_iterator, "EDS"),

      "MRP-AMR" :  {
          "type": "standard_evaluator",
            "formalism" : "MRP-AMR",
            "system_input" : "data/MRP/AMR/"+MRP_AMR_SUBPATH+"/dev/dev.amconll",
            "gold_file": "data/MRP/AMR/"+MRP_AMR_SUBPATH+"/dev/dev.mrp",
            "use_from_epoch" : 1,
            "predictor" : {
                    "type" : "amconll_predictor",
                    "dataset_reader" : dataset_reader, #same dataset_reader as above.
                    "data_iterator" : data_iterator, #same bucket iterator also for validation.
                    "k" : k,
                    "threads" : 4,
                    "give_up": give_up, #try parsing only for 1 second, then retry with smaller k
                    "evaluation_command" : eval_commands['commands']['MRP-AMR']
            }
        },

        "MRP-UCCA" :  {
          "type": "standard_evaluator",
            "formalism" : "MRP-UCCA",
            "system_input" : "data/MRP/UCCA/"+MRP_UCCA_SUBPATH+"/dev/dev.amconll",
            "gold_file": "data/MRP/UCCA/"+MRP_UCCA_SUBPATH+"/dev/dev.mrp",
            "use_from_epoch" : 25,
            "predictor" : {
                    "type" : "amconll_predictor",
                    "dataset_reader" : dataset_reader, #same dataset_reader as above.
                    "data_iterator" : data_iterator, #same bucket iterator also for validation.
                    "k" : k,
                    "threads" : 8,
                    "give_up": give_up, #try parsing only for 1 second, then retry with smaller k
                    "evaluation_command" : eval_commands['commands']['MRP-UCCA']
            }
        }



}
