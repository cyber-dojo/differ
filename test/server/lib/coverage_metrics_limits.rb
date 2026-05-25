def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 375 ],
    [ 'test.lines.missed'   , '<=', 0   ],
    [ 'test.branches.total' , '<=', 0   ],
    [ 'test.branches.missed', '<=', 0   ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 253 ],
    [ 'code.lines.missed'   , '<=', 0   ],
    [ 'code.branches.total' , '<=', 54  ],
    [ 'code.branches.missed', '<=', 0   ],
  ]
end
