#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "start-project-containers.sh: Stop the containers of a rollyourown.xyz project"
  echo ""
  echo "Help: start-project-containers.sh"
  echo "Usage: ./start-project-containers.sh -n hostname -m mode"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to start project containers"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./start-project-containers.sh -h\" for help"
  exit 1
}

while getopts n:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ]
then
  errorMessage
fi

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/../configuration/configuration_"$hostname".yml)"


# Start project containers
##########################

echo ""
echo "Starting project container..."

echo "...starting "$PROJECT_ID"-webserver container"
lxc start "$hostname":"$PROJECT_ID"-webserver
echo ""
echo "...starting "$PROJECT_ID"-provisioner container"
lxc start "$hostname":"$PROJECT_ID"-provisioner
echo ""

echo "Project container started"
echo ""
