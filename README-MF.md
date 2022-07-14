# Meaghan's notes

The am-tools.jar here is Bart's

## Bart

### scripts for Little Prince

```bash
time bash scripts/preprocess_amr.sh -d example/decomposition/amr-lprince/ -o data/AMR/lprince &> data/AMR/lprince/preprocessing.log

python -u train.py jsonnets/single/bert/AMR-2017.jsonnet -s data/AMR/lprince/model  -f --file-friendly-logging  -o ' {"trainer" : {"cuda_device" :  -1  } }' &> data/AMR/lprince/training.log

bash scripts/predict.sh -i example/decomposition/amr-lprince/corpus/test -T AMR-2017 -o data/AMR/lprince/predict -m data/AMR/lprince/model/model.tar.gz &> data/AMR/lprince/predict.log
```

### scripts for toy example

```bash
time bash scripts/preprocess_amr.sh -d example/decomposition/amr/ -o data/AMR/example 2>&1 | tee logfiles/example/preprocessing.log

python -u train.py jsonnets/mini-corpora/example.jsonnet -s models/AMR/toy  -f --file-friendly-logging 2>&1 | tee logfiles/example/training.log

bash scripts/predict.sh -i example/decomposition/amr/corpus/test -T AMR-2017 -o parser_output/example/AMR/predict -m models/AMR/example/model.tar.gz &> logfiles/example/predict.log
```


## Docker commands

`docker ps`: show running containers

`docker ps -a`: show existent containers

`docker rm my_container_name`: remove container

`docker images`: show docker images

`docker start my_container_name`: start stopped container

`docker run <options> my_container_name my_image bash`: create and start a container called `my_container_name` using `my_image` with the given options and then enter a bash shell

`docker run -v $(pwd)/local/directory/to/mount:/where/to/find/it/in/docker/container -it --name my_container_name image_name bash`: create and start container named `my_container_name` using `my_image` and give it access to `local/directory/to/mount`. In the container, you'll find this mounted directory at `/where/to/find/it/in/docker/container` 

This mounts for the docker container all relevant volumes, as you'd find them on your home computer. Use different paths before the colons for the server (probably `/data/volume_2/...`)

```bash
docker run -v $(pwd)/data:/am-parser-app/data -v $(pwd)/logfiles:/am-parser-app/logfiles -v $(pwd)/downloaded_models:/am-parser-app/downloaded_models -v $(pwd)/models:/am-parser-app/models  -it --name am-parser-container am-parser bash
```

Ctrl-P + Ctrl-Q: detach from running container

`docker attach CONTAINER_NAME`: reconnect to running container (don't need to use all the options you used to make it)

`exit` (while in docker bash console): detach and stop running container

## Bug hunting log

```bash
  File "/am-parser-app/graph_dependency_parser/components/cle.py", line 85, in cle_loss
    m[range, g] = m[range, g] - 1.0  # cost augmentation  # TODO MF commented out
RuntimeError: Output 0 of SliceBackward0 is a view and is being modified inplace. This view is the output of a function that returns multiple views. Such functions do not allow the output views to be modified inplace. You should replace the inplace operation by an out-of-place one.

```

Seems switching from `m[range, g] -= 1.0` isn't enough.

According to a warning I saw online from an earlier version of Pytorch, this only became illegal in pytorch 1.6. Am parser documentation recommends 1.1, and it works fine with that.

Fix: use PyTorch 1.1 (updated in Dockerfile)


## Getting Docker to play nicely with Pycharm

* install Docker Engine: https://docs.docker.com/engine/install/ubuntu/
  * I found Docker Desktop's docker daemon wasn't available to PyCharm, so used engine only 
* let non-root run docker: https://docs.docker.com/engine/install/linux-postinstall/
  * or try headless mode, below
* Build the docker image with `docker build -t am-parser .`
* Make it the interpreter:
  * Add Interpreter > Docker > Add server (if none exists, and leave the defaults) > choose am-parser image > ok
* in the terminal, run e.g. `docker run -it --name am-parser-container am-parser bash`

### Headless mode
* use headless mode https://docs.docker.com/engine/security/rootless/
* headless mode can't be turned off, must be uninstalled, I think
* works. Note the terminal isn't using this as an interpreter though. Need to attach to running docker container (see docker commands above)
* 




## Things I tried to make Docker work:

normal docker: can't connect to daemon (permission denied)
Added mego to docker group and now it connects
Can't find the docker images

headless docker: connects to daemon

getting a docker image:
    - docker service in python: can only download remote ones
    - new interpreter > Docker
        - only shows remotely downloaded docker images
        - these don't work either: can't find python
        - once made Pycharm crash so hard I couldn't even find it to stop it


built docker image with dockerd running (root?)
built docker image with headless version running -- didn't need to do anything

terminal in and out of pycharm lists the same docker images as Docker Desktop
These docker images are not listed in pycharm services or possible docker interpreters

restarted pycharm and terminals
