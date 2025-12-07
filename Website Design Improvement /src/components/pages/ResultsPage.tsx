import React from 'react';
import { Page } from '../../App';
import { CoffeeShopCard } from '../CoffeeShopCard';
import { coffeeShops } from '../../data/coffeeShops';

interface ResultsPageProps {
  setCurrentPage: (page: Page) => void;
  onViewDetail: (id: number) => void;
}

export function ResultsPage({ setCurrentPage, onViewDetail }: ResultsPageProps) {
  return (
    <div style={{ 
      minHeight: 'calc(100vh - 80px)',
      padding: '20px',
      maxWidth: '600px',
      margin: '0 auto'
    }}>
      {/* Simple header */}
      <div style={{ marginBottom: '20px' }}>
        <h2 style={{ 
          color: 'var(--color-text)',
          fontSize: '28px',
          margin: '0 0 8px 0'
        }}>
          Nearby Results
        </h2>
        <p style={{ 
          color: 'var(--color-text)', 
          opacity: 0.6,
          fontSize: '16px',
          margin: 0
        }}>
          {coffeeShops.length} places found
        </p>
      </div>

      {/* Cards - single column, easy to scroll */}
      <div>
        {coffeeShops.map(shop => (
          <CoffeeShopCard 
            key={shop.id}
            shop={shop}
            onViewDetail={onViewDetail}
          />
        ))}
      </div>
    </div>
  );
}
