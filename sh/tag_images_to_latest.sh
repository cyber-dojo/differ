
# - - - - - - - - - - - - - - - - - - - - - - - -
tag_images_to_latest()
{
  docker tag $(image_name):$(image_tag) $(image_name):latest
  docker tag $(image_name):$(image_tag) cyberdojo/differ:$(image_tag)
  if [ "${1:-}" != server ]; then
    docker tag ${CYBER_DOJO_DIFFER_CLIENT_IMAGE}:$(image_tag) ${CYBER_DOJO_DIFFER_CLIENT_IMAGE}:latest
  fi
}
