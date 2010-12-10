# Default init script logging functions suitable for Ubuntu.
# See /lib/lsb/init-functions for usage help.

LSB_SCREEN=
LSB_LOG=/var/log/lsb.log
LSB_STARTUP=/var/run/lsb-startup

log_to_screen () {
    [ -z $LSB_SCREEN ] || return $LSB_SCREEN
    if `grep -q '\<quiet\>' /proc/cmdline`; then
        LSB_SCREEN=1  # this is actually 'false'
    else
        LSB_SCREEN=0
    fi
    return $LSB_SCREEN
}

log () {
    if log_to_screen; then
        echo "$@"
    fi
    # $LSB_STARTUP is automatically cleared on each reboot, acting as an
    # effective trigger to identify when to create a new LSB log file.
    if [ ! -e $LSB_STARTUP ]; then
        [ -e $LSB_LOG.5 ] && rm $LSB_LOG.5
        [ -e $LSB_LOG.4 ] && mv $LSB_LOG.4 $LSB_LOG.5
        [ -e $LSB_LOG.3 ] && mv $LSB_LOG.3 $LSB_LOG.4
        [ -e $LSB_LOG.2 ] && mv $LSB_LOG.2 $LSB_LOG.3
        [ -e $LSB_LOG.1 ] && mv $LSB_LOG.1 $LSB_LOG.2
        [ -e $LSB_LOG ] && mv $LSB_LOG $LSB_LOG.1
        touch $LSB_STARTUP
        echo LSB Startup: `date -R` > $LSB_LOG
    fi
    echo "$@" >> $LSB_LOG
}

log_success_msg () {
    log " * $@"
}

log_failure_msg () {
    log " FAIL* $@"
}

log_warning_msg () {
    log " WARN* $@"
}

log_begin_msg () {
    log_daemon_msg "$1"
}

log_daemon_msg () {
    if [ -z "$1" ]; then
        return 1
    fi

    log " * $@"
}

log_progress_msg () {
    :
}

log_end_msg () {
    if [ -z "$1" ]; then
        return 1
    fi

    if [ "$1" -eq 0 ]; then
        log "   ...done."
    else
        log "   ...fail!"
    fi

    return $1
}

log_action_msg () {
    log " * $@"
}

log_action_begin_msg () {
    log_daemon_msg "$@..."
}

log_action_cont_msg () {
    log_daemon_msg "$@..."
}

log_action_end_msg () {
    # In the future this may do something with $2 as well.
    log_end_msg "$1" || true
}
