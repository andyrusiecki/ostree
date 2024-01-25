#!/bin/bash

context="$(kubectl config current-context)"
tooltip="$(kubectl config get-contexts)"

echo '{"text": "'$context'","tooltip":"'$tooltip'"}'

