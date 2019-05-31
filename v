#!/usr/bin/env bash

set -eu

me=$(basename $0)

if [[ $# < 1 || $1 =~ "help" ]]; then
	echo >&2 "usage: $me <command>"
	echo >&2
	echo >&2 "$me kubectl"
	echo >&2 "$me exec"
	echo >&2 "$me shell"
	echo >&2
	echo >&2 "$me add"
	echo >&2 "$me list"
	echo >&2 "$me kubectl"
	exit 1
fi

cmd=$1
shift

case $cmd in
add)

	profile=$1
	account_id=$2
	user_login=$3

	aws configure --profile $profile set region eu-west-1
	aws configure --profile $profile set source_profile vrk-federation
	aws configure --profile $profile set role_arn arn:aws:iam::$account_id:role/VRKCloudAdmin
	aws configure --profile $profile set mfa_serial arn:aws:iam::200875756628:mfa/$user_login

	aws-vault add $profile

	;;

ls | list)

	aws-vault list

	;;

k | kube | kubectl)

	profile=$1
	shift

	export KUBECONFIG=${HOME}/.kube/config-${profile}

	if [[ ! -e $KUBECONFIG ]]; then
		aws-vault exec $profile -- aws eks update-kubeconfig --name EKS-Cluster
	fi

	aws-vault exec $profile -- kubectl "$@"

	;;

s | sh | shell)

	profile=$1
	shift

	aws-vault exec $profile -- $SHELL

	;;

e | ex | exec)

	profile=$1
	shift

	aws-vault exec $profile -- "$@"

	;;

*)

	echo >&2 "unsupported: $cmd"
	exit 1

	;;
esac
