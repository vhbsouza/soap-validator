# Soap Validator

## Prepare for build

Copy `/files` and `/input` to the `soap-validator` folder

## Build docker image

`docker build -t soap-validator .`

## Run container

Rename `./input/message-correct.xml` to `./input/message.xml` to see the test PASS

Or rename `./input/message-error.xml` to `./input/message.xml` to see the test FAIL

Then run: `docker run -v <absolute-path-to-input-folder>/input:/input -it soap-validator`