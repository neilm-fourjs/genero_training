
components=query arrays orders

all:: subdirs

subdirs:: $(components)
	@for component in $^ ; do  \
		$(MAKE) -C $$component all; \
	done

include ./etc/Make_fjs.inc
