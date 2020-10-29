#!/bin/bash -e

owner="docker-training"
repo="openstack-presentations"

read -sp "GH token, generate at https://github.com/settings/tokens/new, click only the box by 'repo' at the top: " token
echo " "

PS3="Select which release you'd like (when in doubt, choose option '1'): "
options=$(curl -H "Authorization: token ${token}" -s https://api.github.com/repos/${owner}/${repo}/releases | jq '.[] | .name')
select tag in $(echo ${options//\"})
do
  break
done

PS3="Select which image you'd like to download: "
options=("Slides (all courses)" "OS100: OpenStack Essentials Exercises" "OS220: OpenStack Admin & Ops Exercises" "OS320: OpenStack Advanced Deployment Exercises")
select opt in "${options[@]}"
do
  case $REPLY in
    1)
      artifact="slides-os-${tag}.tgz"
      break
      ;;
    2)
      artifact="os100-exercises-os-${tag}.tgz"
      break
      ;;
    3)
      artifact="os220-exercises-os-${tag}.tgz"
      break
      ;;
    4)
      artifact="os-320-exercises-os-${tag}.tgz"
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
    docker container run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock training/docker-present:os-${tag} -p 8000
    echo "slides live at localhost:8000"
    echo "feedback? open an issue at https://github.com/docker-training/openstack-presentations/issues"
    ;;
  2)
    docker container run --rm -d -p 8888:80 training/os100-exercises:os-${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8888"
    echo "feedback? open an issue at https://github.com/docker-training/openstack-exercises/issues"
    ;;
  3)
    docker container run --rm -d -p 8889:80 training/os220-exercises:os-${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8889"
    echo "feedback? open an issue at https://github.com/docker-training/openstack-exercises/issues"
    ;;
  4)
    docker container run --rm -d -p 8890:80 training/os320-exercises:os-${tag}
    echo "exercises live at "$(curl -s icanhazip.com)":8890"
    echo "feedback? open an issue at https://github.com/docker-training/openstack-exercises/issues"
    ;;
  *)
    echo "bad option, try again"
esac

