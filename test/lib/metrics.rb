
# max values used by cyberdojo/check-test-results image
# which is called from scripts/test_in_containers.sh

MAX = {
  failures:0,
  errors:0,
  warnings:0,
  skips:0,

  duration:50,

  app: {
    lines: {
       total:362,
      missed:0,
    },
    branches: {
       total:56,
      missed:1,
    }
  },

  test: {
    lines: {
       total:527,
      missed:0,
    },
    branches: {
       total:0,
      missed:0,
    }
  }
}
