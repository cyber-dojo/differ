# frozen_string_literal: true

def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 526 ],
    [ 'test.lines.missed'   , '<=', 0   ],
    [ 'test.branches.total' , '<=', 0   ],
    [ 'test.branches.missed', '<=', 0   ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 351 ],
    [ 'code.lines.missed'   , '<=', 0   ],
    [ 'code.branches.total' , '<=', 58  ],
    [ 'code.branches.missed', '<=', 0   ],
  ]
end
