monkey-vfs-times.bt: monkey-vfs-times.pre.bt
	echo '#/usr/bin/env bpftrace' > $@
	cpp $^ | grep -Pv '^\# \d' >> $@
clean:
	rm monkey-vfs-times.bt
.PHONY: clean
