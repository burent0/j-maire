# J'Maire Farm Reservation System

Online booking for J'Maire Farm: guests pick a cottage or room, see the full price, book, and upload their GCash/bank receipt. Staff verify receipts, handle walk-ins and check guests in and out. The owner manages rates and sees income and occupancy reports.

Built with plain **PHP 8.2 + MySQL (XAMPP)**, Bootstrap 5, Flatpickr, FullCalendar and Chart.js (the last four load from a CDN, so the PC needs internet).

## Setup (XAMPP)

1. Put this folder at `C:\xampp\htdocs\j-maire` and start **Apache** and **MySQL** in XAMPP.
2. Open phpMyAdmin and **Import** these two files, in this order:
   1. `database/01_jmaire_farm_db.sql` (the menu: food, rooms & cottages, activities)
   2. `database/02_reservation_system.sql` (users, bookings, payments, settings + demo data)

   If `jmaire_farm` already exists from before, drop it first (it re-creates the menu tables).
3. Open http://localhost/j-maire/

The old `adminsys` database is no longer used. Its users table now lives in `jmaire_farm.users` with roles.

### Demo accounts

| Role | Login | Password |
|---|---|---|
| Admin / owner | `admin` | `admin123` |
| Staff | `staff` | `staff123` |
| Guest | `guest@example.com` | `guest123` |
| Guest | `maria@example.com` | `guest123` |

Change these before showing the system to anyone outside the team. Demo booking dates are relative to the day you import, so the dashboard always has something on it.

## What's where

| Path | What it is |
|---|---|
| `index.php`, `accommodations.php`, `accommodation.php`, `menu.php` | Public pages |
| `book.php` → `booking.php` | Booking form → summary, payment instructions, receipt upload, cancel |
| `my_bookings.php`, `find_booking.php` | Guest's bookings; lookup by code + phone (for walk-ins without an account) |
| `login.php`, `register.php`, `forgot_password.php`, `reset_password.php`, `profile.php` | Accounts |
| `receipt.php` | Printable receipt (Print → Save as PDF) |
| `admin/` | Staff/owner side: dashboard, bookings, walk-in, calendar, guests, reports, accommodations, add-ons, farm menu, settings, users, audit log, email log |
| `includes/booking_service.php` | **All booking rules**: overlap check, price calculation, status flow, expiry, payments |
| `includes/booking_form.php` + `assets/js/booking.js` | Shared booking form (guest + walk-in) with live price preview |
| `api/quote.php`, `api/availability.php` | JSON used by the form and calendars |
| `cron/expire_bookings.php` | Optional scheduled expiry (see below) |

The old root files `dashboard.php`, `menu_list.php`, `menu_edit.php`, `menu_delete.php` now just redirect to `admin/`. You can delete them, along with the `j'maire_login/` prototype, `style.css`, the root `jmaire_farm_db.sql` (moved to `database/`) and `adminsys.sql`.

## How the important parts work (plan section 8)

**No double booking.** Dates are stored as a half-open range `[check_in, check_out)`. Overnight rooms: `check_out` is the morning the guest leaves, so one guest can check out the same day the next checks in. Day cottages: `check_out = check_in + 1 day`. Two bookings clash when `a.check_in < b.check_out AND a.check_out > b.check_in`, counting only `pending`, `confirmed` and `checked_in`. `create_booking()` runs the check and the insert in one transaction after `SELECT ... FOR UPDATE` on the accommodation row, so two people clicking Book at the same moment are handled one after the other.

**Price.** `calculate_quote()` computes rate × days/nights, entrance fees (adults/kids) for day cottages, optional swimming, add-ons and food pre-orders. Overnight rooms include entrance, swimming and breakfast. The form's live price calls the same function through `api/quote.php`, so the preview always equals the saved total. Every line is copied into `booking_items`, so later rate changes never alter old bookings.

**Status flow.** pending → confirmed (when verified payments ≥ downpayment) → checked_in → completed (only when fully paid). Pending can also become cancelled, rejected or expired; confirmed can be cancelled. Cancel and reject require a reason.

**Expiry.** Unpaid pending bookings expire after `payment_deadline_hours` (Settings, default 24h) and free their dates. This runs on every page load. Bookings whose receipt is waiting for review don't expire. Rejecting a receipt gives the guest a fresh window to re-upload. For a scheduled job, use Windows Task Scheduler every 15 minutes with program `C:\xampp\php\php.exe` and argument `C:\xampp\htdocs\j-maire\cron\expire_bookings.php`.

**Receipts.** Only JPG/PNG/PDF up to 5 MB are accepted. The type is checked from the file content, not the extension. Files get random names in `uploads/receipts/`, which `.htaccess` blocks. They are served only through `receipt_file.php` to staff or the booking's owner.

**Access.** Guests see only their own bookings. `/admin` needs staff. Rates, settings, users, reports and the audit log need admin. Every form has a CSRF token, all SQL uses prepared statements, and output is escaped with `e()`.

**Email.** XAMPP can't send email out of the box, so every email (booking received, confirmed, receipt rejected, cancelled, expired, password reset) is saved to **Admin → Email log**, which is handy for the demo. Set `MAIL_ENABLED` to `true` in `config.php` once SMTP is configured.

## Decisions to confirm with the owner (plan section 2)

- **Unit counts.** The seed has 2 Open Cottages, 2 Kalesa tables and 2 Deluxe Rooms as examples. Add or remove units in Admin → Accommodations.
- **Add-on prices** are placeholders, because the menu lists activities without prices.
- Downpayment %, payment deadline, GCash/bank details, entrance/swimming fees, hours and cancellation policy are all in **Admin → Settings**.

## Test checklist status (plan section 13)

All of these were run end to end against the demo data: overlap blocked, past date / end-before-start / over-capacity rejected, same-day turnover allowed, server total correct, txt / fake-PNG / oversized receipts rejected, approve → confirmed + email, reject requires a reason and the guest sees it, unpaid booking auto-expires and frees dates, guest can't open another guest's booking or `/admin`, staff can't open users or reports, walk-in + check-out with balance, reschedule recalculates price, CSV export. Still to do on your XAMPP: the **two browsers at the same time** test (needs real MySQL), plus checking that `http://localhost/j-maire/uploads/receipts/demo_receipt.png` returns *403 Forbidden*.
