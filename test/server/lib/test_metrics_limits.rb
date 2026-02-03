# frozen_string_literal: true

def metrics
  [
    [ nil ],
    [ 'test_count',    '>=', 106 ],
    [ 'total_time',    '<=',  75 ],
    [ nil ],
    [ 'failure_count', '<=', 0   ],
    [ 'error_count'  , '<=', 0   ],
    [ 'skip_count'   , '<=', 0   ],
  ]
end
