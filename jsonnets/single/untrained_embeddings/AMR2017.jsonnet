# Configuration file for the toy AMR corpus provided in example, with no pre-trained word embeddings
# hyperparameters mainly match AMR 2017 GloVe config file

# set to true when you're ready to evaluate on the test set in addition to the dev set
local evaluate_on_test = false;

# Maximum number of epochs to train for
# when testing things out, eventually use a number higher than 10 because before that, Smatch evaluation isn't run
local num_epochs = 100;

# early stopping
# number of epochs to keep training despite not seeing an improvement in dev score
# local patience = 10;  
local patience = null;  # for no early stopping

# GPU number
local device = 0;
# local device = -1;  # for CPU only

# paths to the rest of the configuration files
local test_evaluators = import '../../../configs/test_evaluators.libsonnet';
local data_paths = import '../../../configs/data_paths.libsonnet';
local eval_commands = import '../../../configs/eval_commands.libsonnet';
local UD_banks = data_paths["UD_banks"];
local task_models = import '../../../configs/task_models.libsonnet';


#=========FREDA=========
local use_freda = 0;  # 0 = no, 1 = yes
#=======================

# dimensions
local pos_dim = 32;
local lemma_dim = 64;
local ner_dim = 16;
local word_dim = 100;
local encoder_output_dim = 256; # encoder output dim, per direction, so total will be twice as large
local final_encoder_output_dim = 2 * encoder_output_dim + use_freda * 2 * encoder_output_dim; # freda again doubles output dimension


#============TASKS==============
local my_tasks = ["AMR-2017"];
local main_task = "AMR-2017";  # what validation metric to pay attention to.
#===============================

local dataset_reader = {
        "type": "amconll",
        "token_indexers": {},
      };

local data_iterator = {
        "type": "same_formalism",
        "batch_size": 32,
        "formalisms" : my_tasks
    };

{
    "dataset_reader": dataset_reader,
    "iterator": data_iterator,
     "vocabulary" : {
            "min_count" : {
            "lemmas" : 7
     }
     },
    "model": {
        "type": "graph_dependency_parser",

        "tasks" : [task_models(task_name,dataset_reader, data_iterator, final_encoder_output_dim, "kg_edges","kg_edge_loss","kg_label_loss") for task_name in my_tasks],

        "input_dropout": 0.3,
        "encoder": {
            "type" : if use_freda == 1 then "freda_split" else "shared_split_encoder",
            "formalisms" : my_tasks,
            "formalisms_without_tagging": UD_banks,
            "task_dropout" : 0.0,  # only relevant for freda
            "encoder": {
                "type": "stacked_bidirectional_lstm",
                "num_layers": 2,  # same as for GloVe (sesame street embeddings use 1)
                "recurrent_dropout_probability": 0.4,
                "layer_dropout_probability": 0.3,
                "use_highway": false,
                "hidden_size": encoder_output_dim,
                "input_size": word_dim + pos_dim + lemma_dim + ner_dim
            }
        },

        "pos_tag_embedding":  {
           "embedding_dim": pos_dim,
           "vocab_namespace": "pos"
        },
        "lemma_embedding":  {
           "embedding_dim": lemma_dim,
           "vocab_namespace": "lemmas"
        },
         "ne_embedding":  {
           "embedding_dim": ner_dim,
           "vocab_namespace": "ner_labels"
        },

        "text_field_embedder": {
          "tokens": {
            "type": "embedding",
            "embedding_dim": word_dim
          },
        },

    },
    "train_data_path": [ [task_name, data_paths["train_data"][task_name]] for task_name in my_tasks],
    "validation_data_path": [ [task_name,data_paths["gold_dev_data"][task_name]] for task_name in my_tasks],


    #=========================EVALUATE ON TEST=================================
    "evaluate_on_test" : evaluate_on_test,
    [if evaluate_on_test == true then "test_evaluators" else null]: [test_evaluators(dataset_reader, data_iterator)[main_task]],
    # if set to, when training is done, call evaluation on test sets with best model as described here.
    #==========================================================================

    "trainer": {
        "type" : "am-trainer",
        "num_epochs": num_epochs,
        "patience" : patience,
        "cuda_device": device,
        "optimizer": {
            "type": "adam",
        },
        "validation_metric" : eval_commands["metric_names"][main_task],
        "num_serialized_models_to_keep" : 1
    }
}

