#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

me=$(basename "$0")
config_file=$HOME/.config/v/config.sh

main() {
	check_params "$@"

	local cmd=$1
	shift

	case $cmd in
	c | conf | config | configure) v_config ;;
	pc | print-config) v_print_config ;;
	add) v_add "$@" ;;
	ls | list) aws-vault list ;;
	aws) v_aws "$@" ;;
	t | tf | terraform) v_terraform "$@" ;;
	k | kube | kubectl) v_kubectl "$@" ;;
	s | sh | shell) v_shell "$@" ;;
	e | ex | exec) v_execute "$@" ;;
	*) usage ;;
	esac
}

check_params() {
	if [[ $# -lt 1 || $1 =~ "help" ]]; then
		usage
	fi
}

usage() {
	cat >&2 <<USAGE
usage: $me <command>

Get started:
  $me config
  $me print-config

Manage accounts:
  $me add
  $me list

Work in target accounts:
  $me kubectl
  $me aws
  $me terraform
  $me shell
  $me exec
USAGE

	exit 1
}

v_config() {
	local federation_account_name federation_account_id target_role_name user_login region

	read -erp "Federation account name: " federation_account_name
	read -erp "Federation account ID: " federation_account_id
	read -erp "Target role name: " target_role_name
	read -erp "User log-in: " user_login
	read -erp "Region: " region

	mkdir -p "$(dirname "$config_file")"

	cat >"$config_file" <<CONFIG
federation_account_name=$federation_account_name
federation_account_id=$federation_account_id
target_role_name=$target_role_name
user_login=$user_login
region=$region
CONFIG

	if ! aws-vault list --profiles | grep -q "$federation_account_name"; then
		aws-configure --profile "$federation_account_name" set region eu-west-1
		aws configure --profile "$federation_account_name" set mfa_serial "arn:aws:iam::$federation_account_id:mfa/$user_login"
		aws-vault add "$federation_account_name"
	fi
}

v_print_config() {
	cat "$config_file"
}

v_add() {
	local region federation_account_name federation_account_id target_role_name user_login

	# shellcheck disable=SC1090
	. "$config_file"

	local profile=${1?usage: $me add <profile> <account id>}
	local account_id=${2?usage: $me add <profile> <account id>}

	aws configure --profile "$profile" set region "$region"
	aws configure --profile "$profile" set source_profile "$federation_account_name"
	aws configure --profile "$profile" set role_arn "arn:aws:iam::$account_id:role/$target_role_name"
	aws configure --profile "$profile" set mfa_serial "arn:aws:iam::$federation_account_id:mfa/$user_login"
}

v_aws() {
	local profile=${1?usage: $me aws <profile>}
	shift

	exec "$me" exec "$profile" aws "$@"
}

v_terraform() {
  local profile=${1?usage: $me terraform <profile>}
  shift

  exec "$me" exec "$profile" terraform "$@"
}

v_kubectl() {
	local profile=${1?usage: $me kubectl <profile>}
	shift

	export KUBECONFIG=$HOME/.kube/config-$profile

	if [[ ! -e "$KUBECONFIG" ]]; then
		aws-vault exec "$profile" -- aws eks update-kubeconfig --name EKS-Cluster
	fi

	aws-vault exec "$profile" -- kubectl "$@"
}

v_shell() {
	local profile=${1?usage: $me shell <profile>}
	shift

	aws-vault exec "$profile" -- "$SHELL"
}

v_execute() {
	local profile=${1?usage: $me exec <profile>}
	shift

	aws-vault exec "$profile" -- "$@"
}

main "$@"
