#!/bin/sh

set -e

# task script is in resource-tutorial/10_job_inputs/ folder
# application input is in gopath/src/github.com/cloudfoundry-community/simple-go-web-app folder
# $GOPATH is gopath/ folder
#export GOPATH=$(pwd)/gopath:$(pwd)/gopath/src/github.com/cloudfoundry-community/simple-go-web-app/Godeps/_workspace
#cd gopath/src/github.com/cloudfoundry-community/simple-go-web-app/

# Get and install Git
#apk add --update git 
#go get -v github.com/spf13/hugo
#go get -u -v github.com/spf13/hugo 


# Test blog with Hugo, create output as stag
cd ./yjeong-blog-git
hugo 
pwd 
