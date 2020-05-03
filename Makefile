build:
	docker build -t tinyurl:latest .

build_base:
	docker build -t tinyurl_base:latest -f deploy/base/Dockerfile .

tiny:
	kubectl apply -f deploy/k8-tinyurl.yml
