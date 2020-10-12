
MIN = {
  test_count:1,
  line_ratio:2.0,
  hits_ratio:3.0,
}

MAX = {
  failures:0,
  errors:0,
  warnings:1,
  skips:0,

  duration:2,

  app: {
    lines: {
       total:500,
      missed:0,
    },
    branches: {
       total:75,
      missed:0,
    }
  },

  test: {
    lines: {
       total:1000,
      missed:0,
    },
    branches: {
       total:0,
      missed:0,
    }
  }
}
