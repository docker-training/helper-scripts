#!/bin/bash -e

owner="docker-training"
repo="cnc-presentations"

read -sp "GH token, generate at https://github.com/settings/tokens/new, click only the box by 'repo' at the top: " token
echo " "

PS3="Select which release you'd like (when in doubt, choose option '1'): "
options=$(curl -s https://api.github.com/repos/${owner}/${repo}/releases?access_token=${token} | jq '.[] | .name')
select tag in $(echo ${options//\"})
do
  break
done

PS3="Select which image you'd like to download: "
options=("Slides (all courses)" "CN100: Container Essentials Exercises" "CN110: Swarm Essentials Exercises" "CN120: Kube Essentials Exercises" "CN210: Docker Enterprise Operations Exercises" "CN220: Kube Operations" "CN230: Kube Native Application Developers Exercises" "CN310: Docker Enterprise Troubleshooting" "CN320: Advanced Kube Ops")
select opt in "${options[@]}"
do
  case $REPLY in
    1)
      artifact="slides-${tag}.tgz"
      break
      ;;
    2)
      artifact="container-essentials-exercises-${tag}.tgz"
      break
      ;;
    3)
      artifact="swarm-essentials-exercises-${tag}.tgz"
      break
      ;;
    4)
      artifact="kube-essentials-exercises-${tag}.tgz"
      break
      ;;
    5)
      artifact="de-operations-exercises-${tag}.tgz"
      break
      ;;
    6)
      artifact="kube-ops-exercises-${tag}.tgz"
      break
      ;;
    7)
      artifact="kube-native-app-dev-exercises-${tag}.tgz"
      break
      ;;
    8)
      artifact="de-troubleshooting-exercises-${tag}.tgz"
      break
      ;;
    9)
      artifact="advanced-kube-ops-exercises-${tag}.tgz"
      break
      ;;
    *)
      echo "bad option, try again"
  esac
done

list_asset_url="https://api.github.com/repos/${owner}/${repo}/releases/tags/${tag}?access_token=${token}"

# get url for artifact with name==$artifact
asset_url=$(curl -s "${list_asset_url}" | jq ".assets[] | select(.name==\"${artifact}\") | .url" | sed 's/\"//g')

# download the artifact
curl -LJO -H 'Accept: application/octet-stream' "${asset_url}?access_token=${token}"

# load as docker image
docker image load -i $artifact

# run image
case $REPLY in
  1)
    docker container run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock training/docker-present:${tag} -p 8000
    echo "slides live at localhost:8000"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-presentations/issues"
    ;;
  2)
    docker container run --rm -d -p 8888:8080 training/container-essentials-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8888"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  3)
    docker container run --rm -d -p 8889:8080 training/swarm-essentials-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8889"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  4)
    docker container run --rm -d -p 8880:8080 training/kube-essentials-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8890"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  5)
    docker container run --rm -d -p 8891:8080 training/de-operations-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8891"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  6)
    docker container run --rm -d -p 8892:8080 training/kube-ops-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8892"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  7)
    docker container run --rm -d -p 8893:8080 training/kube-native-app-dev-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8893"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  8)
    docker container run --rm -d -p 8894:8080 training/de-troubleshooting-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8894"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  9)
    docker container run --rm -d -p 8895:8080 training/advanced-kube-ops-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8895"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  *)
    echo "bad option, try again"
esac
