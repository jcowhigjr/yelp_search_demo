import React from 'react';
import { Phone, Star } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface CoffeeShop {
  id: number;
  name: string;
  distance: string;
  address: string;
  phone: string;
  image: string;
  rating?: number;
  isFavorited?: boolean;
}

interface CoffeeShopCardProps {
  shop: CoffeeShop;
  onViewDetail: (id: number) => void;
}

export function CoffeeShopCard({ shop, onViewDetail }: CoffeeShopCardProps) {
  const handleCall = (e: React.MouseEvent) => {
    e.stopPropagation();
    window.location.href = `tel:${shop.phone.replace(/\D/g, '')}`;
  };

  return (
    <div 
      onClick={() => onViewDetail(shop.id)}
      style={{ 
        backgroundColor: 'var(--color-bg)',
        borderRadius: '12px',
        overflow: 'hidden',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        marginBottom: '16px',
        cursor: 'pointer',
        border: '1px solid var(--color-border)'
      }}
    >
      {/* Image */}
      <div style={{ width: '100%', height: '200px', overflow: 'hidden', backgroundColor: '#f0f0f0' }}>
        <ImageWithFallback
          src={shop.image}
          alt={shop.name}
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
      </div>

      {/* Content */}
      <div style={{ padding: '16px' }}>
        {/* Name and rating */}
        <div className="flex items-start justify-between" style={{ marginBottom: '8px' }}>
          <h3 style={{ 
            color: 'var(--color-text)', 
            fontSize: '22px',
            margin: 0,
            lineHeight: '1.3',
            flex: 1
          }}>
            {shop.name}
          </h3>
          {shop.rating && (
            <div className="flex items-center gap-1" style={{ flexShrink: 0 }}>
              <Star className="w-5 h-5" style={{ color: '#FFD700', fill: '#FFD700' }} />
              <span style={{ color: 'var(--color-text)', fontSize: '18px', fontWeight: 600 }}>
                {shop.rating}
              </span>
            </div>
          )}
        </div>

        {/* Distance */}
        <p style={{ 
          color: 'var(--color-text)', 
          opacity: 0.7,
          fontSize: '18px',
          margin: '4px 0 0 0',
          fontWeight: 600
        }}>
          {shop.distance}
        </p>
      </div>

      {/* Call button - prominent and in thumb zone */}
      <div style={{ padding: '12px 16px 16px' }}>
        <button
          onClick={handleCall}
          className="flex items-center justify-center gap-3 w-full transition-all"
          style={{
            backgroundColor: 'var(--color-button-blue)',
            color: 'white',
            border: 'none',
            borderRadius: '12px',
            height: '56px',
            fontSize: '20px',
            fontWeight: 600,
            cursor: 'pointer',
            boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
          }}
        >
          <Phone className="w-6 h-6" />
          <span>Call Now</span>
        </button>
      </div>
    </div>
  );
}
