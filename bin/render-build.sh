#!/usr/bin/env bash

# Exit on error
set -o errexit
echo "Deploy Started"
echo "Installing gems..."
bundle install --jobs=1 --retry=3

echo "Precompiling assets..."
bundle exec rails assets:precompile

echo "Cleaning assets..."
bundle exec rails assets:clean

echo "Migrating database..."
bundle exec rails db:migrate

echo "Deploy done"