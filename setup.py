p4 = bfrt.msi.pipe

# This function can clear all the tables and later on other fixed objects
# once bfrt support is added.
STATE_SHARED = 0 
STATE_MODIFY = 1 
STATE_SAME = 2 
STATE_INVALID = 3
REQUEST_TYPE_READ = 0
REQUEST_TYPE_WRITE = 1 
REMOTE_READ_MISS = 4 
REMOTE_WRITE_MISS = 5
MISS_TYPE_NOT_MISS = 0
MISS_TYPE_READ_MISS = 1
MISS_TYPE_WRITE_MISS = 2
def clear_all(verbose=True, batching=True):
    global p4
    global bfrt
    
    def _clear(table, verbose=False, batching=False):
        if verbose:
            print("Clearing table {:<40} ... ".
                  format(table['full_name']), end='', flush=True)
        try:    
            entries = table['node'].get(regex=True, print_ents=False)
            try:
                if batching:
                    bfrt.batch_begin()
                for entry in entries:
                    entry.remove()
            except Exception as e:
                print("Problem clearing table {}: {}".format(
                    table['name'], e.sts))
            finally:
                if batching:
                    bfrt.batch_end()
        except Exception as e:
            if e.sts == 6:
                if verbose:
                    print('(Empty) ', end='')
        finally:
            if verbose:
                print('Done')

        # Optionally reset the default action, but not all tables
        # have that
        try:
            table['node'].reset_default()
        except:
            pass
    
    # The order is important. We do want to clear from the top, i.e.
    # delete objects that use other objects, e.g. table entries use
    # selector groups and selector groups use action profile members
    

    # Clear Match Tables
    for table in p4.info(return_info=True, print_info=False):
        if table['type'] in ['MATCH_DIRECT', 'MATCH_INDIRECT_SELECTOR']:
            _clear(table, verbose=verbose, batching=batching)

    # Clear Selectors
    for table in p4.info(return_info=True, print_info=False):
        if table['type'] in ['SELECTOR']:
            _clear(table, verbose=verbose, batching=batching)
            
    # Clear Action Profiles
    for table in p4.info(return_info=True, print_info=False):
        if table['type'] in ['ACTION_PROFILE']:
            _clear(table, verbose=verbose, batching=batching)
    
clear_all()
#fill table
cacheStateTranslate0 = p4.Ingress.cacheStateTranslate0
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_SHARED, request_type = REQUEST_TYPE_READ, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_SHARED, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_WRITE_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_SHARED, request_type = REMOTE_READ_MISS, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_SHARED, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_MODIFY, request_type = REQUEST_TYPE_READ, next_state = STATE_MODIFY, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_MODIFY, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_MODIFY, request_type = REMOTE_READ_MISS, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_MODIFY, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_INVALID, request_type = REQUEST_TYPE_READ, next_state = STATE_SHARED, miss_type = MISS_TYPE_READ_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_INVALID, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_WRITE_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_INVALID, request_type = REMOTE_READ_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate0.add_with_get_next_state0(cur_state = STATE_INVALID, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)

cacheStateTranslate1 = p4.Ingress.cacheStateTranslate1
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_SHARED, request_type = REQUEST_TYPE_READ, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_SHARED, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_WRITE_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_SHARED, request_type = REMOTE_READ_MISS, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_SHARED, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_MODIFY, request_type = REQUEST_TYPE_READ, next_state = STATE_MODIFY, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_MODIFY, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_MODIFY, request_type = REMOTE_READ_MISS, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_MODIFY, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_INVALID, request_type = REQUEST_TYPE_READ, next_state = STATE_SHARED, miss_type = MISS_TYPE_READ_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_INVALID, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_WRITE_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_INVALID, request_type = REMOTE_READ_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate1.add_with_get_next_state1(cur_state = STATE_INVALID, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)

cacheStateTranslate2 = p4.Ingress.cacheStateTranslate2
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_SHARED, request_type = REQUEST_TYPE_READ, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_SHARED, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_WRITE_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_SHARED, request_type = REMOTE_READ_MISS, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_SHARED, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_MODIFY, request_type = REQUEST_TYPE_READ, next_state = STATE_MODIFY, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_MODIFY, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_MODIFY, request_type = REMOTE_READ_MISS, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_MODIFY, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_INVALID, request_type = REQUEST_TYPE_READ, next_state = STATE_SHARED, miss_type = MISS_TYPE_READ_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_INVALID, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_WRITE_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_INVALID, request_type = REMOTE_READ_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate2.add_with_get_next_state2(cur_state = STATE_INVALID, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)

cacheStateTranslate3 = p4.Ingress.cacheStateTranslate3
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_SHARED, request_type = REQUEST_TYPE_READ, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_SHARED, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_WRITE_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_SHARED, request_type = REMOTE_READ_MISS, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_SHARED, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_MODIFY, request_type = REQUEST_TYPE_READ, next_state = STATE_MODIFY, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_MODIFY, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_MODIFY, request_type = REMOTE_READ_MISS, next_state = STATE_SHARED, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_MODIFY, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_INVALID, request_type = REQUEST_TYPE_READ, next_state = STATE_SHARED, miss_type = MISS_TYPE_READ_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_INVALID, request_type = REQUEST_TYPE_WRITE, next_state = STATE_MODIFY, miss_type = MISS_TYPE_WRITE_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_INVALID, request_type = REMOTE_READ_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)
cacheStateTranslate3.add_with_get_next_state3(cur_state = STATE_INVALID, request_type = REMOTE_WRITE_MISS, next_state = STATE_INVALID, miss_type = MISS_TYPE_NOT_MISS)

bfrt.complete_operations()

#Final programming
print("""
******************* PROGAMMING RESULTS *****************
""")
print ("Table cacheStateTranslate0:")
cacheStateTranslate0.dump(table=True)
print ("Table cacheStateTranslate1:")
cacheStateTranslate1.dump(table=True)
print ("Table cacheStateTranslate2:")
cacheStateTranslate2.dump(table=True)
print ("Table cacheStateTranslate3:")
cacheStateTranslate3.dump(table=True)