SHELL=/bin/bash

render.eth:
	cd ./eth/template && for i in $$(ls); do env $$(cat .env) envsubst < $$i > "../$$(basename $$i .tmpl)"; done

deploy.docker:
	make render.eth
	docker compose up -d

stop.docker:
	docker compose stop