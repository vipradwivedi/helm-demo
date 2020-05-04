#!/bin/bash

SECRET_KEY=""
SECRET_VALUE=""
SERVICE_NAME=""
EXISTING_VALUE=""
DELETE_SECRET=""

SECRET_FILENAME=""
EXISTING_SECRETS=""
ANSIBLE_VAULT_KEY_FILE=${ANSIBLE_VAULT_PASSWORD_FILE:-'.vault.pass.file.dev'}

function main() {
#  check_git_status

  parse_args $@

  check_vault_pass_file_exists

  if [ -f "$SECRET_FILENAME" ]; then
    echo "Decrypting $SECRET_FILENAME usinig ansibel-vault with pass file $ANSIBLE_VAULT_KEY_FILE"
    ansible-vault decrypt --vault-password-file $ANSIBLE_VAULT_KEY_FILE $SECRET_FILENAME
  fi

  create_k8_secret

  echo "Encrypted $SECRET_FILENAME"
  ansible-vault encrypt --vault-password-file $ANSIBLE_VAULT_KEY_FILE $SECRET_FILENAME

  echo "Commit changes"
#  git add $SECRET_FILENAME
#  git commit -m "Modified $SECRET_FILENAME with key $SECRET_KEY"
}

function check_git_status() {
  if [[ `git status --porcelain` ]]; then
    echo "You do not have clean git status, commit your changes before you run this script"
    exit 0
  else
    echo "Pulling latest changes from origin"
    git pull
  fi
}

function create_k8_secret() {
  if [ "$DELETE_SECRET" == "true" ]; then
    print_secrets
    echo "Delete secret $SECRET_KEY"
    yq d -i "$SECRET_FILENAME" $SECRET_KEY
    print_secrets
  else
    kubectl create secret generic $SERVICE_NAME --from-literal=$SECRET_KEY=$SECRET_VALUE --dry-run -oyaml > "$SECRET_FILENAME-tmp.yml"
    if [ -f $SECRET_FILENAME ]; then
      echo "Updating $SECRET_FILENAME with new secrets"
      yq merge -i -x "$SECRET_FILENAME" "$SECRET_FILENAME-tmp.yml"

    else
      cp "$SECRET_FILENAME-tmp.yml" "$SECRET_FILENAME"
    fi
    print_secrets
    rm "$SECRET_FILENAME-tmp.yml"
  fi
}

function print_secrets() {
    echo "************************************************"
    cat "$SECRET_FILENAME"
    echo "************************************************"
}

function check_vault_pass_file_exists() {
  SECRET_FILENAME="$SERVICE_NAME-secret.yaml"
  echo "Secret file name: $SECRET_FILENAME"
  if [ ! -f "$ANSIBLE_VAULT_KEY_FILE" ]; then
    s=$(date | md5sum | cut -d' ' -f1)
    echo $s > $ANSIBLE_VAULT_KEY_FILE
  fi
  echo "Using $ANSIBLE_VAULT_KEY_FILE as vault password file, with content `cat $ANSIBLE_VAULT_KEY_FILE`"
}

function parse_args() {
  while getopts ":k:v:s:e:d:h" opt; do
    case ${opt} in
      k) SECRET_KEY="$OPTARG";;
#      v) SECRET_VALUE=$(echo -n "$OPTARG" | base64);;
      v) SECRET_VALUE="$OPTARG";;
      s) SERVICE_NAME="$OPTARG";;
      e) EXISTING_VALUE="$OPTARG";;
      d) DELETE_SECRET="$OPTARG";;
      h) echo_help ;;
      \?) echo "Invalid option -$OPTARG" >&2;;
    esac
  done

  if [ -z "$SECRET_KEY" ] || [ -z "$SECRET_VALUE" ] || [ -z "$SERVICE_NAME" ] || [ -z "$EXISTING_VALUE" ]; then
      echo "All 4 params are mandatory, please check help (-h) for more info"
  else
      echo "SECRET_KEY: $SECRET_KEY, SECRET_VALUE: $SECRET_VALUE, SERVICE_NAME: $SERVICE_NAME"
      echo "EXISTING_VALUE: $EXISTING_VALUE, DELETE_SECRET: $DELETE_SECRET"
  fi

}

function echo_help() {
  echo "******************* H E L P ***************************"
  echo "Script to manage secrets"
  echo "Usage:  ./manage-secrets.sh -k key -v value -s service -e true"
  echo "    -k: (String): Secret Key name"
  echo "    -v: (String): Secret Value for key"
  echo "    -s: (String): Service Name"
  echo "    -e: (true/false): Updating existing key"
  echo "    -d: (true/false): Delete existing key"
  echo ""
  echo "Examples:"
  echo "  ./manage-secrets.sh -s tinyurl -e true -k admin1 -v pass"
  echo "  ./manage-secrets.sh -s tinyurl -e true -k admin1 -v pass -d true"
  echo "******************************************************"
  exit 0
}

main $@
