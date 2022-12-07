**table cacheStateTranslate**

| CUR_STATE     | requestType              | Action         | Parameters                         |
| ------------- | ------------------------ | -------------- | ---------------------------------- |
| STATE_SHARED  | REQUEST_TYPE_FIRST_READ  | get_next_state | STATE_SHARED, MISS_TYPE_NOT_MISS   |
| STATE_SHARED  | REQUEST_TYPE_FIRST_WRITE | get_next_state | STATE_MODIFY, MISS_TYPE_WRITE_MISS |
| STATE_SHARED  | REMOTE_WRITE_MISS        | get_next_state | STATE_INVALID, MISS_TYPE_NOT_MISS  |
| STATE_SHARED  | REMOTE_READ_MISS         | get_next_state | STATE_SHARED, MISS_TYPE_NOT_MISS   |
| STATE_MODIFY  | REQUEST_TYPE_FIRST_READ  | get_next_state | STATE_MODIFY, MISS_TYPE_NOT_MISS   |
| STATE_MODIFY  | REQUEST_TYPE_FIRST_WRITE | get_next_state | STATE_MODIFY, MISS_TYPE_NOT_MISS   |
| STATE_MODIFY  | REMOTE_WRITE_MISS        | get_next_state | STATE_INVALID, MISS_TYPE_NOT_MISS  |
| STATE_MODIFY  | REMOTE_READ_MISS         | get_next_state | STATE_SHARED, MISS_TYPE_NOT_MISS   |
| STATE_INVALID | REQUEST_TYPE_FIRST_READ  | get_next_state | STATE_SHARED, MISS_TYPE_READ_MISS  |
| STATE_INVALID | REQUEST_TYPE_FIRST_WRITE | get_next_state | STATE_MODIFY, MISS_TYPE_WRITE_MISS |
| STATE_INVALID | REMOTE_WRITE_MISS        | get_next_state | STATE_INVALID, MISS_TYPE_NOT_MISS  |
| STATE_INVALID | REMOTE_READ_MISS         | get_next_state | STATE_INVALID, MISS_TYPE_NOT_MISS  |



