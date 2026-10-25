lint:
	yamllint .
	ansible-lint

syntax:
	for playbook in playbooks/*.yml; do ansible-playbook --syntax-check "$$playbook" || exit 1; done

check: lint syntax

.PHONY: lint syntax check
