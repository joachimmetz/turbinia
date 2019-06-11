#!/bin/bash
#
# Script to set up Travis-CI test VM.
#
# This file is generated by l2tdevtools update-dependencies.py any dependency
# related changes should be made in dependencies.ini.

DPKG_PYTHON2_DEPENDENCIES="python-cachetools python-click python-colorlog python-concurrent.futures python-enum34 python-filelock python-google-api-core python-google-api-python-client python-google-auth python-google-auth-httplib2 python-google-cloud-core python-google-cloud-datastore python-google-cloud-pubsub python-google-cloud-storage python-google-resumable-media python-googleapis-common-protos python-grpc-google-iam-v1 python-grpcio python-httplib2 python-oauth2client python-protobuf python-psq python-pyasn1 python-pyasn1-modules python-requests python-rsa python-six python-tz python-uritemplate python-urllib3 python-werkzeug";

DPKG_PYTHON2_TEST_DEPENDENCIES="python-coverage python-funcsigs python-mock python-nose python-pbr python-setuptools python-yapf";

DPKG_PYTHON3_DEPENDENCIES="python3-cachetools python3-click python3-colorlog python3-filelock python3-google-api-core python3-google-api-python3-client python3-google-auth python3-google-auth-httplib2 python3-google-cloud-core python3-google-cloud-datastore python3-google-cloud-pubsub python3-google-cloud-storage python3-google-resumable-media python3-googleapis-common-protos python3-grpc-google-iam-v1 python3-grpcio python3-httplib2 python3-oauth2client python3-protobuf python3-psq python3-pyasn1 python3-pyasn1-modules python3-requests python3-rsa python3-six python3-tz python3-uritemplate python3-urllib3 python3-werkzeug";

DPKG_PYTHON3_TEST_DEPENDENCIES="python3-distutils python3-mock python3-nose python3-pbr python3-setuptools python-yapf";

# Exit on error.
set -e;

if test -n "${UBUNTU_VERSION}";
then
	CONTAINER_NAME="ubuntu${UBUNTU_VERSION}";

	docker pull ubuntu:${UBUNTU_VERSION};

	docker run --name=${CONTAINER_NAME} --detach -i ubuntu:${UBUNTU_VERSION};

	# Install add-apt-repository and locale-gen.
	docker exec ${CONTAINER_NAME} apt-get update -q;
	docker exec -e "DEBIAN_FRONTEND=noninteractive" ${CONTAINER_NAME} sh -c "apt-get install -y locales software-properties-common";

	docker exec ${CONTAINER_NAME} add-apt-repository universe -y;

	# Add additional apt repositories.
	if test "${TARGET}" = "pylint";
	then
		docker exec ${CONTAINER_NAME} add-apt-repository ppa:gift/pylint3 -y;
	fi
	docker exec ${CONTAINER_NAME} add-apt-repository ppa:gift/dev -y;

	docker exec ${CONTAINER_NAME} apt-key adv --fetch-keys https://dl.yarnpkg.com/debian/pubkey.gpg;
	docker exec ${CONTAINER_NAME} add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main";

	docker exec ${CONTAINER_NAME} apt-get update -q;

	# Set locale to US English and UTF-8.
	docker exec ${CONTAINER_NAME} locale-gen en_US.UTF-8;

	# Install packages.
	DPKG_PACKAGES="git yarn";

	if test "${TARGET}" = "pylint";
	then
		DPKG_PACKAGES="${DPKG_PACKAGES} python3-distutils pylint";
	fi
	if test ${TRAVIS_PYTHON_VERSION} = "2.7";
	then
		DPKG_PACKAGES="${DPKG_PACKAGES} python ${DPKG_PYTHON2_DEPENDENCIES} ${DPKG_PYTHON2_TEST_DEPENDENCIES}";
	else
		DPKG_PACKAGES="${DPKG_PACKAGES} python3 ${DPKG_PYTHON3_DEPENDENCIES} ${DPKG_PYTHON3_TEST_DEPENDENCIES}";
	fi
	docker exec -e "DEBIAN_FRONTEND=noninteractive" ${CONTAINER_NAME} sh -c "apt-get install -y ${DPKG_PACKAGES}";

	docker cp ../turbinia ${CONTAINER_NAME}:/

	docker exec ${CONTAINER_NAME} sh -c "cd turbinia && yarn install";

elif test ${TRAVIS_OS_NAME} = "linux";
then
	pip install -r requirements.txt;
	pip install -r test_requirements.txt;

	yarn install;
fi
