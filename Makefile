RUN = docker-compose run --rm

init:
	touch gemfiles/docker-compose/ruby-2-6-rails-6-0-Gemfile.lock || true
	touch gemfiles/docker-compose/ruby-2-6-rails-6-1-Gemfile.lock || true
	touch gemfiles/docker-compose/ruby-2-7-rails-6-0-Gemfile.lock || true
	touch gemfiles/docker-compose/ruby-2-7-rails-6-1-Gemfile.lock || true
	touch gemfiles/docker-compose/ruby-2-7-rails-master-Gemfile.lock || true
	touch gemfiles/docker-compose/ruby-3-0-rails-6-0-Gemfile.lock || true
	touch gemfiles/docker-compose/ruby-3-0-rails-6-1-Gemfile.lock || true
	touch gemfiles/docker-compose/ruby-3-0-rails-master-Gemfile.lock || true
gemfile\:refresh:
	rm gemfiles/docker-compose/ruby-2-6-rails-6-0-Gemfile.lock || true
	rm gemfiles/docker-compose/ruby-2-6-rails-6-1-Gemfile.lock || true
	rm gemfiles/docker-compose/ruby-2-7-rails-6-0-Gemfile.lock || true
	rm gemfiles/docker-compose/ruby-2-7-rails-6-1-Gemfile.lock || true
	rm gemfiles/docker-compose/ruby-2-7-rails-master-Gemfile.lock || true
	rm gemfiles/docker-compose/ruby-3-0-rails-6-0-Gemfile.lock || true
	rm gemfiles/docker-compose/ruby-3-0-rails-6-1-Gemfile.lock || true
	rm gemfiles/docker-compose/ruby-3-0-rails-master-Gemfile.lock || true
	touch gemfiles/docker-compose/ruby-2-6-rails-6-0-Gemfile.lock
	touch gemfiles/docker-compose/ruby-2-6-rails-6-1-Gemfile.lock
	touch gemfiles/docker-compose/ruby-2-7-rails-6-0-Gemfile.lock
	touch gemfiles/docker-compose/ruby-2-7-rails-6-1-Gemfile.lock
	touch gemfiles/docker-compose/ruby-2-7-rails-master-Gemfile.lock
	touch gemfiles/docker-compose/ruby-3-0-rails-6-0-Gemfile.lock
	touch gemfiles/docker-compose/ruby-3-0-rails-6-1-Gemfile.lock
	touch gemfiles/docker-compose/ruby-3-0-rails-master-Gemfile.lock

dev:
	@${RUN} $(filter-out $@,$(MAKECMDGOALS)) bash
bundle:
	@${RUN} $(filter-out $@,$(MAKECMDGOALS)) bundle install
rake:
	@${RUN} $(filter-out $@,$(MAKECMDGOALS)) bundle exec rake

bundle\:all:
	@${RUN} ruby_2_6_rails_6_0 bundle install
	@${RUN} ruby_2_6_rails_6_1 bundle install
	@${RUN} ruby_2_7_rails_6_0 bundle install
	@${RUN} ruby_2_7_rails_6_1 bundle install
	@${RUN} ruby_2_7_rails_master bundle install
	@${RUN} ruby_3_0_rails_6_0 bundle install
	@${RUN} ruby_3_0_rails_6_1 bundle install
	@${RUN} ruby_3_0_rails_master bundle install
db\:setup:
	docker-compose up -d postgres
	docker-compose up -d redis
	@${RUN} ruby_3_0_rails_6_1 bash -c "cd test/dummy && bundle exec rails db:setup db:migrate"
test\:all:
	@${RUN} ruby_2_6_rails_6_0 bundle exec rake
	@${RUN} ruby_2_6_rails_6_1 bundle exec rake
	@${RUN} ruby_2_7_rails_6_0 bundle exec rake
	@${RUN} ruby_2_7_rails_6_1 bundle exec rake
	@${RUN} ruby_2_7_rails_master bundle exec rake
	@${RUN} ruby_3_0_rails_6_0 bundle exec rake
	@${RUN} ruby_3_0_rails_6_1 bundle exec rake
	@${RUN} ruby_3_0_rails_master bundle exec rake
down:
	docker-compose down
ci:
	make init
	make bundle:all
	make test:setup
	make db:setup
	make test:all
	make down
%:
	@: