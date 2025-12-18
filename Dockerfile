FROM ruby:3.4.7
RUN apt-get update
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
RUN bundle exec rake assets:precompile
ENV PORT 5000
EXPOSE 5000

CMD bundle exec rake db:migrate && bundle exec rails server -p $PORT
