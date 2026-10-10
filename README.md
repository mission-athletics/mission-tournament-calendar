# Mission Tournament Calendar

The Mission Athletics wrestling tournament calendar, hosted on Render with data in Supabase.

- Families open the page and see the schedule. No login needed.
- Coaches click **Coach sign in**, enter their email, and open the link they get. Only emails on the coach list can make changes.
- Changes save automatically and show up on everyone's open page within a few seconds.

## Files

| File | What it is |
| --- | --- |
| `index.html` | The calendar page |
| `config.js` | Your two Supabase values go here |
| `setup.sql` | One-time database setup, including your current tournaments and wrestlers |
| `webflow-embed.html` | Code to paste into a Webflow Embed element on the schedule page |

## Setup (about 15 minutes)

### 1. Supabase: create the database
1. Go to supabase.com, sign up (free) and click **New project**. Name it `mission-calendar`, set a database password (save it somewhere), pick a US region, and create it. Wait a minute or two for it to finish.
2. In the left menu open **SQL Editor**, click **New query**, paste in the whole `setup.sql` file and click **Run**. You should see "Success. No rows returned."
3. In **Table Editor** you should now see `tournaments` (2 rows), `wrestlers` (9 rows) and `coaches` (1 row: george@missionathletics.com).

### 2. Supabase: add your coaches
In **Table Editor → coaches**, click **Insert → Insert row**, type the coach's email and save. Repeat for each coach. Removing a row removes that coach's ability to edit.

### 3. Supabase: copy your two keys into config.js
1. Open **Project Settings → API** (newer dashboards split this into **Data API** for the URL and **API Keys** for the key).
2. Copy the **Project URL** and the **anon public** key.
3. Open `config.js`, paste them between the quote marks in place of `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY`, and save.

### 4. GitHub: upload the files
1. On github.com click **New repository**, name it `mission-tournament-calendar`, and create it.
2. Click **uploading an existing file**, drag in all the files, then **Commit changes**.

### 5. Render: put it online
1. In Render click **New → Static Site** and connect the `mission-tournament-calendar` repository.
2. Leave **Build Command** empty and set **Publish Directory** to `.` (a single period).
3. Click **Create Static Site**. In a minute you'll get an address like `mission-tournament-calendar.onrender.com`.

### 6. Supabase: allow the sign-in link to come back to your page
In Supabase open **Authentication → URL Configuration**:
- Set **Site URL** to `https://wrestlingtournaments.missionathletics.com`.
- Under **Redirect URLs** add `https://wrestlingtournaments.missionathletics.com/**`, and also your Render address with `/**` on the end so you can test before the domain is ready.

### 7. Your own address: wrestlingtournaments.missionathletics.com
In Render open the site's **Settings → Custom Domains**, add `wrestlingtournaments.missionathletics.com`, and add the DNS record Render shows you (a CNAME with host/name `wrestlingtournaments`) wherever missionathletics.com's DNS is managed. It usually works within an hour.

### 8. Webflow: the hidden schedule page
1. In Webflow, **Pages → Create new page**. Name it "Wrestling Tournament Schedule" and set the slug to `wrestling-tournament-schedule`.
2. Don't add it to the navigation. In the page's **Settings**, turn on **Exclude this page from site search**, and under **Custom Code → Inside <head> tag** add:
   `<meta name="robots" content="noindex">`
   so search engines skip it.
3. Drag an **Embed** element onto the page and paste in `webflow-embed.html`. It already points to `https://wrestlingtournaments.missionathletics.com`.
4. Publish the Webflow site. The schedule is at missionathletics.com/wrestling-tournament-schedule and grows to fit as cards open.

Hidden means unlisted, not private: anyone who has the address can open it.

## Day to day
- **Coaches:** edit at the calendar's direct address (the Render address or wrestlingtournaments.missionathletics.com), not the Webflow page. On the Webflow page, **Coach sign in** opens the direct address in a new tab for you. Click **Coach sign in**, enter your email, and open the emailed link on the same device. Bookmark the direct address; you'll stay signed in there.
- **Making changes:** just edit. The box in the bottom-right corner says "Saving…" then "All changes saved."
- **Updating the page design later:** replace `index.html` in GitHub. Render republishes on its own. Your data is untouched because it lives in Supabase.

## Good to know
- The free Supabase email service only sends a few sign-in emails per hour. That's plenty for a handful of coaches. If you hit the limit, wait an hour, or connect your own email sender under **Authentication → SMTP Settings**.
- A free Supabase project can pause after a long stretch with no visits. If the page says it couldn't load the schedule, open the project in Supabase and click **Resume**.
- Anyone with the calendar address can read the schedule and roster, the same as the current public link. Only approved coaches can change anything.
