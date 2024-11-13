# frozen_string_literal: true

def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 525 ],
    [ 'test.lines.missed'   , '<=', 0   ],
    [ 'test.branches.total' , '<=', 0   ],
    [ 'test.branches.missed', '<=', 0   ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 352 ],
    [ 'code.lines.missed'   , '<=', 0   ],
    [ 'code.branches.total' , '<=', 60  ],
    [ 'code.branches.missed', '<=', 1   ],
  ]
end
