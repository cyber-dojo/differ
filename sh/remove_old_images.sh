
# - - - - - - - - - - - - - - - - - - - - - -
remove_old_images()
{
  echo Removing old images
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
  remove_all_but_latest "${dil}" "${CYBER_DOJO_DIFFER_IMAGE}"
  remove_all_but_latest "${dil}" "${CYBER_DOJO_DIFFER_CLIENT_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  for image_name in $(echo "${docker_image_ls}" | grep "${name}:")
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      if [ "${image_name}" != "${name}:<none>" ]; then
        docker image rm "${image_name}"
      fi
    fi
  done
  docker system prune --force
}
