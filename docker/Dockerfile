FROM avo_gems

ARG NAME
ARG GEMSPEC_NAME
ARG BUNDLER_TOKEN

WORKDIR /${NAME}/

# Create required directories
RUN mkdir /${NAME}/lib
RUN mkdir /${NAME}/lib/avo
RUN mkdir /${NAME}/lib/avo/${NAME}

ENV BUNDLE_WITHOUT=development:test

# Cache the bundle install command with a fake version
COPY ./tmp/Gemfile_v1.lock /${NAME}/Gemfile.lock
COPY ./tmp/version_v1.rb /${NAME}/lib/avo/${NAME}/version.rb

COPY ./Gemfile /${NAME}/Gemfile
COPY ./Rakefile /${NAME}/
COPY ./${GEMSPEC_NAME}.gemspec /${NAME}/
COPY ./lib/avo/${NAME}.rb /${NAME}/lib/avo/${NAME}.rb
COPY ./package.json /${NAME}/
COPY ./yarn.lock /${NAME}/

RUN ls -la /
RUN ls -la /${NAME}
RUN ls -la /${NAME}/lib
RUN ls -la /${NAME}/lib/avo
RUN ls -la /${NAME}/lib/avo/${NAME}

RUN bundle config set --global https://packager.dev/avo-hq-beta/ ${BUNDLER_TOKEN}
RUN bundle config set --local without 'development test'
RUN bundle install --jobs 4 --retry 3
RUN yarn install

# Re-run bundle install with the appropriate version number
COPY ./lib/avo/${NAME}/version.rb /${NAME}/lib/avo/${NAME}/version.rb
# Remove gems used to test things locally

# Copy the files
COPY . /${NAME}

# Run the install again
RUN bundle install --jobs 4 --retry 3
RUN yarn install
RUN yarn check --integrity

# Build assets
RUN yarn build

# Build gem
RUN bundle exec rails build
