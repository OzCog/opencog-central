#! /bin/bash
#
# compute-mst-marginals.sh
#
# Start the cogserver, open the database and compute the disjunct
# marginal statistics.  It is safe to run this multiple times.
#
# ----------------------

# Load config parameters
if [ -z $MASTER_CONFIG_FILE ]; then
	echo "MASTER_CONFIG_FILE not defined!"
	exit -1
fi

if [ -r $MASTER_CONFIG_FILE ]; then
	source $MASTER_CONFIG_FILE
else
	echo "Cannot find master configuration file at MASTER_CONFIG_FILE"
	env |grep CONF
	exit -1
fi

if [ -r ${MST_CONF_FILE} ]; then
	source ${MST_CONF_FILE}
else
	echo "Cannot find MST configuration file at MST_CONF_FILE"
	env |grep CONF
	exit -1
fi

rm -f /tmp/mst-marginals-done

# Default to using shapes. I guess this should be configurable.
# guile -s ${COMMON_DIR}/marginals-mst.scm
guile -s ${COMMON_DIR}/marginals-mst-shape.scm

# Leave evidence behind that we finished.
# Docker uses this to self-destruct containers when done.
# Yes, it pollutes the file system and needs a better fix.
date > /tmp/mst-marginals-done
