# frozen_string_literal: true

def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 545 ],
    [ 'test.lines.missed'   , '<=', 1   ],
    [ 'test.branches.total' , '<=', 2   ],
    [ 'test.branches.missed', '<=', 1   ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 351 ],
    [ 'code.lines.missed'   , '<=', 0   ],
    [ 'code.branches.total' , '<=', 58  ],
    [ 'code.branches.missed', '<=', 0   ],
  ]
end
