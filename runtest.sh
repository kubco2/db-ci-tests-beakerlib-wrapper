#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/beakerlib/Sanity/db-ci-tests
#   Description: run ci tests
#   Author: Jakub Janco <jjanco@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2018 Red Hat, Inc.
#
#   This program is free software: you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation, either version 2 of
#   the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE.  See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see http://www.gnu.org/licenses/.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include Beaker environment
. /usr/bin/rhts-environment.sh || exit 1
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="cassandra"
KOJI_TASK="25697502"

rlJournalStart
    rlPhaseStartSetup
        rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        rlRun "yum -y install git"
        rlRun "git clone https://github.com/kubco2/db-ci-tests.git"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "pushd db-ci-tests"
        rlRun "./run-koji.sh $PACKAGE $KOJI_TASK"
        rlRun "ls /tmp/db-ci-results-*/tests.log" 0
        cat /tmp/db-ci-results-*/tests.log | while read line; do 
            rlAssertEquals "$(echo $line | cut -d' ' -f2)" "[PASSED]" "$(echo $line | cut -d' ' -f1)"; 
        done
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
        # maybe copy them into jenkins artifacts before deleting them
        rlRun "rm -r /tmp/db-ci-results-*/" 0 "Removing tmp db-ci-tests directory"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
