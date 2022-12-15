
# - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_demo_only()
{
  if demo_only_arg "${1:-}" ; then
    demo
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_only_arg()
{
  [ "${1:-}" == '--demo-only' ] || [ "${1:-}" == '-do' ]
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
demo()
{
  local -r TMP_HTML_FILENAME=/tmp/differ-demo.html
  docker exec \
    "${CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME}" \
      sh -c 'ruby /differ/app/html_demo.rb' \
        > ${TMP_HTML_FILENAME}
  open "file://${TMP_HTML_FILENAME}"
}
