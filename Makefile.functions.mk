define generate_file
  echo 1 $(1)
	echo 2 $(2)
endef

xyz:
	$(call generate_file,John Doe,101)
	$(call generate_file,Peter Pan,102)

define echo
	@printf "\033[36m$(1)\033[0m %s\n"
endef

define oksign
	@printf "\033[36m%-24s\033[0m %s\n" $(1) [OK]
endef

.PHONY: zzz
zzz:
	$(call echo,hello brave world)
	@echo hello brave world