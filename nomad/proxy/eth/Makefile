SHELL=/bin/bash

run.all:
	for i in $$(ls .packs); do nomad-pack run --address="http://192.168.56.66:4646" --var-file=.packs/$$i . ; done
stop.all:
	for i in $$(ls .packs); do nomad-pack stop --address="http://192.168.56.66:4646" --var-file=.packs/$$i . ; done