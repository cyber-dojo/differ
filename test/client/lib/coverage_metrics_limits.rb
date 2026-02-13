def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 230 ],
    [ 'test.lines.missed'   , '<=', 0   ],
    [ 'test.branches.total' , '<=', 0   ],
    [ 'test.branches.missed', '<=', 0   ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 101 ],
    [ 'code.lines.missed'   , '<=', 0   ],
    [ 'code.branches.total' , '<=', 8   ],
    [ 'code.branches.missed', '<=', 0   ],
  ]
end
