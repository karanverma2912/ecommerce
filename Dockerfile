FROM ruby:3.4.7

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENV RAILS_ENV=production

EXPOSE 3000

RUN bundle exec rails db:migrate

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
