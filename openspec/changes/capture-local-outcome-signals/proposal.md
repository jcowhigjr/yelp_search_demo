## Why

The app already records searches, favorites, reviews, and authenticated users, but it does not normalize those behaviors into a durable product signal. A small local outcome-event layer lets the app identify useful searches, engagement gaps, review quality trends, and search failures without adding an external analytics system.

## What Changes

- Add a local `outcome_events` store for compact app-owned product events.
- Capture intentional user-action events for search success, search error, favorite creation, review creation, and return visits.
- Add a local reporting task that summarizes search-to-favorite rate, review rating trend, and search error rate.
- Keep the first version synchronous, Rails-native, and local to the app database.
- Do not add an external analytics vendor, dashboard, background job system, or automatic GitHub issue creation.

## Capabilities

### New Capabilities

- `local-outcome-signals`: Captures durable local product outcome events and reports basic signal quality from those events.

### Modified Capabilities

None.

## Impact

- Adds one database table and one Active Record model.
- Touches search, favorite, and review user-action boundaries.
- Adds a rake task and focused tests.
- Uses Rails-native event/service patterns; no new gem dependency is required.
