# Soap Validator

## Prepare for build

Copy `/files` and `/input` to the `soap-validator` folder

## Build docker image

`docker build -t soap-validator .`

## Run container

Run `docker run -v <absolute-path-to-input-folder>/input:/input -it soap-validator` to see the test pass using a correct xml file

Or run `docker run -v <absolute-path-to-input-folder>/input:/input -it -e FILE='message-error.xml' soap-validator` to see the test FAIL