import React from 'react';
import { Page } from '../../App';
import { CoffeeShopCard } from '../CoffeeShopCard';
import { coffeeShops } from '../../data/coffeeShops';

interface FavoritesPageProps {
  setCurrentPage: (page: Page) => void;
  onViewDetail: (id: number) => void;
}

export function FavoritesPage({ setCurrentPage, onViewDetail }: FavoritesPageProps) {
  const favoriteShops = coffeeShops.filter(shop => shop.isFavorited);

  return (
    <div style={{ 
      minHeight: 'calc(100vh - 80px)',
      padding: '20px',
      maxWidth: '600px',
      margin: '0 auto'
    }}>
      <div style={{ marginBottom: '20px' }}>
        <h2 style={{ 
          color: 'var(--color-text)',
          fontSize: '28px',
          margin: '0 0 8px 0'
        }}>
          My Favorites
        </h2>
        {favoriteShops.length > 0 && (
          <p style={{ 
            color: 'var(--color-text)', 
            opacity: 0.6,
            fontSize: '16px',
            margin: 0
          }}>
            {favoriteShops.length} saved location{favoriteShops.length !== 1 ? 's' : ''}
          </p>
        )}
      </div>

      {favoriteShops.length === 0 ? (
        <div style={{ 
          textAlign: 'center', 
          padding: '60px 20px',
          color: 'var(--color-text)',
          opacity: 0.6
        }}>
          <p style={{ fontSize: '20px', marginBottom: '24px' }}>
            No favorites yet
          </p>
          <button
            onClick={() => setCurrentPage('search')}
            style={{
              background: 'none',
              border: 'none',
              color: 'var(--color-primary)',
              fontSize: '18px',
              cursor: 'pointer',
              textDecoration: 'underline'
            }}
          >
            Start searching
          </button>
        </div>
      ) : (
        <div>
          {favoriteShops.map(shop => (
            <CoffeeShopCard 
              key={shop.id}
              shop={shop}
              onViewDetail={onViewDetail}
            />
          ))}
        </div>
      )}
    </div>
  );
}
