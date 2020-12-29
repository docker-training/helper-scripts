#!/bin/bash -e

owner="docker-training"
repo="cnc-presentations"

read -sp "GH token, generate at https://github.com/settings/tokens/new, click only the box by 'repo' at the top: " token
echo " "

PS3="Select which release you'd like (when in doubt, choose option '1'): "
options=$(curl -H "Authorization: token ${token}" -s https://api.github.com/repos/${owner}/${repo}/releases | jq '.[] | .name')
select tag in $(echo ${options//\"})
do
  break
done

PS3="Select which image you'd like to download: "
options=("Slides (all courses)" "CN100: Container Essentials Exercises" "CN110: Swarm Essentials Exercises" "CN120: Kube Essentials Exercises" "CN211: Mirantis Container Cloud Exercises" "CN212: Mirantis Kubernetes Engine Exercises" "CN213: Mirantis Secure Registry" "CN220: Kube Operations Exercises" "CN230: Kube Native Application Developers Exercises" "CN320: Advanced Kube Ops Exercises")
select opt in "${options[@]}"
do
  case $REPLY in
    1)
      artifact="slides-${tag}.tgz"
      break
      ;;
    2)
      artifact="cn100-exercises-${tag}.tgz"
      break
      ;;
    3)
      artifact="cn110-exercises-${tag}.tgz"
      break
      ;;
    4)
      artifact="cn120-exercises-${tag}.tgz"
      break
      ;;
    5)
      artifact="cn211-exercises-${tag}.tgz"
      break
      ;;
    6)
      artifact="cn212-exercises-${tag}.tgz"
      break
      ;;
    7)
      artifact="cn213-exercises-${tag}.tgz"
      break
      ;;
    8)
      artifact="cn220-exercises-${tag}.tgz"
      break
      ;;
    9)
      artifact="cn230-exercises-${tag}.tgz"
      break
      ;;
    10)
      artifact="cn320-exercises-${tag}.tgz"
      break
      ;;
    *)
      echo "bad option, try again"
  esac
done

list_asset_url="https://api.github.com/repos/${owner}/${repo}/releases/tags/${tag}"

# get url for artifact with name==$artifact
asset_url=$(curl -H "Authorization: token ${token}" -s "${list_asset_url}" | jq ".assets[] | select(.name==\"${artifact}\") | .url" | sed 's/\"//g')
asset_url=$(echo $asset_url | sed "s|https://|https://${token}:@|g")

# download the artifact
curl -LJO -H 'Accept: application/octet-stream' "${asset_url}"

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
    docker container run --rm -d -p 8888:80 training/cn100-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8888"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  3)
    docker container run --rm -d -p 8889:80 training/cn110-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8889"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  4)
    docker container run --rm -d -p 8890:80 training/cn120-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8890"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  5)
    docker container run --rm -d -p 8891:80 training/cn211-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8891"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  6)
    docker container run --rm -d -p 8892:80 training/cn212-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8892"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  7)
    docker container run --rm -d -p 8893:80 training/cn213-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8893"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  8)
    docker container run --rm -d -p 8894:80 training/cn220-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8894"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  9)
    docker container run --rm -d -p 8895:80 training/cn230-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8895"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  10)
    docker container run --rm -d -p 8896:80 training/cn320-exercises:${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8896"
    echo "feedback? open an issue at https://github.com/docker-training/cnc-exercises/issues"
    ;;
  *)
    echo "bad option, try again"
esac
