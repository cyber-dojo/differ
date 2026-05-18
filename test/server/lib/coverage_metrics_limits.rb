def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 531 ],
    [ 'test.lines.missed'   , '<=', 0   ],
    [ 'test.branches.total' , '<=', 0   ],
    [ 'test.branches.missed', '<=', 0   ],
    [ nil ],
    [ 'code.lines.total'    , '<=', 356 ],
    [ 'code.lines.missed'   , '<=', 0   ],
    [ 'code.branches.total' , '<=', 62  ],
    [ 'code.branches.missed', '<=', 0   ],
  ]
end
