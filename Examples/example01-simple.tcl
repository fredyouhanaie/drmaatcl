
source ~/.drmaashrc

drmaa init
set jt [drmaa ajt]
drmaa sa $jt drmaa_remote_command /bin/sleep
drmaa sva $jt drmaa_v_argv 10
set jid [drmaa rj $jt]
puts "Job ID is $jid"
set wout [drmaa wait $jid $drmaa::DRMAA_TIMEOUT_WAIT_FOREVER]
puts $wout
drmaa exit
