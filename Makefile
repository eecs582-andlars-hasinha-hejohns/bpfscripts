monkey-vfs-times.bt: monkey-vfs-times.pre.bt
	echo '#!/usr/bin/env bpftrace' > $@
	cpp $^ | grep -Pv '^\# \d' >> $@
clean:
	rm monkey-vfs-times.bt
TCCFLAGS = -O0 -ggdb
no_work-16B: no_work.c
	tcc -o $@ $(TCCFLAGS) -DBLOCK_SIZE='1<<4' $^ -luring
no_work-4KB: no_work.c
	tcc -o $@ $(TCCFLAGS) -DBLOCK_SIZE='1<<12' $^ -luring
no_work-4MB: no_work.c
	tcc -o $@ $(TCCFLAGS) -DBLOCK_SIZE='1<<22' $^ -luring
do_work.c: do_work.c.gz
	gunzip --keep $^
do_work-16B: do_work.c
	# gcc and clang both hang on a source file this large
	tcc -o $@ $(TCCFLAGS) -DBLOCK_SIZE='1<<4' $^ -luring
.PHONY: clean
