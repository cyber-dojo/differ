
MIN = {
  test_count:1,
  line_ratio:3.0,
  hits_ratio:1.3,
}

MAX = {
  failures:0,
  errors:0,
  warnings:1,
  skips:0,

  duration:2,

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
       total:500,
      missed:0,
    },
    branches: {
       total:0,
      missed:0,
    }
  }
}
