# frozen_string_literal: true

def metrics
  [
    [ nil ],
    [ 'test_count',    '>=', 34 ],
    [ 'total_time',    '<=', 50  ],
    [ nil ],
    [ 'failure_count', '<=', 0   ],
    [ 'error_count'  , '<=', 0   ],
    [ 'skip_count'   , '<=', 0   ],
  ]
end
