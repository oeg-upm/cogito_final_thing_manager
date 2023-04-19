docker buildx build --output type=docker --platform=linux/amd64 -t thing_manager:0.1.0-amd .
docker tag thing_manager:0.1.0-amd salva5297/thing_manager:0.1.0
docker push salva5297/thing_manager:0.1.0

docker buildx build --output type=docker --platform=linux/amd64 -t thing_manager:latest-amd .
docker tag thing_manager:latest-amd salva5297/thing_manager:latest
docker push salva5297/thing_manager:latest