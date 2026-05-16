## ADDED Requirements

### Requirement: Durable outcome event capture
The system SHALL persist compact outcome events for intentional user actions using a fixed event type allowlist and safe JSON-compatible payloads.

#### Scenario: Search success is captured
- **WHEN** a search completes successfully
- **THEN** the system SHALL persist a `search_success` outcome event with the search id, query, and result count when available

#### Scenario: Search error is captured
- **WHEN** a search fails before results are shown
- **THEN** the system SHALL persist a `search_error` outcome event with the query and a safe error category

#### Scenario: Favorite creation is captured
- **WHEN** an authenticated user adds a coffee shop to favorites
- **THEN** the system SHALL persist a `favorite_added` outcome event with the user id and coffee shop id

#### Scenario: Review creation is captured
- **WHEN** a user successfully leaves a review
- **THEN** the system SHALL persist a `review_left` outcome event with the user id, coffee shop id, review id, and rating

#### Scenario: Return visit is captured
- **WHEN** a signed-in user with prior searches starts a new search session
- **THEN** the system SHALL persist a `return_visit` outcome event without changing the page response

### Requirement: Local signal summary
The system SHALL provide a local task that summarizes outcome event signal quality in plain text.

#### Scenario: Summary includes core rates
- **WHEN** the local outcome signal summary task runs
- **THEN** it SHALL print search-to-favorite rate, average review rating, review count, and search error rate

#### Scenario: Summary handles empty data
- **WHEN** no outcome events exist
- **THEN** the summary task SHALL complete successfully and print zero counts or unavailable rates instead of failing

### Requirement: No external analytics dependency
The system SHALL keep the first version local and Rails-native.

#### Scenario: No analytics vendor is introduced
- **WHEN** the change is implemented
- **THEN** it SHALL NOT add Ahoy, Blazer, Solid Queue, external analytics services, background jobs, dashboards, or automatic GitHub issue creation
