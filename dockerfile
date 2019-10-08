FROM ruby:2.6.3-alpine

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache \
    build-base curl-dev yaml-dev zlib-dev 
WORKDIR /usr/src/app

COPY Gemfile*  ./
RUN bundle install

COPY files/ ./files
COPY wsdl_validator.rb validator.rb ./

ENV FILE=message-correct.xml

VOLUME [ "/input" ]

CMD ["sh", "-c", "./validator.rb /input/${FILE}"]