FROM avo_base

ARG NAME

WORKDIR /${NAME}/

# Create required directories
RUN mkdir /${NAME}/lib
RUN mkdir /${NAME}/lib/${NAME}

ENV BUNDLE_WITHOUT=development:test

# Cache the bundle install command with a fake version
COPY ./tmp/Gemfile_v1.lock /${NAME}/Gemfile.lock
COPY ./tmp/version_v1.rb /${NAME}/lib/${NAME}/version.rb

COPY ./Gemfile /${NAME}/Gemfile
COPY ./Rakefile /${NAME}/
COPY ./${NAME}.gemspec /${NAME}/
COPY ./lib/${NAME}.rb /${NAME}/lib/${NAME}.rb
COPY ./package.json /${NAME}/
COPY ./yarn.lock /${NAME}/

RUN bundle install --jobs 4 --retry 3
RUN yarn install

# Re-run bundle install with the appropriate version number
COPY ./lib/${NAME}/version.rb /${NAME}/lib/${NAME}/version.rb
# Remove gems used to test things locally
RUN bundle config set --local without 'development:test'

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
