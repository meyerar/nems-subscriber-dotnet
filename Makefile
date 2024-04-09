GHUNAME	:= gh-username
GHPAT	:= abcdef
build:
	- docker buildx build --platform linux/amd64 -f Dockerfile --progress=plain --output type=docker --compress -t nems-subscriber-base:latest .

inspect:
	- docker rm inspect-container
	- docker create --name inspect-container nems-subscriber-base:latest
	- docker export inspect-container > inspect-container.tar
clean:
	- docker system prune -a -f
	- docker volume prune -f
push: login
	- docker build . --tag ghcr.io/healthsharedevops/nems-subscriber-base:latest
	docker push ghcr.io/healthsharedevops/nems-subscriber-base:latest
run:
	- docker stop nems-subscriber
	- docker rm nems-subscriber
	- docker run --rm -v $PWD:/source -v my_volume:/App/config -w /source nems-subscriber-base:latest cp properties.json /dest
login:
	- echo $(GHPAT) | docker login ghcr.io -u $(GHUNAME) --password-stdin