IMAGE_NAME := waja/mojolicious

build:
	docker build --rm -t $(IMAGE_NAME) .
	
run:
	@echo docker run --rm -it $(IMAGE_NAME) 
	
shell:
	docker run --rm -it --entrypoint sh $(IMAGE_NAME) -l

test: build
	@if ! [ "$$(docker run --rm -it $(IMAGE_NAME) morbo --help 2>&1 | head -1 | cut -d' ' -f2)" = "morbo" ]; then exit 1; fi
