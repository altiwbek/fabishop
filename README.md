# Fabishop

A Rails 8 e-commerce application: a customer-facing storefront plus an admin
CRM for managing the catalog, orders, and content. The UI is built on the
Molla template (assets live under `public/molla`).

## Tech stack

- **Ruby** 3.3.3, **Rails** 8.1
- **PostgreSQL** for the primary database
- **Solid Queue / Solid Cache / Solid Cable** for jobs, caching, and websockets
- **Hotwire** (Turbo + Stimulus) over **Importmap** — no Node/bundler build step
- **Tailwind CSS** (`tailwindcss-rails`) and **Propshaft** for assets
- **Active Storage** with `image_processing` (ImageMagick) for product images
- **RSpec** + **FactoryBot** + **shoulda-matchers** for tests
- **Kamal** for containerized deployment

## Key features

- **Storefront:** products, categories, brands, collections, blog posts,
  cart, checkout, wishlist, order tracking, search, and recently-viewed items
- **Admin CRM** (`/admin`): dashboard plus CRUD for products (with images),
  categories, brands, collections, posts, slides, reviews, orders, and users
- **Authentication:** session-based sign-in with password reset, backed by
  `has_secure_password` and role support (staff / owner)

## Getting started

### Prerequisites

- Ruby 3.3.3 (see `.ruby-version`)
- PostgreSQL
- ImageMagick (for Active Storage image variants)

### Setup

```bash
bin/setup
```

`bin/setup` installs gems, prepares the database, and starts the app. To do it
manually:

```bash
bundle install
bin/rails db:prepare   # create + load schema + seed
```

### Database configuration

`config/database.yml` reads connection settings from environment variables
(with local defaults):

| Variable | Default |
| --- | --- |
| `FABISHOP_DATABASE_HOST` | `localhost` |
| `FABISHOP_DATABASE_USERNAME` | `yourname` |
| `FABISHOP_DATABASE_PASSWORD` | `yourpassword` |

The development database is `fabishop_development`.

### Seed data

```bash
bin/rails db:seed
```

Seeds rebuild the catalog and attach sample product images from the Molla
template assets in `public/molla`.

## Running the app

```bash
bin/dev
```

This boots the Rails server and the Tailwind CSS watcher (see `Procfile.dev`).
The storefront is at `http://localhost:3000` and the admin at
`http://localhost:3000/admin`.

## Testing

The suite uses RSpec:

```bash
bundle exec rspec
```

Request specs render full layouts, so Tailwind CSS must be built first (this is
handled automatically while `bin/dev` is running):

```bash
bin/rails tailwindcss:build
```

CI runs the spec suite on every push to `main` and on pull requests — see
`.github/workflows/ci.yml`.

## Mailer previews

Email previews are available in development at
`http://localhost:3000/rails/mailers` (preview classes live in
`spec/mailers/previews`).

## Deployment

Deployment is configured with [Kamal](https://kamal-deploy.org):

```bash
bin/kamal deploy
```

See `config/deploy.yml` and `.kamal/` for configuration.
