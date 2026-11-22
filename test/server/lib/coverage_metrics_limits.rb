def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 378 ],
    [ 'test.lines.missed'   , '<=', 0   ],
    [ 'test.branches.total' , '<=', 0   ],
    [ 'test.branches.missed', '<=', 0   ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 281 ],
    [ 'code.lines.missed'   , '<=', 0   ],
    [ 'code.branches.total' , '<=', 50  ],
    [ 'code.branches.missed', '<=', 0   ],
  ]
end
