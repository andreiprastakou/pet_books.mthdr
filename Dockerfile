# syntax=docker/dockerfile:1
FROM ruby:3.4.8
RUN apt-get update -qq && apt-get install -y curl gnupg
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash
RUN curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/yarn-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq
RUN apt-get install -y nodejs cmake sqlite3 yarn
WORKDIR /app
COPY Gemfile Gemfile.lock ./
COPY engines ./engines
RUN bundle install && bundle clean --force

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY bin/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

COPY . .
RUN SECRET_KEY_BASE=placeholder bundle exec rails assets:precompile 2>/dev/null || true
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
EXPOSE 3000
EXPOSE 8983

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
