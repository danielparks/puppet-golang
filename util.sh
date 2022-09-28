# Source this file to get convenient rake and bolt_task_run functions.
#
# Set UTIL_TRACE to print the function and its parameters before running.

util_trace () {
  [[ -z "$UTIL_TRACE" ]] || echo "$*"
}

rake () {
  util_trace "rake $*"
  pdk bundle exec rake "$@"
}

bolt_task_run () {
  util_trace "bolt_task_run $*"
  BOLT_GEM=1 pdk bundle exec bolt task run \
    --modulepath spec/fixtures/modules \
    --inventoryfile spec/fixtures/litmus_inventory.yaml \
    --targets '*' \
    "$@"
}
