# Makefile

# Copyright (C) 2009, 2011, 2012, 2013 Richard Smith <richard@ex-parrot.com>
# All rights reserved.

STAGES = 5

all init check clean world:
	set -e; for n in `seq 0 $(STAGES)`; do $(MAKE) -r -C stage-$$n $@; done
