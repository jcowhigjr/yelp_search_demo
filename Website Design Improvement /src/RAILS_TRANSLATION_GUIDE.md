# Rails Translation Guide
## React Prototype → Rails ERB Implementation

This guide shows how to translate each React component into Rails views, partials, and CSS.

---

## 📋 Table of Contents
1. [CSS Setup](#css-setup)
2. [Component Library](#component-library)
3. [Page Templates](#page-templates)
4. [Data Structure](#data-structure)
5. [Quick Reference](#quick-reference)

---

## CSS Setup

### Update your `/app/assets/stylesheets/application.css`

Add these styles if not already present:

```css
/* Page typography (already in your app) */
.page-name {
  font-size: 60px;
  line-height: 1.2;
}

.page-text {
  font-size: 30px;
  line-height: 1.4;
}

.form-link {
  font-size: 20px;
}

/* Navigation links (already in your app) */
.language-nav__link {
  color: var(--color-text);
  text-decoration: none;
  transition: all 0.2s;
  font-size: 16px;
}

.language-nav__link:hover,
.language-nav__link:focus {
  text-decoration: underline;
}

.language-nav__link--active {
  font-weight: 600;
  text-decoration: underline;
}

/* Search bar (already in your app) */
.search-bar {
  display: inline-block;
  width: 100%;
  border-radius: 15px;
  border: 1px solid var(--color-text);
  padding: 5px 5px 5px 15px;
  display: flex;
  align-items: center;
  gap: 8px;
  background-color: var(--color-bg);
  transition: all 0.3s;
}

.search-bar input {
  flex: 1;
  border: none;
  outline: none;
  font-size: 16px;
  padding: 8px 4px;
  background: transparent;
  color: var(--color-text);
}

/* Coffee shop card */
.coffeeshop-card {
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s;
  box-shadow: 0 2px 5px 0 rgba(0,0,0,0.16), 0 2px 10px 0 rgba(0,0,0,0.12);
}

.coffeeshop-card:hover {
  box-shadow: 0 8px 17px 0 rgba(0,0,0,0.2), 0 6px 20px 0 rgba(0,0,0,0.19);
  transform: translateY(-2px);
}

.coffeeshop-card .card-action {
  border-top: 1px solid;
  border-color: color-mix(in srgb, var(--color-text) 10%, transparent);
}

/* Favorite button (already in your app) */
.favorite-btn {
  font-size: 24px;
  padding: 8px;
  border-radius: 50%;
  background: transparent;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

.favorite-btn:hover {
  transform: scale(1.1);
  background: rgba(128, 128, 128, 0.1);
}

.favorite-btn:active {
  transform: scale(0.95);
}

/* Material inputs */
.material-input {
  width: 100%;
  padding: 12px 16px;
  border-radius: 4px;
  font-size: 16px;
  outline: none;
  transition: all 0.3s;
  background-color: var(--color-bg);
  color: var(--color-text);
  border: 1px solid var(--color-border);
}

.material-input:focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(75, 156, 211, 0.1);
}
```

---

## Component Library

### 1. Material Button (`.btn-large` / `.btn-small`)

**React Component:**
```tsx
<MaterialButton size="large" onClick={handleClick}>
  Log In
</MaterialButton>
```

**Rails ERB:**
```erb
<!-- Already in your app! -->
<%= submit_tag 'Log In', class: 'btn-large' %>
<!-- or -->
<%= link_to 'More Info', coffeeshop_path(@coffeeshop), class: 'btn-large' %>
<!-- Small variant -->
<%= link_to 'Edit', edit_path, class: 'btn-small' %>
```

**CSS:** Already styled in your `application.css` with `#1C5B82` background

---

### 2. Favorite Button

**React Component:**
```tsx
<FavoriteButton 
  isFavorited={shop.isFavorited} 
  onToggle={handleToggle}
/>
```

**Rails ERB (already in your app):**
```erb
<!-- From your favorites/_button.html.erb -->
<%= button_to favorite_path(@coffeeshop), 
    method: :post,
    class: "favorite-btn inline-flex items-center space-x-1" do %>
  <i class="material-icons" style="color: <%= @coffeeshop.favorited_by?(current_user) ? 'var(--color-yelp)' : 'var(--color-text)' %>">
    <%= @coffeeshop.favorited_by?(current_user) ? 'favorite' : 'favorite_border' %>
  </i>
  <span class="sr-only">
    <%= @coffeeshop.favorited_by?(current_user) ? 'Remove from favorites' : 'Add to favorites' %>
  </span>
<% end %>
```

**Or with Lucide icons (like in prototype):**
```erb
<%= button_to favorite_path(@coffeeshop), 
    method: :post,
    class: "favorite-btn" do %>
  <!-- Use SVG heart icon or Material icon -->
  <i class="material-icons">favorite</i>
<% end %>
```

---

### 3. Search Bar

**React Component:**
```tsx
<SearchBar 
  onSearch={handleSearch}
  placeholder="Search for coffee..."
  initialValue="coffee"
/>
```

**Rails ERB:**
```erb
<!-- From your searches/_form.html.erb pattern -->
<%= form_with url: search_path, method: :get, local: true do |f| %>
  <div class="search-bar">
    <i class="material-icons">search</i>
    <%= f.text_field :query, 
        placeholder: 'Search for coffee shops...',
        style: 'color: var(--color-text); background: transparent;' %>
    <% if params[:query].present? %>
      <%= link_to search_path, class: 'clear-button' do %>
        <i class="material-icons">close</i>
      <% end %>
    <% end %>
    <%= f.submit 'Search', class: 'btn-small', style: 'background-color: var(--color-button-blue);' %>
  </div>
<% end %>
```

---

### 4. Coffee Shop Card

**React Component:**
```tsx
<CoffeeShopCard 
  shop={shop}
  onViewDetail={handleViewDetail}
/>
```

**Rails ERB Partial: `/app/views/coffeeshops/_coffeeshop.html.erb`**

```erb
<div class="coffeeshop-card card large" style="background-color: var(--color-bg);">
  <div class="card-image">
    <%= image_tag coffeeshop.image_url, alt: coffeeshop.name, class: 'responsive-img' %>
  </div>

  <div class="card-content">
    <div class="flex items-start justify-between mb-2">
      <span class="card-title" style="color: var(--color-text);">
        <%= coffeeshop.name %>
      </span>
      
      <!-- Favorite button -->
      <%= render 'favorites/button', coffeeshop: coffeeshop %>
    </div>

    <p style="color: var(--color-text); opacity: 0.6;">
      <%= coffeeshop.distance %>
    </p>
  </div>

  <div class="card-action">
    <!-- Address and phone -->
    <div class="mb-4">
      <div class="flex items-start gap-2 mb-2">
        <i class="material-icons" style="color: var(--color-primary);">place</i>
        <span style="color: var(--color-text);"><%= coffeeshop.address %></span>
      </div>
      <div class="flex items-center gap-2">
        <i class="material-icons" style="color: var(--color-primary);">phone</i>
        <span style="color: var(--color-text);"><%= coffeeshop.phone %></span>
      </div>
    </div>

    <%= link_to 'MORE INFO', coffeeshop_path(coffeeshop), class: 'btn-large w-full' %>
  </div>
</div>
```

**Controller:** `app/controllers/coffeeshops_controller.rb`
```ruby
def index
  @coffeeshops = Coffeeshop.near([current_lat, current_long], 10)
end
```

**View:** `app/views/coffeeshops/index.html.erb`
```erb
<div class="row">
  <% @coffeeshops.each do |coffeeshop| %>
    <div class="col s12 m6 l4">
      <%= render coffeeshop %>
    </div>
  <% end %>
</div>
```

---

### 5. Page Container

**React Component:**
```tsx
<PageContainer>
  {children}
</PageContainer>
```

**Rails ERB:**
```erb
<!-- Already in your app! -->
<div class="page-container" style="background-color: var(--color-bg);">
  <!-- Your content here -->
</div>
```

**CSS already in `application.css`:**
```css
.page-container {
  margin-top: 20px;
  border-radius: 25px;
  padding: 30px 50px;
  margin-bottom: 50px;
  box-shadow: 0 2px 5px 0 rgba(0,0,0,0.08);
}
```

---

## Page Templates

### 1. Search/Home Page

**React:** `SearchPage.tsx`

**Rails:** `app/views/searches/new.html.erb` or `app/views/home/index.html.erb`

```erb
<div class="container">
  <div class="page-container" style="background-color: var(--color-bg);">
    <div class="center-align">
      <h1 class="page-name" style="color: var(--color-text);">
        COFFEE NEAR YOU!
      </h1>
      
      <p class="page-text" style="color: var(--color-text); opacity: 0.8;">
        Find the best coffee shops in your area
      </p>

      <div class="row">
        <div class="col s12 m8 offset-m2">
          <%= render 'searches/form' %>
        </div>
      </div>

      <!-- Feature icons -->
      <div class="row" style="margin-top: 3rem;">
        <div class="col s12 m4">
          <div class="center-align">
            <div style="width: 80px; height: 80px; border-radius: 50%; background-color: var(--color-primary); opacity: 0.2; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 1rem;">
              <span style="font-size: 2.5rem;">☕</span>
            </div>
            <p style="color: var(--color-text); opacity: 0.7;">Search nearby</p>
          </div>
        </div>

        <div class="col s12 m4">
          <div class="center-align">
            <div style="width: 80px; height: 80px; border-radius: 50%; background-color: var(--color-primary); opacity: 0.2; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 1rem;">
              <span style="font-size: 2.5rem;">⭐</span>
            </div>
            <p style="color: var(--color-text); opacity: 0.7;">Read reviews</p>
          </div>
        </div>

        <div class="col s12 m4">
          <div class="center-align">
            <div style="width: 80px; height: 80px; border-radius: 50%; background-color: var(--color-primary); opacity: 0.2; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 1rem;">
              <span style="font-size: 2.5rem;">❤️</span>
            </div>
            <p style="color: var(--color-text); opacity: 0.7;">Save favorites</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
```

---

### 2. Results Page

**React:** `ResultsPage.tsx`

**Rails:** `app/views/coffeeshops/index.html.erb`

```erb
<div class="container">
  <div class="row">
    <div class="col s12">
      <!-- Search bar at top -->
      <%= render 'searches/form' %>
    </div>
  </div>

  <div class="row" style="margin-top: 2rem;">
    <div class="col s12">
      <h2 style="color: var(--color-text);">Coffee Shops Near You</h2>
      <p style="color: var(--color-text); opacity: 0.6;">
        <%= @coffeeshops.count %> results found
      </p>
    </div>
  </div>

  <div class="row">
    <% @coffeeshops.each do |coffeeshop| %>
      <div class="col s12 m6 l4">
        <%= render coffeeshop %>
      </div>
    <% end %>
  </div>
</div>
```

**Controller:**
```ruby
class CoffeeshopsController < ApplicationController
  def index
    @coffeeshops = if params[:query].present?
      Coffeeshop.search(params[:query]).near([current_lat, current_long], 10)
    else
      Coffeeshop.near([current_lat, current_long], 10)
    end
  end
end
```

---

### 3. Detail Page

**React:** `DetailPage.tsx`

**Rails:** `app/views/coffeeshops/show.html.erb`

```erb
<div class="container">
  <%= link_to '← Back to Results', coffeeshops_path, class: 'btn-small', style: 'background-color: var(--color-primary); margin-bottom: 1.5rem;' %>

  <div class="page-container" style="background-color: var(--color-bg);">
    <div class="row">
      <!-- Image -->
      <div class="col s12 l6">
        <%= image_tag @coffeeshop.image_url, alt: @coffeeshop.name, class: 'responsive-img', style: 'border-radius: 8px;' %>
      </div>

      <!-- Info -->
      <div class="col s12 l6">
        <div class="flex items-start justify-between">
          <div>
            <h1 class="page-name" style="color: var(--color-text);">
              <%= @coffeeshop.name %>
            </h1>
            
            <!-- Star rating -->
            <div class="flex items-center" style="margin: 1rem 0;">
              <% 5.times do |i| %>
                <i class="material-icons" style="color: <%= i < @coffeeshop.rating.floor ? '#FFD700' : '#ccc' %>;">
                  <%= i < @coffeeshop.rating.floor ? 'star' : 'star_border' %>
                </i>
              <% end %>
              <span style="color: var(--color-text); opacity: 0.7; margin-left: 0.5rem;">
                <%= @coffeeshop.rating %> (<%= @coffeeshop.reviews_count %> reviews)
              </span>
            </div>

            <p style="color: var(--color-text); opacity: 0.6;">
              <%= @coffeeshop.distance %>
            </p>
          </div>

          <%= render 'favorites/button', coffeeshop: @coffeeshop %>
        </div>

        <!-- Contact info -->
        <div style="margin: 2rem 0;">
          <div class="flex items-start gap-3" style="margin-bottom: 1rem;">
            <i class="material-icons" style="color: var(--color-primary);">place</i>
            <p style="color: var(--color-text);"><%= @coffeeshop.address %></p>
          </div>

          <div class="flex items-center gap-3" style="margin-bottom: 1rem;">
            <i class="material-icons" style="color: var(--color-primary);">phone</i>
            <p style="color: var(--color-text);"><%= @coffeeshop.phone %></p>
          </div>

          <div class="flex items-center gap-3">
            <i class="material-icons" style="color: var(--color-primary);">schedule</i>
            <p style="color: var(--color-text);"><%= @coffeeshop.hours %></p>
          </div>
        </div>

        <!-- Description -->
        <div style="margin-bottom: 2rem;">
          <h3 style="color: var(--color-text); margin-bottom: 1rem;">About</h3>
          <p style="color: var(--color-text); opacity: 0.8;">
            <%= @coffeeshop.description %>
          </p>
        </div>

        <!-- Action buttons -->
        <div class="flex gap-3">
          <%= link_to 'Get Directions', @coffeeshop.maps_url, class: 'btn-large', target: '_blank', style: 'flex: 1;' %>
          <%= link_to 'Call Now', "tel:#{@coffeeshop.phone}", class: 'btn-large', style: 'flex: 1; background-color: var(--color-primary);' %>
        </div>
      </div>
    </div>

    <!-- Reviews section -->
    <div class="row" style="margin-top: 3rem;">
      <div class="col s12">
        <h3 style="color: var(--color-text); margin-bottom: 1.5rem;">Reviews</h3>
        
        <% @coffeeshop.reviews.each do |review| %>
          <div class="card" style="background-color: var(--color-bg); border: 1px solid var(--color-border); padding: 1.5rem; margin-bottom: 1.5rem;">
            <div class="flex items-start justify-between" style="margin-bottom: 1rem;">
              <div>
                <p style="color: var(--color-text);"><%= review.user.name %></p>
                <div class="flex items-center" style="margin-top: 0.25rem;">
                  <% 5.times do |i| %>
                    <i class="material-icons small" style="color: <%= i < review.rating ? '#FFD700' : '#ccc' %>;">star</i>
                  <% end %>
                </div>
              </div>
              <span style="color: var(--color-text); opacity: 0.5; font-size: 14px;">
                <%= time_ago_in_words(review.created_at) %> ago
              </span>
            </div>
            <p style="color: var(--color-text); opacity: 0.8;">
              <%= review.content %>
            </p>
          </div>
        <% end %>
      </div>
    </div>
  </div>
</div>
```

---

### 4. Login Page

**React:** `LoginPage.tsx`

**Rails:** `app/views/sessions/new.html.erb` (Already exists!)

```erb
<div class="container">
  <div class="row">
    <div class="col s12 m8 offset-m2 l6 offset-l3">
      <div class="page-container" style="background-color: var(--color-bg);">
        <h1 class="page-name center-align" style="color: var(--color-text);">
          Login
        </h1>

        <%= form_with url: login_path, method: :post, local: true do |f| %>
          <div class="row">
            <div class="col s12">
              <%= f.label :email, style: 'color: var(--color-text);' %>
              <%= f.email_field :email, 
                  required: true, 
                  class: 'material-input',
                  placeholder: 'your@email.com' %>
            </div>
          </div>

          <div class="row">
            <div class="col s12">
              <%= f.label :password, style: 'color: var(--color-text);' %>
              <%= f.password_field :password, 
                  required: true, 
                  class: 'material-input',
                  placeholder: '••••••••' %>
            </div>
          </div>

          <div class="row">
            <div class="col s12">
              <%= f.submit 'Log In', class: 'btn-large w-full' %>
            </div>
          </div>
        <% end %>

        <div class="center-align" style="margin-top: 1.5rem;">
          <%= link_to "Don't have an account? Sign up", signup_path, class: 'form-link', style: 'color: var(--color-primary);' %>
        </div>

        <!-- OAuth section -->
        <div style="margin-top: 2rem;">
          <div style="position: relative; margin-bottom: 1.5rem;">
            <div style="border-top: 1px solid var(--color-border); position: absolute; width: 100%; top: 50%;"></div>
            <div style="position: relative; text-align: center;">
              <span style="background-color: var(--color-bg); color: var(--color-text); opacity: 0.7; padding: 0 1rem;">
                Or continue with
              </span>
            </div>
          </div>

          <div class="row">
            <div class="col s6">
              <%= button_to 'Google', auth_google_path, class: 'btn-small', style: 'background-color: var(--color-primary); width: 100%;' %>
            </div>
            <div class="col s6">
              <%= button_to 'Facebook', auth_facebook_path, class: 'btn-small', style: 'background-color: var(--color-primary); width: 100%;' %>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
```

---

### 5. Signup Page

**React:** `SignupPage.tsx`

**Rails:** `app/views/users/new.html.erb`

```erb
<div class="container">
  <div class="row">
    <div class="col s12 m8 offset-m2 l6 offset-l3">
      <div class="page-container" style="background-color: var(--color-bg);">
        <h1 class="page-name center-align" style="color: var(--color-text);">
          Sign Up
        </h1>

        <%= form_with model: @user, url: signup_path, local: true do |f| %>
          <div class="row">
            <div class="col s12">
              <%= f.label :name, style: 'color: var(--color-text);' %>
              <%= f.text_field :name, 
                  required: true, 
                  class: 'material-input',
                  placeholder: 'Your name' %>
            </div>
          </div>

          <div class="row">
            <div class="col s12">
              <%= f.label :email, style: 'color: var(--color-text);' %>
              <%= f.email_field :email, 
                  required: true, 
                  class: 'material-input',
                  placeholder: 'your@email.com' %>
            </div>
          </div>

          <div class="row">
            <div class="col s12">
              <%= f.label :password, style: 'color: var(--color-text);' %>
              <%= f.password_field :password, 
                  required: true, 
                  class: 'material-input',
                  placeholder: '••••••••' %>
            </div>
          </div>

          <div class="row">
            <div class="col s12">
              <%= f.label :password_confirmation, style: 'color: var(--color-text);' %>
              <%= f.password_field :password_confirmation, 
                  required: true, 
                  class: 'material-input',
                  placeholder: '••••••••' %>
            </div>
          </div>

          <div class="row">
            <div class="col s12">
              <%= f.submit 'Sign Up', class: 'btn-large w-full' %>
            </div>
          </div>
        <% end %>

        <div class="center-align" style="margin-top: 1.5rem;">
          <%= link_to 'Already have an account? Login here', login_path, class: 'form-link', style: 'color: var(--color-primary);' %>
        </div>
      </div>
    </div>
  </div>
</div>
```

---

### 6. Favorites Page

**React:** `FavoritesPage.tsx`

**Rails:** `app/views/favorites/index.html.erb`

```erb
<div class="container">
  <div class="page-container" style="background-color: var(--color-bg);">
    <h1 class="page-name" style="color: var(--color-text);">
      My Favorites
    </h1>

    <% if @favorites.empty? %>
      <div class="center-align" style="padding: 3rem 0;">
        <p class="page-text" style="color: var(--color-text); opacity: 0.6; margin-bottom: 1.5rem;">
          You haven't added any favorites yet
        </p>
        <%= link_to 'Start searching for coffee shops', search_path, class: 'form-link', style: 'color: var(--color-primary);' %>
      </div>
    <% else %>
      <p style="color: var(--color-text); opacity: 0.7; margin-bottom: 1.5rem;">
        <%= pluralize(@favorites.count, 'saved location') %>
      </p>
      
      <div class="row">
        <% @favorites.each do |favorite| %>
          <div class="col s12 m6 l4">
            <%= render favorite.coffeeshop %>
          </div>
        <% end %>
      </div>
    <% end %>
  </div>
</div>
```

**Controller:**
```ruby
class FavoritesController < ApplicationController
  before_action :require_login

  def index
    @favorites = current_user.favorites.includes(:coffeeshop)
  end
end
```

---

## Data Structure

### Coffee Shop Model

**Migration:**
```ruby
class CreateCoffeeshops < ActiveRecord::Migration[8.0]
  def change
    create_table :coffeeshops do |t|
      t.string :name, null: false
      t.string :address
      t.string :phone
      t.text :description
      t.string :hours
      t.decimal :latitude
      t.decimal :longitude
      t.decimal :rating, default: 0.0
      t.integer :reviews_count, default: 0
      t.string :image_url

      t.timestamps
    end

    add_index :coffeeshops, [:latitude, :longitude]
  end
end
```

**Model:**
```ruby
class Coffeeshop < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :users, through: :favorites
  has_many :reviews, dependent: :destroy

  # Geocoding (if using geocoder gem)
  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  # Search
  scope :search, ->(query) { where("name ILIKE ?", "%#{query}%") }

  # Distance (requires geocoder gem)
  def distance
    "#{distance_to([current_lat, current_long]).round(1)} mi away"
  end

  def favorited_by?(user)
    user && favorites.exists?(user: user)
  end

  def maps_url
    "https://www.google.com/maps/search/?api=1&query=#{CGI.escape(address)}"
  end
end
```

**Favorite Model:**
```ruby
class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :coffeeshop, counter_cache: true

  validates :user_id, uniqueness: { scope: :coffeeshop_id }
end
```

---

## Quick Reference

### Tailwind Utility Classes Used (Materialize Equivalent)

| React/Tailwind | Rails/Materialize |
|----------------|-------------------|
| `flex items-center gap-2` | `row` with `col` or custom flexbox |
| `grid grid-cols-3 gap-6` | `row` with `col s12 m6 l4` |
| `rounded-lg` | `border-radius: 8px` in style |
| `shadow-md` | Materialize `z-depth-2` class |
| `mb-4` | Materialize spacing or `margin-bottom: 1rem` |
| `text-center` | Materialize `center-align` |
| `w-full` | Materialize `s12` or `width: 100%` |

### Color Variables in Templates

Always use CSS variables for theming:

```erb
<div style="background-color: var(--color-bg); color: var(--color-text);">
  <button style="background-color: var(--color-button-blue); color: white;">
    Click me
  </button>
</div>
```

### Material Icons vs Lucide Icons

The prototype uses Lucide icons, but your Rails app uses Material Icons:

| Lucide (React) | Material Icons (Rails) |
|----------------|------------------------|
| `<Search />` | `<i class="material-icons">search</i>` |
| `<MapPin />` | `<i class="material-icons">place</i>` |
| `<Phone />` | `<i class="material-icons">phone</i>` |
| `<Clock />` | `<i class="material-icons">schedule</i>` |
| `<Heart />` | `<i class="material-icons">favorite</i>` |
| `<Star />` | `<i class="material-icons">star</i>` |

---

## Routes Setup

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root 'home#index'
  
  # Search
  get '/search', to: 'searches#new', as: :search
  
  # Coffee shops
  resources :coffeeshops, only: [:index, :show]
  
  # Favorites
  resources :favorites, only: [:index, :create, :destroy]
  post '/coffeeshops/:id/favorite', to: 'favorites#create', as: :favorite
  
  # Auth
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
end
```

---

## Implementation Checklist

- [ ] Copy CSS styles to `app/assets/stylesheets/application.css`
- [ ] Create `_coffeeshop.html.erb` partial
- [ ] Update search form partial with `.search-bar` styling
- [ ] Add `.material-input` class to all form inputs
- [ ] Ensure favorite button uses existing `.favorite-btn` class
- [ ] Update layout navigation with `.language-nav__link` classes
- [ ] Add light/dark theme toggle (optional - use Stimulus controller)
- [ ] Use `.page-container` wrapper on all main pages
- [ ] Test all pages in both light and dark modes

---

## Tips for Translation

1. **Component → Partial:** Each React component becomes a Rails partial
2. **Props → Local variables:** `<Component prop={value} />` → `<%= render 'partial', value: value %>`
3. **State → Database/Session:** React state becomes database records or session data
4. **onClick → Rails routes:** `onClick={() => navigate()}` → `link_to` or `button_to`
5. **Conditional rendering:** `{condition && <div>}` → `<% if condition %><div><% end %>`
6. **Loops:** `items.map(item =>)` → `<% items.each do |item| %>`

---

## Need Help?

- The visual prototype is running and you can inspect any component
- All styling is based on your existing CSS variables and Materialize classes
- Every component in the prototype has a direct Rails/ERB equivalent above
- Focus on maintaining the visual design while using Rails conventions

Good luck with your implementation! 🚀
