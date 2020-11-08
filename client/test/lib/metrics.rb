
# max values used by cyberdojo/check-test-results image
# which is called from scripts/test_in_containers.sh

MAX = {
  failures:0,
  errors:0,
  warnings:0,
  skips:0,

  duration:10,

  app: {
    lines: {
       total:100,
      missed:0,
    },
    branches: {
       total:10,
      missed:0,
    }
  },

  test: {
    lines: {
       total:300,
      missed:0,
    },
    branches: {
       total:0,
      missed:0,
    }
  }
}
