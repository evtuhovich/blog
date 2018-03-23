FROM ruby

RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  nodejs

RUN mkdir -p /app 
WORKDIR /app

COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 4567

CMD ["bundle", "exec", "middleman"]
