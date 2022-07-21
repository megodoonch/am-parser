#!/bin/bash
##
## Copyright (c) 2020 Saarland University.
##
## This file is part of AM Parser
## (see https://github.com/coli-saar/am-parser/).
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##



usage="Preprocess an AMR corpus, in ACL 2019 style.\n\n

Arguments: \n
\n\t   -d  main directory where corpus lives
\n\t	 -m  memory limit to be used for the task (default: 6G)
\n\t	 -o  directory where output files will be put (default: new 'output' folder in main directory)
\n\t	 -t  number of threads (default: 1)
\n\t   -v  (flag) make corefSplit print all remaining graph IDs after every step
"

verbose=""

while getopts "d:m:o:t:hv" opt; do
    case $opt in
	h) echo -e $usage
	   exit
	   ;;
	d) maindir="$OPTARG"
	   ;;
	m) memLimit="$OPTARG"
	   ;;
	o) outputPath="$OPTARG"
	   ;;
	t) threads="$OPTARG"
	   ;;
	v) verbose="-v"
	  ;;
       	\?) echo "Invalid option -$OPTARG" >&2
	    ;;
    esac
done

if [ "$maindir" = "" ]; then
    printf "\n No main directory given. Please use -d option."
    exit 1
fi





rawAMRCorpus=$maindir/corpus # folder containing the raw corpus as if just downloaded from the website

# folder containing the alto corpora (train, dev and test folders; will use versions $NNdataCorpusName for input to neural network (i.e. the constraints) and $evalDataCorpusName for evaluation input
# TODO move the following to the appropriate script: 'path to the folder containing train, dev and test folders (usually PATH_TO_CORPUS/data/amrs/split/)'

# path to the output folder for the NN training data and evaluation input (this will generate train and dev folders inside)

if [ "$outputPath" = "" ]; then
    outputPath=$maindir/data
fi

log=$outputPath/preprocessLog

trainNNdata=$outputPath/nnData/train/
devNNdata=$outputPath/nnData/dev/
evalDevNNdata=$outputPath/nnData/evalDev/
testNNdata=$outputPath/nnData/test/

trainAltodata=$outputPath/alto/train/
devAltodata=$outputPath/alto/dev/
evalDevAltodata=$outputPath/alto/evalDev/
testAltodata=$outputPath/alto/test/

echo "Starting $(date)" >> "$log"

#alto="alto-2.3-SNAPSHOT-jar-with-dependencies.jar"
alto="am-tools.jar"

if [ -f "$alto" ]; then
    echo "jar file found at $alto"
else
    echo "jar file not found at $alto, downloading it!"
    wget -O "$alto" http://www.coli.uni-saarland.de/projects/amparser/am-tools.jar
fi

# a lot of scripts live here so let's store it as a variable in case it changes
datascriptPrefix="de.saar.coli.amrtagging.formalisms.amr.tools.datascript"


# make subdirectories in the output directory
mkdir -p $trainNNdata  # neural network (NN) training input
mkdir -p $devNNdata  # NN dev set (to optimise the epoch)
mkdir -p $evalDevNNdata  # NN evalDev set 
mkdir -p $testNNdata  # NN test set 

# for alto to read
mkdir -p $trainAltodata              # train input for evaluation
mkdir -p $devAltodata              # dev input for evaluation
mkdir -p $evalDevAltodata              # dev input for evaluation
mkdir -p $testAltodata             # test input for evaluation

# Download models if necessary.
bash scripts/setup_AMR.sh

NNdataCorpusName="namesDatesNumbers_AlsFixed_sorted.corpus"  # from which we get the NN training data
evalDataCorpusName="finalAlto.corpus"                        # from which we get the dev and test evaluation data
trainMinuteLimit=180                                         # limit for generating NN training data
devMinuteLimit=20                                            # limit for generating NN dev data
if [ "$threads" = "" ]; then
    threads=1
fi
if [ "$memLimit" = "" ]; then
    memLimit=6G
fi
posTagger="downloaded_models/stanford/english-bidirectional-distsim.tagger"
nerTagger="downloaded_models/stanford/english.conll.4class.distsim.crf.ser.gz"
wordnet="downloaded_models/wordnet3.0/dict/"
#wordnet="/proj/corpora/wordnet/3.0/dict/"

# disable use of conceptnet by replacing this with 'conceptnet=""'
#conceptnet="--conceptnet resources/conceptnet-assertions-5.7.0.csv.gz"
conceptnet=""

# raw training data, preprocess, alto format.
preprocessTrainCMD="java -Xmx$memLimit -cp $alto $datascriptPrefix.RawAMRCorpus2TrainingData -i $rawAMRCorpus/training/ -o $trainAltodata --corefSplit -t $threads --minutes $trainMinuteLimit -w $wordnet $conceptnet -pos $posTagger $verbose >>$log 2>&1"
printf "preprocessing training set and putting it into Alto-readable format %s\n" "$(date)"
printf "preprocessing training set and putting it into Alto-readable format %s\n" "$(date)" >> $log
echo $preprocessTrainCMD >> $log
eval $preprocessTrainCMD

# TODO same for nndev
preprocessNNDevCMD="java -Xmx$memLimit -cp $alto $datascriptPrefix.RawAMRCorpus2TrainingData -i $rawAMRCorpus/dev/ -o $devAltodata --corefSplit -t $threads --minutes $devMinuteLimit -w $wordnet $conceptnet -pos $posTagger $verbose >>$log 2>&1"
printf "\npreprocessing NNdev set (dev set for neural network optimisation) and putting it into Alto-readable format %s\n" "$(date)"
printf "\npreprocessing NNdev set (dev set for neural network optimisation) and putting it into Alto-readable format %s\n" "$(date)" >> $log
echo $preprocessNNDevCMD >> $log
eval $preprocessNNDevCMD


# get the dependency trees for the training set
trainCMD="java -Xmx$memLimit -cp $alto de.saar.coli.amrtagging.formalisms.amr.tools.DependencyExtractorCLI -c $trainAltodata/$NNdataCorpusName -li $trainMinuteLimit -o $trainNNdata -t $threads -pos $posTagger >>$log 2>&1"
printf "\ngenerating dependency trees for the train set %s\n"  "$(date)"
printf "\ngenerating dependency trees for the train set %s\n"  "$(date)" >> $log
echo $trainCMD >> $log
eval $trainCMD


# create a words2labelsLookup.txt
wds2lCMD="java -Xmx$memLimit -cp $alto de.saar.coli.amrtagging.ConstraintStats $trainNNdata >>$log 2>&1"
printf "\ncreating words2labelsLookup.txt %s\n"  "$(date)"
printf "\ncreating words2labelsLookup.txt %s\n"  "$(date)" >> $log
echo $wds2lCMD >> $log
eval $wds2lCMD

printf "\nmoving words2labelsLookup.txt to $trainNNdata\n"
cp $trainNNdata/words2labelsLookup.txt $trainAltodata

#get the dependency trees for the dev set
devCMD="java -Xmx$memLimit -cp $alto de.saar.coli.amrtagging.formalisms.amr.tools.DependencyExtractorCLI -c $devAltodata/$NNdataCorpusName -li $devMinuteLimit -o $devNNdata -t $threads -v $trainNNdata -pos $posTagger  >>$log 2>&1"
printf "\ngenerating dependency trees for the dev set, using graph strings from the training set %s\n"  "$(date)"
printf "\ngenerating dependency trees for the dev set, using graph strings from the training set %s\n"  "$(date)" >> $log
echo $devCMD >> $log
eval $devCMD



# Raw dev and test to Alto

# dev set
devRawCMD="java -Xmx$memLimit -cp $alto $datascriptPrefix.FullProcess --amrcorpus $rawAMRCorpus/dev/ --output $evalDevAltodata >>$log 2>&1"
printf "\nconverting dev set to Alto format for evaluation %s\n"  "$(date)"
printf "\nconverting dev set to Alto format for evaluation %s\n"  "$(date)" >> $log
echo $devRawCMD >> $log
eval $devRawCMD

# test set
testRawCMD="java -Xmx$memLimit -cp $alto $datascriptPrefix.FullProcess --amrcorpus $rawAMRCorpus/test/ --output $testAltodata  >>$log 2>&1"
printf "\nconverting test set to Alto format for evaluation %s\n"  "$(date)"
printf "\nconverting test set to Alto format for evaluation %s\n"  "$(date)" >> $log
echo $testRawCMD >> $log
eval $testRawCMD

# dev eval input data preprocessing
devEvalCMD="java -Xmx$memLimit -cp $alto $datascriptPrefix.MakeDevData -c $evalDevAltodata -o $evalDevNNdata --stanford-ner-model $nerTagger --tagger-model $posTagger >>$log 2>&1"
printf "\ngenerating evaluation input (full corpus) for dev data %s\n"  "$(date)"
printf "\ngenerating evaluation input (full corpus) for dev data %s\n"  "$(date)" >> $log
echo $devEvalCMD  >> $log
eval $devEvalCMD

# test eval input data preprocessing
testEvalCMD="java -Xmx$memLimit -cp $alto $datascriptPrefix.MakeDevData -c $testAltodata -o $testNNdata --stanford-ner-model $nerTagger --tagger-model $posTagger >>$log 2>&1"
printf "\ngenerating evaluation input (full corpus) for test data %s\n"  "$(date)"
printf "\ngenerating evaluation input (full corpus) for test data %s\n"  "$(date)" >> $log
echo $testEvalCMD  >> $log
eval $testEvalCMD

# move some stuff around
printf "\nMoving some files around. If you get errors here, something above didn't work. Check the logfile in $log\n"
mkdir $outputPath/nnData/vocab
mv $trainNNdata/vocab*  $outputPath/nnData/vocab/

cp $evalDevAltodata/raw.amr $evalDevNNdata/goldAMR.txt
cp $testAltodata/raw.amr $testNNdata/goldAMR.txt


#Create amconll file for training set
devamconllCMD="java -Xmx$memLimit -cp $alto de.saar.coli.amrtagging.formalisms.amr.tools.ToAMConll -c $trainNNdata -o $outputPath --stanford-ner-model $nerTagger >>$log 2>&1"
printf "\nGenerate amconll for training data %s\n"  "$(date)"
eval $devamconllCMD
mv $outputPath/corpus.amconll $outputPath/train.amconll

#Create amconll file for dev set
devamconllCMD="java -Xmx$memLimit -cp $alto de.saar.coli.amrtagging.formalisms.amr.tools.ToAMConll -c $devNNdata -o $outputPath --stanford-ner-model $nerTagger >>$log 2>&1"
printf "\nGenerate amconll for (gold) dev data %s\n"  "$(date)"
eval $devamconllCMD
mv $outputPath/corpus.amconll $outputPath/gold-dev.amconll


#Create empty amconll for (actual) dev set, also called evalDev
emptyDevAmconllCMD="java -Xmx$memLimit -cp $alto de.saar.coli.amrtagging.formalisms.amr.tools.PrepareTestDataFromFiles -c $evalDevNNdata -o $outputPath --stanford-ner-model $nerTagger >>$log 2>&1"
printf "\nGenerate empty amconll dev data %s\n"  "$(date)"
eval $emptyDevAmconllCMD

#Create empty amconll for test set
emptyTestAmconllCMD="java -Xmx$memLimit -cp $alto de.saar.coli.amrtagging.formalisms.amr.tools.PrepareTestDataFromFiles -c $testNNdata -o $outputPath --prefix test --stanford-ner-model $nerTagger >>$log 2>&1"
printf "\nGenerate empty amconll test data %s\n"  "$(date)"
eval $emptyTestAmconllCMD

#create correct directory structure
output_subdir="output"

mkdir -p $outputPath/$output_subdir/train
mkdir -p $outputPath/$output_subdir/dev
mkdir -p $outputPath/$output_subdir/gold-dev
mkdir -p $outputPath/$output_subdir/test

mv $outputPath/train.amconll "$outputPath/$output_subdir/train/"
mv $outputPath/gold-dev.amconll "$outputPath/$output_subdir/gold-dev/"
mv $outputPath/dev.amconll "$outputPath/$output_subdir/dev/"
mv $outputPath/test.amconll "$outputPath/$output_subdir/test/"

#gold AMRs, create an empty line after each graph
sed ':a;N;$!ba;s/\n/\n\n/g' "$outputPath/alto/dev/raw.amr" > "$outputPath/$output_subdir/dev/goldAMR.txt"
sed ':a;N;$!ba;s/\n/\n\n/g' "$outputPath/nnData/test/goldAMR.txt" > "$outputPath/$output_subdir/test/goldAMR.txt"


#collect lookup data:
mkdir -p "$outputPath/$output_subdir/lookup"

for file in nameLookup.txt nameTypeLookup.txt wikiLookup.txt words2labelsLookup.txt
do
    cp "$outputPath/alto/train/$file" "$outputPath/$output_subdir/lookup/$file"
done



printf "Finished %s\n" "$(date)"
printf "\neverything is in $outputPath\n"
printf "\namconll files are in $outputPath/$output_subdir\n"









