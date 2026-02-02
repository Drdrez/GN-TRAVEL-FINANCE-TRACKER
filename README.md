# GN Travel Marketing LLC - Finance Tracker

A comprehensive finance tracking application for GN Travel Marketing LLC with a Vercel backend and **Supabase** (free) database.

## Features

- **Dashboard**: Overview of income, expenses, net income, and profit margins
- **Income Tracker**: Track client payments with service types, pricing models, and payment status
- **Expenses Tracker**: Monitor business expenses by category, vendor, and payment method
- **Cash Overview**: Track cash account balances and monthly cash movement
- **Export**: Export data to CSV format
- **Invoice Generation**: Generate printable invoices from income entries
- **Currency Toggle**: Switch between PHP and USD display
- **Auto-Save**: All changes are automatically saved to the cloud

## Tech Stack

- Frontend: HTML, Tailwind CSS, Chart.js
- Backend: Vercel Serverless Functions (Node.js)
- Database: **Supabase** (PostgreSQL, free tier)

## Setup: Supabase (Free)

### Step 1: Create a Supabase project

1. Go to [supabase.com](https://supabase.com) and sign in or create an account.
2. Click **New project**.
3. Choose an organization, name the project (e.g. `gn-finance-tracker`), set a database password, and pick a region.
4. Click **Create new project** and wait for it to be ready.

### Step 2: Run the database schema

1. In your Supabase project, open **SQL Editor**.
2. Open the file `supabase/schema.sql` in this repo and copy its full contents.
3. Paste into the SQL Editor and click **Run**.
4. Confirm that the tables and policies were created (no errors).

### Step 3: Get your API keys

1. In Supabase, go to **Project Settings** (gear icon) → **API**.
2. Copy:
   - **Project URL** (e.g. `https://xxxxx.supabase.co`)
   - **anon public** key (for client or server; RLS applies), **or**
   - **service_role** key (for server-only; bypasses RLS — use only in backend env, never in frontend)

For the Vercel API routes, you can use either:
- **anon** key + the RLS policies in `schema.sql`, or  
- **service_role** key (simplest; no extra RLS setup).

## Deployment to Vercel

### Step 1: Deploy the app

**Option A: Vercel Dashboard**

1. Push this project to GitHub/GitLab/Bitbucket.
2. Go to [Vercel Dashboard](https://vercel.com/dashboard) → **Add New** → **Project**.
3. Import the repo and deploy (default settings are fine).

**Option B: Vercel CLI**

```bash
npm i -g vercel
vercel login
vercel --prod
```

### Step 2: Add Supabase environment variables

1. In Vercel, open your project → **Settings** → **Environment Variables**.
2. Add:

| Name | Value | Environment |
|------|--------|-------------|
| `SUPABASE_URL` | Your Supabase **Project URL** | Production, Preview, Development |
| `SUPABASE_SERVICE_ROLE_KEY` | Your Supabase **service_role** key | Production, Preview, Development |

If you prefer to use the anon key instead:

| Name | Value |
|------|--------|
| `SUPABASE_URL` | Your Project URL |
| `SUPABASE_ANON_KEY` | Your **anon public** key |

The API uses `SUPABASE_SERVICE_ROLE_KEY` if set, otherwise `SUPABASE_ANON_KEY`.

### Step 3: Redeploy

Trigger a new deployment (e.g. **Deployments** → **Redeploy**) so the new env vars are applied.

## Local Development

### Prerequisites

- Node.js 18+
- Vercel CLI (optional)

### Setup

1. Install dependencies:

```bash
npm install
```

2. Create a `.env.local` in the project root (same folder as `package.json`):

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

Or use `SUPABASE_ANON_KEY` if you prefer.

3. Run the dev server:

```bash
npm run dev
```

Or:

```bash
vercel dev
```

4. Open `http://localhost:3000` (or the port Vercel shows).

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/income` | GET | Get all income records |
| `/api/income` | POST | Add new income record |
| `/api/income` | PUT | Update income record(s) |
| `/api/income?id=xxx` | DELETE | Delete income record |
| `/api/expenses` | GET | Get all expense records |
| `/api/expenses` | POST | Add new expense record |
| `/api/expenses` | PUT | Update expense record(s) |
| `/api/expenses?id=xxx` | DELETE | Delete expense record |
| `/api/cash?type=accounts` | GET | Get cash account balances |
| `/api/cash?type=movement` | GET | Get cash movement data |
| `/api/cash?type=accounts` | POST/PUT | Save cash accounts |
| `/api/cash?type=movement` | POST/PUT | Save cash movement |
| `/api/business` | GET | Get business columns and data |
| `/api/business` | POST | Save business data |

## Data structure (API)

### Income record

- `id`, `date`, `clientName`, `serviceType`, `pricingModel`, `gross`, `net`, `paymentMode`, `status`, `refId`, `notes`

### Expense record

- `id`, `date`, `vendor`, `category`, `type`, `service`, `amount`, `payment`, `status`, `recurring`, `notes`

## Troubleshooting

### "Database not configured" or 503

- Ensure `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` (or `SUPABASE_ANON_KEY`) are set in Vercel and in `.env.local` for local dev.
- Redeploy after changing env vars.

### Data not saving / RLS errors

- If using **anon** key: ensure you ran `supabase/schema.sql` so RLS policies exist.
- If using **service_role** key: RLS is bypassed; check Vercel function logs for other errors.

### CORS / local dev

- Use `vercel dev` or your normal dev server and open the app at the URL it prints (e.g. `http://localhost:3000`).

## License

Private - GN Travel Marketing LLC
