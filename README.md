# Ecommerce API

A **Ruby on Rails REST API** for an ecommerce application. This repository demonstrates backend workflows for a product catalog, customer accounts, shopping cart, orders, product feedback, and integrations.

> **Portfolio / development project:** The repository is a code sample. Deployments, payments, and production readiness have not been verified as part of this documentation update.

## Technology

- **Backend:** Ruby on Rails 8.1, Ruby 3.4, PostgreSQL
- **Authentication & authorization:** JWT, bcrypt, Pundit
- **Async/background processing:** Sidekiq
- **Other integrations:** Active Storage, Stripe gem, AWS SDK for S3
- **Testing & development tools:** RSpec, FactoryBot, Git

## API functionality

The routes and code include:

- Account registration, login, token refresh, logout, email verification, and profile management
- Products: listing, search, detail, creation, updates, and deletion
- Categories and product image attachments
- Shopping cart: view, add, edit quantity, remove, and clear
- Orders: create, list, detail, and status updates
- Product reviews and review comments
- Customer wishlist
- Stripe webhook endpoint

See [`config/routes.rb`](config/routes.rb) for the endpoint map and [`app/controllers`](app/controllers) for the implementation.

## Local setup

**Prerequisites:** Ruby 3.4.x, PostgreSQL, Bundler. Some workflows also require Redis and external service credentials.

```bash
git clone https://github.com/karanverma2912/ecommerce.git
cd ecommerce
bundle install
bin/rails db:prepare
bin/rails server
```

The Rails server typically runs at `http://localhost:3000`.

Example public read request:

```bash
curl http://localhost:3000/api/v1/products
```

Environment variables or credentials may be needed for authentication, outbound email, Stripe, storage, and background jobs. Configure them for your local environment; do not commit secrets.

## Quality checks

```bash
bundle exec rspec
```

Tests and local services require a configured database. This README documents the repository structure and available interfaces; it does not claim that every integration has been exercised or deployed.

## Related project

The separate [Ecommerce Frontend](https://github.com/karanverma2912/ecommerce-frontend) repository contains a Next.js shopping interface.

## Maintainer

[Karan Verma](https://github.com/karanverma2912) · [LinkedIn](https://www.linkedin.com/in/karan-verma-4068541a0/)
