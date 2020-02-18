#/bin/bash

# Check if JQ is intalled
export jqPath="$(which jq)"

if [ "$jqPath" == "" ]; then
  echo "FAILED: jq needs to be installed"
  exit 1
fi

# Functions
function getDcResources(){

  echo "Allocated Resources on dc $2"
  echo $(oc get dc $2 -o json -n $1 | jq .spec.template.spec.containers[].resources)
}

getPodActualUsage(){

  echo "Actual Resource Usage at this time for pods from dc $1"
  oc adm top pod -n $1 | grep "^$2" | grep -v '\-deploy' | grep -v '\-build'
}

function getProjectDCResourceLimits(){

  echo "Itterating through DC's in project $1"

  dcList=$(oc get dc -n $1 --no-headers | awk '{ print $1 }')

  for dc in $dcList; do
    echo "Resources on deployment : $dc"

      getDcResources $1 $dc
      getPodActualUsage $1 $dc

    echo "-----------------------------"
  done

}

function getProjects() {
  echo "Getting Projects"

  # Get projects except for built in projects
  PROJECTS=$(oc get projects --no-headers | grep -v ^openshift | grep -v ^kube | grep -v default | grep -v ^istio | awk '{ print $1 }')

  for project in $PROJECTS; do
    echo "Project: $project"
    getProjectDCResourceLimits $project


    echo "===================================="
  done
}

getProjects