# frozen_string_literal: true

def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 237 ],
    [ 'test.lines.missed'   , '<=', 0   ],
    [ 'test.branches.total' , '<=', 0   ],
    [ 'test.branches.missed', '<=', 0   ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 103 ],
    [ 'code.lines.missed'   , '<=', 0   ],
    [ 'code.branches.total' , '<=', 8   ],
    [ 'code.branches.missed', '<=', 0   ],
  ]
end
