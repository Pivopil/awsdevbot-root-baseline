docker_generate_docs:
	docker run --rm -it \
		-v "${CURDIR}":/workspace \
		gcr.io/cloud-foundation-cicd/cft/developer-tools:0.13 \
		/bin/bash -c 'source /usr/local/bin/task_helper_functions.sh && generate_docs'


